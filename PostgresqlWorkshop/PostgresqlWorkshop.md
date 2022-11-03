
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
        ![](media/image4.png)
     - 下载bicep模板
        ```bash
        wget https://storageaccounthol.z6.web.core.windows.net/scripts/bicep.zip
        ```
        ![](media/image5.png)
     - 压缩下载文件
        ```bash
        unzip bicep
        ```
        ![](media/image6.png)
     - 创建一个名为PG-Workshop的资源组来部署实验资源
        ```bash
        az group create -l Eastus -n PG-Workshop
        ```
        ![](media/image7.png)
     - 使用bicep模板部署
        ```bash
        az deployment group create --resource-group PG-Workshop --template-file bicep/main.bicep
        ```
        需要为跳板机和数据库分别设置管理用户名和密码
    
    部署需要十几分钟时间，如果部署失败可以多执行几次，直到部署成功以后将会出现以下输出： 
    ![](media/image8.png)

    之后您可以在名为PG-Workshop的资源组看到部署后的资源：  
    ![](media/image9.png)

   - 使用Azure Cloud Shell连接跳板机DNS VM，然后通过DNS VM连接数据库。  
  
     - 在Azure Cloud Shell中通过ssh连接跳板机
        ```bash
        ssh username@<jumpbox-ip> # 您设置的登录DNS VM的IP地址和用户名
        ```
     - 登录后安装psql（如未安装）
        ```bash
        sudo dnf module enable -y postgresql:13
        sudo dnf install -y postgresql
        ```
        
     - 通过DNS VM连接数据库
        ```bash
        psql -U adminuser -h postgresql-db.postgres.database.azure.com postgre
        ```
     - 通过预先配置连接参数快速连接数据库
       - 在Azure portal左栏位“Connection Strings”处找到psql字段
       - 在跳板机上创建配置文件
        ```bash
        vi .pg_azure
        ```  
        文件中配置以下内容:  
        ```bash
        export PGDATABASE=postgres
        export PGHOST=HOSTNAME.postgres.database.azure.com
        export PGUSER=adminuser
        export PGPASSWORD=your_password
        export PGSSLMODE=require
        ```
       - 读取配置文件
        ```bash
        source .pg_azure
        ```
       - psql连接数据
        ```bash
        psql
        ```

2. 数据引入和环境准备
   - 插入数据
    ```bash
    CREATE DATABASE quiz;
    \connect quiz

    CREATE TABLE public.answers (
        question_id serial NOT NULL,
        answer text NOT NULL,
        is_correct boolean NOT NULL DEFAULT FALSE
    );

    CREATE TABLE public.questions (
        question_id integer NOT NULL,
        question text NOT NULL
    );

    ALTER TABLE ONLY public.answers
        ADD CONSTRAINT answers_pkey PRIMARY KEY (question_id, answer);

    ALTER TABLE ONLY public.questions
        ADD CONSTRAINT questions_pkey PRIMARY KEY (question_id);

    ALTER TABLE ONLY public.answers
        ADD CONSTRAINT question_id_answers_fk FOREIGN KEY (question_id) REFERENCES public.questions(question_id);

    CREATE SCHEMA calc;
    CREATE OR REPLACE FUNCTION calc.increment(i integer) RETURNS integer AS $$
            BEGIN
                    RETURN i + 1;
            END;
    $$ LANGUAGE plpgsql;

    CREATE VIEW calc.vista AS SELECT $$I'm in calc$$;

    CREATE VIEW public.vista AS SELECT $$I'm in public$$;

    INSERT INTO public.questions (question_id, question) VALUES (1, 'Jaki symbol chemiczny ma tlen?');

    INSERT INTO public.answers (question_id, answer, is_correct) VALUES (1, 'Au', false);
    INSERT INTO public.answers (question_id, answer, is_correct) VALUES (1, 'O', true);
    INSERT INTO public.answers (question_id, answer, is_correct) VALUES (1, 'Oxy', false);
    INSERT INTO public.answers (question_id, answer, is_correct) VALUES (1, 'Tl', false);
    ```
   - 
3. 管理PostgreSQL数据库
   - 管理存储和计算
   - 开启pgbouncer服务器参数
   - 使用服务锁
4. 设置角色和权限
    本部分实验原理：用户组中的用户

### 可用性和业务连续性
1. 备份和恢复
    - 逻辑备份
    - 物理备份和PITR还原
2. 复制
3. 高可用和灾备
4. 维护
5. 审计