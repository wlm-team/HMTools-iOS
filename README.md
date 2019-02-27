# HMTools-iOS
针对weex封装的自定义工具module，（包括rsa加密，发送邮件，打开webview）

打开项目中podfile文件, 将插件路径写入 ( 默认安装最新版本 )

```
pod 'HMTools',:git => 'https://github.com/wlm-team/HMTools-iOS'
```

***

### 这里需要注意!

*要注意tag的修改, 根据最新版本下载(如果需要指定版本可固定版本号)*

*根据个人需求, 如若需固定插件版本号, 在podfile文件中配置代码后加上*
***:tag => '1.0.5'***

```
pod 'HMTools',:git => 'https://github.com/wlm-team/HMTools-iOS', :tag => '1.0.5'
```

***

上述步骤完成后, 在终端执行

```
pod install
```

成功安装后重新编译自己的项目

## HMTools插件使用

此插件基于weex-eros框架, 可直接在js端直接调用方法

```
const hmTools = weex.requireModule('hmTools')

hmTools.encryptDataByPublicKey(RSAKey, password, function (response) {
	// 返回结果为加密后的密码, 为string型
	console.log(response) 
})
```

**对密码进行RSA加密**

    参数    |     说明     |    类型 
-----------|--------------|-----------
   RSAKey  |     公钥     |   string
  password |     密码     |   string
  
---------------------------------------------------------
  
```
hmTools.sendMail(address)
```

**发送邮件**

    参数    |     说明     |    类型 
-----------|--------------|-----------
  address  |    url地址    |   string

---------------------------------------------------------

```
let config = {
	url: 'www.XXX.com',
	title: '标题',
	navShow: false,
	...
}
hmTools.toWebViewWithNoCache(config)
```

**打开web页面**

**此方法用于打开页面前需清除缓存情况**

### 参数详情

           参数            |     说明       |    类型 
--------------------------|----------------|-----------
      url                 | 页面url地址     |    string
      title               | 页面title标题   |    string
      navShow             | 是否隐藏导航栏   |    bool
      shareModel          | 分享详细信息     |    json
      shareModel.image    | 分享图片路径     |    string
      shareModel.title    | 分享标题        |    string
      shareModel.content  | 分享内容        |    string
      shareModel.url      | 分享地址        |    string
      shareModel.platform | 分享平台        |    array
 
---------------------------------------------------------

```
hmTools.scan(function(response){
	// 返回结果为二维码扫描出的数据
	console.log(response)
})
```

**扫描二维码**



