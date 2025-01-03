### 一、前提条件

确保服务器安装了以下依赖：

**Java 17+**：用于运行 Sonic 服务端  
**MySQL 8+**：用于存储平台数据  
**Node.js 和 NPM (NVM 更灵活)**：用于构建前端资源  
**ADB**：用于连接安卓设备（仅客户端需要）  

#### 安装java17  
1. 更新系统包管理器  
```bash
sudo apt update
```
2. 安装 OpenJDK 17  
在基于Debian/Ubuntu的系统上，可以直接通过包管理器安装OpenJDK 17：
```
bash
sudo apt install openjdk-17-jdk
```  
对于基于RHEL/CentOS的系统，可以使用以下命令：
```
bash
sudo yum install java-17-openjdk-devel
```  
3. 验证安装  
安装完成后，确认Java版本：
```bash
java -version
```
如果安装成功，应该看到类似以下输出：
```
openjdk version "17.0.x" ... 
```
4. 设置 JAVA_HOME 环境变量（可选）  
有些应用需要设置 JAVA_HOME 环境变量。将以下内容添加到你的 `~/.bashrc` 或 `/etc/profile` 文件中：  

bash

export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
export PATH=$JAVA_HOME/bin:$PATH
然后使更改生效：

```bash
source ~/.bashrc
```
5. 检查 JAVA_HOME 变量  
确认 JAVA_HOME 已正确设置：

```bash
echo $JAVA_HOME
```  
至此，Java 17+ 在Linux上安装和配置完成。

---

#### 安装&配置 Mysql
1. 安装 MySQL
```
# 更新包列表
sudo apt update

# 安装MySQL服务器
sudo apt install mysql-server

```

2. 安全配置  
运行安全安装向导，来设置root密码并移除不必要的测试数据库和用户：  
```
sudo mysql_secure_installation
```
在过程中，会提示设置root密码、移除匿名用户、禁止远程root登录、删除测试数据库等。根据需求选择。  

3. 登录 MySQL  
用root账户登录MySQL：  
```
sudo mysql -u root -p
```  

4. 创建数据库和用户  
在Sonic的配置中，需要一个独立的数据库和用户，按以下步骤创建：
```
-- 创建数据库
CREATE DATABASE sonic CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 创建新用户并设置密码（替换yourpassword为你的密码）
CREATE USER 'sonicuser'@'%' IDENTIFIED BY 'sonicpassword';

-- 赋予用户对数据库的全部权限
GRANT ALL PRIVILEGES ON sonic.* TO 'sonicuser'@'%';

-- 刷新权限
FLUSH PRIVILEGES;
```  
5. 修改配置以允许远程访问（可选）  
如果需要从其他服务器访问MySQL，编辑MySQL配置文件`/etc/mysql/mysql.conf.d/mysqld.cnf`（不同Linux版本路径可能有所不同），找到 `bind-address`，将其修改为：
```bash
bind-address = 0.0.0.0
```  
重启MySQL服务应用配置：  
```
sudo systemctl restart mysql
```  
6. 验证配置  
使用命令确认MySQL正在监听：
```
sudo netstat -tulnp | grep mysql
```  
7. 测试连接  
在MySQL客户端中可以使用新创建的用户进行连接测试：
```
mysql -u sonicuser -p -h 127.0.0.1 -P 3306 sonic
```  
至此，MySQL数据库配置完成，可以将其连接信息添加到Sonic的配置文件中

---

