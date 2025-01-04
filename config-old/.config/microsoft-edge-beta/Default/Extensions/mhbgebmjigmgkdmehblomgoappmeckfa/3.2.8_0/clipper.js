/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	
function __webpack_require__inject_script_fix(moduleId) {
  if(installedModules[moduleId]) { return installedModules[moduleId].exports;}
var module = installedModules[moduleId] = {
 i: moduleId,
 l: false,
 exports: {}
};
const resp = modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
module.l = true;
return resp;
}
 function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__inject_script_fix(__webpack_require__.s = 13);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */,
/* 1 */,
/* 2 */,
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.bgAsk = void 0;
function bgAsk(ev, props) {
    return new Promise((accept) => {
        chrome.runtime.sendMessage({
            event: ev,
            props,
            destination: 'background',
            v2: true,
        }, (resp) => {
            accept(resp);
        });
    });
}
exports.bgAsk = bgAsk;


/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.comp2El = exports.addCss2 = exports.htmlString2El = void 0;
function htmlString2El(s) {
    var wrapper = document.createElement('div');
    wrapper.innerHTML = s;
    return wrapper.children[0];
}
exports.htmlString2El = htmlString2El;
function addCss2(rule) {
    let css = document.createElement('style');
    css.type = 'text/css';
    css.appendChild(document.createTextNode(rule)); // Support for the rest
    document.getElementsByTagName('head')[0].appendChild(css);
}
exports.addCss2 = addCss2;
function comp2El(comp, vars) {
    const el = htmlString2El(comp.html(vars));
    addCss2(typeof comp.css == 'function' ? comp.css(vars) : comp.css);
    return el;
}
exports.comp2El = comp2El;


