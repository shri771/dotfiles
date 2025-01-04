document.getElementById("alert-save").addEventListener("click", async (e) => {
    let Alert = {
        Notification: {
            Status: document.getElementById("alert-notification-enable").checked
        },
        Telegram: {
            Status: document.getElementById("alert-telegram-enable").checked,
            ChatId: document.getElementById("alert-telegram-chat-id").value,
            Token: document.getElementById("alert-telegram-bot").value
        }
    }

    await chrome.storage.sync.set({ alert: JSON.stringify(Alert) });

    // console.log("Alert", Alert)
});

document.getElementById("ph-tabs-alert-tab").addEventListener("click", () => {
    UpdateAlert();
});

async function UpdateAlert() {
    let Data = await chrome.storage.sync.get("alert");
    let Alert = {
        Notification: {
            Status: true
        },
        Telegram: {
            Status: false,
            ChatId: "",
            Token: ""
        }
    }
    try {
        if (Data.alert) {
            Alert = JSON.parse(Data.alert)
        }
    } catch (error) { }

    if (Alert) {
        if (Alert.Notification && Alert.Notification.Status) {
            document.getElementById("alert-notification-enable").checked = Alert.Notification.Status
            if (Alert.Notification.Status) {
                document.querySelector("#meta-chrome-alert span.value").innerHTML = ("ON");
            } else {
                document.querySelector("#meta-chrome-alert span.value").innerHTML = ("OFF");
            }
        }
        if (Alert.Telegram) {
            if (Alert.Telegram.Status && typeof Alert.Telegram.Status === "boolean") {
                document.getElementById("alert-telegram-enable").checked = Alert.Telegram.Status
            }
            if (Alert.Telegram.ChatId && typeof Alert.Telegram.ChatId === "string") {
                document.getElementById("alert-telegram-chat-id").value = Alert.Telegram.ChatId
            }
            if (Alert.Telegram.Token && typeof Alert.Telegram.Token === "string") {
                document.getElementById("alert-telegram-bot").value = Alert.Telegram.Token
            }
            if (Alert.Telegram.Status && typeof Alert.Telegram.Status === "boolean" && Alert.Telegram.Status == true && Alert.Telegram.ChatId && typeof Alert.Telegram.ChatId === "string" && Alert.Telegram.ChatId.length > 0 && Alert.Telegram.Token && typeof Alert.Telegram.Token === "string" && Alert.Telegram.Token.length > 0) {
                document.querySelector("#meta-telegram-alert span.value").innerHTML = ("ON");
            } else {
                document.querySelector("#meta-telegram-alert span.value").innerHTML = ("OFF");
            }
        }
    }
}

UpdateAlert();