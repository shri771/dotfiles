const TRACKER_CONSTANTS = {
    LIST_LIMIT: 10,
    PRODUCT_IN_LIST_LIMIT: 10
}
document.getElementById("ph-tabs-settings-tab").addEventListener("click", () => { UpdateTrackings() });

const AddTrackerInitiator = document.getElementById("add-tracker-initiator");
const AddTracker = document.getElementById("add-tracker");
const AddTrackerName = document.getElementById("add-tracker-name");
const EditNewTrackerName = document.getElementById("edit-new-tracker-name");
const EditOldTrackerName = document.getElementById("edit-old-tracker-name");
const EditTracker = document.getElementById("edit-tracker");
const EditProduct = document.getElementById("edit-product-save");
const ListProductRefresh = document.getElementById("tracking-list-product-refresh");

[AddTrackerName, EditNewTrackerName, EditOldTrackerName].forEach(element => {
    element.addEventListener("keyup", () => {
        element.value = element.value.replace(/[^a-zA-Z0-9- ]/g, "")
    })
});

ListProductRefresh.addEventListener("click", async () => {
    let List = ListProductRefresh.dataset.list
    let ProductBody = document.getElementById("tracking-list-product-body");
    let btns = ProductBody.querySelectorAll(".user-btn-refresh")
    if (btns.length == 0) {
        Swal.fire({
            title: "No Product!",
            text: "No product to refresh!",
            icon: "warning"
        });
        return;
    }
    btns.forEach(btn => {
        btn.click();
    });
    setTimeout(() => {
        ViewListElement({ dataset: { list: List } });
    }, (1000 * btns.length) + (2500));
});

EditProduct.addEventListener("click", async () => {
    let List = document.getElementById("edit-product-list").value
    let Code = document.getElementById("edit-product-code").value
    let Price = document.getElementById("edit-product-price").value
    let Active = document.getElementById("edit-product-active").value == "1" ? true : false

    let ProductList = await GetOrSetTrackerStorage("ProductList", true, true, {});
    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true, false, {});
    TrackerList = TrackerList == null ? { default: { Name: "default", Products: [] } } : TrackerList;

    if (ProductList[Code]) {
        if (ProductList[Code].l != List) {
            if (TrackerList[ProductList[Code].l] && TrackerList[ProductList[Code].l].Products.includes(Code)) {
                TrackerList[ProductList[Code].l].Products = TrackerList[ProductList[Code].l].Products.filter((item) => item != Code);
            }
        }
        ProductList[Code].p = Price
        ProductList[Code].a = Active
        ProductList[Code].l = List
        await chrome.storage.sync.set({ ProductList: JSON.stringify(ProductList), TrackerList: JSON.stringify(TrackerList) });
        ViewListElement({ dataset: { list: List } })
        try {
            ViewTrackedProducts();
        } catch (error) { }
        $("#modal-edit-product").modal("hide")
    } else {
        Swal.fire({
            title: "Invalid Product!",
            text: "Product Not Found!",
            icon: "warning"
        });
        return;
    }
});

EditTracker.addEventListener("click", async () => {
    UpdateListElement()
});

AddTracker.addEventListener("click", async () => {
    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true);
    TrackerList = TrackerList == null ? {} : TrackerList
    if (Object.keys(TrackerList).length >= TRACKER_CONSTANTS.LIST_LIMIT) {
        Swal.fire({
            title: "Limit Reached!",
            text: "You have reached maximum limit. Remove older list to add new!",
            icon: "warning"
        });
        return;
    }

    AddTrackerName.value = AddTrackerName.value.replace(/[^a-zA-Z0-9- ]/g, "")
    let NewListName = AddTrackerName.value
    if (NewListName in TrackerList) {
        Swal.fire({
            title: "Same List Exist!",
            text: "Please change the name of tracker list!",
            icon: "warning"
        });
        return;
    }

    TrackerList[NewListName] = {
        "Name": NewListName,
        "Products": []
    }

    await chrome.storage.sync.set({ "TrackerList": JSON.stringify(TrackerList) });

    Swal.fire({
        title: "New List Added!",
        text: "",
        icon: "success"
    });

    $("#modal-add-tracker").modal("hide");
    AddTrackerName.value = ""
    UpdateTrackings();
    return;
});

