document.getElementById("ph-tabs-settings-tab").addEventListener("click", () => { UpdateSettings() });
// Setting Page | Config
let PhExtEnable = document.getElementById("ph-ext-enable")
let PhExtEnableFloatingButton = document.getElementById("ph-ext-enable-floating-button")
let PhExtFloatingButtonLocation = document.getElementById("ph-ext-floating-button-location")
let PhExtSave = document.getElementById("ph-ext-save")

PhExtEnableFloatingButton.addEventListener("change", (event) => {
    if (PhExtEnableFloatingButton.checked) {
        PhExtFloatingButtonLocation.parentElement.parentElement.style.display = ""
    } else {
        PhExtFloatingButtonLocation.parentElement.parentElement.style.display = "none"
    }
})

function UpdateSettings() {
    // console.log("Updating Settings");
    chrome.storage.sync.get(["ph-ext-data"], (data) => {
        let PhExtensionData = {}
        try {
            PhExtensionData = JSON.parse(data["ph-ext-data"])
        } catch (error) { }

        if ("enable-chart" in PhExtensionData && PhExtensionData["enable-chart"] == false) {
            PhExtEnable.checked = false
            document.querySelector("#meta-show-history span.value").innerHTML = ("OFF");
        } else {
            PhExtEnable.checked = true
            document.querySelector("#meta-show-history span.value").innerHTML = ("ON");
        }

        if ("enable-floating-button" in PhExtensionData && PhExtensionData["enable-floating-button"] == false) {
            PhExtEnableFloatingButton.checked = false

        } else {
            PhExtEnableFloatingButton.checked = true
        }
        PhExtEnableFloatingButton.dispatchEvent(new Event("change"))

        if ("floating-button-location" in PhExtensionData && PhExtensionData["floating-button-location"] != null && PhExtensionData["floating-button-location"].length > 0) {
            PhExtFloatingButtonLocation.value = PhExtensionData["floating-button-location"]
        }

        PhExtSave.addEventListener("click", () => {
            let UserPhExtensionData = {
                "enable-chart": PhExtEnable.checked,
                "enable-floating-button": PhExtEnableFloatingButton.checked,
                "floating-button-location": PhExtFloatingButtonLocation.value
            }
            chrome.storage.sync.set({ "ph-ext-data": JSON.stringify(UserPhExtensionData) }, function (e) { });
        })
        PhExtSave.removeAttribute("disabled")

    });
}

UpdateSettings();