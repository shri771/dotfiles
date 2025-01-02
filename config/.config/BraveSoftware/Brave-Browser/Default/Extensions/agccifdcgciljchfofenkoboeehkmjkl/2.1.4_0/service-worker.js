import { AlertObj } from './assets/js/sw/alert.js';
import { UrlObj } from './assets/js/sw/url.js';
let TrackerInterval = null;
const TrackerIntervalTime = 1000 * 60;

chrome.runtime.onInstalled.addListener(function (details) {
    // console.log("onInstalled", details);
    if (details.reason === "install" || details.reason === "update") {
        chrome.tabs.create({ url: "https://pricehistory.app/page/extension" }); // Replace with your desired URL
    }
});

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.action === 'fetchData') {
        fetch("https://pricehistory.app/api/embed", {
            method: "POST",
            body: JSON.stringify(message.data),
            headers: {
                "Content-Type": "application/json",
            },
        })
            .then((response) => response.json())
            .then((responseData) => {
                sendResponse({ status: true, data: responseData });
            })
            .catch((error) => {
                // console.error("An error occurred:", error);
                sendResponse({ status: false, error: "An error occurred" });
            });
    } else if (message.action === 'GenerateGAEvent') {
        SendAnalyticsEvent(message.data)
    } else if (message.action === 'Traking') {
        if (TrackerInterval == null) {
            InitiateTracker();
        }
    } else if (message.action === 'RefreshProduct') {
        // console.log("RefreshProduct", message.code);
        TrackProducts(message.code).then(() => {
            sendResponse({ status: true });
        });
    } else if (message.action === 'OpenUrl') {
        chrome.tabs.create({ url: message.url });
    } else if (message.action === 'Notification') {
        AlertObj.createNotification(message.options);
    } else if (message.action === 'RefreshBadge') {
        RefreshBadge();
    }
    return true;
});

async function GetProductPrice(store, Code) {

    function GetArrayLastValue(Array) {
        return Array[Array.length - 1];
    }

    try {
        switch (store) {
            case "amazon.in": {
                let data = {}
                let HTML = await (await fetch(`https://www.amazon.in/dp/${Code}?th=1`)).text();

                if (HTML.includes("\"priceAmount\":")) {
                    try {
                        data.price = parseFloat(HTML.split("\"priceAmount\":")[1].split(",")[0]);
                    } catch (error) { }
                }
                if ((!data.price) && HTML.includes(" id=\"priceValue\"")) {
                    try {
                        data.price = parseFloat(GetArrayLastValue(HTML.split(" id=\"priceValue\"")[0].split("value=\"")).split("\"")[0]);
                    } catch (error) { }
                }
                if ((!data.price) && HTML.includes("price-data-price\" value=\"")) {
                    try {
                        data.price = parseFloat(HTML.split("price-data-price\" value=\"")[1].split("\"")[0]);
                    } catch (error) { }
                }
                // console.log("data", data);
                if (HTML.includes(" off coupon applied ")) {
                    try {
                        let coupon = GetArrayLastValue(HTML.split(" off coupon applied ")[0].split(">")).replace("&nbsp;", "");
                        // console.log("coupon", coupon);
                        if (coupon.includes("₹")) {
                            coupon = parseFloat(coupon.replace("₹", ""))
                            // console.log("coupon", coupon);
                            if (coupon != NaN) {
                                data.price = data.price - coupon;
                            }
                        }
                        if (coupon.includes("%")) {
                            coupon = parseFloat(coupon.replace("%", ""))
                            // console.log("coupon", coupon);
                            if (coupon != NaN) {
                                data.price = data.price - (data.price * (coupon / 100));
                            }
                        }
                    } catch (error) { }
                }
                // console.log("data", data);
                return data;
            }
                break;

            case "flipkart.com": {
                let data = {}
                let HTML = await (await fetch(`https://www.flipkart.com/a/p/b?pid=${Code}`)).text();
                if (HTML.includes("Sold Out")) {
                    return {}
                }
                if (HTML.includes("PRODUCT_PRICING_PAGE")) {
                    try {
                        data.price = parseFloat(HTML.split("PRODUCT_PRICING_PAGE")[1].split("finalPrice")[1].split("\"decimalValue\":\"")[1].split("\"")[0]);
                    } catch (error) { }
                }
                return data;
            }
                break;

            default:
                return {}
                break;
        }
    } catch (error) {
        return {}
    }
}