AddTrackerInitiator.addEventListener("click", async (e) => {
    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true);
    TrackerList = TrackerList == null ? {} : TrackerList
    if (Object.keys(TrackerList).length >= TRACKER_CONSTANTS.LIST_LIMIT) {
        Swal.fire({
            title: "Limit Reached!",
            text: "You have reached maximum limit. Remove other list to add new!",
            icon: "warning"
        });
        return;
    } else {
        $("#modal-add-tracker").modal("show");
    }
})

async function GetOrSetTrackerStorage(key, IsParse = true, IsCreate = false, Value = {}) {
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



// Tracking Config
async function UpdateTrackings() {

    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true);
    // console.log("TrackerList", TrackerList)
    TrackerList = TrackerList == null ? {} : TrackerList

    // console.log("TrackerList", TrackerList)
    let TrackingListBodyElement = document.getElementById("tracking-list-body");
    TrackingListBodyElement.innerHTML = "";

    if (Object.keys(TrackerList).length > 0) {
        document.getElementById("tracking-list-container").querySelector("h3").innerHTML = "Tracking List";

        Object.keys(TrackerList).forEach(key => {
            let TempListElement = document.createElement("div");
            TempListElement.className = "col-12 mt-2";
            TempListElement.innerHTML = `
                <div class="card bg-white border-0 shadow-sm p-2" data-list="${key}">
                    <div class="row">
                        <div class="col-12">
                            <label class="font-weight-bold d-block text-muted h6 mb-0 pl-3 view-list-element"
                                data-list="${key}">
                                ${key.toUpperCase()}
                                <span class="badge float-right badge-dark mr-1">${TrackerList[key].Products.length}</span>
                            </label>
                        <div>
                        <div class="col-12 px-1 text-right">
                            <small class="btn py-0 px-1 btn-sm text-warning mr-1 edit-list-element"
                                data-list="${key}">
                                    <svg height="15" viewBox="0 0 21 21" width="15"
                                        stroke-width="2" xmlns="http://www.w3.org/2000/svg">
                                        <g fill="none" fill-rule="evenodd"
                                            stroke="currentColor" stroke-linecap="round"
                                            stroke-linejoin="round"
                                            transform="translate(3 3)">
                                            <path
                                                d="m14 1c.8284271.82842712.8284271 2.17157288 0 3l-9.5 9.5-4 1 1-3.9436508 9.5038371-9.55252193c.7829896-.78700064 2.0312313-.82943964 2.864366-.12506788z" />
                                            <path d="m12.5 3.5 1 1" />
                                        </g>
                                    </svg>
                                Edit
                            </small>
                            <small class="btn py-0 px-1 btn-sm text-danger delete-list-element"
                                data-list="${key}">
                                <svg height="17" viewBox="0 0 21 21" width="17"
                                    stroke-width="2" xmlns="http://www.w3.org/2000/svg">
                                    <g fill="none" fill-rule="evenodd"
                                        stroke="currentColor" stroke-linecap="round"
                                        stroke-linejoin="round"
                                        transform="translate(5 5)">
                                        <path d="m10.5 10.5-10-10z" />
                                        <path d="m10.5.5-10 10" />
                                    </g>
                                </svg>
                                Delete
                            </small>
                        <div>

                    </div>
                </div>
            `


            const TrackingListProductBody = document.getElementById("tracking-list-product-body");
            document.getElementById("tracking-list-title").innerHTML = "";
            TrackingListProductBody.innerHTML = `
                <div class="col-12 text-center text-muted my-5 py-5">
                    <svg height="75" viewBox="0 0 21 21" width="75"
                        xmlns="http://www.w3.org/2000/svg">
                        <g fill="none" fill-rule="evenodd" stroke="currentColor"
                            stroke-linecap="round" stroke-linejoin="round"
                            transform="translate(3 6)">
                            <path d="m1.378 1.376 4.243.003v4.242"
                                transform="matrix(-.70710678 .70710678 .70710678 .70710678 3.500179 -1.449821)" />
                            <path
                                d="m5.5 9.49998326h5c2 .00089417 3-.99910025 3-2.99998326s-1-3.00088859-3-3.00001674h-10" />
                        </g>
                    </svg>

                    <span class="d-block h4">Select list</span>`;


            TrackingListBodyElement.append(TempListElement)
        });

        TrackingListBodyElement.querySelectorAll(".edit-list-element").forEach(element => {
            element.addEventListener("click", () => {
                EditListElement(element);
            })
        });

        TrackingListBodyElement.querySelectorAll(".delete-list-element").forEach(element => {
            element.addEventListener("click", () => {
                DeleteListElement(element);
            })
        });

        TrackingListBodyElement.querySelectorAll(".view-list-element").forEach(element => {
            element.addEventListener("click", () => {
                TrackingListBodyElement.querySelectorAll(".card").forEach(card => {
                    card.classList.remove("active");
                });
                TrackingListBodyElement.querySelector(`.card[data-list="${element.dataset.list}"]`).classList.add("active");
                ViewListElement(element);
            })
        });

        if (Object.keys(TrackerList).length == 1) {
            ViewListElement({ dataset: { list: Object.keys(TrackerList)[0] } });
        }

    } else {
        document.getElementById("tracking-list-container").querySelector("h3").innerHTML = "No List";
    }
    return;

}

