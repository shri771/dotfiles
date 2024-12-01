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
/******/ 	return __webpack_require__inject_script_fix(__webpack_require__.s = 21);
/******/ })
/************************************************************************/
/******/ ({

/***/ 0:
/***/ (function(module, exports, __webpack_require__) {

"use strict";

// License: MIT
// Author: Anton Medvedev <anton@medv.io>
// Source: https://github.com/antonmedv/finder
Object.defineProperty(exports, "__esModule", { value: true });
exports.finder = void 0;
let config;
let rootDocument;
function finder(input, options) {
    if (input.nodeType !== Node.ELEMENT_NODE) {
        throw new Error(`Can't generate CSS selector for non-element node type.`);
    }
    if ('html' === input.tagName.toLowerCase()) {
        return 'html';
    }
    const defaults = {
        root: document.body,
        idName: (name) => true,
        className: (name) => true,
        tagName: (name) => true,
        attr: (name, value) => false,
        seedMinLength: 1,
        optimizedMinLength: 2,
        threshold: 1000,
        maxNumberOfTries: 10000,
    };
    config = Object.assign(Object.assign({}, defaults), options);
    rootDocument = findRootDocument(config.root, defaults);
    let path = bottomUpSearch(input, 'all', () => bottomUpSearch(input, 'two', () => bottomUpSearch(input, 'one', () => bottomUpSearch(input, 'none'))));
    if (path) {
        const optimized = sort(optimize(path, input));
        if (optimized.length > 0) {
            path = optimized[0];
        }
        return selector(path);
    }
    else {
        throw new Error(`Selector was not found.`);
    }
}
exports.finder = finder;
function findRootDocument(rootNode, defaults) {
    if (rootNode.nodeType === Node.DOCUMENT_NODE) {
        return rootNode;
    }
    if (rootNode === defaults.root) {
        return rootNode.ownerDocument;
    }
    return rootNode;
}
function bottomUpSearch(input, limit, fallback) {
    let path = null;
    let stack = [];
    let current = input;
    let i = 0;
    while (current) {
        let level = maybe(id(current)) ||
            maybe(...attr(current)) ||
            maybe(...classNames(current)) ||
            maybe(tagName(current)) || [any()];
        const nth = index(current);
        if (limit == 'all') {
            if (nth) {
                level = level.concat(level.filter(dispensableNth).map((node) => nthChild(node, nth)));
            }
        }
        else if (limit == 'two') {
            level = level.slice(0, 1);
            if (nth) {
                level = level.concat(level.filter(dispensableNth).map((node) => nthChild(node, nth)));
            }
        }
        else if (limit == 'one') {
            const [node] = (level = level.slice(0, 1));
            if (nth && dispensableNth(node)) {
                level = [nthChild(node, nth)];
            }
        }
        else if (limit == 'none') {
            level = [any()];
            if (nth) {
                level = [nthChild(level[0], nth)];
            }
        }
        for (let node of level) {
            node.level = i;
        }
        stack.push(level);
        if (stack.length >= config.seedMinLength) {
            path = findUniquePath(stack, fallback);
            if (path) {
                break;
            }
        }
        current = current.parentElement;
        i++;
    }
    if (!path) {
        path = findUniquePath(stack, fallback);
    }
    if (!path && fallback) {
        return fallback();
    }
    return path;
}
function findUniquePath(stack, fallback) {
    const paths = sort(combinations(stack));
    if (paths.length > config.threshold) {
        return fallback ? fallback() : null;
    }
    for (let candidate of paths) {
        if (unique(candidate)) {
            return candidate;
        }
    }
    return null;
}
function selector(path) {
    let node = path[0];
    let query = node.name;
    for (let i = 1; i < path.length; i++) {
        const level = path[i].level || 0;
        if (node.level === level - 1) {
            query = `${path[i].name} > ${query}`;
        }
        else {
            query = `${path[i].name} ${query}`;
        }
        node = path[i];
    }
    return query;
}
function penalty(path) {
    return path.map((node) => node.penalty).reduce((acc, i) => acc + i, 0);
}
function unique(path) {
    const css = selector(path);
    switch (rootDocument.querySelectorAll(css).length) {
        case 0:
            throw new Error(`Can't select any node with this selector: ${css}`);
        case 1:
            return true;
        default:
            return false;
    }
}
function id(input) {
    const elementId = input.getAttribute('id');
    if (elementId && config.idName(elementId)) {
        return {
            name: '#' + CSS.escape(elementId),
            penalty: 0,
        };
    }
    return null;
}
function attr(input) {
    const attrs = Array.from(input.attributes).filter((attr) => config.attr(attr.name, attr.value));
    return attrs.map((attr) => ({
        name: `[${CSS.escape(attr.name)}="${CSS.escape(attr.value)}"]`,
        penalty: 0.5,
    }));
}
function classNames(input) {
    const names = Array.from(input.classList).filter(config.className);
    return names.map((name) => ({
        name: '.' + CSS.escape(name),
        penalty: 1,
    }));
}
function tagName(input) {
    const name = input.tagName.toLowerCase();
    if (config.tagName(name)) {
        return {
            name,
            penalty: 2,
        };
    }
    return null;
}
function any() {
    return {
        name: '*',
        penalty: 3,
    };
}
function index(input) {
    const parent = input.parentNode;
    if (!parent) {
        return null;
    }
    let child = parent.firstChild;
    if (!child) {
        return null;
    }
    let i = 0;
    while (child) {
        if (child.nodeType === Node.ELEMENT_NODE) {
            i++;
        }
        if (child === input) {
            break;
        }
        child = child.nextSibling;
    }
    return i;
}
function nthChild(node, i) {
    return {
        name: node.name + `:nth-child(${i})`,
        penalty: node.penalty + 1,
    };
}
function dispensableNth(node) {
    return node.name !== 'html' && !node.name.startsWith('#');
}
function maybe(...level) {
    const list = level.filter(notEmpty);
    if (list.length > 0) {
        return list;
    }
    return null;
}
function notEmpty(value) {
    return value !== null && value !== undefined;
}
function* combinations(stack, path = []) {
    if (stack.length > 0) {
        for (let node of stack[0]) {
            yield* combinations(stack.slice(1, stack.length), path.concat(node));
        }
    }
    else {
        yield path;
    }
}
function sort(paths) {
    return [...paths].sort((a, b) => penalty(a) - penalty(b));
}
function* optimize(path, input, scope = {
    counter: 0,
    visited: new Map(),
}) {
    if (path.length > 2 && path.length > config.optimizedMinLength) {
        for (let i = 1; i < path.length - 1; i++) {
            if (scope.counter > config.maxNumberOfTries) {
                return; // Okay At least I tried!
            }
            scope.counter += 1;
            const newPath = [...path];
            newPath.splice(i, 1);
            const newPathKey = selector(newPath);
            if (scope.visited.has(newPathKey)) {
                return;
            }
            if (unique(newPath) && same(newPath, input)) {
                yield newPath;
                scope.visited.set(newPathKey, true);
                yield* optimize(newPath, input, scope);
            }
        }
    }
}
function same(path, input) {
    return rootDocument.querySelector(selector(path)) === input;
}


/***/ }),

/***/ 21:
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
const finder_1 = __webpack_require__(0);
function rgbToHex(r, g, b) {
    return '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
}
function realColor(elem) {
    const col = window.getComputedStyle(elem, null).getPropertyValue('color');
    if (col.startsWith('rgb')) {
        try {
            const [r, g, b] = col
                .match(/\((.*)\)/)[1]
                .split(',')
                .map((e) => parseInt(e));
            return rgbToHex(r, g, b);
        }
        catch (e) { }
    }
    return '#000';
}
const colorsMap = {
    /*
        default or yellow: #FFE7A3
        --notion-red_background: rgb(251, 228, 228);
        --notion-pink_background: rgb(244, 223, 235);
        --notion-blue_background: rgb(221, 235, 241);
        --notion-purple_background: rgb(234, 228, 242);
        --notion-teal_background: rgb(221, 237, 234);
        // --notion-yellow_background: rgb(251, 243, 219);
        --notion-orange_background: rgb(250, 235, 221);
        --notion-brown_background: rgb(233, 229, 227);
        --notion-gray_background: rgb(235, 236, 237);
    */
    light: {
        default: '#FFE7A3',
        yellow_background: '#FFE7A3',
        red_background: 'rgb(251, 228, 228)',
        pink_background: 'rgb(244, 223, 235)',
        blue_background: 'rgb(221, 235, 241)',
        purple_background: 'rgb(234, 228, 242)',
        teal_background: 'rgb(221, 237, 234)',
        // yellow_background: 'rgb(251, 243, 219)',
        orange_background: 'rgb(250, 235, 221)',
        brown_background: 'rgb(233, 229, 227)',
        gray_background: 'rgb(235, 236, 237)',
    },
    /*
default or yellow: #99844c
--notion-red_background: rgb(89, 65, 65);
--notion-pink_background: rgb(83, 59, 76);
--notion-blue_background: rgb(54, 73, 84);
--notion-purple_background: rgb(68, 63, 87);
--notion-teal_background: rgb(53, 76, 75);
--notion-yellow_background: rgb(89, 86, 59);
--notion-orange_background: rgb(89, 74, 58);
--notion-brown_background: rgb(67, 64, 64);
--notion-gray_background: rgb(69, 75, 78);
*/
    dark: {
        default: '#99844c',
        yellow_background: '#99844c',
        red_background: 'rgb(89, 65, 65)',
        pink_background: 'rgb(83, 59, 76)',
        blue_background: 'rgb(54, 73, 84)',
        purple_background: 'rgb(68, 63, 87)',
        teal_background: 'rgb(53, 76, 75)',
        // yellow_background: 'rgb(89, 86, 59)',
        orange_background: 'rgb(89, 74, 58)',
        brown_background: 'rgb(67, 64, 64)',
        gray_background: 'rgb(69, 75, 78)',
    },
};
function haveDarkText(elem) {
    let c = realColor(elem);
    c = c.substring(1); // strip #
    var rgb = parseInt(c, 16); // convert rrggbb to decimal
    var r = (rgb >> 16) & 0xff; // extract red
    var g = (rgb >> 8) & 0xff; // extract green
    var b = (rgb >> 0) & 0xff; // extract blue
    var luma = 0.2126 * r + 0.7152 * g + 0.0722 * b; // per ITU-R BT.709
    return luma < 160;
}
function highlightRange(range, highlightId) {
    var _a;
    var newNode = document.createElement('highlight');
    const highlight = __highlights.find((h) => h.id === highlightId);
    const highlightColor = (_a = highlight === null || highlight === void 0 ? void 0 : highlight.highlightColor) !== null && _a !== void 0 ? _a : "default";
    newNode.setAttribute('x-id', highlightId.replace(/-/g, ''));
    const isDarkText = haveDarkText(range.startContainer.parentNode);
    newNode.setAttribute('style', `background-color: ${isDarkText ? colorsMap.light[highlightColor] : colorsMap.dark[highlightColor]}; display: inline;`);
    range.surroundContents(newNode);
}
function removeSelection(highlightId) {
    const highlightNodes = document.querySelectorAll(`highlight[x-id="${highlightId.replace(/-/g, '')}"]`);
    // console.log('remove', highlightId, highlightNodes)
    highlightNodes.forEach((highlightNode) => {
        const parent = highlightNode.parentNode;
        while (highlightNode.firstChild) {
            parent.insertBefore(highlightNode.firstChild, highlightNode);
        }
        parent.removeChild(highlightNode);
    });
}
function getContainerOrText(css, isText) {
    const x = document.querySelector(css);
    if (x && isText) {
        return x.childNodes[0];
    }
    return x;
}
function getRangeFromSelectionRangePresentation(range) {
    const rangeObject = new Range();
    rangeObject.setStart(getContainerOrText(range.startContainerCss, range.startContainerIsText), range.startOffset);
    rangeObject.setEnd(getContainerOrText(range.endContainerCss, range.endContainerIsText), range.endOffset);
    return rangeObject;
}
function getSafeRanges(dangerous) {
    var a = dangerous.commonAncestorContainer;
    // Starts -- Work inward from the start, selecting the largest safe range
    var s = new Array(0), rs = new Array(0);
    if (dangerous.startContainer != a)
        for (var i = dangerous.startContainer; i != a; i = i.parentNode)
            s.push(i);
    if (0 < s.length)
        for (var i = 0; i < s.length; i++) {
            var xs = document.createRange();
            if (i) {
                xs.setStartAfter(s[i - 1]);
                xs.setEndAfter(s[i].lastChild);
            }
            else {
                xs.setStart(s[i], dangerous.startOffset);
                xs.setEndAfter(s[i].nodeType == Node.TEXT_NODE ? s[i] : s[i].lastChild);
            }
            rs.push(xs);
        }
    // Ends -- basically the same code reversed
    var e = new Array(0), re = new Array(0);
    if (dangerous.endContainer != a)
        for (var i = dangerous.endContainer; i != a; i = i.parentNode)
            e.push(i);
    if (0 < e.length)
        for (var i = 0; i < e.length; i++) {
            var xe = document.createRange();
            if (i) {
                xe.setStartBefore(e[i].firstChild);
                xe.setEndBefore(e[i - 1]);
            }
            else {
                xe.setStartBefore(e[i].nodeType == Node.TEXT_NODE ? e[i] : e[i].firstChild);
                xe.setEnd(e[i], dangerous.endOffset);
            }
            re.unshift(xe);
        }
    // Middle -- the uncaptured middle
    if (0 < s.length && 0 < e.length) {
        var xm = document.createRange();
        xm.setStartAfter(s[s.length - 1]);
        xm.setEndBefore(e[e.length - 1]);
    }
    else {
        return [dangerous];
    }
    // Concat
    rs.push(xm);
    let response = rs.concat(re);
    // Send to Console
    return response;
}
function findAllHighlights() {
    const highlights = __highlights;
    highlights.forEach((highlight) => {
        if (!highlight.selectionRange) {
            return;
        }
        try {
            const range = getRangeFromSelectionRangePresentation(highlight.selectionRange);
            // console.log('try to find', highlight, range)
            addHighlightColorToSelectionRange(range, highlight.id);
        }
        catch (e) {
            // console.log('error', e)
            // ignore for now
        }
    });
}
function getNodeCss(node) {
    if (node.nodeType == Node.TEXT_NODE) {
        return getNodeCss(node.parentNode);
    }
    return (0, finder_1.finder)(node);
}
function getSelectionRangeRepresentation() {
    const selRange = window.getSelection().getRangeAt(0);
    const commonAncestorContainerCss = getNodeCss(selRange.commonAncestorContainer);
    const startContainerCss = selRange.startContainer == selRange.commonAncestorContainer
        ? commonAncestorContainerCss
        : getNodeCss(selRange.startContainer);
    const endContainerCss = selRange.endContainer == selRange.commonAncestorContainer
        ? commonAncestorContainerCss
        : selRange.endContainer == selRange.startContainer
            ? startContainerCss
            : getNodeCss(selRange.endContainer);
    if (!commonAncestorContainerCss || !startContainerCss || !endContainerCss)
        return null;
    return {
        type: 'range',
        collapsed: selRange.collapsed,
        commonAncestorContainerCss,
        commonAncestorContainerIsText: selRange.commonAncestorContainer.nodeType == Node.TEXT_NODE,
        endContainerCss,
        endContainerIsText: selRange.endContainer.nodeType == Node.TEXT_NODE,
        startContainerCss,
        startContainerIsText: selRange.startContainer.nodeType == Node.TEXT_NODE,
        startOffset: selRange.startOffset,
        endOffset: selRange.endOffset,
    };
}
function addHighlightColorToSelectionRange(range, highlightId) {
    var safeRanges = getSafeRanges(range);
    for (var i = 0; i < safeRanges.length; i++) {
        highlightRange(safeRanges[i], highlightId);
    }
}
function highlightSelection() {
    if (window.location.href.endsWith('.pdf')) {
        return;
    }
    if (__action == 'getSelectionRangeRepresentation') {
        return getSelectionRangeRepresentation();
    }
    if (__action == 'removeSelection') {
        return removeSelection(__highlightId);
    }
    if (__highlights) {
        return findAllHighlights();
    }
    var userSelection = window.getSelection();
    addHighlightColorToSelectionRange(userSelection.getRangeAt(0), __highlightId);
    window.getSelection().removeAllRanges();
}
// @ts-ignore
const response = highlightSelection();
return response;


/***/ })

/******/ });