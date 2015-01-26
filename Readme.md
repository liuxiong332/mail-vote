
# 使用须知

* 安装ruby

    windows下，可以下载installer一键安装

* 安装mongodb

    通过`mongod -dbpath <db path>`启动mongo数据库服务进程

* 安装ruby包管理工具bundle

    `gem install bundle`

* 在root目录下，运行`bundle install`安装依赖包

# 运行服务端

在root目录下，运行`rake run`启动服务进程

# 测试

在root目录下，运行`rake test`

# 自动运行(模拟服务端和客户端的一次通信过程)

在root目录下，运行`rake autorun`

