# 实验目标

Azure SQL Managed Instance 是一种智能、可缩放的云数据库服务；它将最广泛的 SQL Server 数据库引擎兼容性与完全托管且经久不衰的平台即服务的所有优势相结合。本次实验将Azure VM中的 SQL Server 2022 和 Azure SQL Managed Instance 相连，并在SQL Managed Instance中实时同步、查看 SQL Server中的数据更新。



# 实验环境准备

本实验延用[Azure Arc Enabled SQL Server](https://github.com/ZuoXuangn/SQLdemo/blob/main/Azure%20Arc%20Enabled%20SQL%20Server.md)中创建的 VM (Windows Server 2022)进行测试。

实验中需要创建的 SQL Managed Instance 以及 subnet 均已配置

## 1. 配置 SQL Managed Instance 环境

按照[Prepare your environment for a link - Azure SQL Managed Instance](https://learn.microsoft.com/zh-cn/azure/azure-sql/managed-instance/managed-instance-link-preparation?view=azuresql)配置SQL Server环境，配置完成之后，在SQL Server Configuration Manager ->SQL Server Services下面分别右击SQL Server 和 SQL Server Agent 进行重启。

![image](https://user-images.githubusercontent.com/34478391/226514357-87fe2732-37f8-4974-9670-3f0074b2497d.png)

在SQL MI 和 Windows VM 的 NSG中分别设置 Inbound Security Rules 和 Outbound Security Rules, 配置 5022 端口

![image](https://user-images.githubusercontent.com/34478391/226515349-31e46a58-42c0-4a91-89ce-68767d83384c.png)

![image](https://user-images.githubusercontent.com/34478391/226525292-1a409c7d-4344-46a1-bbe2-5f3710b0489a.png)

![image](https://user-images.githubusercontent.com/34478391/226525543-c6c5b12a-d119-4392-b64c-d1265fc18f51.png)

![image](https://user-images.githubusercontent.com/34478391/226525638-0c7f255b-2fde-48ec-912e-1d2acc0ccb79.png)

在Windows VM上的SQL Server 实例使用以下 PowerShell 脚本打开 Windows 防火墙中的端口：
```
New-NetFirewallRule -DisplayName "Allow TCP port 5022 inbound" -Direction inbound -Profile Any -Action Allow -LocalPort 5022 -Protocol TCP
New-NetFirewallRule -DisplayName "Allow TCP port 5022 outbound" -Direction outbound -Profile Any -Action Allow -LocalPort 5022 -Protocol TCP
```

![image](https://user-images.githubusercontent.com/34478391/226526081-138a741f-34cc-4d1a-ad01-b1392266d2eb.png)

## 2. 测试双向网络连接
### 2.1 配置SQL Managed Instance并使用SSMS/ADS进行连接

参考[Configure public endpoint in Azure SQL Managed Instance](https://learn.microsoft.com/zh-cn/azure/azure-sql/managed-instance/public-endpoint-configure?view=azuresql)配置公共终结点，并[使用Azure Data Studio 或 SQL Server Management Studio](https://learn.microsoft.com/zh-cn/sql/ssms/quickstarts/ssms-connect-query-azure-sql?view=sql-server-ver16) 进行连接。

### 2.2 测试从 SQL Server 到 SQL Managed Instance 的连接
参考 [测试从 SQL Server 到 SQL Managed Instance 的连接](https://learn.microsoft.com/zh-cn/azure/azure-sql/managed-instance/managed-instance-link-preparation?view=azuresql#test-the-connection-from-sql-server-to-sql-managed-instance)

### 2.2 测试从 SQL Managed Instance 到 SQL Server的连接

参考[测试从 SQL Managed Instance 到 SQL Server的连接](https://learn.microsoft.com/zh-cn/azure/azure-sql/managed-instance/managed-instance-link-preparation?view=azuresql#test-the-connection-from-sql-managed-instance-to-sql-server)

## 3. 使用SSMS复制数据库

### 3.1 使用SSMS复制数据库

参考[使用 SSMS 中的链接功能复制数据库](https://learn.microsoft.com/zh-cn/azure/azure-sql/managed-instance/managed-instance-link-use-ssms-to-replicate-database?view=azuresql)


### 3.2建表测试

在Windows VM 的 SQL Server 上创建一个新表，并插入数据：
```
CREATE TABLE tbl_user (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(255),
    age INT,
    email VARCHAR(255),
    updatetime DATETIME DEFAULT GETDATE()
);
```

```
DECLARE @i INT = 1;
WHILE @i <= 10
BEGIN
    INSERT INTO tbl_user (username, age, email)
    VALUES ('User' + CAST(@i AS VARCHAR), @i * 10, 'user' + CAST(@i AS VARCHAR) + '@example.com');
    SET @i = @i + 1;
END;
```
在SQL Managed Instance上即刻查询结果：

```
select * from dbo.tbl_user
```
可以看到：

![image](https://user-images.githubusercontent.com/34478391/226543151-a8ffaf7d-af48-4b6d-b4bd-24bf04a7a6a3.png)


## 4. 使用SSMS进行故障转移

参考[使用 SSMS 中的链接对数据库进行故障转移](https://learn.microsoft.com/zh-cn/azure/azure-sql/managed-instance/managed-instance-link-use-ssms-to-failover-database?view=azuresql#fail-over-a-database)
