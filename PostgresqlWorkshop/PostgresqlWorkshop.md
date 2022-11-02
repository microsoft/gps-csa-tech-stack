
> [实验环境准备](#实验环境准备)
>
> [动手实验](#动手实验)
>
> [考虑](#考虑)

&nbsp;
&nbsp;


## 实验环境准备
1. 登录Azure portal  
    使用用户名和密码登录[Azure Portal](https://portal.azure.com)  
    
2. 打开Azure Cloud Shell  
   点击此处使用Azure Cloud Shell  
    ![Azure Cloud Shell](./media/image1.png)  

    显示下图表示您已经成功开启Azure Cloud Shell  

    ![success](./media/image2.png)  

3. 实验整体架构
   ![](./media/image3.png)

   **注意**：本动手实验文档默认按Azure Global环境运行，探索对象主要是Azure Database for PostgreSQL的flexible server版本，该版本支持AzureGlobal和AzureChina（世纪互联）等所有Azure公有云
   
## 动手实验
### 部署
1. 使用Bicep部署数据库
   - 使用Bicep部署Azure Database for PostgreSQL - Flexible server。
     - 安装bicep
         ```bash
        az bicep install
        ```
     - 下载bicep模板
        ```bash
        wget https://storageaccounthol.z6.web.core.windows.net/scripts/bicep.zip
        ```
     - 压缩下载文件
        ```bash
        unzip bicep
        ```
     - 创建一个名为PG-Workshop的资源组来部署实验资源
        ```bash
        az group create -l Eastus -n PG-Workshop
        ```
     - 使用bicep模板部署
        ```bash
        az deployment group create --resource-group PG-Workshop --template-file bicep/main.bicep
        ```
    
    部署需要几分钟时间，部署成功以后将会出现以下输出：  

    之后您可以在名为PG-Workshop的资源组看到部署后的资源：  

   - 使用Azure Cloud Shell连接跳板机DNS VM，然后通过DNS VM连接数据库。

2. 数据引入和环境准备
3. 管理PostgreSQL数据库
4. 设置角色和权限