async function EditListElement(element) {
    let List = element.dataset.list
    // console.log("List", List)
    EditTracker.dataset.list = List

    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true);
    // console.log("TrackerList", TrackerList)
    TrackerList = TrackerList == null ? {} : TrackerList

    if (List in TrackerList) {
        document.getElementById("edit-old-tracker-name").value = List
        document.getElementById("edit-new-tracker-name").value = ""
        document.getElementById("ModalEditTracker").innerHTML = `Edit List <br><span class="d-block h6 mb-0">${List}</span>`
        $("#modal-edit-tracker").modal("show")
    } else {
        Swal.fire({
            title: "Can not edit!",
            text: "List does not exist of might be deleted!",
            icon: "warning"
        });
        return;
    }
}
async function UpdateListElement() {
    let List = EditTracker.dataset.list

    if (EditNewTrackerName.value == EditOldTrackerName.value) {
        Swal.fire({
            title: "Nothing Changed!",
            text: "Please change name to update!",
            icon: "warning"
        });
        return;
    }

    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true);
    // console.log("TrackerList", TrackerList)
    TrackerList = TrackerList == null ? {} : TrackerList

    if (!(List in TrackerList)) {
        Swal.fire({
            title: "original List not found!",
            text: "List that you want to edit is removed or not exist!",
            icon: "warning"
        });
        return;
    }

    if (EditNewTrackerName.value in TrackerList) {
        Swal.fire({
            title: "Name Already exist!",
            text: "List with same name already exist!",
            icon: "warning"
        });
        return;
    }

    // console.log("Old TrackerList", TrackerList)

    TrackerList[EditNewTrackerName.value] = TrackerList[List]

    TrackerList[EditNewTrackerName.value].Name = EditNewTrackerName.value

    delete TrackerList[List]

    // console.log("New TrackerList", TrackerList)

    await chrome.storage.sync.set({ "TrackerList": JSON.stringify(TrackerList) });

    Swal.fire({
        title: "Name Updated!",
        text: `Name is changed to "${EditNewTrackerName.value}" from "${List}"`,
        icon: "success"
    });

    UpdateTrackings();

}

async function DeleteListElement(element) {
    let List = element.dataset.list

    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true);
    // console.log("TrackerList", TrackerList)
    TrackerList = TrackerList == null ? {} : TrackerList

    if (List in TrackerList) {
        if (TrackerList[List].Products && Array.isArray(TrackerList[List].Products) && TrackerList[List].Products.length > 0) {
            Swal.fire({
                title: "Can not Delete!",
                text: "There sre some products in this list",
                icon: "warning"
            });
            return;
        } else {
            Swal.fire({
                title: "Are you sure?",
                text: "You won't be able to revert this!",
                icon: "warning",
                showCancelButton: true,
                confirmButtonColor: "#3085d6",
                cancelButtonColor: "#d33",
                confirmButtonText: "Yes, delete it!"
            }).then(async (result) => {
                if (result.isConfirmed) {
                    delete TrackerList[List]
                    await chrome.storage.sync.set({ "TrackerList": JSON.stringify(TrackerList) });
                    Swal.fire({
                        title: "Deleted!",
                        text: "Your list has been deleted.",
                        icon: "success"
                    });
                    UpdateTrackings();
                }
            });

        }
    } else {
        Swal.fire({
            title: "Invalid List!",
            text: "List Not found!",
            icon: "warning"
        });
    }

}

UpdateTrackings();

