const CONSTANTS = {
    Buy: "https://pricehistory.app/redirect",
    ChartPreURL: "https://pricehistory.app/embed/",
    RemoveElementsClassName: "pricehistory-remove-element",
    GenerateGAEvent: async (Name, Params) => {
        try {
            chrome.runtime.sendMessage(
                { action: 'GenerateGAEvent', data: [{ name: Name, params: Params }] },
                (response) => { }
            );
        } catch (error) {

        }
    },
    ExtensionPosition: (Position) => {
        switch (Position) {
            case "top-left":
                return " left: 0rem; top: 15rem; border-top-left-radius: 0px; border-bottom-left-radius: 0px;";
                break;

            case "bottom-right":
                return " right: 0rem; bottom: 7rem; border-top-right-radius: 0px; border-bottom-right-radius: 0px;";
                break;

            case "bottom-left":
                return " left: 0rem; bottom: 7rem; border-top-left-radius: 0px; border-bottom-left-radius: 0px;";
                break;

            default:
                return " right: 0rem; top: 15rem; border-top-right-radius: 0px; border-bottom-right-radius: 0px;";
                break;
        }
    }
}

var ExtensionConfigs = {}

chrome.storage.sync.get(["ph-ext-data"], (data) => {
    try {
        ExtensionConfigs = JSON.parse(data["ph-ext-data"])
    } catch (error) { }
})

var CURRENT_PRODUCT_CODE = ""

function GetArrayLastValue(arr) {
    if (!Array.isArray(arr)) {
        return arr;
    }
    if (arr.length == 0) {
        return "";
    } else {
        return arr[arr.length - 1];
    }
}

class Amazon {

    Constants = {
        Domain: "amazon.in"
    }

    IsProductPage = (url) => {
        if (url.includes("/dp/") || url.includes("/gp/product/") || url.includes("/gp/aw/d/")) {
            const match = url.match(/\/(dp|gp\/product|gp\/aw\/d)\/([A-Za-z0-9]+)/);
            if (match && match[2]) {
                return true;
            }
        }
        return false;
    }

    GetElementAfterEnd = () => {
        try {
            return document.getElementById("centerCol").getElementsByTagName("hr")[0]
        } catch (error) { }

        return document.getElementsByTagName("h1")[0]
    }

    GetProductData = () => {

        var PriceHistoryData = {
            Status: false,
            Store: "www.amazon.in"
        }

        let PageData = document.documentElement.innerHTML.toString();
        if (document.getElementById("asin")) {
            PriceHistoryData.Code = document.getElementById("asin").value
        } else if (document.getElementById("ASIN")) {
            PriceHistoryData.Code = document.getElementById("ASIN").value
        }

        if (PageData.includes("buying-options-price-data")) {
            let TempObj = []
            try {
                TempObj = JSON.parse(PageData.split("buying-options-price-data")[1].split("</div>")[0].split(">")[1]);
            } catch (error) { }

            if ("desktop_buybox_group_1" in TempObj) {
                TempObj = TempObj.desktop_buybox_group_1
            }

            for (let index = 0; index < TempObj.length; index++) {
                if ("buyingOptionType" in TempObj[index] && typeof TempObj[index].buyingOptionType === "string") {
                    switch (TempObj[index].buyingOptionType.toLowerCase()) {
                        case "lightning_deal":
                        case "prime_savings_upsell":
                            if ("priceAmount" in TempObj[index] && typeof TempObj[index].priceAmount === "number") {
                                try {
                                    PriceHistoryData.Lightning = parseFloat(TempObj[index].priceAmount)
                                } catch (error) { }
                            }
                            break;

                        case "bundle":
                            break;

                        case "new":
                            if ("priceAmount" in TempObj[index] && typeof TempObj[index].priceAmount === "number") {
                                try {
                                    PriceHistoryData.Price = parseFloat(TempObj[index].priceAmount)
                                } catch (error) { }
                            }
                            break;

                        default:
                            break;
                    }
                }
            }
        } else if (document.getElementById("priceValue")) {
            try {
                PriceHistoryData.Price = parseFloat(document.getElementById("priceValue").value)
            } catch (error) { }
        }

        if (PageData.includes(" coupon applied ") || PageData.includes(" voucher applied ")) {
            if (PageData.includes(" coupon applied ")) {
                PriceHistoryData.Coupon = GetArrayLastValue(PageData.split(" coupon applied ")[0].split(">")).replace(/\&.*?\;/g, "").trim();
            } else if (PageData.includes(" voucher applied ")) {
                PriceHistoryData.Coupon = GetArrayLastValue(PageData.split(" voucher applied ")[0].split(">")).replace(/\&.*?\;/g, "").trim();
            }
        }

        if (PageData.includes("\"zipCode\":\"")) {
            PriceHistoryData.Pincode = PageData.split("\"zipCode\":\"")[1].split("\"")[0]
        }

        if (PageData.includes("config.isPrimeMember',")) {
            PriceHistoryData.IsMember = (PageData.split("config.isPrimeMember',")[1].split(")")[0].trim() == "true") ? 1 : 0;
        }
        PriceHistoryData.Status = true

        return PriceHistoryData
    }