async function TrackProducts(code = null) {

    let Data = await chrome.storage.sync.get("ProductList");
    let ProductList = {}
    try {
        ProductList = JSON.parse(Data.ProductList);
        ProductList = ProductList == null ? {} : ProductList;
    } catch (error) { }

    let productWithLowestCt = null;
    if (code == null) {
        for (let key in ProductList) {
            if (ProductList[key].a === true) {
                if ((ProductList[key].ct + ((parseFloat(ProductList[key].f) == NaN ? 8 : parseFloat(ProductList[key].f)) * 60 * 60 * 1000)) <= Date.now()) {
                    if (productWithLowestCt === null || ProductList[key].ct < productWithLowestCt.ct) {
                        productWithLowestCt = ProductList[key];
                    }
                }
            }
        }

        if (productWithLowestCt === null) {
            clearInterval(TrackerInterval);
            TrackerInterval = null;
            setTimeout(() => {
                InitiateTracker();
            }, 1000 * 60 * 60);
            return;
        }
    } else {
        if (ProductList[code]) {
            productWithLowestCt = ProductList[code];
        }
    }

    // console.log(productWithLowestCt);

    let { price } = await GetProductPrice(productWithLowestCt.s, productWithLowestCt.c);

    if (price && productWithLowestCt.p >= price) {
        let TrackedProductList = {}
        try {
            let Data = await chrome.storage.sync.get("TrackedProductList");
            try {
                TrackedProductList = JSON.parse(Data.TrackedProductList);
            } catch (error) { }
        } catch (error) { }

        let ShowNotification = false;

        TrackedProductList = TrackedProductList == null ? {} : TrackedProductList;
        if (TrackedProductList[productWithLowestCt.c]) {
            if (TrackedProductList[productWithLowestCt.c].p != price) {
                TrackedProductList[productWithLowestCt.c].lp = TrackedProductList[productWithLowestCt.c].p;
            }
            if (TrackedProductList[productWithLowestCt.c].p > price) {
                TrackedProductList[productWithLowestCt.c].p = price;
                TrackedProductList[productWithLowestCt.c].t = Date.now();
                ShowNotification = true;
            }
        } else {
            ShowNotification = true;
            TrackedProductList[productWithLowestCt.c] = {
                lp: null,
                p: price,
                t: Date.now()
            }
        }
        await chrome.storage.sync.set({ TrackedProductList: JSON.stringify(TrackedProductList) });
        RefreshBadge();
        // console.log("ShowNotification", ShowNotification);
        if (ShowNotification) {
            if (await AlertObj.CheckNotificationStatus()) {
                AlertObj.createNotification({
                    id: "ph-product-" + productWithLowestCt.c,
                    title: "Price Drop on " + productWithLowestCt.n,
                    message: "Price Dropped to ₹" + price + " at " + new Date().toLocaleString(),
                    iconUrl: productWithLowestCt.i ? productWithLowestCt.i : chrome.runtime.getURL("assets/images/icon-128x128.png")
                });
            } else {
                // console.log("Notification Disabled");
            }
            if (await AlertObj.CheckTelegramStatus()) {
                AlertObj.sendMessageToTelegram(`🎉 Price Drop Alert! 🎉\n\n🔖 ${productWithLowestCt.n} \n\n 💸 New Price: ₹${price} \n\n ⏰ Alert Time: ${new Date().toLocaleString()} \n\n 🛍️ Grab the Deal Here: ${UrlObj.GetRedirectUrl("etg") + UrlObj.GetIdByDomain(productWithLowestCt.s) + "-" + productWithLowestCt.c} \n\n Hurry! Prices may go up soon! 🚀✨`);
            } else {
                // console.log("Telegram Disabled");
            }

            try {
                SendAnalyticsEvent([{
                    name: "Target_Reached_Notified",
                    params: {
                        target_price: productWithLowestCt.p,
                        product_code: productWithLowestCt.c,
                        product_name: productWithLowestCt.n,
                        product_url: "",
                        store_domain: productWithLowestCt.s,
                        user_type: "Guest",
                        found_price: price,
                        time_to_get_target: Date.now()
                    }
                }]);
            } catch (error) { }
        }
    }

    Data = await chrome.storage.sync.get("ProductList");
    try {
        ProductList = JSON.parse(Data.ProductList);
        ProductList = ProductList == null ? {} : ProductList;
        ProductList[productWithLowestCt.c].ct = Date.now();
        if (price) {
            ProductList[productWithLowestCt.c].lp = price;
        }
        await chrome.storage.sync.set({ ProductList: JSON.stringify(ProductList) });
    } catch (error) { }

    return true;
}

async function InitiateTracker() {
    let Data = await chrome.storage.sync.get("ProductList");
    let ProductList = {}
    try {
        ProductList = JSON.parse(Data.ProductList);
        ProductList = ProductList == null ? {} : ProductList;
    } catch (error) { }

    if (Object.keys(ProductList).length > 0) {
        TrackerInterval = setInterval(() => {
            TrackProducts();
        }, TrackerIntervalTime);
    } else {
        clearInterval(TrackerInterval);
        TrackerInterval = null;
    }

}


