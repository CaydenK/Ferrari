
var uniqueId = 1;
// const handlers = {};
const ParamsType = {
    input: 0,
    func: 1
}


var ferrari = window.ferrari = {
    callNative: (className, selector, params, returnType) => {
        params.forEach(paramItem => {
            if (paramItem["type"] === ParamsType.func) {
                var callbackID = 'cb_' + (uniqueId++) + '_' + new Date().getTime();
                FRREvent.addHandler(selector, callbackID, paramItem["content"]);
                paramItem["content"] = callbackID;//修改值
            }
        });
        var message = { "className": className, "selectorName": selector, "params": params, "returnType": returnType };
        // window.webkit.messageHandlers.Ferrari.postMessage(message);
        var msgJSON = JSON.stringify(message);

        var resultJSON = null;
        if (window.FRRWebEngine === 0) {
            resultJSON = prompt("ferrariBridge_24F20539", msgJSON);
        } else if (window.FRRWebEngine === 1) {
            resultJSON = FerrariNative.jsbridgeNativeDisposeWithMesage(msgJSON);
        }
        var result = JSON.parse(resultJSON);
        if (result["code"] === 1) {
            return result["data"];
        } else {
            return null
        }
    },
    callJS: (selector, callbackID, params) => {
        FRREvent.execHandler(selector, callbackID, params);
        FRREvent.removeHandler(selector);
    },
    canIUse: (str) => {
        if (objectHas(ferrari.builtInCanIUseData, str)) { return true; }
        return objectHas(ferrari.canIUseData, str);
    }
}

function objectHas(obj, path) {
    const p = path.split('.');
    let current = obj;
    const l = p.length;
    for (let i = 0; i < l; i++) {
        if (!current) {
            return false;
        }
        if (i === l - 1) {
            return p[i] in current;
        }
        current = current[p[i]];
    }
    return true;
}

var FRREvent = {
    _handlers: {},
    addHandler: function (selector, handlerID, handler) {
        if (typeof selector === 'string' && typeof handlerID === 'string' && typeof handler === 'function') {
            var functions = this._handlers[selector];
            if (typeof functions !== 'object') {
                functions = {};
                this._handlers[selector] = functions;
            }
            functions[handlerID] = handler;
        }
    },
    execHandler: function (selector, handlerID, params) {
        var functions = this._handlers[selector];
        if (typeof functions === 'object') {
            var handler = functions[handlerID];
            if (typeof handler === 'function') {
                handler(params["data"]);
            }
        }
    },
    removeHandler: function (selector) {
        if (typeof selector === 'string') {
            delete this._handlers[selector];
        }
    },
    removeAllHandler: function () {
        this._handlers = {};
    }
}

ferrari.builtInCanIUseData = {
    "setDiskCache": {
        "return": {},
        "htmlPath": {},
        "cacheKey": {},
        "dataValue": {}
    },
    "getDiskCache": {
        "return": {},
        "htmlPath": {},
        "cacheKey": {}
    },
    "setMemoryCache": {
        "return": {},
        "cacheKey": {},
        "cacheObj": {}
    },
    "getMemoryCache": {
        "return": {},
        "cacheKey": {}
    }
}

ferrari.setDiskCache = function (htmlPath, cacheKey, dataValue) {
    className = "FRRJSCachePlugin";
    selector = "setDiskCache:cacheKey:dataValue:";
    params = [{ "type": 0, "class": "NSString", "content": htmlPath }, { "type": 0, "class": "NSString", "content": cacheKey }, { "type": 0, "class": "NSString", "content": dataValue }];
    this.callNative(className, selector, params, 'null');
}


ferrari.getDiskCache = function (htmlPath, cacheKey) {
    className = "FRRJSCachePlugin";
    selector = "getDiskCache:cacheKey:";
    params = [{ "type": 0, "class": "NSString", "content": htmlPath }, { "type": 0, "class": "NSString", "content": cacheKey }];
    return this.callNative(className, selector, params, 'id');
}


ferrari.setMemoryCache = function (cacheKey, cacheObj) {
    className = "FRRJSCachePlugin";
    selector = "setMemoryCache:cacheObj:";
    params = [{ "type": 0, "class": "NSString", "content": cacheKey }, { "type": 0, "class": "id", "content": cacheObj }];
    this.callNative(className, selector, params, 'null');
}


ferrari.getMemoryCache = function (cacheKey) {
    className = "FRRJSCachePlugin";
    selector = "getMemoryCache:";
    params = [{ "type": 0, "class": "NSString", "content": cacheKey }];
    return this.callNative(className, selector, params, 'id');
}