    AdditionalFeatures = async (Product) => {
        try {
            let LowestAmount = parseFloat(document.getElementsByClassName("olp-link-widget")[0].innerText.replaceAll(/\n+/g, " ").match(/₹[\d,]+\.{0,1}\d*/)[0].replaceAll(",", "").replace("₹", ""))
            let FlagDisplayButton = (Product.Lightning && Product.Lightning < LowestAmount) ? false : (Product.Price && Product.Price > LowestAmount) ? true : false

            if (FlagDisplayButton) {
                let ButtenText = "Available at ₹" + LowestAmount + " by other seller. Check Now ⏩"
                let TempElement = CreatePriceElement("SeeAllPriceButton", { BG: "#FF8F00", Color: "#0F1111" }, ButtenText, { Style: "border-radius: 2rem;", Url: CONSTANTS.Buy + "/" + this.Constants.Domain + "?phasource=extension&phamethod=allseller&phastore=" + this.Constants.Domain + "&phaproduct=" + Product.Code });


                TempElement.addEventListener("click", () => {
                    CONSTANTS.GenerateGAEvent("product_redirect", { "product_code": Product.Code, "store_domain": this.Constants.Domain, "price": "" + LowestAmount, "redirect_type": "all_price", "click_source": "see_all_price", engagement_time_msec: "100" });
                })

                if (this.PriceContainer && this.PriceContainer != null) {
                    this.PriceContainer.insertAdjacentElement("afterend", TempElement)
                } else {
                    this.GetElementAfterEnd().insertAdjacentElement("afterend", TempElement)
                }
            }
        } catch (error) {
        }
    }
}

class Flipkart {

    Constants = {
        Domain: "flipkart.com"
    }

    IsProductPage = (url) => {
        if (url.includes("/p/")) {
            const match = url.match(/\/.*?\/p\/([A-Za-z0-9]+)/);
            if (match && match != null) {
                return true;
            }
        }
        return false
    }

    GetElementAfterEnd = () => {
        return document.getElementsByTagName("h1")[0].parentElement
    }

