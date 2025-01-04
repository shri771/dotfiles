document.getElementById("ph-tabs-home-tab").addEventListener("click", () => { ViewTrackedProducts() });

document.querySelectorAll("#ph-tabs-tab .nav-link").forEach((link) => {
    link.addEventListener("click", (e) => {
        let href = link.getAttribute("href");
        window.location.hash = href;
    });
});
document.addEventListener("DOMContentLoaded", () => {
    if (window.location.hash) {
        document.querySelector("[href='" + window.location.hash + "']").click();
    }
    ViewTrackedProducts();
});


// Products Configs
async function ViewTrackedProducts() {

    let HTML = ``;

    let TrackedProductList = {}
    try {
        let Data = await chrome.storage.sync.get("TrackedProductList");
        try {
            TrackedProductList = JSON.parse(Data.TrackedProductList);
        } catch (error) { }
    } catch (error) { }

    let ProductList = await GetOrSetTrackerStorage("ProductList", true, true, {});
    ProductList = ProductList == null ? {} : ProductList;

    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true, true, {});
    TrackerList = TrackerList == null ? {} : TrackerList;

    const TrackerListProductBody = document.getElementById("tracked-container-list");
    const TrackedList = document.getElementById("tracked-container");

    if (Object.keys(TrackedProductList).length > 0) {
        TrackedList.classList.remove("d-none");
        Object.keys(TrackedProductList).forEach(code => {
            if (code in TrackedProductList && code in ProductList) {
                let TrackedProduct = ProductList[code];
                TrackedProduct.fp = TrackedProductList[code].p;
                TrackedProduct.ft = TrackedProductList[code].t;
                HTML += GetTrackedProductHTML(TrackedProduct)
            }
        });
        TrackerListProductBody.innerHTML = HTML;
    } else {
        TrackedList.classList.add("d-none");
        TrackerListProductBody.innerHTML = "";
    }

    TrackerListProductBody.querySelectorAll(".user-btn-delete").forEach(element => {
        element.addEventListener("click", () => {
            DeleteProduct(element, () => {
                ViewTrackedProducts();
            });
        })
    });
    TrackerListProductBody.querySelectorAll(".user-btn-edit").forEach(element => {
        element.addEventListener("click", () => {
            InitiateEditProduct(element, () => {
                ViewTrackedProducts();
            });
        })
    });
    TrackerListProductBody.querySelectorAll(".user-btn-keep").forEach(element => {
        element.addEventListener("click", () => {
            KeepProductTracking(element, () => {
                ViewTrackedProducts();
            });
        })
    });


    document.querySelector("#meta-product-tracking span.value").innerHTML = (Object.keys(ProductList).length);
    document.querySelector("#meta-list-added span.value").innerHTML = (Object.keys(TrackerList).length);
    document.querySelector("#meta-product-tracked span.value").innerHTML = (Object.keys(TrackedProductList).length);

    document.querySelectorAll("#meta-container .meta-list").forEach(metalist => {
        metalist.addEventListener("click", () => {
            let queryCount = metalist.getAttribute("data-query-count");
            for (let i = 0; i < queryCount; i++) {
                setTimeout(() => {
                    document.querySelector(metalist.getAttribute("data-query-" + (i + 1))).click();
                }, 1500 * i);
            }
        });
    });


}

async function KeepProductTracking(element, response) {
    let Code = element.dataset.code

    let TrackedProductList = await GetOrSetTrackerStorage("TrackedProductList", true, true, {});
    TrackedProductList = TrackedProductList == null ? {} : TrackedProductList;

    try {
        if (TrackedProductList[Code]) {
            delete TrackedProductList[Code];
            await chrome.storage.sync.set({ "TrackedProductList": JSON.stringify(TrackedProductList) });

            chrome.runtime.sendMessage({ action: "RefreshBadge" });

            response();
        } else {
            Swal.fire({
                title: "Invalid Product!",
                text: "Product Not Found!",
                icon: "warning"
            });
            return;
        }
    } catch (error) {
        Swal.fire({
            title: "Invalid Product!",
            text: "Product Not Found!",
            icon: "warning"
        });
        return;
    }
}

