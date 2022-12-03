# Azure上通过Functions实现httpdns的简易思路
## 引言
DNS（域名系统）是工作生活中很常见的名词，用户只需要在浏览器中输入一个可识别的网址，系统便会在很短的时间内找到相应的 IP 地址。在解析过程中，DNS 会访问各种名称服务器，从这些名称服务器中获取存储着的与 URL 对应的数字地址。截止到现在，DNS 已经发展了几十年，虽然使用广泛，却很少引起人们对其安全性的关注。从安全角度来看，请求传输时通常不进行任何加密，任何人都可以读取的 DNS 其实是不安全的。这意味着网络罪犯可以很容易地使用自己的服务器拦截受害者的 DNS，将用户的请求跳转到钓鱼网站上，这些网站发布恶意软件，或在正常网站上投放大量广告吸引用户，这种行为我们称之为 DNS 劫持。
## 场景假设
设想一下，当我们坐在咖啡馆上网，是否曾经会出现这样的情况，在打开www.baidu.com的时候，页面突然跳转到了咖啡馆的主页，或者某广告页面。或者我们在公司，机场的WiFi环境下打开某个网页游戏时，部分资源总是加载不出来，而换到家里的网络时却可以正常加载。出现诸如此类的情况，有很大可能性都是您的DNS解析过程被运营商/公司的Local DNS劫持了，它篡改/禁止了你的DNS解析记录，导致资源加载错误或无法加载。