    GetProductData = () => {

        var PriceHistoryData = {
            Status: false,
            Store: "www.flipkart.com"
        }

        let PageData = document.documentElement.innerHTML.toString();
        PriceHistoryData.Code = new URL(window.location.href).searchParams.get("pid")
        if (PriceHistoryData.Code != null && PriceHistoryData.Code.match(/[0-9A-Za-z]{15}/)) {
        } else if (PageData.includes("sellers?pid=")) {
            PriceHistoryData.Code = PageData.split("sellers?pid=")[1].split("&")[0].trim();
        } else {
            return PriceHistoryData
        }

        let TempFlag = true
        if (PageData.includes("id=\"jsonLD\"")) {
            try {
                let TempData = PageData.split("id=\"jsonLD\"")[1].split("</script")[0].splice(">").splice(1).join(">")
                for (let index = 1; index < TempData.length; index++) {
                    try {
                        let TempData1 = JSON.parse(TempData[index].split("</script")[0])
                        for (let index1 = 0; index1 < TempData1.length; index1++) {
                            if (TempData1[index1] && "offers" in TempData1[index1] && TempData1[index1].offers != null && typeof TempData1[index1].offers === "object" && "price" in TempData1[index1].offers.price && TempData1[index1].offers.price != null && typeof TempData1[index1].offers.price === "number") {
                                PriceHistoryData.Price = TempData1[index1].offers.price;
                                TempFlag = false
                            }
                        }
                    } catch (error) { }
                }
            } catch (error) {
                TempFlag = true
            }
        }

        if (TempFlag && PageData.includes("price-info-icon")) {
            let TempData = PageData.split("price-info-icon")[0].split("₹")
            let TempData1 = []
            for (let index = 1; index < TempData.length; index++) {
                try {
                    let TempString = TempData[index].split("</")[0].trim().replaceAll(",", "")
                    if (!(TempString.includes(" off"))) {
                        TempData1.push(parseFloat(TempString))
                    }
                } catch (error) { }
            }
            for (let index = 0; index < TempData1.length; index++) {
                if ("Price" in PriceHistoryData && PriceHistoryData.Price != null && typeof PriceHistoryData.Price === "number") {
                    if (PriceHistoryData.Price > TempData1[index]) {
                        PriceHistoryData.Price = TempData1[index]
                    }
                } else {
                    PriceHistoryData.Price = TempData1[index]
                }
            }
        }

        if (PageData.includes("id=\"pincodeInputId\" value=\"")) {
            PriceHistoryData.Pincode = PageData.split("id=\"pincodeInputId\" value=\"")[1].split("\"")[0]
        }

        if (PageData.includes("img/fk-plus_")) {
            PriceHistoryData.IsMember = 1;
        } else {
            PriceHistoryData.IsMember = 0;
        }

        PriceHistoryData.Status = true

        return PriceHistoryData
    }

    AdditionalFeatures = async (Product) => {

        var Iframe = document.createElement("iframe")
        Iframe.className = CONSTANTS.RemoveElementsClassName
        Iframe.src = "https://www.flipkart.com/sellers?data=" + new Date().getTime() + "&pid=" + Product.Code
        Iframe.style = "height:800px;width:1200px;display:none;";
        document.getElementsByTagName("body")[0].append(Iframe)
        Iframe.addEventListener("load", () => {
            setTimeout(() => {
                let PageData = Iframe.contentDocument.documentElement.innerHTML.toString()
                if (PageData.includes("<span>Delivery</span>")) {

                    let Sellers = []
                    try {
                        let RelatedContentBlocks = PageData.split("<span>Delivery</span>")[1].split("<footer")[0].split("col-3-12\">").splice(1)
                        for (let i = 1; i < RelatedContentBlocks.length; i = i + 2) {
                            let Seller = {}
                            try {
                                Seller.Name = RelatedContentBlocks[i - 1].split("</span></div>")[0].split("<span>")[1].trim();
                            } catch (e) { }
                            try {
                                Seller.Rating = parseFloat(GetArrayLastValue(RelatedContentBlocks[i - 1].split("<img")[0].split(">")).trim());
                            } catch (e) { }
                            try {
                                Seller.Assured = RelatedContentBlocks[i].includes("img/fa_");
                            } catch (e) { }
                            try {
                                let AllPrices = RelatedContentBlocks[i].split(">₹").splice(1).map((blocks) => { return blocks.split("<")[0].replaceAll(",", "") });
                                AllPrices = AllPrices.filter(oneprice => !(oneprice.toLowerCase().includes("off") || oneprice.toLowerCase().includes(" + ")))
                                AllPrices = AllPrices.map(oneprice => parseFloat(oneprice))
                                if (AllPrices.length > 0) {
                                    if (AllPrices.length > 1) {
                                        Seller.Price = Math.min(...AllPrices)
                                    } else {
                                        Seller.Price = AllPrices[0];
                                    }
                                }
                            } catch (e) { }
                            if (Seller.Price) {
                                Sellers.push(Seller)
                            }
                        }
                    } catch (error) { }
                    if (Sellers.length > 0) {
                        Sellers = Sellers.sort((a, b) => {
                            return a.Price - b.Price
                        })
                    }
                    if (Sellers.length > 1) {
                        if ("Price" in Product && Product.Price > Sellers[0].Price) {
                            let TempElement = CreatePriceElement("SeeAllPriceButton", { BG: "#fb641b", Color: "#f0f0f0" }, "Available at ₹" + Sellers[0].Price + " by other seller. Check Now ⏩ ", { Url: CONSTANTS.Buy + "/" + this.Constants.Domain + "?phasource=extension&phamethod=allseller&phastore=" + this.Constants.Domain + "&phaproduct=" + Product.Code });

                            TempElement.addEventListener("click", () => {

                                CONSTANTS.GenerateGAEvent("product_redirect", { "product_code": Product.Code, "store_domain": this.Constants.Domain, "price": "" + Sellers[0].Price, "redirect_type": "all_price", "click_source": "see_all_price", engagement_time_msec: "100" });
                            })

                            if (this.PriceContainer && this.PriceContainer != null) {
                                this.PriceContainer.insertAdjacentElement("afterend", TempElement)
                            } else {
                                this.GetElementAfterEnd().insertAdjacentElement("afterend", TempElement)
                            }
                        }
                    }
                }
                Iframe.parentElement.removeChild(Iframe)
            }, 500)
        })
    }

}

