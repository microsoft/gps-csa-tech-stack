## 实验三：使用dataflow刷新数据时发送通知

### 3.1 登录 Power Automate，创建新的 flow

进入刚刚创建 dataflow 和 canvas app 的环境中，创建并重命名 automated cloud flow

![image](https://user-images.githubusercontent.com/34478391/203142878-79a0dc01-2776-4178-b24e-083d4ba60dce.png)

进入flow创建界面，并且建立power query的连接之后，填写相应字段：

* 组类型：environment
* 组：刚刚创建 dataflow 和 canvas app 的环境
* 数据流：刚刚创建的 dataflow

![image](https://user-images.githubusercontent.com/34478391/203143162-cbceae93-d750-47a8-8525-e44654a6c5c2.png)

### 3.2 添加条件判断逻辑，根据刷新成功 or 失败 发送不同消息

![image](https://user-images.githubusercontent.com/34478391/203147591-8c6b8724-5095-4a81-91ff-bedd2170d292.png)

成功手动刷新dataflow之后，收到邮箱正文：

![image](https://user-images.githubusercontent.com/34478391/203147666-2afcf98a-aa12-41c2-a89c-8a7e73bbb114.png)

### 3.3 参考链接

* https://learn.microsoft.com/en-us/power-query/dataflows/dataflow-power-automate-connector-templates


