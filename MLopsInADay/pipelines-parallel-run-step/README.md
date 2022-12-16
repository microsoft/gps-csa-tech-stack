# 实验二：使用ParallelRunStep实现并行处理

本实验旨在学习使用ParallelRunStep实现大规模数据的并行处理或多模型的并行处理。打开 [`parallel_run_step_pipeline.ipynb`](parallel_run_step_pipeline.ipynb) 然后根据Notebook中的指导完成实验。

# 随堂小测

:question: **问题:** 如何修改 `ParallelRunStep` 输出的位置？
<details>
  <summary>:white_check_mark: See solution!</summary>
  
可以使用`OutputFileDatasetConfig` class. 这里我们可以定义`destination`来指向datastore的地址

```python
# Direct path
output_dataset = OutputFileDatasetConfig(name='batch_results', destination=(datastore, 'batch-scoring-results/'))

# run-id is replaced with the run's id
output_dataset = OutputFileDatasetConfig(name='batch_results', destination=(datastore, 'batch-scoring-results/{run-id}/'))

# output-name is replaced with the name, in this case batch_results
output_dataset = OutputFileDatasetConfig(name='batch_results', destination=(datastore, 'batch-scoring-results/{output-name}/'))

# Lastly, we can automatically register it as a Dataset in the workspace
output_dataset = OutputFileDatasetConfig(name='batch_results', destination=(datastore, 'batch-scoring-results/')).register_on_complete(name='batch-scoring-results')
``` 
</details>

