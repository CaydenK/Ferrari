# Ferrari简介

**若要使用WKWebView，请先移除URLProtocol的拦截，post 丢 body的问题暂未解决**

Ferrari框架包含
为了降低原生方法翻译到js方法，并提供简洁且符合iOS/Android/JS的API风格的API调用方式，所以使用编译脚本/编译时AOP的方式，通过原生方法生成js方法提供调用。
[Android库](https://github.com/snailycy/AndroidHybridLib)

例如：
- iOS原生方法定义

```objc
+ (HSATestOutput *)allTypeWithInput:(HSATestInput *)inputParam abcabc:(void(^)(NSString *))completion FRRJSMethod {
    completion(@"2fjhsdjfkl32j2lkj3rl2l3jl2j3lkj23kl2jl32j");
    return [HSATestOutput testObject];
}
```

- JS调用方法
```js
var returnValue = window.ferrari.allTypeWithInput({"propertyName1":"value1","propertyName2":23333},(output)=>{
    console.log("completion:",output);
});
console.log("return:",returnValue);
```


## 集成
### iOS
iOS使用pod方式集成到工程
pod 暂未加入公有source

```ruby
pod 'Ferrari'
```
并在podfile中，通过post_install配置xcode target环境变量，来指定Hybrid的JSExport的工作文件夹
```ruby
post_install do |installer|
    ferrari_bridge_path = '${PODS_ROOT}/../Ferrari/FRRJSExport'
    installer.pods_project.targets.each do |target|
        if target.name == "Ferrari"
            target.build_configurations.each do |config|
                config.build_settings['FERRARI_WORK_PATH'] = ferrari_bridge_path
            end
        end
    end
end
```
**要求：所有JSExport的内容（类、方法、参数类型定义）都必须在该文件夹下**

## JS集成
iOS会直接将bridge对象注入到window对象，不需要js额外支持。


# API 定义

**iOS/Android方法名必须一样,参数名也必须一样**<br />
**iOS/Android方法名必须一样,参数名也必须一样**<br />
**iOS/Android方法名必须一样,参数名也必须一样**<br />

重要的事情说3遍 ~~不然等着被前端的哥哥姐姐揍吧~~

iOS：
- 扩展类定义须继承`NSObject`且继承`FRRJSExport`协议
- 协议可以在`Class`、`Category`、`Extension`中,就可以被接受为扩展类了。(当扩展类通过`Category`、`Extension`来继承`FRRJSExport`，该扩展类可不强制继承`NSObject`,但无视其父类中的扩展方法)
- iOS的方法定义，需要定义扩展类中，且定义在`implementation`中的方法为准，且需要方法添加`FRRJSMethod`宏的标识。
- 参数可以任意个数，但是当参数为block时，block的参数只能有**1个**参数或者**无参数**
- 第一个参数前的为方法名，必须为类方法，不支持对象方法
如：

```objc
@interface FRRTestObject : NSObject <FRRJSExport>
@end
@implementation FRRTestObject
+ (HSATestOutput *)allTypeWithInput:(HSATestInput *)inputParam abcabc:(void(^)(NSString *))completion FRRJSMethod {
    completion(@"2fjhsdjfkl32j2lkj3rl2l3jl2j3lkj23kl2jl32j");
    return [HSATestOutput testObject];
}
@end
```

该代码定义了一个方法名为`allTypeWithInput`的方法，该方法有两个参数，一个返回值，返回值为自定义的`HSATestOutput`类型，参数`inputParam`为自定义的`HSATestInput`类型，参数`completion`为参数为`NSString`类型的block

则JS调用代码为：

```js
var returnValue = window.ferrari.allTypeWithInput({"propertyName":"value1",propertyName:23333},(output)=>{
    console.log("completion:",output);
});
console.log("return:",returnValue);
```

注意点：

0. 大小写敏感
0. 禁止在不同的扩展类里面，定义两个相同函数名的扩展方法
0. 返回值、参数都可被json序列化，并且由于JS的json有大小限制，不接受过大参数
0. 当方法没有`FRRJSMethod`标志，则不认为是需要翻译成js的方法
0. 理论上接受任意类型的参数，但是只有自定义类型的时候，`canIUse`方法才能解析参数的某个属性是否支持，并且自定义参数类型的属性，不能为block


# canIUse方法

## 函数定义
```javascript
boolean ferrari.canIUse(string keyPath)
```

判断API、返回值、回调、参数等是否在当前版本可用

| 方法名  | 参数    | 返回值  |
|:---     |:---     |:---     |
|`canIUse`|`string` |`boolean`|

## 参数：

使用`${api}.${param}.${property}` 方式使用

## 返回值
boolean

判断当前版本是否可用

## 参数说明

1. `${api}`: 代表API名
1. `${param}`：参数名或者return
1. `${property}`：参数或return的对象是否有此属性

## 示例代码
```javascript
ferrari.canIUse('allTypeWithInput')
ferrari.canIUse('allTypeWithInput.return')
ferrari.canIUse('allTypeWithInput.inputParam')
```

# TODO
- [ ] 使用clang来解析原生代码
- [ ] hook XMLHTTPRequest类，解决WKWebView的post 丢 body问题
