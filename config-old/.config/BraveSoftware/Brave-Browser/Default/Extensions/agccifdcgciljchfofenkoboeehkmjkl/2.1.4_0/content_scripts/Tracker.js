const TRACKER_CONSTANTS = {
    LIST_LIMIT: 10,
    PRODUCT_IN_LIST_LIMIT: 10,
    DEFAULT_TRACKER_LIST: { default: { Name: "default", Products: [] } }
}

async function IsProductTracking(Code) {

    // console.log("IsProductTracking", Code);

    let ProductList = await GetOrSetTrackerStorage("ProductList", true, false, {});
    ProductList = ProductList == null ? {} : ProductList;

    // console.log("ProductList", ProductList, Code, ProductList[Code]);

    if (ProductList[Code] == undefined) {
        return false;
    } else {
        return true;
    }
}

async function ListTracker() { }

async function RemoveTracker() {

    if (confirm("Do you want to remove from traking?!") == false) {
        return;
    }

    let Ele = document.getElementById("TrackerInitiator");
    let Code = Ele.getAttribute("data-code");

    let ProductList = await GetOrSetTrackerStorage("ProductList", true, true, {});
    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true, false, {});
    TrackerList = TrackerList == null ? TRACKER_CONSTANTS.DEFAULT_TRACKER_LIST : TrackerList;

    if (ProductList[Code] && ProductList[Code].l) {
        if (TrackerList[ProductList[Code].l] && TrackerList[ProductList[Code].l].Products.includes(Code)) {
            TrackerList[ProductList[Code].l].Products = TrackerList[ProductList[Code].l].Products.filter((item) => item != Code);
        }

        try {
            let Tracker = ProductList[Code];
            let GaEvent = {
                name: "Product_removed_from_Tracking",
                params: {
                    target_price: Tracker.p,
                    product_code: Tracker.c,
                    product_name: Tracker.n,
                    product_url: "",
                    store_domain: Tracker.s,
                    user_type: "Guest",
                }
            }
            chrome.runtime.sendMessage(
                { action: 'GenerateGAEvent', data: [GaEvent] },
                (response) => { }
            );
        } catch (error) { }


        delete ProductList[Code];

        let TrackedProductList = await GetOrSetTrackerStorage("TrackedProductList", true, false, {});
        TrackedProductList = TrackedProductList == null ? {} : TrackedProductList;
        if (TrackedProductList[Code]) {
            delete TrackedProductList[Code];
        }
        await chrome.storage.sync.set({ ProductList: JSON.stringify(ProductList), TrackerList: JSON.stringify(TrackerList), TrackedProductList: JSON.stringify(TrackedProductList) });



        StartExecution();


        try {
            chrome.runtime.sendMessage(
                { action: 'GenerateGAEvent', data: [{ name: Name, params: Params }] },
                (response) => { }
            );
        } catch (error) {

        }

    } else {
        alert("Invalid Product!");
    }

}

async function AddToTrackerInitiator(e) {
    Ele = document.getElementById("TrackerInitiator");
    let Code = Ele.getAttribute("data-code");
    let Store = Ele.getAttribute("data-store");
    let Product = JSON.parse(Ele.getAttribute("data-price"));

    Product.ProductCode = Code;
    Product.Store = Store;

    let ProductList = await GetOrSetTrackerStorage("ProductList", true, true, {});
    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true, false, {});
    TrackerList = TrackerList == null ? TRACKER_CONSTANTS.DEFAULT_TRACKER_LIST : TrackerList;

    let CurrentProduct = {};

    // console.log("ProductList", ProductList);

    if ((typeof ProductList == "object" && ProductList[Code] != undefined && ProductList[Code] != null)) {
        if (typeof ProductList[Code] == "object") {
            CurrentProduct = ProductList[Code];
        }
    }

    // console.log("CurrentProduct", CurrentProduct);

    CreateDialog(TrackerList, CurrentProduct, Product);
}

async function GetOrSetTrackerStorage(key, IsParse = true, IsCreate = false, Value = []) {
    let Data = await chrome.storage.sync.get(key);
    // console.log("GetOrSetTrackerStorage", key, Data)
    if (Data[key]) {
        try {
            return IsParse ? JSON.parse(Data[key]) : Data[key]
        } catch (error) { }
    }

    if (IsCreate) {
        await chrome.storage.sync.set({ key: IsParse ? JSON.stringify(Value) : Value });
        return Value
    } else {
        return null;
    }
}

