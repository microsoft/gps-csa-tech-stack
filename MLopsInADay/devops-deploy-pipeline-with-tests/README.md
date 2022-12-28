# 实验四：使用Azure DevOps 实现实验的部署和测试

在本实验中，我们将部署如下场景的DevOps Pipeline:
![Pipeline With Testing Drawing](../media/pipline_with_testing.png)

## 导入 `deploy-simple-pipeline-with-tests.yml` pipeline

本实验中的DevOps pipeline将实现自动的部署和测试之前实验一中使用的ML training pipeline. 

1. 选择 `Pipelines --> Pipelines` 然后选择 `New pipeline`
1. 选择`Azure Repos Git`
1. 选择你的代码库 
1. 选择 `Existing Azure Pipelines YAML file` 然后选择文件位置 `/devops-deploy-pipeline-with-tests/deploy-simple-pipeline-with-tests.yml`
1. 在接下来的preview的界面中，更新 `variables` 参数部分section： 
  ```yaml
  variables:
    resourcegroup: 'aml-mlops-workshop' # 替换成你的AML资源所在的的资源组
    workspace: 'aml-mlops-workshop' # 替换成你的AML工作区的名称
    aml_compute_target: 'cpu-cluster' # 可以不做修改
  ```
1. 仔细浏览本实验中运行的YAML文件，此次的CI/CD pipeline将完成以下八个步骤（前五个跟前面的实验相同）：
    * 设置build agent上的Python版本
    * 安装Azure Machine Learning CLI (主要用于与AML 工作区的身份验证)
    * 把本实验所在的文件夹附在该AML工作区
    * 创建AML计算集群
    * 发布模型训练的Pipeline
    * 使用`pytest`运行测试数据集
    * 发布测试结果Publish the test results
    * 添加本实验的测试pipeline到pipeline终结点，使得最终暴露的URL时统一的
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
