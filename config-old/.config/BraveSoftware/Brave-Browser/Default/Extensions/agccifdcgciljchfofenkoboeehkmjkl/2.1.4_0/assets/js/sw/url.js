export const UrlObj = {
    GetRedirectUrl: (path) => {
        return `https://phapp.co/${path}/`;
    },
    GetDomainById: (id) => {
        switch (id) {
            case "1":
                return "amazon.in";
                break;

            case "2":
                return "flipkart.com";
                break;

            default:
                return ""
                break;
        }
    },
    GetIdByDomain: (domain) => {
        switch (domain) {
            case "amazon.in":
                return "1";
                break;

            case "flipkart.com":
                return "2";
                break;

            default:
                return "0"
                break;
        }
    }
}