var CurrentChartUrl = "";
var ChartContainer = null;
const CreatePriceElement = (Type, Color, Name, ExtraObj) => {
    switch (Type) {
        case "priceElement":
            let PriceElement = document.createElement("div");
            PriceElement.className = CONSTANTS.RemoveElementsClassName
            PriceElement.style = `display:${ExtraObj.Display}; color: ${Color.Color};padding: 0.5rem 1.5rem;`;
            PriceElement.innerHTML = `<span style=\"font-size:smaller;\">${Name}: </span>${ExtraObj.InLine ? "" : "<br>"}<span style=\"font-weight:bolder;\">₹${ExtraObj.Price}</span>`;
            return PriceElement
            break;

        case "SeeAllPriceButton":
            let SeeAllPriceButton = document.createElement("a");
            SeeAllPriceButton.className = CONSTANTS.RemoveElementsClassName
            if (ExtraObj.Url) {
                SeeAllPriceButton.href = ExtraObj.Url
            } else {
                SeeAllPriceButton.href = "#"
            }
            SeeAllPriceButton.target = "_blank"
            let TempStyle = 'display:inline-block;background-color: ' + Color.BG + ';color: ' + Color.Color + ';padding: 0.25rem 1rem;border-radius:0.25rem;text-decoration:none;box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2);font-weight:500;';
            SeeAllPriceButton.innerHTML = `<span style=\"font-size:smaller;\">${Name}</span>`;
            if (ExtraObj.Style) {
                TempStyle = TempStyle + ExtraObj.Style;
            }
            SeeAllPriceButton.style = TempStyle
            return SeeAllPriceButton
            break;

        default:
            break;
    }
}

