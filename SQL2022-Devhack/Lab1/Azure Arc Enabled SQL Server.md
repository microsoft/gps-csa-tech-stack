# 实验目标

Azure Arc-enabled SQL Server 允许管理本地Windows 和 Linux 物理服务器以及托管在 Azure 外部、公司网络或其他云提供商上的虚拟机。本次实验使用Azure VM 来测试 Azure Arc enbaled SQL Server 的效果,模拟Azure 门户管理混合环境下的 SQL Server.

# 实验环境准备

本实验所需权限以及 resource provider 均已配置

## 1. 创建window Server VM

参考[Quickstart: Create a Windows virtual machine in the Azure portal](https://learn.microsoft.com/zh-cn/azure/virtual-machines/windows/quick-create-portal),region 选择 "japaneast"，availability zone 选择"No infrastructure redundancy required",Image选择 "Windows Server 2022 Datacenter: Azure Edition - x64 Gen2"

![image](https://user-images.githubusercontent.com/34478391/226507704-66a5f75b-b793-4647-b4f4-e7a1ab119c55.png)

## 2. 配置 Windows VM 进行测试

Azure Arc 并不支持在Azure VM 上运行的SQL Server，但是可以参考 [Evaluate Azure Arc-enabled servers on an Azure virtual machine](https://learn.microsoft.com/zh-cn/azure/azure-arc/servers/plan-evaluate-on-azure-virtual-machine#reconfigure-azure-vm)对VM进行配置，用于本次实验测试

![image](https://user-images.githubusercontent.com/34478391/226508124-7f2d5c42-236b-4680-99d3-c9a47b8bfb6e.png)

## 3. 创建 SQL Server-Azure Arc 并运行脚本

参考[Connect your SQL Server to Azure Arc](https://learn.microsoft.com/zh-cn/sql/sql-server/azure-arc/connect?view=sql-server-ver16&tabs=linux), license type 选择 "PAYG"

![image](https://user-images.githubusercontent.com/34478391/226508795-fbccc931-f8cc-4da9-b08b-7da0900b8f99.png)

下载.ps1脚本

![image](https://user-images.githubusercontent.com/34478391/226508846-8bd393bf-0230-4aae-8ad8-9bf9f45ae47e.png)

在 Window VM powershell上运行脚本 RegisterSqlServerArc.ps1，如果出现报错 ".ps1 is not digitally signed."：

![image](https://user-images.githubusercontent.com/34478391/226509131-bf212212-6d73-4077-bc9b-302d87209190.png)

请在 powershell中用Set-ExectionPolicy 设置执行策略：
```
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

再重新运行RegisterSqlServerArc.ps1即可

![image](https://user-images.githubusercontent.com/34478391/226509579-dddfbcc7-ccd3-4bca-8d7b-632ae9c1eb92.png)

## 4. 在 Windows VM 上安装 SQL Server

参考 [安装SQL 2022](https://learn.microsoft.com/zh-cn/sql/database-engine/install-windows/install-sql-server-from-the-installation-wizard-setup?view=sql-server-ver16#install-sql-server-2022),licenseTerms 选择 PAYG-Enterprise版本，Instance feature 只选择 "Data Engine Services"即可。

![image](https://user-images.githubusercontent.com/34478391/226510918-5a39d7e8-663b-4c2b-a833-44bc34e984d9.png)


![image](https://user-images.githubusercontent.com/34478391/226510930-cf332dc1-5b6e-4d7f-9469-5030e6b36875.png)


![image](https://user-images.githubusercontent.com/34478391/226510946-ab7b3cb4-ccc4-47cf-94af-51716f397339.png)


![image](https://user-images.githubusercontent.com/34478391/226510953-e25fa60b-b3ac-4564-8d9d-075843928f7d.png)

如果VM上没有 SSMS (SQL Server Management Studio), [下载SSMS](https://aka.ms/ssmsfullsetup)并安装。

## 5. SQL Server安装好之后，等待一个小时，即可在 Azure Arc上看到已经安装好的SQL Server

connect成功的示图如下：

![image](https://user-images.githubusercontent.com/34478391/226511773-09998476-85f7-4cd4-9269-f533fadcaf0f.png)

![image](https://user-images.githubusercontent.com/34478391/226511887-c580ee4d-0f4e-4b80-8cac-ff291d65b26b.png)