### 安装node.js & npm
参考官方文件：[https://github.com/nvm-sh/nvm](https://github.com/nvm-sh/nvm)
1. 安装NVM
运行以下命令
```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```  
或  
```
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```   
完成后执行
```
source ~/.bashrc
```  
2.安装node.js & npm  
查看可用node的长期维护版本  
```
nvm ls-remote --lts
```  
安装 (*低版本会导致源码编译失败*)
```
nvm install v20.18.0
```  
修改为国内源  
```
npm config set registry http://mirrors.cloud.tencent.com/npm/
```  
至此，node.js 安装完成  
**注意：当后续操作中 `npm run build` 出现问题，可尝试升级node版本**

---  
### 安装adb
```
sudo apt install adb
```
---
---

## 源码安装后端  

### 1. 下载服务端源码
```
git clone https://github.com/SonicCloudOrg/sonic-server.git
cd sonic-server
```  
### 2. 配置数据库  
打开 `sonic-server-common/src/main/resources/application-jdbc.yml` 文件。  
在文件中找到 `spring.datasource` 部分，并按以下内容进行配置：

```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    #  jdbc:mysql://{mysql host}:{mysql port}/{database}
    url: jdbc:mysql://${MYSQL_HOST:172.16.63.19}:${MYSQL_PORT:3306}/${MYSQL_DATABASE:sonic}?useUnicode=true&characterEncoding=utf8&serverTimezone=UTC&autoReconnect=true&serverTimezone=GMT%2b8
    # mysql username
    username: ${MYSQL_USERNAME:sonicuser}
    # mysql password
    password: ${MYSQL_PASSWORD:sonicpassword}
    schema:
      - classpath:data.sql
  sql:
    init:
      mode: always
```  
`url`：替换为你的MySQL数据库的URL。  
`username` 和 `password`：替换为之前创建的数据库用户名和密码  




### 3.构建服务端代码

```
若是使用idea ，则在修改数据库链接后，依次启动 eureka、gateway ... 
(右键执行模块下的Application.java 即可)

可跳过 1-4 步，直接验证 eureka 是否绑定了其他微服务
```

在 Sonic 项目的源码结构中，构建和运行服务端的主要操作应该在项目的根目录（即 `sonic-server` 目录）下执行。

##### 具体操作步骤

1. **导航到项目根目录**：

   如果当前不在 `sonic-server` 根目录，先进入该目录：

   ```bash
   cd /path/to/sonic-server
   ```

2. **构建服务端**：

   使用 Maven 构建整个项目，跳过测试：

   ```bash
   ./mvnw clean package -DskipTests
   ```
   或者  
   ```
   # 可能需要另外安装mvn
   mvn clean package -DskipTests
   
   # 可能需要修改maven源：
   # 修改 /usr/share/maven/conf/settings.xml 文件中的 mirrors 标签：
   #     修改访问权限
   #     chmod 777 /usr/share/maven/conf/settings.xml
   #     
   #     增加
   #     <mirror>
   #     	<id>aliyunmaven</id>
   #     	<mirrorOf>*</mirrorOf>
   #     	<name>阿里云公共仓库</name>
   #     	<url>https://maven.aliyun.com/repository/public</url>
   #     </mirror>
   ```
   
   这会在 `sonic-server` 的 `target` 目录下生成一个可执行的 `.jar` 文件，例如 `sonic-server-gateway/target/sonic-server-gateway.jar`。  
   如果构建失败，出现字体文件.woff 相关问题，可尝试修改一下插件版本(sonic-server/pom.xml)：
   ```
   <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-resources-plugin</artifactId>
      <version>3.1.0</version>
      <configuration>
        <nonFilteredFileExtensions>
          <nonFilteredFileExtension>woff</nonFilteredFileExtension>
          <nonFilteredFileExtension>woff2</nonFilteredFileExtension>
          <nonFilteredFileExtension>ttf</nonFilteredFileExtension>
        </nonFilteredFileExtensions>
      </configuration>
    </plugin>
	```


3. **启动 Eureka 服务器**：

   在 `sonic-server` 目录中找到 `sonic-server-eureka` 模块，并先启动这个模块，确保 Eureka 服务运行在默认的 `8761` 端口上。

   ```bash
   java -jar sonic-server-eureka/target/sonic-server-eureka.jar
   ```

   确认 `Eureka` 服务启动后，可以通过浏览器访问 `http://127.0.0.1:8761` 来查看 Eureka 的管理页面， 默认账号密码都是`sonic`。  
   配置信息在 `sonic-server-common/src/main/resources/application-sonic-server-eureka.yml` 文件的 `eureka.client.service-url` 字段
   
   ##### 注意
   如果pom.xml 中没有的话，可能需要安装security 依赖，版本可能需要调整：
   ```
   <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
    <version>3.1.8</version>
	</dependency>
   ```

4. **启动 `sonic-server-gateway`**：

   确认 Eureka 正常运行后，再启动 `sonic-server-gateway`：

   ```bash
   java -jar sonic-server-gateway/target/sonic-server-gateway.jar
   ```

5. **检查配置文件**：

   如果出现错误，确认 `sonic-server-gateway` 和其他模块的 `application.yml` 配置文件中，Eureka 服务器的地址是否正确：

   ```yaml
   eureka:
     client:
       serviceUrl:
         defaultZone: http://127.0.0.1:8761/eureka/
   ```

   确保 `defaultZone` 的地址和端口与实际运行的 Eureka 地址相匹配。



5. **验证服务是否成功启动**：

   可以在浏览器中访问 `http://localhost:8761` 来验证是否成功启动， 账号密码都是 `sonic`。
   查看 `Instances currently registered with Eureka` 中是否有已注册的Application。
   
   
   若点击注册的应用id，比如`gateway`应用的ID，跳转后提示异常(white page)，则需要安装依赖：
   ```
	    <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
   ```
   并在gateway 的配置文件yml中，增加如下内容(与spring、server同级，最高)：
	```
	management:
	  endpoints:
		web:
		  exposure:
			include: 
	  info:
		defaults:
		  enabled: true
   ```
   配置后即可访问 `/actuator` 路径，可看到包括 `/actuator/mappings` 在内的映射信息。

7. **验证gateway关联**
   访问 `localhost:3000/api/controller` ，若返回 `{"code":1001,"message":"unauthorized"}` 表示 gateway 绑定 controller 成功。

**注意**
* 如果需要更改服务端口、数据库连接等配置，可以在 `sonic-server-common/src/main/resources` 对应文件中进行修改。
* 出现依赖缺失的情况，最好直接访问**maven**仓库获取正确的依赖代码。

   
**额外**  
自定义函数验证服务的联通性。
在需要验证的模块，如controller中，定义类：
```
@RestController
@RequestMapping()
public class HelloTest {

    @GetMapping("/hello")
    public String hello() {
        return "hello, there is controller !";
    }
}

```
并在 gateway 的yml 配置中增加
```
filter:
  white-list: ...,/api/controller/hello,/hello
 ```
重启服务后，通过 eureka web 获取到端口，然后访问验证，如 
```
http://localhost:1299/hello                  # 验证controller服务
```
```
http://localhost:3000/api/controller/hello   # 验证gateway 与 controller 关联
```
其中 1299 是服务分配给 controller 的端口，每次都不一样。




-----------------------------------------------------------------------------------------------------------------------


## 源码安装前端(windows版)  

**下载源码**  
    ```
	git clone https://github.com/SonicCloudOrg/sonic-client-web.git
	```
	
### **目标**

使用 Nginx 部署 `sonic-client-web`，从而通过 `localhost:80`（或其他端口）访问 Sonic 的前端界面，同时确保其与 Sonic 的后端服务（如 `sonic-server-gateway` 和 `sonic-server-controller`）联通。

---

### **详细步骤**

#### **1\. 构建 `sonic-client-web` 前端**

确保 `sonic-client-web` 已经正确拉取到本地，并已安装 Node.js 和 npm。

在 `sonic-client-web` 目录下运行以下命令：

```bash
npm install
npm run build
```

构建成功后，会生成一个 `dist` 目录，其中包含所有前端静态文件。

---

#### **2\. 配置 Nginx**

在 Windows 上，假设您的 Nginx 根目录为：`D:\Program Files\nginx-1.18.0`。

我们将 `sonic-client-web` 的构建文件放到 `html` 文件夹中，并修改 Nginx 配置文件（`conf/nginx.conf`）以支持前端与后端服务的联通。

**将 `dist` 文件夹复制到 Nginx 的 `html` 目录：**

```powershell
xcopy /s /e /y dist "D:\Program Files\nginx-1.18.0\html"
```

---

#### **3\. 修改 Nginx 配置文件**

打开 `D:\Program Files\nginx-1.18.0\conf\nginx.conf`，确保配置如下：

```nginx
########################### sonic config start ###########################################
    server {
        listen 80;
        server_name localhost;

        # 前端静态文件路径
        location / {
            root "D:/Program Files/nginx-1.18.0/html/dist";
            index index.html;
            try_files $uri $uri/ /index.html;
        }

        # 代理到 Sonic 后端 API
        location /api/ {
            proxy_pass http://localhost:3000/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # 代理 WebSocket 请求
        location /websockets/ {
            proxy_pass http://localhost:3000/websockets/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
        }
        
        # 代理转发 API 请求到 Gateway
        location /server/api/ {
            proxy_pass http://localhost:3000/server/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # WebSocket 转发（如果有）
        location /server/websocket/ {
            proxy_pass http://localhost:3000/server/websocket/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

    }

########################### sonic config end   ###########################################

```

解释：

* `location /`：指向 `html` 文件夹，提供静态文件服务。
* `location /api/`：代理所有 `/api/` 开头的请求到 `sonic-server-gateway` 的 3000 端口。
* `location /websockets/`：代理 WebSocket 请求。

#### **4\. 启动 Nginx**

在 Windows 命令提示符（管理员模式）下运行：

```powershell
powershellcd "D:\Program Files\nginx-1.18.0"
nginx.exe
```

如果需要重新加载配置文件：

```powershell
powershellnginx.exe -s reload
```

#### **5\. 验证**

打开浏览器，访问：

* **`http://localhost`**：验证前端页面是否正确加载。
* **`http://localhost/api/controller/hello`**：验证通过前端页面访问后端服务是否正常工作。

---

### **总结**

通过以上步骤，您将 `sonic-client-web` 前端部署在 Nginx 上，并将 Nginx 作为反向代理，以便与 Sonic 后端服务交互。在 Windows 环境下，这样的配置可以让您在不使用 Docker 的情况下成功部署和运行整个 Sonic 云平台。
