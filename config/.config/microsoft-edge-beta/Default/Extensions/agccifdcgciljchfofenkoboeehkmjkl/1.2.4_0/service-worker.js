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
                console.error("An error occurred:", error);
                sendResponse({ status: false, error: "An error occurred" });
            });
    } else if (message.action === 'GenerateGAEvent') {
        SendAnalyticsEvent(message.data)
    }
    return true;
});

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
            console.log("error", error)
        }
    }
);

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