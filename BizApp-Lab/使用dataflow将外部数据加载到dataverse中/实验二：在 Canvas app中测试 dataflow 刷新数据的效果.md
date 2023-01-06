## 实验二：在 Canvas app中测试 dataflow 刷新数据的效果
### 2.1 在 solution 中新建一个 canvas app 进行测试

新建 canvas app 并命名为 "RefreshTest"

![image](https://user-images.githubusercontent.com/34478391/203124521-8ca8f441-3108-47d9-8158-6d4a110f6595.png)

添加 "Manufacturerss" table作为数据源

![image](https://user-images.githubusercontent.com/34478391/203125211-2f3ee06f-3c3a-43fa-a255-d8236077a9f8.png)

将 "Manufacturerss" table 添加作为数据源

![98816ba2d432a239a8edfd6dd45c71e](https://user-images.githubusercontent.com/34478391/203129535-bb1b4489-0ac1-4d0d-aca2-efce7783140e.jpg)

### 2.2 新建一个vertical gallery 来展示 "Manufacturerss" table 中的数据

添加垂直库如下：

![image](https://user-images.githubusercontent.com/34478391/203139316-e115d08c-57ce-4534-8df9-29f9d4b96027.png)

添加文本框，修改 "Text"属性为： "总共："& CountA(Manufacturerss.Title) & "家生产商"

![image](https://user-images.githubusercontent.com/34478391/203139641-138c6b63-4759-4e60-b381-b100d5d0f657.png)

### 2.3 手动刷新dataflow,同时在canvas app中刷新 "Manufacturerss" table

![image](https://user-images.githubusercontent.com/34478391/203139964-d7227001-cec5-4f41-aea0-6617cd24f4c0.png)

![image](https://user-images.githubusercontent.com/34478391/203140074-d9fa004d-392e-4d75-80d8-848286c78edd.png)

刷新之后的结果：

![image](https://user-images.githubusercontent.com/34478391/203140289-239db7b3-863c-42ab-b389-7707eb529cb3.png)


