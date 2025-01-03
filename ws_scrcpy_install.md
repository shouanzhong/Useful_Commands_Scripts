**ws-scrcpy** 是一个通过 WebSocket 实现的远程安卓屏幕控制工具，它结合了 `scrcpy` 的强大功能和 Web 技术，允许在浏览器中访问安卓设备。

### **运行步骤：**

1.  **安装前提条件**：
    
    *   确保已安装 `adb` 和 `scrcpy`。
    *   确保设备通过 USB 或 WiFi 正确连接到主机，并可以被 `adb devices` 检测到。
2.  **安装 Node.js**:
    
    *   根据 ws-scrcpy 的 GitHub 仓库，建议使用 **Node.js 16.x 或更高版本**。
3.  **克隆 ws-scrcpy 仓库**：
    
    ```bash
    git clone https://github.com/NetrisTV/ws-scrcpy.git
    cd ws-scrcpy
    ```
    
4.  **安装依赖**：
    
    ```bash
    npm install
    ```
    
5.  **运行服务**：
    
    *   启动 WebSocket 服务：
        
        ```bash
        npm start
        ```
        
    *   默认情况下，服务会在 `ws://localhost:8083` 上运行。
6.  **访问前端界面**：
    
    *   打开浏览器，访问 `http://localhost:8080`。
    *   浏览器会连接到 WebSocket 服务，显示安卓设备屏幕。
7.  **连接设备**：
    
    *   使用 `adb devices` 确认设备已连接。
    *   在浏览器的设备列表中选择目标设备，即可开始控制。

* * *

### **Node.js 版本要求**：

*   推荐使用 Node.js 16 或更高版本。
*   如果系统上没有安装对应版本的 Node.js，可以使用 [nvm](https://github.com/nvm-sh/nvm) 管理 Node.js 版本：
    
    ```bash
    nvm install 16
    nvm use 16
    ```
    

如果需要更多配置指导或遇到问题，可以查看 ws-scrcpy 的 [官方文档](https://github.com/NetrisTV/ws-scrcpy)。



  

## 安装 node-gyp 失败问题:
问题异常，请使用`npm install -g node-gyp`复现。  
大概是提示："**npm ERR! gyp ERR! find VS looking for Visual Studio 2015**"  
问题的根本原因是 `node-gyp` 无法找到 Visual Studio 的相关工具来编译 `node-pty` 模块。以下是解决方法的详细步骤：

* * *

### **解决步骤**

#### 1\. **安装 Visual Studio 和 C++ 工作负载**

*   下载并安装 [Visual Studio 2022 Community](https://visualstudio.microsoft.com/zh-hans/vs/community/) 或更新的版本。
*   在安装过程中，确保选择 **"Desktop development with C++"** 工作负载，同时包括以下组件：
    *   MSBuild
    *   Windows 10 或 11 SDK
    *   C++ CMake 工具
-   安装完成后，重启电脑，一般就能解决。重新运行 `npm install` 就可以了。

#### 2\. **配置环境变量**

*   安装完成后，确保命令行可以找到 Visual Studio 工具：
    *   打开 **开发者命令提示符 (Developer Command Prompt)**，执行以下命令以验证路径：
        
        ```cmd
        cl
        ```
        
        如果命令返回编译器版本信息，说明配置正常。

#### 3\. **升级 `node-gyp`**

*   有时旧版本的 `node-gyp` 可能会导致兼容性问题，升级到最新版本：
    
    ```bash
    npm install -g node-gyp
    ```
    

#### 4\. **确保 Python 版本兼容**

*   日志显示 Python 版本为 `3.11.9`。确保 Python 版本在 `3.x` 范围内。
*   如果需要，可以指定 Python 版本：
    
    ```bash
    npm config set python "C:\Path\To\Python.exe"
    ```
    

#### 5\. **清理缓存和重新安装依赖**

*   删除 `node_modules` 文件夹和 `package-lock.json` 文件，然后重新安装依赖：
    
    ```bash
    npm cache clean --force
    rm -rf node_modules package-lock.json
    npm install
    ```
    

#### 6\. **手动安装 `node-pty`**

*   如果问题仍然存在，可以单独尝试安装 `node-pty`：
    
    ```bash
    npm install node-pty
    ```
    

* * *

### **附加检查**

1.  确保你正在使用的 Node.js 版本支持当前的依赖项（推荐 Node.js 16.x 或 18.x）。
2.  如果问题仍然未解决，可以尝试降低 `node-pty` 的版本以兼容项目需求：
    
    ```bash
    npm install node-pty@最新兼容版本号
    ```
    

#### **参考文档**

*   [node\-gyp 官方指南](https://github.com/nodejs/node-gyp#on-windows)
*   [node\-pty GitHub](https://github.com/microsoft/node-pty)

完成以上步骤后，再次运行 `npm install`，问题应能解决。