// Products Configs
async function ViewListElement(element) {
    let List = element.dataset.list

    let HTML = ``;
    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true);
    TrackerList = TrackerList == null ? {} : TrackerList;

    let ProductList = await GetOrSetTrackerStorage("ProductList", true, true, {});
    const TrackingListProductBody = document.getElementById("tracking-list-product-body");
    document.getElementById("tracking-list-title").innerHTML = List.toUpperCase() + " List";
    ListProductRefresh.dataset.list = List;

    if (List in TrackerList) {
        if (TrackerList[List].Products && Array.isArray(TrackerList[List].Products) && TrackerList[List].Products.length > 0) {
            TrackerList[List].Products.forEach(ProductCode => {
                if (ProductCode in ProductList) {
                    HTML += GetProductHTML(ProductList[ProductCode])
                }
            });

        } else {
            HTML = `<div class="col-12 text-center text-muted my-5 py-5"><span class="d-block h4 mb-5 py-5">No Product in this list</span></div>`
        }
    }

    document.getElementById("tracking-list-product-container").classList.remove("d-none");
    TrackingListProductBody.innerHTML = HTML;
    TrackingListProductBody.querySelectorAll(".user-btn-deactivate").forEach(element => {
        element.addEventListener("click", () => {
            ChangeProductStatus(element, false, (a) => {
                ViewListElement(a);
            });
        })
    });
    TrackingListProductBody.querySelectorAll(".user-btn-activate").forEach(element => {
        element.addEventListener("click", () => {
            ChangeProductStatus(element, true, (a) => {
                ViewListElement(a);
            });
        })
    });
    TrackingListProductBody.querySelectorAll(".user-btn-delete").forEach(element => {
        element.addEventListener("click", () => {
            DeleteProduct(element, (a) => {
                ViewListElement(a);
            });
        })
    });
    TrackingListProductBody.querySelectorAll(".user-btn-edit").forEach(element => {
        element.addEventListener("click", () => {
            InitiateEditProduct(element);
        })
    });
    TrackingListProductBody.querySelectorAll(".user-btn-refresh").forEach(element => {
        element.addEventListener("click", () => {
            RefreshProduct(element);
        })
    });
}

async function ChangeProductStatus(element, Status, response) {
    let List = element.dataset.list
    let Code = element.dataset.code
    // console.log("ChangeProductStatus", List, Code, Status)

    let ProductList = await GetOrSetTrackerStorage("ProductList", true, true, {});
    try {
        ProductList[Code].a = Status
        await chrome.storage.sync.set({ "ProductList": JSON.stringify(ProductList) });
        response({ dataset: { list: List } })
    } catch (error) {
        Swal.fire({
            title: "Invalid Product!",
            text: "Product Not Found!",
            icon: "warning"
        });
        return;
    }
}

async function DeleteProduct(element, response) {

    Swal.fire({
        title: "Are you sure?",
        text: "You won't be able to revert this!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
        confirmButtonText: "Yes, delete it!"
    }).then(async (result) => {
        if (result.isConfirmed) {
            let List = element.dataset.list
            let Code = element.dataset.code
            // console.log("DeleteProduct", List, Code)

            let ProductList = await GetOrSetTrackerStorage("ProductList", true, true, {});
            let TrackerList = await GetOrSetTrackerStorage("TrackerList", true, false, {});
            let TrackedProductList = await GetOrSetTrackerStorage("TrackedProductList", true, false, {});

            TrackerList = TrackerList == null ? {} : TrackerList;
            TrackedProductList = TrackedProductList == null ? {} : TrackedProductList;

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
                if (TrackedProductList[Code]) {
                    delete TrackedProductList[Code];
                }
                await chrome.storage.sync.set({ ProductList: JSON.stringify(ProductList), TrackerList: JSON.stringify(TrackerList), TrackedProductList: JSON.stringify(TrackedProductList) });

                chrome.runtime.sendMessage({ action: "RefreshBadge" });

                response({ dataset: { list: List } });

                Swal.fire({
                    title: "Deleted!",
                    text: "Your list has been deleted.",
                    icon: "success"
                });

            } else {
                Swal.fire({
                    title: "Product Not Found!",
                    text: "You won't be able to delete this!",
                    icon: "warning"
                });
            }

        }
    });

}

