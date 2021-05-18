<!--
 * @Author: your name
 * @Date: 2021-05-13 12:44:38
 * @LastEditTime: 2021-05-18 15:55:31
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: /ws_cloudsolution_gitlab/solution-mysql-redis-cache-simple/README.md
-->
### Project URL
[http://gitlab.alibaba-inc.com/alibabacloud-labs/solution-mysql-redis-cache-simple](http://gitlab.alibaba-inc.com/alibabacloud-labs/solution-mysql-redis-cache-simple)


### Architecture Overview
![image.png](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/main/images/archi.png)


### Deployment
#### Terraform
Use terraform to provision ECS, Redis and RDS MySQL instances that used in this solution against this .tf file:
[https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/blob/main/deployment/terraform/main.tf](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/blob/main/deployment/terraform/main.tf)


For more information about how to use Terraform, please refer to this tutorial: [https://www.youtube.com/watch?v=zDDFQ9C9XP8](https://www.youtube.com/watch?v=zDDFQ9C9XP8)
For the video tutorial about how to use Redis and RDS MySQL, and cache retiring based on TTL in Redis, please refer to: [https://www.youtube.com/watch?v=_JqcsKyDljw](https://www.youtube.com/watch?v=_JqcsKyDljw)


### Run Demo
#### Step 1: Log on ECS & setup environment
In this tutorial, Alibaba Cloud Linux is used,  when you check with the terraform script, you will see the image id is: aliyun_2_1903_x64_20G_alibase_20200904.vhd

- Get the EIP of the ECS, and then logon to ECS via SSH. Please use the account root/N1cetest, the password has been predefined in Terraform script for this tutorial. If you changed the password, please use the correct password accordingly.

![image.png](http://gitlab.alibaba-inc.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/master/images/step1_1.png)

![image.png](http://gitlab.alibaba-inc.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/master/images/step1_2.png)

```bash
ssh root@<EIP_ECS>
```

- Run the following command to install required utilities on the instance, including JDK, Maven and MySQL with MySQL Client: 

```bash
yum install java-latest-openjdk.x86_64
yum install maven
yum install mysql
```

#### Step 2: Modify & run application
Execute the following commands one by one, which are to download the demo application code, then build the demo Java application.

```bash
wget https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/main/source.tar.gz
tar xvf source.tar.gz && cd source
mvn clean package assembly:single -DskipTests
```

Edit the env.sh file to set the Redis and RDS MySQL endpoints (you can get from Redis and RDS MySQL web console) accordingly.

- Redis endpoint:

![image.png](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/main/images/step2_1.png)

- RDS MySQL endpoint:

![image.png](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/main/images/step2_2.png)

- Edit to apply the Redis and RDS MySQL endpoints

![image.png](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/main/images/step2_3.png)

![image.png](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/main/images/step2_4.png)

Use the mysql_client.sh to create a demo table and insert some records into the RDS MySQL.

```bash
sh mysql_client.sh < rosebowl.sql
```

![image.png](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/main/images/step2_5.png)

You can also use mysql_client.sh to query the data in RDS MySQL. There should be 30 records now.

![image.png](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/main/images/step2_6.png)

![image.png](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/main/images/step2_7.png)

Run the Redis demo application to verify the cache and TTL logic. You can pick up a query from the file query.sql to run. The default TTL is set as 10 seconds in the demo application. It will tell you that the result is fetched from MySQL or Redis cache. Do remember that the life time of query result in Redis cache is only 10 seconds. If you want to make it longer, you can modify the code [https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/blob/main/source/src/main/java/demo/RedisCache.java](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/blob/main/source/src/main/java/demo/RedisCache.java) and build to run again.

```bash
sh run_sample_app.sh
```

![image.png](https://github.com/alibabacloud-labs/solution-mysql-redis-cache-simple/raw/main/images/step2_8.png)