/***/ }),
/* 5 */,
/* 6 */,
/* 7 */,
/* 8 */,
/* 9 */,
/* 10 */,
/* 11 */,
/* 12 */,
/* 13 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const InjectableClipper_1 = __webpack_require__(14);
const clipperUtil_1 = __webpack_require__(4);
const twitterMonkeyPatch_1 = __webpack_require__(15);
function throttle(fn, waitMs) {
    let last;
    let prevFn;
    let prevTimer;
    return (...args) => {
        const now = new Date();
        if (prevFn) {
            prevFn(undefined);
            clearTimeout(prevTimer);
            prevFn = null;
        }
        return new Promise((resolve) => {
            const x = last
                ? Math.max(0, waitMs - (now.getTime() - last.getTime()))
                : 0;
            prevFn = resolve;
            prevTimer = setTimeout(function () {
                last = now;
                prevFn = null;
                resolve(fn.apply(null, args));
            }, x);
        });
    };
}
function checkNodeHasIdParent(child, ids) {
    if (!child)
        return false;
    if (ids.includes(child.id))
        return true;
    return checkNodeHasIdParent(child.parentNode, ids);
}
function attachDrag(barSel, blockSel) {
    var bar = document.querySelector(barSel);
    var block = document.querySelector(blockSel);
    var initX, blockWidth, initY, mousePressX, mousePressY;
    bar.addEventListener('mousedown', function (event) {
        if (checkNodeHasIdParent(event.target, [
            `close-button-${idName}`,
            `expand-button-${idName}`,
            `list-button-${idName}`,
        ]))
            return;
        //display the hidden overlay
        const overlay = document.querySelector(`#overlay-${idName}`);
        if (overlay) {
            overlay.style.height = '100%';
            overlay.style.display = 'block';
        }
        initX = block.offsetLeft;
        initY = block.offsetTop;
        mousePressX = event.clientX;
        mousePressY = event.clientY;
        blockWidth = block.offsetWidth;
        document.body.style.cursor = 'grabbing';
        window.addEventListener('mousemove', repositionElement, false);
        //console.log("got", window.innerWidth, window.innerHeight,blockWidth);
        window.addEventListener('mouseup', function () {
            if (overlay) {
                overlay.style.height = '0%';
                overlay.style.display = 'none';
            }
            document.body.style.cursor = null;
            window.removeEventListener('mousemove', repositionElement, false);
        }, false);
    }, false);
    const repositionElement = (event) => {
        const left = Math.max(0, Math.min(window.innerWidth - blockWidth, initX + event.clientX - mousePressX));
        const top = Math.max(0, initY + event.clientY - mousePressY);
        block.style.left = left + 'px';
        block.style.top = top + 'px';
    };
}
function upsertDialog() {
    // debug if domain == "twitter" insert monkey patch 2s after
    if (['x.com', 'www.x.com', 'mobile.x.com'].includes(window.location.hostname)) {
        setTimeout(() => {
            (0, twitterMonkeyPatch_1.twitterMonkeyPatch)();
        }, 200);
    }
    let exists = document.getElementById(`dialog-${idName}`);
    if (exists)
        return false;
    let a = (0, clipperUtil_1.comp2El)(InjectableClipper_1.InjectableClipper, {
        idName: idName,
        popupUrl: popupUrl,
        showHeader: true,
        prefixId: null,
        fixed: true,
        titleInfo: null,
    });
    document.body.appendChild(a);
    attachDrag(`#dialog-top-${idName}`, `#dialog-${idName}`);
    document
        .querySelector(`#close-button-${idName}`)
        .addEventListener('click', function (e) {
        e.stopPropagation();
        e.preventDefault();
        closeDialog();
    });
    const expandButtonEl = document.querySelector(`#expand-button-${idName}`);
    expandButtonEl.addEventListener('click', function (e) {
        e.stopPropagation();
        e.preventDefault();
        expandPopup();
        setTimeout(() => {
            expandButtonEl.style.opacity = '0';
            setTimeout(() => {
                expandButtonEl.style.display = 'none';
            }, 100);
        }, 100);
    });
    // const listButtonEl = document.querySelector(
    //     `#list-button-${idName}`
    // ) as HTMLDivElement
    // listButtonEl.addEventListener('click', function (e) {
    //     e.stopPropagation()
    //     e.preventDefault()
    //     startListFeature()
    //     // setTimeout(() => {
    //     //     expandButtonEl.style.opacity = '0'
    //     //     setTimeout(() => {
    //     //         expandButtonEl.style.display = 'none'
    //     //     }, 100)
    //     // }, 100)
    // })
    return true;
}
function removeDomElem(sel) {
    const el = document.querySelector(sel);
    if (!el)
        throw `el '${sel}' not found`;
    el.parentNode.removeChild(el);
}
function closeDialog() {
    removeDomElem(`#dialog-${idName}`);
}
function resizeDialog({ width, height, silosModeEnabled }) {
    console.log('here resizing...', width, height);
    const prefixId = integration == 'quickNote' ? 'floating-' : '';
    const iframe = document.getElementById(`${prefixId}iframe-${idName}`);
    const dialog = document.getElementById(`${prefixId}dialog-${idName}`);
    if (!iframe || !dialog)
        return;
    if (height) {
        //console.log("change height",height);
        //iframe.height = height + 'px';
        iframe.style.height =
            Math.min(Math.min(window.innerHeight - 50, 720), height) + 'px';
    }
    if (width) {
        //console.log('resized',width);
        dialog.style.width = width + 'px';
    }
    // if (silosModeEnabled) {
    //     turnOnSilosMode(dialog, iframe, height)
    // } else {
    //     turnOffSilosMode(dialog, iframe)
    // }
}
function sleep(ms) {
    return new Promise((resolve) => {
        setTimeout(resolve, ms);
    });
}
function rerenderRects(rects) {
    rects.forEach((rect) => {
        const x = rect.getAttribute('width');
        rect.setAttribute('width', x);
    });
}
function turnOnSilosMode(dialog, iframe, height) {
    return __awaiter(this, void 0, void 0, function* () {
        dialog.style.clipPath = 'url(#floating-silos)';
        iframe.style.backgroundColor = 'transparent';
        const svg = document.querySelector('#floating-silos-svg');
        svg.style.display = 'none';
        svg.style.display = 'block';
        const rects = [...svg.querySelectorAll('rect')];
        yield sleep(300);
        rerenderRects(rects);
        yield sleep(300);
    });
}
function turnOffSilosMode(dialog, iframe) {
    iframe.style.backgroundColor = '#efeef5';
    if (dialog.style.clipPath != null) {
        dialog.style.clipPath = null;
    }
}
function expandPopup() {
    chrome.runtime.sendMessage({ popup: { name: 'expandPopup' } });
}
function startListFeature() {
    chrome.runtime.sendMessage({ popup: { name: 'startListFeature' } });
}
function toggleShowExandButton() {
    const btn = document.querySelector(`#expand-button-${idName}`);
    if (!btn)
        return;
    // let hidden = btn.style.display == 'none'
    btn.style.display = 'flex'; // : 'none'
    btn.style.opacity = '1'; // : '0'
}
function showListButton() {
    const btn = document.querySelector(`#list-button-${idName}`);
    if (!btn)
        return;
    // let hidden = btn.style.display == 'none'
    btn.style.display = 'flex'; // : 'none'
    btn.style.opacity = '1'; // : '0'
}
function turnOffClipperHeaderExpandButton() {
    const btn = document.querySelector(`#expand-button-${idName}`);
    if (!btn)
        return;
    btn.style.display = 'none';
    btn.style.opacity = '0';
}
function clipper() {
    let actionName = typeof action == 'string' ? action : action.action;
    switch (actionName) {
        case 'open':
            upsertDialog();
            return;
        case 'close':
            return closeDialog();
        case 'closeAndLogin':
            closeDialog();
            window.alert('In order to use the extension, please login to Notion');
            window.location.href = 'https://www.notion.so/login';
            return;
        case 'toggleShowExandButton':
            return toggleShowExandButton();
        case 'showListButton':
            return showListButton();
        case 'turnOffClipperHeaderExpandButton':
            return turnOffClipperHeaderExpandButton();
        case 'resize':
            return resizeDialog(action);
    }
}
clipper();
// let macosEventsMap = {}
// function randomId(length:number){
//     var result = '';
//     var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
//     var charactersLength = characters.length;
//     for ( var i = 0; i < length; i++ ) {
//        result += characters.charAt(Math.floor(Math.random() * charactersLength));
//     }
//     return result;
// }
// export function macOsAsk(ev: keyof MacOsEvents, props: Parameters<MacOsEvents[keyof MacOsEvents]>[0]): Promise<Awaited<ReturnType<MacOsEvents[keyof MacOsEvents]>>> {
//     const eventId = randomId(20)
//     //@ts-ignore
//     safari.extension.dispatchMessage(ev, {
//         data:props,
//         eventId,
//     });
//     return new Promise((resolve, reject) => {
//         macosEventsMap[eventId] = {resolve, reject}    
//     });
// }
// function listenMacOsEvents(){
//     console.log("listen events")
//     //@ts-ignore
//     safari.self.addEventListener("message", function(event){
//         if (event.name == "response") {
//             if (macosEventsMap[event.message.eventId]){
//                 macosEventsMap[event.message.eventId].resolve(event.message.data)
//             }
//         }
//     }, false);
// }
// console.log("DEBUG -> ask macos...")
// listenMacOsEvents();
// macOsAsk("ping",{}).then(r => {
//     console.log("DEBUG -> ask macos + response", r)
// })


/***/ }),
/* 14 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.InjectableClipper = void 0;
exports.InjectableClipper = {
    css: ({ idName }) => `
#close-button-${idName}, #list-button-${idName}, #expand-button-${idName}, #highlight-button-${idName}, #screenshot-button-${idName},#toggle-highlight-button-${idName} {
  transition: background,opacity, fill 20ms ease-in 0s !important;
  border-radius: 3px;
  cursor:pointer !important;
  background:white !important;
}

#close-button-${idName}:hover, #list-button-${idName}:hover, #expand-button-${idName}:hover, #highlight-button-${idName}:hover, #screenshot-button-${idName}:hover, #toggle-highlight-button-${idName}:hover {
background: rgba(202, 204, 206, 0.4) !important;
}

.highlightHeader--unfocused {
    box-shadow: 0px 2px 4px 0px #0000004D inset, 0px -2px 5px 0px #0000000F inset !important;
    opacity: 0.75 !important;
}

.highlightHeader--focused {
    box-shadow: none !important;
    opacity: 1 !important;
}


.iframe--focused {
    box-shadow: none !important;
    opacity: 1 !important;
}

.iframe--unfocused {
    opacity: 0.75 !important;
}

`,
    html: ({ idName, popupUrl, prefixId, fixed, showHeader, titleInfo }) => `
      <div id="dialog-${idName}" role="dialog" style="all:unset; position:relative; transition: opacity 0.04s ease 0s;background: black;border: 0px; border-radius: 5px;     box-shadow: rgba(0, 0, 0, 0.25) 0px 0px 0px 5px;clip: auto;display: block;height: auto;overflow: hidden;
      ${fixed
        ? `position: fixed;
      right: 12px;top: 12px;`
        : `position:absolute;`}
      user-select: none;width: 380px;z-index: 2147483647; background-color:transparent;">
	${!showHeader
        ? ''
        : `<div 
    id="${prefixId || ''}dialog-top-${idName}" style="all:unset; align-items: center;background-color: rgb(255, 255, 255);box-shadow: rgb(234, 234, 234) 0px -1px inset;cursor: grab; display: inline-flex;height: 40px;left: 0px;padding: 0px 8px 0px 12px;position: absolute; right: 0px;top: 0px;">
		<div style="all:unset; display: flex; align-items: center; color: rgb(51, 51, 51);  font-family: -apple-system, system-ui, BlinkMacSystemFont, &quot;Segoe UI&quot;, Roboto, Oxygen-Sans, Ubuntu, Cantarell, &quot;Helvetica Neue&quot;, sans-serif, &quot;Apple Color Emoji&quot;, &quot;Segoe UI Emoji&quot;, &quot;Segoe UI Symbol&quot;, sans-serif;    font-size: 13px;     font-weight: 500;flex: 1 1 0%;line-height: 15px;    margin: 0px;padding: 0px 0px 0px 8px;">Save to Notion${titleInfo ? ` - ${titleInfo}` : ''}
             <!--<div tabindex="0" role="button" aria-label="Enable List Feature" id="list-button-${idName}" 
     style="all:unset; color: rgba(0, 0, 0, 0.5); border-radius: 999px;cursor: pointer;padding: 6px;margin-left:4px; opacity:1;display:none;">
     <svg style="color: rgba(0, 0, 0, 0.5); display: block !important;" width="15" height="15" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 0 0 2.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 0 0-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 0 0 .75-.75 2.25 2.25 0 0 0-.1-.664m-5.8 0A2.251 2.251 0 0 1 13.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25ZM6.75 12h.008v.008H6.75V12Zm0 3h.008v.008H6.75V15Zm0 3h.008v.008H6.75V18Z" />
      </svg>
     </div>-->


        </div>
     <div style="display:flex; gap: 4px; align-items:center;"> 
     
     <div tabindex="0" role="button" aria-label="Expand web clipper" id="expand-button-${idName}" 
     style="all:unset; color: rgba(0, 0, 0, 0.5);border-radius: 999px;cursor: pointer;padding: 6px;margin-left:-2px; opacity:1;display:none;">
      <svg style="all:unset; color: rgba(0, 0, 0, 0.5); display: block !important;" width="15" height="16" viewBox="0 0 15 19" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M8.38377 2.36625C8.14936 2.13191 7.83148 2.00027 7.50002 2.00027C7.16857 2.00027 6.85068 2.13191 6.61627 2.36625L2.86627 6.11625C2.63857 6.352 2.51258 6.66776 2.51543 6.9955C2.51828 7.32325 2.64974 7.63676 2.8815 7.86852C3.11326 8.10028 3.42677 8.23174 3.75452 8.23459C4.08226 8.23744 4.39802 8.11145 4.63377 7.88375L7.50002 5.0175L10.3663 7.88375C10.602 8.11145 10.9178 8.23744 11.2455 8.23459C11.5733 8.23174 11.8868 8.10028 12.1185 7.86852C12.3503 7.63676 12.4818 7.32325 12.4846 6.9955C12.4875 6.66776 12.3615 6.352 12.1338 6.11625L8.38377 2.36625Z" fill="currentColor"/>
        <path d="M10.3662 11.1163L7.49998 13.9825L4.63373 11.1163C4.51842 10.9969 4.38049 10.9016 4.22799 10.8361C4.07548 10.7706 3.91146 10.7361 3.74548 10.7347C3.57951 10.7332 3.41491 10.7649 3.26129 10.8277C3.10767 10.8906 2.9681 10.9834 2.85074 11.1008C2.73337 11.2181 2.64055 11.3577 2.5777 11.5113C2.51485 11.6649 2.48322 11.8295 2.48467 11.9955C2.48611 12.1615 2.52059 12.3255 2.5861 12.478C2.65161 12.6305 2.74684 12.7684 2.86623 12.8838L6.61623 16.6338C6.85064 16.8681 7.16852 16.9997 7.49998 16.9997C7.83143 16.9997 8.14932 16.8681 8.38373 16.6338L12.1337 12.8838C12.2531 12.7684 12.3483 12.6305 12.4139 12.478C12.4794 12.3255 12.5139 12.1615 12.5153 11.9955C12.5167 11.8295 12.4851 11.6649 12.4223 11.5113C12.3594 11.3577 12.2666 11.2181 12.1492 11.1008C12.0319 10.9834 11.8923 10.8906 11.7387 10.8277C11.5851 10.7649 11.4205 10.7332 11.2545 10.7347C11.0885 10.7361 10.9245 10.7706 10.772 10.8361C10.6195 10.9016 10.4815 10.9969 10.3662 11.1163Z" fill="currentColor"/>
      </svg>
     </div>

      <div tabindex="0" role="button" aria-label="Close web clipper" id="close-button-${idName}" 
      style="all:unset; color: rgba(0, 0, 0, 0.5);border-radius: 999px;cursor: pointer;padding: 6px;margin-left:-2px;">
        <svg style="all:unset; display: block !important;" width="16" height="16" viewBox="0 0 16 16"
          xmlns="http://www.w3.org/2000/svg">
          <path fill-rule="evenodd" clip-rule="evenodd" d="M13.0539 4.55972C13.2434 4.37015 13.2432 4.05082 13.0461 3.85373L12.3456 3.15325C12.1401 2.94773 11.8325 2.95269 11.6396 3.14551L8.09968 6.68547L4.55972 3.14551C4.37015 2.95593 4.05082 2.95616 3.85373 3.15325L3.15325 3.85373C2.94773 4.05925 2.95269 4.36691 3.14551 4.55972L6.68547 8.09968L3.14551 11.6396C2.95593 11.8292 2.95616 12.1485 3.15325 12.3456L3.85373 13.0461C4.05925 13.2516 4.36691 13.2467 4.55972 13.0539L8.09968 9.5139L11.6396 13.0539C11.8292 13.2434 12.1485 13.2432 12.3456 13.0461L13.0461 12.3456C13.2516 12.1401 13.2467 11.8325 13.0539 11.6396L9.5139 8.09968L13.0539 4.55972Z" fill="currentColor"></path>
        </svg>
      </div>
    </div>
	</div>`}
  <iframe id="${prefixId || ''}iframe-${idName}" src="${popupUrl}" 
  sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-modals"
  class="iframe--focused"
  style="all:unset; border: 0px;clip: auto;display: block;height: 250px;margin-top: ${!showHeader ? '0px' : '40px'};width: 100%; background:white;opacity:1;transition: opacity 0.4s ease 0s;background-color:#efeef5;color-scheme: none !important;"></iframe>

  <svg id="floating-silos-svg" height="100%" width="100%" style="display: flex;position: absolute;top: 0px;left: 0px;z-index:-1;">
  <defs>
    <clipPath id="floating-silos">
      <rect y="-5" x="-5" width="calc(100% + 10px)" height="calc(100% + 10px - 50px - 20px)" rx="10"></rect>
      <rect y="calc(100% - 50px - 5px)" x="-5" width="calc(100% + 10px)" height="calc(50px + 10px)" background="" rx="10"></rect>
      <rect y="0" x="0" width="100%" height="100%"></rect>
    </clipPath>
</defs>
</svg>

  <div id="overlay-${idName}" style="position: absolute; top: 0; display: none; height: 0%; left: 0px; width: 100%; z-index: 2147483646;"></div>
</div>
      `,
};


/***/ }),
/* 15 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
exports.twitterMonkeyPatch = void 0;
const bgAsk_1 = __webpack_require__(3);
const twitterMonkeyPatch = () => {
    console.log('twitterMonkeyPatch');
    var script = document.createElement('script');
    script.src = chrome.runtime.getURL('assets/twitterMonkeyPatch.js');
    ;
    (document.head || document.documentElement).appendChild(script);
    script.remove();
    window.addEventListener('updateHeaders', (x) => {
        console.log('updateTwitterSession', x.detail);
        (0, bgAsk_1.bgAsk)('updateTwitterSession', x.detail);
    });
};
exports.twitterMonkeyPatch = twitterMonkeyPatch;


/***/ })
/******/ ]);