## DNS工作原理
![](https://cdn.nlark.com/yuque/0/2022/png/1303094/1667792261763-8cf40f34-6cab-4287-8929-9833848548d8.png#averageHue=%23ebeae8&clientId=u65f88f02-e024-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=ud5e0f338&margin=%5Bobject%20Object%5D&originHeight=568&originWidth=1097&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=none&taskId=u5e0b8b43-6131-49eb-a44b-78caf6aa4bc&title=)

首先我们围观一下正常的DNS解析过程
(1) 举个例子，当我们使用浏览器试图访问 abc.nook.com, 浏览器会调用设备操作系统的DNS 查询功能，向Local DNS resolver 发起查询请求，"what is the IP address of  abc.nook.com?"。
(2) Local DNS（服务器地址一般是由运营商分配或者由企业通过DHCP统一分配给设备）会向根域名服务器中查找顶级域名服务器的NS记录和 A记录 （根域名服务器返回负责顶级域名服务器.com的IP地址列表。
(3) Local DNS服务器发送请求，从顶级域名服务器中查找权限域名服务器的NS记录和A记录（顶级域名服务器返回负责权限域名服务器.nook的IP地址列表）。
(4) 本地DNS服务器发送请求，从权限域名服务器中查找对应主机名的IP地址列表，然后将解析得到的结果缓存以便备查，并将其返回给浏览器。

## DNS 如何被劫持
![](https://cdn.nlark.com/yuque/0/2022/jpeg/1303094/1669523695524-563a10c6-8522-4cd4-a4eb-05819962afb3.jpeg#averageHue=%23dae3f2&clientId=u873900c0-9f77-4&crop=0&crop=0&crop=0.9987&crop=0.9131&from=paste&height=406&id=u3ab194f3&margin=%5Bobject%20Object%5D&originHeight=500&originWidth=791&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=stroke&taskId=u3284ffdd-cc20-4916-8961-aabff13da2c&title=&width=642)

我们继续来分析DNS解析异常的情况，
当浏览器执行上述过程(1)时，Local DNS Resolver 会将DNS查询请求交给运营商或公司DNS的Local DNS resolver，运营商或公司会根据未加密的域名请求的明文，通过黑名单过滤DNS请求的域名，如果未匹配则放行继续执行过程2，如果匹配上，则可以禁止域名返回，或者返回运营商/企业修改过的IP地址，即DNS解析的A记录。通过上述办法，运营商/企业可以控制是否放行DNS请求，即构成DNS劫持或DNS 污染。

_**业界专家目前在讨论基于 HTTPS 的 DNS（DoH）的可行性选择。那么什么是通过 HTTPS 的 DNS，它可以使 Internet 更安全吗？我们一起来看看吧。**_
## 如何防止DNS被污染
当前方式DNS被污染主要由两种手段，第一，借助DNSSec，DNSSEC可以依靠数字签名保证DNS应答报文的真实性和完整性。第二，使用DoH（DNS over Http），即Httpdns，简单来说就是将DNS请求封装到http报文里面，直接去DoH server 请求结果，从而绕过Local DNS resolver 和运营商DNS 服务器，同时可以叠加https 的加密措施，即DoT，保证请求报文的端到端加密。
## DoH 的优点
DoH 的加密措施可防止窃听或拦截 DNS 查询，优点是显而易见的，该技术提高了安全性并保护了用户隐私。与传统的 DNS 相比，DoH 提供了加密措施。它利用 HTTPS 这种行业通用的安全协议，将 DNS 请求发往 DNS 服务器，这样运营商或第三方在整个传输过程中，只能知道发起者和目的地，除此以外别的什么都知道，甚至都不知道我们发起了 DNS 请求。

## 通过 HTTPS 的 DNS 如何工作？
通常一些域名解析请求会直接从用户的客户端发起，相应的域名信息被保存在浏览器或路由器的缓存中。而期间传输的所有内容都需要通过 UDP 连接，因为这样可以更快速地交换信息。但是我们都知道，UDP 既不安全也不可靠。使用该协议是，数据包可能会随时丢失，因为没有任何机制可以保证传输的可靠性。
![](https://cdn.nlark.com/yuque/0/2022/png/1303094/1669528760790-3109088e-5fac-42b8-858e-646e3c9ff7b3.png#averageHue=%23fefcfc&clientId=u873900c0-9f77-4&crop=0&crop=0&crop=1&crop=1&from=paste&id=ue9279bad&margin=%5Bobject%20Object%5D&originHeight=250&originWidth=1024&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=stroke&taskId=u286ad973-0cee-493e-a825-d4e23823e5c&title=)
而 DoH 则使用于 HTTPS，因此通过TCP链接，一种可靠传输的协议。这样既可以对连接进行加密， TCP 协议也可以确保完整的数据传输。另外，使用了基于 HTTPS 的 DNS，通信始终通过 443 端口进行，并在 443 端口传输实际的网络流量（例如，访问网站）。因此，外人无法区分 DNS 请求和其他通信，这也保障了更高级别的用户隐私。

## DoH 的难点
DoH 尚未成为 Internet 上的全球标准，大多数连接仍依赖基本的 DNS。到目前为止，仅 Google 和 Mozilla 两家公司涉足了这一领域。国内大部分客户会使用腾讯云DNSPod。
[https://cloud.tencent.com/document/product/379](https://cloud.tencent.com/document/product/379) 

DoH 需要用户专门对浏览器或者APP进行配置，或应用程序集成DoH服务提供商的SDK来开启DNS over http功能。
![](https://cdn.nlark.com/yuque/0/2022/png/1303094/1669528668908-2dd8a0de-a5d7-4ad7-9670-5734088dbadb.png#averageHue=%23f2f3f5&clientId=u873900c0-9f77-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=520&id=u2255fa43&margin=%5Bobject%20Object%5D&originHeight=808&originWidth=760&originalType=url&ratio=1&rotation=0&showTitle=false&status=done&style=stroke&taskId=u36270fc4-e34b-44e1-b0bc-3a8fce8cdc2&title=&width=489)

使用DoH/DoT提供商的服务后，风险依然存在，即这些厂商如果一旦有配置变更或者服务降级，那客户应用相应的会大面积受到影响，其造成的业务风险很高，所以最好是能自建一套DoH服务。
![image.png](https://cdn.nlark.com/yuque/0/2022/png/1303094/1669530711980-e175f4ec-6a33-44f5-ae2a-b4b3ad1728ab.png#averageHue=%23fafafa&clientId=u873900c0-9f77-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=291&id=ucd4214b1&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1123&originWidth=2285&originalType=binary&ratio=1&rotation=0&showTitle=false&size=295663&status=done&style=stroke&taskId=u824303da-2806-4349-8c65-8449bf9cd3a&title=&width=593)

## 搭建属于自己的DoH 服务
当前国外主流云厂商不提供DNS over http 服务，如果用户想使用此功能，可以通过serverless 架构搭建免运维的DoH 服务，效果不输DNSPod。

### 简单的设计思路
首先，DoH 主要解决的问题是运营商/公司的Local DNS劫持，那是否只需要绕过这一层，直接将DNS请求直接交给云厂商/第三方去做解析，并成功拿到返回的IP地址即可？简而言之，HTTPDNS 就是使用 HTTP 协议向 DNS 服务器进行请求，从而获取 IP 地址，简化了请求的复杂性。在请求 DNS 服务器的时候，使用 IP 直接访问。跳过使用系统解析的过程，自己来做 DNS 解析系统。

我们来探讨一种简单的Httpdns实现方式，利用自己可控的 DNS 系统和 dig 命令来实现简单 HttpsDNS 服务。
思路如下：

- 1、将域名和 ip 的配置在公司自建 DNS 或第三方的 DNS 系统配置好，可实现地区或运营商的动态调用。
- 2、开发 http api 服务，用来提供域名查询服务接口。
- 3、在 http api 服务接口业务逻辑中，拿到客户端的 IP，通过如下命令查询域名的解析 IP，返回该 IP 即可。

dig @ns服务器 www.baidu.com +subnet=客户端ip 

该方式利用了 DNS 系统的动态调度功能和域名 IP 的管理功能，结合 Http api 服务提供 Http 协议的 DNS 解析能力。绕过了 LocalDNS 的递归查询，解决了 DNS 劫持问题和精度问题。
该方式，只是一个简单的思路探索，其中还有很多细节的问题需要深究。DNS 解析是业务系统的一个强依赖服务，可用性和稳定性不容忽视。

### 具体实现
我们考虑将DNS请求封装进HTTP请求，参考DNSPod 的结构：

- 接口请求地址：http://119.29.29.98/d? + {请求参数}。[https://cloud.tencent.com/document/product/379/54976](https://cloud.tencent.com/document/product/379/54976)

[https://119.29.29.99/d?dn=](https://119.29.29.99/d?dn=)abc.nook.com

 其中119.29.29.99 我们可以替换为Azure的http 服务，通过dn=abc.nook.com 将需要解析的域名放到http请求的query string中。
### 请求样例

- **输入示例：**
curl "http://119.29.29.98/d?dn={cloud.tencent.com 加密后字符串}&id=xxx"
- **解密后返回格式：**
2.3.3.4;2.3.3.5;2.3.3.6
- **格式说明**：返回查询结果，多个结果以 ';' 分隔。

返回的A记录结果只需要以';'分隔，供应用程序解析即可。

### Functions 示例代码：

```
import logging
import azure.functions as func
import socket


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    ds = req.params.get('ds')
    if not ds:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            ds = req_body.get('ds') # 通过query string 传入域名

    addrs = [ str(i[4][0]) for i in socket.getaddrinfo(ds, 80) ] #遍历dns查询结果中的Ip地址


    if addrs:
        return func.HttpResponse(f"{addrs}")
    else:
        return func.HttpResponse(
            "This DNS Query triggered function executed successfully. Pass a domain name in the query string or in the request body for a personalized response.",
            status_code=200
        )
```

### 测试效果
以json形式封装需要请求的域名 {“ds”：“www.baidu.com”}, POST 请求给Azure Functions
![image.png](https://cdn.nlark.com/yuque/0/2022/png/1303094/1669530132436-07945c11-e8f2-4453-90f1-688762b59da0.png#averageHue=%23fbfbfb&clientId=u873900c0-9f77-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=327&id=u22a85168&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1197&originWidth=1391&originalType=binary&ratio=1&rotation=0&showTitle=false&size=61881&status=done&style=stroke&taskId=u162a122d-30dd-4e4f-a38f-a228f26da1f&title=&width=380.22222900390625)
返回结果为www.baidu.com的A记录，以','分隔
![image.png](https://cdn.nlark.com/yuque/0/2022/png/1303094/1669530096919-18d92c7d-3485-453d-8820-621db28ff423.png#averageHue=%23f7f7f7&clientId=u873900c0-9f77-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=269&id=MX9gQ&margin=%5Bobject%20Object%5D&name=image.png&originHeight=881&originWidth=1389&originalType=binary&ratio=1&rotation=0&showTitle=false&size=32688&status=done&style=stroke&taskId=u1102addd-a388-4c43-8ff0-7e4bfac0785&title=&width=424.33331298828125)

### 使用Frontdoor网络加速
![image.png](https://cdn.nlark.com/yuque/0/2022/png/1303094/1669537694191-53dda077-d471-4af9-8a25-f8228396d726.png#averageHue=%23f9f9f9&clientId=u2856cbac-b940-4&crop=0&crop=0&crop=1&crop=1&from=paste&height=550&id=u62bae0c5&margin=%5Bobject%20Object%5D&name=image.png&originHeight=1238&originWidth=2154&originalType=binary&ratio=1&rotation=0&showTitle=false&size=143123&status=done&style=stroke&taskId=ua1905f75-e3df-48ef-b166-88b1a36feb9&title=&width=957.3333333333334)

目前，azure functions 为区域性服务，也就是说如果仅部署一套azure functions 去做httpdns 服务器，全球所有的用户请求都会最终路由到此服务器上，对于长距离传输并不友好。可以借助Azure Frontdoor的TCP动态加速功能，让httpdns的TCP请求与PoP点建立链接，从而借助Azure 稳定的高速骨干网来承载数据传输，保证请求的速度和服务的稳定性。后续如果Azure Functions可以部署在边缘数据中心，也就是PoP点中，此httpdns 的性能和效果会更加。
### 压力测试
（后续可以基于自己的业务区域进行DNS的请求压测，由于本方案使用的都是托管服务，压测部分不在此讨论）
## 总结
### HTTPDNS 的优点

- 跳过 LocalDNS，防止本地DNS劫持
- 直接通过 IP 访问，平均访问延迟下降
- 服务器算法筛选最佳节点 IP，提升请求成功率
- 快速更换 IP（不受TTL的限制）
### HTTPDNS 的适用场景

1. App 防止恶意劫持
2. 对访问速度要求高的应用
3. 应用、视频加速服务，配合CDN，通过DNS服务器返回最佳节点，提高访问效率
4. 提供更灵活的流量调度能力

从原理上来讲，HTTPDNS 只是将域名解析的协议由 DNS 协议换成了 HTTP 协议，并不复杂。但是这一微小的转换，却带来了巨大的收益，其中 DNS 劫持（域名劫持）就是最为严重的一个问题，通过某些方式篡改了用户正常访问的 web 网页，插入广告或者其他内容，在页游时代就经常发生。而移动 App 主要导致无法访问、成功率下降等问题。同时，在今天移动互联网高度成熟环境下，用户体验越发重要，智能解析，就近接入，提升连接成功率，快速响应，确保用户访问顺畅，这些都是 HTTPDNS 的优势。

**Httpdns 主要应用在以下几类移动 App 开发中：**

- **资讯、游戏类 App**: 希望降低访问延迟、减少跨网访问，注重快速响应体验。
- **电商类 App**: 希望降低连接失败率，提高业务工作率，注重访问请求稳定性。
- **社交类 App**: 域名屡次被劫持，希望用户访问顺畅无阻。
- **音视频类 App**: 对流畅度要求高，提升音乐、视频播放的连接成功率。

### 



