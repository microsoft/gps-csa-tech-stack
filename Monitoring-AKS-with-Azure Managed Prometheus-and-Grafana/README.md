# **使用Auzre托管Prometheus和Grafana监控AKS**

##  **背景**

2022年10月，微软在全球Ignite大会上发布了Azure上**Prometheus**托管服务，即 **Azure Monitor managed service for Prometheus**。通过Azure上托管的Prometheus+Grafana，可以近一步提升Azure Kubernetes Service的可观测性。本文通过分享将Azure Monitor集成Azure托管的Prometheus+Grafana提升运维AKS的监控体验，从而有效提升企业AKS运维的高可用性、可靠性和性能。

&nbsp;
&nbsp;

##  **构建AKS及容器应用基础环境**

如果您已经有了AKS集群及已经在其之上部署了可供测试的容器应用，可以跳过此段，直接进入

1.  使用Azure CLI命令行工具登陆Azure

    ```bash
    az cloud set --name AzureCloud

    az login
    ```

![](.//media/image1.png)

2.  设置Azure 默认订阅并创建实验所需Azure资源组
    ```bash
    az account set --subscription xxxxxxxxxxxx-xxxx-xxxx-xxxxxxxxx

    ```
![文本 描述已自动生成](.//media/image2.png)

3.  验证是否已在订阅中注册了
    Microsoft.OperationsManagement，Microsoft.OperationalInsights和Microsoft.Insights提供程序。
    这些是支持容器简介所需的 Azure Resource Provider。
    若要检查注册状态，请运行以下命令：

    ```bash
    az provider show -n Microsoft.OperationsManagement -o table
    az provider show -n Microsoft.OperationalInsights -o table
    az provider show -n Microsoft.Insights -o table
    ```


4.  如果未注册，请使用以下命令注册：

    ```bash
    az provider register --namespace Microsoft.OperationsManagement
    az provider register --namespace Microsoft.OperationalInsights
    az provider register --namespace Microsoft.Insights
    ```

![](.//media/image3.png)

5.  通过以下命令创建AKS集群，并带有 --enable-addons monitoring 和--enable-msi-auth-for-monitoring
    参数，目的是启用带有托管标识身份验证的 [Azure Monitor容器见解（预览版）](https://learn.microsoft.com/zh-cn/azure/azure-monitor/containers/container-insights-overview)

   ```bash
    az aks create -g rg-aksmonitoringtest -n aksmonitoringtest --enable-managed-identity --node-count 1 --enable-addons monitoring --enable-msi-auth-for-monitoring --generate-ssh-keys
   ```
![图形用户界面, 文本, 应用程序描述已自动生成](.//media/image4.png)

6.  使用 **az aks get-credentials** 命令将 kubectl 配置为连接到你的Kubernetes群集
    ```bash
    az aks get-credentials --resource-group rg-aksmonitoringtest --name aksmonitoringtest
    ```
![](.//media/image5.png)

7.  通过使用 **kubectl get** 命令验证与群集之间的连接。
    ```bash
    kubectl get nodes
    ```
![图示, 文本
中度可信度描述已自动生成](.//media/image6.png)

8.  部署测试应用（也可以随意部署其他容器样例）
    ```bash
    kubectl apply -f
    https://raw.githubusercontent.com/microsoft/gps-csa-tech-stack/main/Monitoring-AKS-with-Azure%20Managed%20Prometheus-and-Grafana/yaml/azure-vote.yaml
    ```
![文本 描述已自动生成](.//media/image7.png)

9.  使用带有 --watch 参数的 **kubectl get service** 命令来监视K8Sservice创建进度进度。观测输出的**External-IP**
```bash
kubectl get service azure-vote-front --watch
```
![](.//media/image8.png)

10.  复制EXTERNAL-IP的IP地址到浏览器，将显示该应用网页。到目前为止，AKS集群和一个简单的应用均创建部署成功。

![图形用户界面描述已自动生成](.//media/image9.png)

&nbsp;
&nbsp;


##  **在AKS上集成Prometheus和Grafana托管服务**

1.  首先通过Azure门户创建Azur Grafana托管服务

![图形用户界面, 文本, 应用程序, 电子邮件描述已自动生成](.//media/image10.png)

2.  根据向导输入相关的参数，然后"审阅+创建"

![图形用户界面, 文本, 应用程序描述已自动生成](.//media/image11.png)

3.  在创建好的Grafana托管服务的"概述"界面上，查看Grafana终结点，点击进去，查看Dashboard

![](.//media/image12.png)

4.  目前还没有集成Prometheus，还不能观察AKS指标。

![](.//media/image13.png)

5.  在Azure门户里，进入AKS集群管理界面的"见解"项，点击 **"启用Prometheus"**

![图形用户界面, 文本, 应用程序, 电子邮件描述已自动生成](.//media/image14.png)
6.  点击 **"启用功能标记"**

![图形用户界面, 文本, 应用程序, 电子邮件描述已自动生成](.//media/image15.png)

7.  根据向导继续输入参数并集成之前创建的**"Grafana工作区"，之后点击 **"配置"**

![](.//media/image16.png)

8.  为收集AKS集群的监控指标，Prometheus会生成一个基于K8SDeamonSet的守护资源workload，即**ama-metrics-node**。通过以下命令验证该DeamonSet是否部署成功。
    ```bash
    kubectl get ds ama-metrics-node --namespace=kube-system
    ```
![文本 描述已自动生成](.//media/image17.png)

9.  到目前为止，Prometheus与Grafana在该AKS集群的集成、配置及启用已经完成。接下来从AKS监视页面点击"查看Grafana工作区"查看监控指标。

![图形用户界面, 应用程序描述已自动生成](.//media/image18.png)

10.  点击 **"浏览仪表板"**，之后根据您的Azure身份管理策略可能需要进行认证。

![图形用户界面, 应用程序描述已自动生成](.//media/image19.png)

11.  默认情况下，Managed Prometheus已经显示在Grafana Dashboards上，无需近一步配置数据源。在Managed Prometheus列点击"Go to folder ".

![电脑萤幕的截图描述已自动生成](.//media/image20.png)

12.  可监控的AKS资源类别列了出来，点击Pod来查看一下指标。

![](.//media/image21.png)

13.  Pod相关指标列了出来。Grafana可视化监控功能非常强大，可以近一步设置Grafana Dashboards，来客户化显示所需的指标。

![](.//media/image22.png)

&nbsp;
&nbsp;

## **总结**

Prometheus与Grafana集成监控方案在云原生领域非常流行，功能非常丰富，本文仅仅通过简单的配置实现两者集成，技术爱好者们如果感兴趣的话，可以客户化监控更多的指标，进阶了解功能体系和技术内容，可以访问以下文档：

1.  [Monitoring Azure Kubernetes Service (AKS) with Azure Monitor](https://learn.microsoft.com/en-us/azure/aks/monitor-aks)

2.  [Azure ManagedGrafana](1.%09https:/azure.microsoft.com/en-us/services/managed-grafana#overview)

3.  [Azure Monitor managed service for Prometheus(preview)](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/prometheus-metrics-overview)