function GetTrackedProductHTML(TrackerProduct) {
    let HTML = `
                <div
                    class="col-12 col-md-6 col-lg-6 col-xl-4 px-1 mb-2 tracking-list-product">
                    <div class="card bg-white border-0 shadow-sm p-1">
                        <h5 class="card-title mb-0 h6 px-2 mb-1">
                            <a href="${UrlObj.GetRedirectUrl("ext") + UrlObj.GetIdByDomain(TrackerProduct.s) + "-" + TrackerProduct.c}"
                                target="_blank" class="small font-weight-bold text-dark"
                                title="Check on ${TrackerProduct.s}">${TrackerProduct.n}</a>
                        </h5>
                        <div class="row m-0">
                            <div class="col-6 px-0 text-center">

                                <a href="${UrlObj.GetRedirectUrl("ext") + UrlObj.GetIdByDomain(TrackerProduct.s) + "-" + TrackerProduct.c}"
                                    target="_blank" title="Check on ${TrackerProduct.s}">
                                    <img src="${TrackerProduct.i ? TrackerProduct.i : "/assets/images/icon-128x128.png"}"
                                        height="125" class="card-img-top"
                                        alt="Product Image">
                                </a>

                                <div class="row m-0 text-muted text-left">
                                    <div class="col-12 px-0">
                                        <span class="badge font-weight-bold ${TrackerProduct.a ? "badge-success" : "badge-secondary"}">${TrackerProduct.a ? "Active" : "Deactive"}</span>
                                        <span class="small float-right">Found ${timeAgo(TrackerProduct.ft)}
                                            ago</span>
                                        <br>
                                    </div>
                                    <div class="col-12 px-0"><span class="small">Tracking
                                            Price:</span> <span
                                            class="text-dark font-weight-bold big"><big>₹${TrackerProduct.p}</big></span>
                                    </div>
                                    <div class="col-12 px-0"><span class="small">Found
                                            Price:</span> <span
                                            class="text-dark font-weight-bold big">₹${TrackerProduct.fp}</span>
                                    </div>
                                </div>

                            </div>
                            <div class="col-6 px-1">
                                <div class="row m-0 text-right">

                                    <div class="col-12 px-0">
                                        <span
                                            class="btn btn-sm btn-block text-right text-warning mt-2 user-btn-edit"
                                            data-store="${TrackerProduct.s}" data-code="${TrackerProduct.c}">
                                            Edit Product
                                        </span>
                                    </div>

                                    <div class="col-12 px-0">
                                        <span
                                            class="btn btn-sm btn-block text-right text-info mt-2 user-btn-keep"
                                            data-store="${TrackerProduct.s}" data-code="${TrackerProduct.c}">
                                            Alert Again
                                        </span>
                                    </div>
                                    <div class="col-12 px-0">
                                        <a href="https://pricehistory.app/p/${TrackerProduct.url}"
                                            target="_blank"
                                            class="btn btn-sm btn-block text-right text-primary mt-2">Check
                                            History</a>
                                    </div>
                                    <div class="col-12 px-0">
                                        <span
                                            class="btn btn-sm btn-block text-right text-danger user-btn-delete mt-2" data-store="${TrackerProduct.s}" data-code="${TrackerProduct.c}">Remove
                                            from Tracking</span>
                                    </div>
                                    <div class="col-12 px-0">
                                        <a href="${UrlObj.GetRedirectUrl("ext") + UrlObj.GetIdByDomain(TrackerProduct.s) + "-" + TrackerProduct.c}"
                                            target="_blank"
                                            class="btn btn-sm btn-block text-right btn-success mt-2 text-center">Buy
                                            on ${TrackerProduct.s}</a>
                                    </div>

                                </div>
                            </div>
                            
                        </div>
                    </div>
                </div>`;
    return HTML;
}