const UpdatePrices = (Prices, ele) => {
    let PriceContainer = null
    if (Prices.highest || Prices.lowest || (Prices.total && Prices.count) || Prices.lowestoffer) {
        PriceContainer = document.createElement("div");
        PriceContainer.className = CONSTANTS.RemoveElementsClassName
        PriceContainer.style = "background-color: #00000010;border-radius: 0.25rem;margin-bottom: 0.5rem;box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2);text-align: center;display:table;";
        if (Prices.highest) {
            PriceContainer.appendChild(CreatePriceElement("priceElement", { Color: "#ff534b" }, "Highest", { Price: parseInt(Prices.highest), Display: "inline-block", InLine: false }))
        }
        if (Prices.total && Prices.count) {
            PriceContainer.appendChild(CreatePriceElement("priceElement", { Color: "#555555" }, "Average", { Price: parseInt(Prices.total / Prices.count), Display: "inline-block", InLine: false }))
        }
        if (Prices.lowest) {
            Prices.lowest = parseFloat(Prices.lowest)
            PriceContainer.appendChild(CreatePriceElement("priceElement", { Color: "#17a2b8" }, "Lowest", { Price: parseInt(Prices.lowest), Display: "inline-block", InLine: false }))
        }
        if (Prices.lowestoffer) {
            Prices.lowestoffer = parseFloat(Prices.lowestoffer)
            if (Prices.lowest) {
                Prices.lowest = parseFloat(Prices.lowest)
                if (Prices.lowest > Prices.lowestoffer) {
                    PriceContainer.appendChild(CreatePriceElement("priceElement", { Color: "#28a745" }, "Lowest Offer Price", { Price: parseInt(Prices.lowestoffer), Display: "block", InLine: true }))
                }
            } else {
                PriceContainer.appendChild(CreatePriceElement("priceElement", { Color: "#28a745" }, "Lowest Offer Price", { Price: parseInt(Prices.lowestoffer), Display: "block", InLine: true }))

            }
        }
        ele.insertAdjacentElement("afterend", PriceContainer)
    }

    if ("code" in Prices && Prices.code.length > 0) {
        if (!(ExtensionConfigs && ExtensionConfigs["enable-floating-button"] && ExtensionConfigs["enable-floating-button"] === false)) {
            let ChartButton = document.createElement("div");
            ChartButton.className = CONSTANTS.RemoveElementsClassName
            ChartButton.style = "position: fixed; z-index: 1001; text-align: center; background-color: #021542; padding: 0rem 0.5rem 0.2rem 0.5rem; border-radius: 0.5rem; cursor: pointer;" + CONSTANTS.ExtensionPosition((ExtensionConfigs && ExtensionConfigs["floating-button-location"] && ExtensionConfigs["floating-button-location"].length > 0) ? ExtensionConfigs["floating-button-location"] : "");

            ChartButton.setAttribute("ChartUrl", CONSTANTS.ChartPreURL + Prices.code)

            CurrentChartUrl = CONSTANTS.ChartPreURL + Prices.code

            ChartButton.addEventListener("click", () => { OpenChart(CurrentChartUrl) });

            let ChartButtonImage = document.createElement("img");
            ChartButtonImage.className = CONSTANTS.RemoveElementsClassName
            ChartButtonImage.src = chrome.runtime.getURL("assets/images/icon-128x128.png");
            ChartButtonImage.style = "height: 40px; padding: 0.2rem;"

            let ChartButtonText = document.createElement("span");
            ChartButtonText.className = CONSTANTS.RemoveElementsClassName
            ChartButtonText.innerText = "Price Chart"
            ChartButtonText.style = "font-size: 0.65rem; color: #ffffff; display: block; margin-top: -0.6rem;";

            ChartButton.appendChild(ChartButtonImage)
            ChartButton.appendChild(ChartButtonText)

            document.body.appendChild(ChartButton)

        }

        if (PriceContainer != null) {
            let ChartSmallImageButton = document.createElement("img");
            ChartSmallImageButton.className = CONSTANTS.RemoveElementsClassName
            ChartSmallImageButton.src = chrome.runtime.getURL("assets/images/icon-128x128.png")
            ChartSmallImageButton.title = "Price History Chart"
            ChartSmallImageButton.style = "float:left;height:1.75rem;border-radius:50%;cursor: pointer;"
            PriceContainer.insertBefore(ChartSmallImageButton, PriceContainer.firstChild)
            ChartSmallImageButton.addEventListener("click", () => { OpenChart(CurrentChartUrl) });
        }
        ChartContainer = null
    }
    return PriceContainer
}

const OpenChart = (CurrentChartUrl) => {

    if (ChartContainer == null) {
        ChartContainer = document.createElement("div")
        ChartContainer.className = CONSTANTS.RemoveElementsClassName
        ChartContainer.id = "pricihistory-embedded-chart";
        ChartContainer.style = "position: fixed; top: 0px; bottom: 0px; right: 0px; left: 0px; text-align: center;margin: auto;background-color: #00000055; z-index:1002;display:none;";
        ChartContainer.innerHTML = `
        <div style="display: block;width: 90%; max-width: 900px; margin: auto; padding-top: 1rem;height: 1000px;max-height:90%;">
            <span class="pricehistory-chart-close" style="float: right; font-size: 2rem; cursor: pointer; padding: 0.25rem; background-color: #ffffff99; margin-bottom: 0.25rem; margin-top: -0.25rem; height:2rem; line-height:1.5rem; border-radius: 0.25rem;">&times;</span>
            <iframe id="pricehistory_iframe" src="${CurrentChartUrl}" style="width: 100%;height:560px;backgroud-color:#fff;" frameborder="0"></iframe>
        </div>`;
        CONSTANTS.GenerateGAEvent("product_graph_loaded", { "product_code": CurrentChartUrl, engagement_time_msec: "100" });
        document.body.appendChild(ChartContainer)

        ChartContainer.getElementsByClassName("pricehistory-chart-close")[0].addEventListener("click", (event) => {
            document.getElementById("pricihistory-embedded-chart").style.display = "none";
        })


        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape') {
                let ChartContainer = document.getElementById("pricihistory-embedded-chart")
                if (ChartContainer && ChartContainer.style.display == "block") {
                    ChartContainer.style.display = "none";
                }
            }
        });
    }

    let PricehistoryChartContainer = document.getElementById("pricihistory-embedded-chart")
    if (PricehistoryChartContainer) {
        CONSTANTS.GenerateGAEvent("product_graph_visible", { "product_code": CurrentChartUrl ? CurrentChartUrl : "", engagement_time_msec: "100" });
        PricehistoryChartContainer.style.display = "block";
    }

}

