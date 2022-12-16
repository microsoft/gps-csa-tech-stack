# 实验一：使用AML Pipeline实现模型训练

## 预先准备

在开始本实验之前，请确保准备好以下环境:

* 微软机器学习工作区 Azure Machine Learning workspace
   * 如果您第一次使用微软机器学习服务，请参考此 [入门指南](https://docs.microsoft.com/en-us/azure/machine-learning/how-to-manage-workspace#create-a-workspace), 无需特殊配置网络部分
* 在工作区中，开启机器学习计算实例 (资源大小可选择`Standard_D2_v2`)
  * 进入 [AML Studio (https://ml.azure.com)](https://ml.azure.com)
  - 登录你的账号
  - 选择`计算 （Compute）`
  - 选择`计算实例（Compute Instance）`
  - 点击`创建（Create）`
  - 填写实例名称，选择 `Standard_D2_v2` 然后创建

## 开始实验（以下内容均在计算实例中运行）

我们推荐本实验内容在机器学习服务中的计算实例中运行，因为其为运行机器学习项目的标准环境，可减少开发者的环境配置时间，也避免因为环境配置产生冲突。

开始实验，您可以打开`Jupyter` 或者`Jupyter Lab` 然后选择`New --> Terminal` 并克隆本repo:

```console
git clone https://github.com/zwang53/azure-machine-learning-mlops-workshop.git
cd azure-machine-learning-mlops-workshop/
```

然后在Jupyter中导航到克隆的文件目录，打开 [`single_step_pipeline.ipynb`](single_step_pipeline.ipynb) . 请在Jupyter中选择并设置kernal为 `Python 3.8 - AzureML` 



## 敲黑板

* 本实验中的Notebook将在Azure Machine Learning的工作区中创建AML Pipeline
* 这个Pipeline会暴露REST API以供调用
* 在Pipeline创建的过程中，我们会定义本实验将运行的训练脚本`train.py`
* 在Pipeline中我们会定义此次模型训练依赖的环境
* 在Pipeline中我们可以选定要使用的数据集，这样参数化的设置使得我们随时可以修改或使用新的数据集进行训练（比如有新的数据需要做retrain）
* 此Pipeline会运行在指定的计算集群上 (该集群是在pipeline运行时才会被启用的)
* 此实验会输出一些数据或者注册一个模型，这些将在后续的实验中被使用


# 随堂小测

:question: **问题1:** `train_step = PythonScriptStep(name="train-step", ...)` 在哪里设置相关的Python依赖?
<details>
  <summary>:white_check_mark: See solution!</summary>

实验中通过在Notebook中创建的AML environment `workshop-env`来定义python相关依赖。该环境加载了一个`conda.yml`，这里定义了所有python的依赖库

</details>

:question: **问题2:** 在哪里如何配置计算集群，使得它能够更快/慢的响应集群缩放?
<details>
  <summary>:white_check_mark: See solution!</summary>

我们可以通过设置如下参数 `idle_seconds_before_scaledown=3600`, 来自动缩放时等待的空闲时间。
</details>

