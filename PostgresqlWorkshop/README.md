# PostgresqlWorkshop
Azure Database for PostgreSQL迁移部署实操

> [实验背景](#实验背景)
>
> [基础知识](#所需基础知识介绍)
>

&nbsp;
&nbsp;

## 实验背景
Azure Database for PostgreSQL 是基于开源 Postgres 数据库引擎的关系型数据库服务。它是完全托管的数据库即服务，具有可预测的性能、安全性、高可用性和动态可伸缩性。

本实验目的意在帮助您掌握Azure Database for PostgreSQL的迁移和部署相关操作，包括：
- 部署
  -  前提条件
  -  使用Bicep部署数据库
  -  数据引入和环境准备
  -  管理PostgreSQL数据库
  -  设置角色和权限
- 可用性和业务连续性
  - 备份和恢复
    - 逻辑备份
    - 物理备份和PITR还原
  - 复制
  - 高可用和灾备
  - 维护
  - 审计
- 高级特性（可选）
  - 监控数据库
  - 性能优化
    - PgBadger
    - MVCC
    - SQL特性
    - 查询优化

    
## 基础知识