async function InitiateEditProduct(element) {
    let List = element.dataset.list
    let Code = element.dataset.code
    // console.log("InitiateEditProduct", List, Code)

    let ProductList = await GetOrSetTrackerStorage("ProductList", true, true, {});
    let TrackerList = await GetOrSetTrackerStorage("TrackerList", true, false, {});
    TrackerList = TrackerList == null ? { default: { Name: "default", Products: [] } } : TrackerList;
    let EditProductList = document.getElementById("edit-product-list")
    EditProductList.innerHTML = "";

    for (const key in TrackerList) {
        EditProductList.innerHTML += `<option value="${key}" ${key == List ? "selected" : ""}>${key} List</option>`
    }

    if (ProductList[Code]) {
        document.getElementById("edit-product-code").value = ProductList[Code].c
        document.getElementById("edit-product-price").value = ProductList[Code].p
        document.getElementById("edit-product-frequency").value = ProductList[Code].f ? ProductList[Code].f : "4"
        document.getElementById("edit-product-active").value = ProductList[Code].a ? "1" : "0"
        document.getElementById("ModalEditProduct").innerHTML = ProductList[Code].n

        $("#modal-edit-product").modal("show")
    } else {
        Swal.fire({
            title: "Invalid Product!",
            text: "Product Not Found!",
            icon: "warning"
        });
        return;
    }
}

async function RefreshProduct(element) {
    let List = element.dataset.list
    let Code = element.dataset.code
    // console.log("RefreshProduct", List, Code)

    element.querySelector("svg").classList.add("animated-rotate");

    setTimeout(() => {
        element.querySelector("svg").classList.remove("animated-rotate");
    }, 5000);

    chrome.runtime.sendMessage({ action: "RefreshProduct", code: Code }, function (response) {
        ViewListElement({ dataset: { list: List } });
    });

}

