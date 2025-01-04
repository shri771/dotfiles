export const AlertObj = {

    default: {
        Notification: {
            Status: true
        },
        Telegram: {
            Status: false,
            ChatId: "",
            Token: ""
        }
    },

    createNotification: (options) => {
        // console.log("Creating Notification", options);
        chrome.notifications.create(options.id || "my-notification-" + Date.now(), { // Generate unique ID
            type: options.type || 'basic', // Default to basic notification
            iconUrl: options.iconUrl || chrome.runtime.getURL("assets/images/icon-128x128.png"), // Path to your icon
            title: options.title || 'Notification',
            message: options.message || '',
            priority: options.priority || 0, // -2 to 2, 2 is highest
            buttons: options.buttons || [],
            requireInteraction: options.requireInteraction || false // Notification stays until user interacts
            // Other options: contextMessage, progress, items (for list notifications)
        });
    },
    sendMessageToTelegram: async (message) => {

        try {
            let Data = await chrome.storage.sync.get("alert");
            let Alert = AlertObj.default;
            try {
                if (Data.alert) {
                    Alert = JSON.parse(Data.alert)
                }
            } catch (error) { }

            const url = `https://api.telegram.org/bot${Alert.Telegram.Token}/sendMessage`;
            const data = {
                chat_id: Alert.Telegram.ChatId,
                text: message
            };
            const response = await fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });

            if (!response.ok) {
                throw new Error(`Error: ${response.statusText}`);
            }

            const result = await response.json();
            // console.log('Message sent successfully:', result);
        } catch (error) {
            // console.error('Error sending message:', error);
        }
    },

    CheckNotificationStatus: async () => {
        try {
            let Data = await chrome.storage.sync.get("alert");
            let Alert = AlertObj.default;
            try {
                if (Data.alert) {
                    Alert = JSON.parse(Data.alert)
                }
            } catch (error) { }

            if (Alert.Notification && Alert.Notification.Status && typeof Alert.Notification.Status === "boolean") {
                return Alert.Notification.Status;
            } else {
                return false;
            }

        } catch (error) {
            // console.error("Error Checking Notification Status", error);
            return false;
        }
    },

    CheckTelegramStatus: async () => {
        try {
            let Data = await chrome.storage.sync.get("alert");
            let Alert = AlertObj.default;
            try {
                if (Data.alert) {
                    Alert = JSON.parse(Data.alert)
                }
            } catch (error) { }

            if (!(Alert.Telegram && Alert.Telegram.Status && typeof Alert.Telegram.Status === "boolean")) {
                return false;
            }

            if (Alert.Telegram.Status == false) {
                return false;
            }

            if (Alert.Telegram.ChatId && typeof Alert.Telegram.ChatId === "string" && Alert.Telegram.ChatId.length > 0 && Alert.Telegram.Token && typeof Alert.Telegram.Token === "string" && Alert.Telegram.Token.length > 0) {
                return true;
            } else {
                return false;
            }

        } catch (error) {
            // console.error("Error Checking Telegram Status", error);
            return false;
        }
    }
}
