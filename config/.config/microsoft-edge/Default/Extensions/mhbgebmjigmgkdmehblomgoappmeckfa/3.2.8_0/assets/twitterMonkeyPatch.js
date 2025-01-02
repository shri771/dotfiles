// define monkey patch function
const monkeyPatch = () => {
    // should be sent only once
    let prevHeaders = {}
    let trigger = null

    let oldXHRSend = window.XMLHttpRequest.prototype.setRequestHeader
    window.XMLHttpRequest.prototype.setRequestHeader = function (
        key,
        val,
        ...args
    ) {
        if (
            ['authorization', 'x-csrf-token', 'x-guest-token'].includes(key) &&
            !(prevHeaders[key] == val)
        ) {
            prevHeaders[key] = val
            if (trigger) {
                clearTimeout(trigger)
            }
            trigger = setTimeout(() => {
                trigger = null
                if (
                    prevHeaders['authorization'] &&
                    prevHeaders['x-csrf-token']
                ) {
                    window.dispatchEvent(
                        new CustomEvent('updateHeaders', {
                            detail: {
                                authorization:
                                    prevHeaders['authorization'],
                                csrfToken: prevHeaders['x-csrf-token'],
                                guestToken: prevHeaders['x-guest-token'],
                            },
                        })
                    )
                }
            }, 20)
        }
        return oldXHRSend.apply(this, [key, val, ...args])
    }
}

monkeyPatch()