## 服务端

#### 接收并响应客户端指令
- 计划用CocoaHTTPServer来做。这块不太熟悉，暂时先做到支持在局域网环境下的数据交互。

#### 下载代码
- NSTask执行svn命令行工具。
- 获取指定分支代码。

#### 打包IPA
- NSTask执行xcrun命令行工具。

#### 上传至蒲公英
- 蒲公英API

#### 发送邮件通知
- NSTask执行SendEmail命令行工具。


## 客户端

- 向服务端发送打包指令
- 显示可以打包的分支列表
- 设置 API HOST
- 线上环境/开发环境


## 代码提交方式调整
主要大致分三层

- tag 保存已经发布的代码。
- release 可正确运行的代码，提供给测试打包用。
- develop 开发中的代码，根据需求或者个人来切分支，完成一部分后向release合并。

## 依赖文件管理
- 单独开一个代码仓库放依赖文件并管理依赖文件版本。  
- 需要写个脚本根据项目配置文件更新依赖文件。