function GetProductHTML(TrackerProduct) {
    let HTML = `
        <div class="col-6 col-lg-4 col-xl-3 px-2 mb-2 tracking-list-product">
            <div class="card bg-white border-0 shadow-sm p-2">
                <div class="row">
                    <div class="col-12">
                        <span class="small text-muted float-right">Added <b>${timeAgo(TrackerProduct.at)}</b> ago</span>
                        <br>
                        <h5 class="card-title mb-0 h6 px-2 mb-1">
                            <a href="${UrlObj.GetRedirectUrl("ext") + UrlObj.GetIdByDomain(TrackerProduct.s) + "-" + TrackerProduct.c}" target="_blank" class="small font-weight-bold text-dark" title="Check on ${TrackerProduct.s}">${TrackerProduct.n}</a>
                        </h5>
                        <a href="${UrlObj.GetRedirectUrl("ext") + UrlObj.GetIdByDomain(TrackerProduct.s) + "-" + TrackerProduct.c}" target="_blank" title="Check on ${TrackerProduct.s}" class="float-left d-none">
                            <span class="small text-muted ">${TrackerProduct.s} / ${TrackerProduct.c}</span>
                        </a>
                    </div>
                    <div class="col-12 text-center">
                        <a href="${UrlObj.GetRedirectUrl("ext") + UrlObj.GetIdByDomain(TrackerProduct.s) + "-" + TrackerProduct.c}" target="_blank" title="Check on ${TrackerProduct.s}">
                            <img src="${TrackerProduct.i ? TrackerProduct.i : "/assets/images/icon-128x128.png"}" height="150" class="card-img-top" alt="Product Image">
                        </a>
                    </div>
                    <div class="col-12">
                        <div class="card-body px-0 py-2">
                            <div class="card-text">
                                <div class="row text-muted">
                                    <div class="col-12"> 
                                        <span class="badge font-weight-bold ${TrackerProduct.a ? "badge-success" : "badge-secondary"}">${TrackerProduct.a ? "Active" : "Deactive"}</span>
                                        <span class="float-right small">Checked ${timeAgo(TrackerProduct.ct)} ago</span>
                                        <br>
                                    </div>
                                    <div class="col-12"><span class="small">Target Price:</span> <span
                                            class="text-dark font-weight-bold big"><big>₹${TrackerProduct.p}</big></span>
                                    </div>
                                    <div class="col-12"><span class="small">Last Price:</span> <span
                                            class="text-dark font-weight-bold big">₹${TrackerProduct.lp ? TrackerProduct.lp : " -- "}</span>
                                    </div>
                                </div>
                            </div>
                            <div class="d-block text-right justify-content-between mt-1">
                                <button class="btn text-warning pt-0 pb-1 px-1 u user-btn-edit" data-list="${TrackerProduct.l}" data-code="${TrackerProduct.c}" title="Edit Product">
                                    <svg height="21" viewBox="0 0 21 21" width="21"
                                        stroke-width="2" xmlns="http://www.w3.org/2000/svg">
                                        <g fill="none" fill-rule="evenodd"
                                            stroke="currentColor" stroke-linecap="round"
                                            stroke-linejoin="round"
                                            transform="translate(3 3)">
                                            <path
                                                d="m14 1c.8284271.82842712.8284271 2.17157288 0 3l-9.5 9.5-4 1 1-3.9436508 9.5038371-9.55252193c.7829896-.78700064 2.0312313-.82943964 2.864366-.12506788z" />
                                            <path d="m12.5 3.5 1 1" />
                                        </g>
                                    </svg>
                                </button>
                                <button class="btn text-danger py-0 px-1 u user-btn-delete" data-list="${TrackerProduct.l}" data-code="${TrackerProduct.c}" title="Delete Product">

                                    <svg height="21" viewBox="0 0 21 21" width="21"
                                        stroke-width="2" xmlns="http://www.w3.org/2000/svg">
                                        <g fill="none" fill-rule="evenodd"
                                            stroke="currentColor" stroke-linecap="round"
                                            stroke-linejoin="round"
                                            transform="translate(5 5)">
                                            <path d="m10.5 10.5-10-10z" />
                                            <path d="m10.5.5-10 10" />
                                        </g>
                                    </svg>
                                </button>
                                <button class="btn text-info py-0 px-1 u user-btn-refresh" data-list="${TrackerProduct.l}" data-code="${TrackerProduct.c}" title="Refresh Product Prices">

                                    <svg height="21" viewBox="0 0 21 21" width="21"
                                        stroke-width="2" xmlns="http://www.w3.org/2000/svg">
                                        <g fill="none" fill-rule="evenodd"
                                            stroke="currentColor" stroke-linecap="round"
                                            stroke-linejoin="round"
                                            transform="translate(2 2)">
                                            <path
                                                d="m4.5 1.5c-2.41169541 1.37786776-4 4.02354835-4 7 0 4.418278 3.581722 8 8 8m4-1c2.2866288-1.4081018 4-4.1175492 4-7 0-4.418278-3.581722-8-8-8" />
                                            <path d="m4.5 5.5v-4h-4" />
                                            <path d="m12.5 11.5v4h4" />
                                        </g>
                                    </svg>
                                </button>
                                
                                <button class="btn ${TrackerProduct.a ? "text-secondary user-btn-deactivate" : "text-success user-btn-activate"} py-0 px-1" data-list="${TrackerProduct.l}" data-code="${TrackerProduct.c}" title="${TrackerProduct.a ? "Deactivate Product" : "Activate Product"}">
                                    <svg height="35" viewBox="0 0 21 21" width="35" stroke-width="1" xmlns="http://www.w3.org/2000/svg"> 
                                        <g fill="none" fill-rule="evenodd" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round">
                                            <circle cx="10.5" cy="10.5" r="5"/><circle cx="10.5" cy="10.5" fill="currentColor" r="3"/>
                                        </g>
                                    </svg>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-12">
                        <div class="row">
                            <div class="col-12">
                                <a href="https://pricehistory.app/p/${TrackerProduct.url}" target="_blank"
                                    class="btn btn-sm btn-block btn-primary mt-2">Check History</a>
                            </div>
                            <div class="col-12">
                                <a href="${UrlObj.GetRedirectUrl("ext") + UrlObj.GetIdByDomain(TrackerProduct.s) + "-" + TrackerProduct.c}" target="_blank"
                                    class="btn btn-sm btn-block btn-danger mt-2">Check ${TrackerProduct.s}</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        `
    return HTML;
}

function timeAgo(timestamp) {
    const now = new Date();
    const past = new Date(timestamp);
    const secondsPast = (now.getTime() - past.getTime()) / 1000;

    if (secondsPast < 60) {
        return `${Math.floor(secondsPast)} sec`;
    } else if (secondsPast < 3600) {
        return `${Math.floor(secondsPast / 60)} min`;
    } else if (secondsPast < 86400) {
        return `${Math.floor(secondsPast / 3600)} hr`;
    } else if (secondsPast < 604800) {
        return `${Math.floor(secondsPast / 86400)} days`;
    } else if (secondsPast < 2592000) {
        return `${Math.floor(secondsPast / 604800)} weeks`;
    } else if (secondsPast < 31536000) {
        return `${Math.floor(secondsPast / 2592000)} months`;
    } else {
        return `${Math.floor(secondsPast / 31536000)} years`;
    }
}