async function CreateDialog(TrackerList, CurrentProduct, Product) {

    document.getElementById("ph-dialog")?.remove();

    let Dialog = document.createElement("dialog");
    Dialog.className = "ph-dialog p-2";
    Dialog.id = "ph-dialog";

    let TrackerListHTML = ``;
    Object.keys(TrackerList).forEach((key) => { TrackerListHTML += `<option value="${key}">${TrackerList[key].Name.toUpperCase()} List</option>` });

    // console.log("Product", Product);

    let HistoryHTML = ``;
    if (Product.highest || "lowest" in Product) {
        HistoryHTML += `<div class="d-block">`;
        if (Product.highest) {
            HistoryHTML += `<span class="d-block ph-previous" style="text-align:left;">Highest Price: <span style="color:red;"> ₹${parseInt(Product.highest)} </span> <small class="d-block" style="text-align:right;opacity:0.6;"> ${Product.highestdate} </small></span>`;
        }
        if (Product.lowest) {
            HistoryHTML += `<span class="d-block ph-previous" style="text-align:left;">Lowest Price: <span style="color:green;"> ₹${parseInt(Product.lowest)} </span> <small class="d-block" style="text-align:right;opacity:0.6;"> ${Product.lowestdate} </small></span>`;
        }
        HistoryHTML += `</div>`;
    }

    CurrentProduct.f = CurrentProduct.f ? CurrentProduct.f : "4";

    Dialog.innerHTML = `
        <div class="d-block p-0">
            <div class="container">
                <div class="d-block">
                    <div class="ph-dialog-close">X</div>
                    <div class="d-block">
                        <h3 class="title">
                            <img src="https://pricehistory.app/assets/images/icons/icon-144x144.png" class="rounded shadow-sm" height="25" alt="" width="25" style="borde;border-radius: 0.25rem;margin-left: -1.5rem;margin-right: 0.5rem;">
                            Set Price Alert!
                        </h3>
                        <div class="form-group">
                            <input type="number" class="form-control traking-amount" value="${CurrentProduct.p ? CurrentProduct.p : ""}" placeholder="Enter Alert Price" title="Amount, if price drops below that price, you will receive alert.">
                        </div>
                    </div>
                    <div class="d-block">
                        <select class="form-control tracker-frequency d-block" title="List in which this product is saved!">
                            <option value="24" ${CurrentProduct.f == "24" ? "selected" : ""}>Every 24 Hours</option>
                            <option value="12" ${CurrentProduct.f == "12" ? "selected" : ""}>Every 12 Hours</option>
                            <option value="8" ${CurrentProduct.f == "8" ? "selected" : ""}>Every 8 Hours</option>
                            <option value="4" ${CurrentProduct.f == "4" ? "selected" : ""}>Every 4 Hours</option>
                            <option value="2" ${CurrentProduct.f == "2" ? "selected" : ""}>Every 2 Hours</option>
                            <option value="1" ${CurrentProduct.f == "1" ? "selected" : ""}>Every 1 Hours</option>
                        </select>
                    </div>

                    <div class="d-block">
                        <select class="form-control tracker-list d-block" title="List in which this product is saved!">
                            ${TrackerListHTML}
                        </select>
                    </div>

                    <div class="d-block" style="text-align: right;width: 100%;">
                        <button class="d-block form-control tracker-save" style="width: 100%;"> Update </button>
                    </div>

                    ${HistoryHTML}

                </div>
            </div>
        </div>
    `;

    document.body.appendChild(Dialog);

    Dialog.querySelectorAll(".ph-dialog-close").forEach((ele) => {
        ele.addEventListener("click", (e) => {
            Dialog.style.display = "none";
        })
    })

    Dialog.querySelector(".tracker-save").addEventListener("click", async (e) => {
        let Amount = Dialog.querySelector(".traking-amount").value;
        let Frequency = Dialog.querySelector(".tracker-frequency").value;
        let List = Dialog.querySelector(".tracker-list").value;

        if (Amount == "" || Amount == null || Amount == undefined) {
            alert("Invalid price, Price can not be empty!");
            return;
        }

        if (List == "" || List == null || List == undefined) {
            alert("Invalid List, Amount can not be empty!");
            return;
        }

        if (parseFloat(Frequency) == NaN) {
            alert("Invalid Frequency");
            return;
        }

        let ProductList = await GetOrSetTrackerStorage("ProductList", true, true, {});
        let TrackerList = await GetOrSetTrackerStorage("TrackerList", true, false, {});
        TrackerList = TrackerList == null ? TRACKER_CONSTANTS.DEFAULT_TRACKER_LIST : TrackerList;

        let CurrentProduct = {};
        // p=price, f=frequency, l=list, lp=last price, c=code, s=store, n=name, url=product url, a=active, at=added time, ct=checked time, i=image
        let Tracker = {
            p: Amount,
            f: Frequency,
            l: List,
            lp: null,
            c: Product.ProductCode,
            s: Product.Store,
            n: Product.name ? Product.name : document.getElementsByTagName("h1")[0].innerText ? document.getElementsByTagName("h1")[0].innerText : "",
            i: Product.image,
            url: Product.code,
            a: true,
            at: new Date().getTime(),
            ct: new Date().getTime(),
        }

        // console.log("Tracker", Tracker);

        if (ProductList[Product.ProductCode]) {
            if (ProductList[Product.ProductCode].l != List) {
                if (TrackerList[ProductList[Product.ProductCode].l] && TrackerList[ProductList[Product.ProductCode].l].Products.includes(Product.ProductCode)) {
                    TrackerList[ProductList[Product.ProductCode].l].Products = TrackerList[ProductList[Product.ProductCode].l].Products.filter((item) => item != Product.ProductCode);
                }
            }
        }

        if (Object.keys(TrackerList).length == 0) {
            TrackerList.default = { Name: "default", Products: [] };
        }

        if (!(List in TrackerList)) {
            alert("Invalid List!");
        }

        ProductList[Product.ProductCode] = Tracker;
        await chrome.storage.sync.set({ ProductList: JSON.stringify(ProductList) });

        if (!(TrackerList[List].Products && TrackerList[List].Products.includes(Product.ProductCode))) {
            TrackerList[List].Products.push(Product.ProductCode);
        }
        await chrome.storage.sync.set({ TrackerList: JSON.stringify(TrackerList) });

        try {
            let GaEvent = {
                name: "Product_Added_in_Tracking",
                params: {
                    target_price: Tracker.p,
                    product_code: Tracker.c,
                    product_name: Tracker.n,
                    product_url: "",
                    store_domain: Tracker.s,
                    user_type: "Guest",
                }
            }
            chrome.runtime.sendMessage(
                { action: 'GenerateGAEvent', data: [GaEvent] },
                (response) => { }
            );
        } catch (error) { }

        Dialog.remove();

        StartExecution();
    });


}