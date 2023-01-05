# 实验三：通过Azure DevOps 部署pipeline

本实验将部署下图所示的DevOps Pipeline:
![Simple Pipeline Drawing](../media/simple_pipeline.png)

## 创建一个新的DevOps项目

1. 登录到 [Azure DevOps](http://dev.azure.com)
1. 选择 `Create project` (可以选择private项目)
1. 填写项目名称: `mlops-workshop-001` (或者其他名称) 然后选择 `Create`

## 导入项目代码

下面，我们将克隆本次实验的代码库:

1. 在Azure DevOps页面左侧选择Repos, 然后选择`Import a repository`
1. 选择 `Clone URL`: `https://github.com/zwang53/azure-machine-learning-mlops-workshop` and import it

## 在Azure DevOps中创建服务连接

接下来我们将配置Azure DevOps到Azure Machine Learning的验证体系，使得Azure DevOps可以访问到AML的工作区。

1. 从左边的导航栏选择 `Project settings` (左下角齿轮形状) 然后选择`Service connections`
1. 选择 `Create service connection` 然后选择 `Azure Resource Manager`
1. 选择 `Service principal (automatic)`
1. 默认 `Scope level` 为 `Subscription`, 然后选择:
   1. Subscription: 选择你现在使用的Azure订阅
   1. Resource Group: 选择AML所在的资源组
   1. Service connection name: `aml_workspace`
1. 点击 `Save`

## 导入Pipeline `deploy-simple-pipeline.yml` 

该Pipeline将自动部署我们实验一中创建的训练Pipeline。

1. 选择 `Pipelines --> Pipelines` 然后选择`Create pipeline`
1. 选择 `Azure Repos Git`
1. 选择本实验的代码库 
1. 选择 `Existing Azure Pipelines YAML file` 然后选择文件位置 `/devops-deploy-simple-pipeline/deploy-simple-pipeline.yml`
1. 在后面的preview界面里，更新 `variables` 参数部分 : 
  ```yaml
  variables:
    resourcegroup: 'aml-mlops-workshop' # 替换成你的 resource group (同之前建立Service Connection一样)
    workspace: 'aml-mlops-workshop' # 替换你的工作区名称 (同之前建立Service Connection一样)
    aml_compute_target: 'cpu-cluster' # 可以不做修改
  ```
1. 仔细浏览YAML文件，本次实验的CI/CD pipeline将完成以下五个步骤：
    * 设置build agent上的Python版本
    * 安装Azure Machine Learning CLI (主要用于与AML 工作区的身份验证)
    * 把文件夹附在该工作区
    * 创建AML计算集群
    * 发布模型训练的Pipeline
1. 选择 `Run` 来保存和运行pipeline.

最后，请导航到Azure Machine Learning Studio的UI界面中，查看 `Endpoints -> Pipeline Endpoints`. 

# 随堂小测

:question: **Question:** 为什么需要做service connection?
<details>
  <summary>:white_check_mark: See solution!</summary>

Service connection将Azure DevOps和AML工作区所在的资源组联系起来，由此授权Azure DevOps可以对工作区中的pipeline相关内容做读写等访问。 
</details>

:question: **Question:** 为什么需要使用 `az ml folder attach -w $(workspace) -g $(resourcegroup)`?
<details>
  <summary>:white_check_mark: See solution!</summary>

该指令能够将本实验的代码关联到工作区，使得后续python代码里在使用 `ws = Workspace.from_config()` 时可以连接到AML工作区。
</details>