const removeElements = () => {
    let elementsToRemove = document.querySelectorAll('.' + CONSTANTS.RemoveElementsClassName);

    elementsToRemove.forEach(function (element) {
        element.parentNode.removeChild(element);
    });
}

const StartExecution = () => {
    removeElements()
    const PageURL = new URL(window.location.href)
    var Obj;
    if (PageURL.host == "www.amazon.in") {
        Obj = new Amazon();
    } else if (PageURL.host == "www.flipkart.com") {
        Obj = new Flipkart();
    } else {
        return;
    }
    let IsProductPage = Obj.IsProductPage(PageURL.href)

    if (IsProductPage) {
        const GetProductData = Obj.GetProductData();

        if (GetProductData.Status) {

            if (GetProductData.Code) {
                CURRENT_PRODUCT_CODE = GetProductData.Code
            }

            CONSTANTS.GenerateGAEvent("product_page_opened", { product_code: GetProductData.Code ? GetProductData.Code : "", "price": GetProductData.Price ? "" + GetProductData.Price : "", "store_promotion": GetProductData.Coupon ? GetProductData.Coupon : "", "store_deal": GetProductData.Lightning ? GetProductData.Lightning : "", "store_domain": GetProductData.Store ? GetProductData.Store : "", user_type: GetProductData.IsMember ? "yes" : "no", "pincode": GetProductData.Pincode ? GetProductData.Pincode : "", product_url: PageURL.href.substring(0, 99), product_name: GetProductData.Name ? GetProductData.Name.substring(0, 99) : "", engagement_time_msec: "100" });

            try {
                chrome.runtime.sendMessage(
                    { action: 'fetchData', data: GetProductData },
                    (response) => {
                        if (response.status) {

                            removeElements()

                            Obj.PriceContainer = UpdatePrices(response.data, Obj.GetElementAfterEnd());
                            if (response.data && response.data.status && response.data.status) {
                                CONSTANTS.GenerateGAEvent("product_price_fetch", { product_code: GetProductData.Code ? GetProductData.Code : "", "error": "false", "valid": "true", "message": "Data found: " + JSON.stringify(response.data), engagement_time_msec: "100" });
                            } else {
                                CONSTANTS.GenerateGAEvent("product_price_fetch", { product_code: GetProductData.Code ? GetProductData.Code : "", "error": "false", "valid": "false", "message": "Data Not found: " + JSON.stringify(response), engagement_time_msec: "100" });
                            }
                        } else {
                            CONSTANTS.GenerateGAEvent("product_price_fetch", { product_code: GetProductData.Code ? GetProductData.Code : "", "error": "true", "valid": "false", "message": "Fetch Error: " + JSON.stringify(response.error), engagement_time_msec: "100" });

                        }
                        if (GetProductData.Code && CURRENT_PRODUCT_CODE == GetProductData.Code) {
                            Obj.AdditionalFeatures(GetProductData)
                        } else {
                            removeElements()
                        }
                    }
                );

            } catch (error) { }
        } else {
            removeElements()
        }
    } else {
        removeElements()
    }
}


chrome.runtime.onMessage.addListener(
    function (request, sender, sendResponse) {
        if (request.message === 'UrlChanged') {
            setTimeout(() => {
                StartExecution();
            }, 500);
        }
    }
);