chrome.tabs.onUpdated.addListener(
    function (tabId, changeInfo, tab) {
        try {
            if ("status" in changeInfo && changeInfo.status == "complete") {
                chrome.tabs.sendMessage(tabId, {
                    message: 'UrlChanged',
                    url: changeInfo.url
                })
            }
        } catch (error) {
            // console.log("error", error)
        }
    }
);

chrome.notifications.onClicked.addListener(async function (notificationId) {
    // Retrieve the URL from storage
    // console.log("notificationId", notificationId);
    if (notificationId.startsWith("ph-product-")) {
        let Code = notificationId.split("ph-product-")[1];
        let ProductList = {}
        try {
            let Data = await chrome.storage.sync.get("ProductList");
            ProductList = JSON.parse(Data.ProductList);
            ProductList = ProductList == null ? {} : ProductList;
            if (ProductList[Code]) {
                chrome.tabs.create({ url: UrlObj.GetRedirectUrl("ecn") + UrlObj.GetIdByDomain(ProductList[Code].s) + "-" + ProductList[Code].c });
            }
        } catch (error) {
            // console.log(" notificationId Error", error);
        }
        return;
    }
});


async function getOrCreateClientId() {
    const result = await chrome.storage.local.get('clientId');
    if (result.clientId) {
        return result.clientId;
    }

    const tenDigitNumberCode = Math.floor(Math.random() * 9999999999).toString().padStart(10, '0');
    const unixTimestamp = Date.now().toString().substring(0, 10);
    const uniqueIdentifier = `${tenDigitNumberCode}.${unixTimestamp}`;
    let clientId = `GA1.2.${uniqueIdentifier}`;
    await chrome.storage.local.set({ "clientId": clientId });
    return clientId;
}

async function getOrCreateSessionId() {
    let SESSION_EXPIRATION_IN_MIN = 30;

    let { sessionData } = await chrome.storage.session.get('sessionData');
    const currentTimeInMs = Date.now();
    if (sessionData && sessionData.timestamp) {
        const durationInMin = (currentTimeInMs - sessionData.timestamp) / 60000;
        if (durationInMin > SESSION_EXPIRATION_IN_MIN) {
            sessionData = null;
        } else {
            sessionData.timestamp = currentTimeInMs;
            await chrome.storage.session.set({ "sessionData": sessionData });
        }
    }
    if (!sessionData) {
        sessionData = {
            session_id: currentTimeInMs.toString(),
            timestamp: currentTimeInMs.toString(),
        };
        await chrome.storage.session.set({ "sessionData": sessionData });
    }
    return sessionData.session_id;
}


async function SendAnalyticsEvent(events) {
    const GA_ENDPOINT = 'https://www.google-analytics.com/mp/collect';
    const MEASUREMENT_ID = `G-2WYQQ15XYX`;
    const API_SECRET = `jwhOMoczT62zu2bs2wDxZw`;
    const CLIENT_ID = await getOrCreateClientId()
    const SESSION_ID = await getOrCreateSessionId()
    for (let i = 0; i < events.length; i++) {
        if (!events[i].params) {
            events[i].params = {}
        }
        events[i].params.session_id = SESSION_ID
    }

    fetch(
        `${GA_ENDPOINT}?measurement_id=${MEASUREMENT_ID}&api_secret=${API_SECRET}`,
        {
            method: 'POST',
            body: JSON.stringify({
                client_id: CLIENT_ID,
                timestamp_micros: (new Date().getTime() * 1000).toString(),
                non_personalized_ads: "false",
                events: events,
            }),
        }
    );

}

async function RefreshBadge() {
    let TrackedProductList = {}
    let Data = await chrome.storage.sync.get("TrackedProductList");
    try {
        TrackedProductList = JSON.parse(Data.TrackedProductList);
        TrackedProductList = TrackedProductList == null ? {} : TrackedProductList;
        if (Object.keys(TrackedProductList).length > 0) {
            chrome.action.setBadgeText({ text: Object.keys(TrackedProductList).length.toString() });
            chrome.action.setTitle({ title: "Price History: " + Object.keys(TrackedProductList).length.toString() + " Products Tracked" });
        } else {
            chrome.action.setBadgeText({ text: '' });
            chrome.action.setTitle({ title: "Price History" });
        }
    } catch (error) { }
}

// Starting Tracker
InitiateTracker();
RefreshBadge();

chrome.action.onClicked.addListener((tab) => {
    chrome.tabs.create({ url: chrome.runtime.getURL("options/settings.html") });
});