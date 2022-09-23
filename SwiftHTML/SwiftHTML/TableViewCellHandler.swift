//
//  TableViewCellHandler.swift
//  SwiftHTML
//
//  Created by MTX on 2022/9/4.
//

/*
 % gitbook build SDE
 导出后的_book文件夹拷贝到 ../Resources目录下并重命名为SDE.bundle
 
 将工程中index.html中的
 /">
 全部替换为
 /index.html">
 即可实现本地加载HTML并正确跳转对应的页面!
 
 但是iOS这边还有沙盒文件访问的权限控制，最终只能妥协为建立本地服务器，这样什么都不用改了，效果和发布到服务器是一样的！
 
 可以使用Safari开发中的网页检查器工具调试当前真机上显示的webview的内容和终端日志！
 
 URL在线转码工具：https://www.sojson.com/encodeurl.html
 
 Cross origin requests are only supported for HTTP.
 SecurityError: Blocked attempt to use history.pushState() to change session history URL from file:///var/mobile/Containers/Data/Application/5B1847C7-FEFF-42C5-A735-6E6B417B8514/tmp/SDE.bundle/index.html to file:///var/mobile/Containers/Data/Application/5B1847C7-FEFF-42C5-A735-6E6B417B8514/tmp/SDE.bundle/%E8%80%83%E8%AF%95%E5%A4%A7%E7%BA%B2/index.html. Paths and fragments must match for a sandboxed document.
 
 SecurityError: Blocked attempt to use history.pushState() to change session history URL from file:///var/mobile/Containers/Data/Application/9159B41D-EBEF-44BE-8884-A328B065B9C1/tmp/SDE.bundle/index.html to file:///var/mobile/Containers/Data/Application/9159B41D-EBEF-44BE-8884-A328B065B9C1/tmp/SDE.bundle/Summary/index.html. Paths and fragments must match for a sandboxed document.
 */

/*
 Gitbook目前最稳定的版本：
 % gitbook fetch 3.2.3
 其余版本有各种环境配置问题！！！
 */

/*
 一、卸载GitBook(没有安装的跳过此步骤)

 Tips:前导摘要：记得有一次不小心卸载了一个东西，后面执行gitbook init报错：Cannot find module 'internal/util/types

 找到C:\Users\{User}\.gitbook 找到并删除此文件夹
 % rm /usr/local/bin/gitbook

 删除后执行命令

 # npm uninstall -g gitbook
 # npm uninstall -g gitbook-cli
 --- 清除npm缓存
 # npm cache clean --force
 
 二、安装GitBook

 需要node环境 ➡️ Linux或Win下安装node和npm
 需要Git环境 ➡️ https://www.jianshu.com/p/f2da5e76a588

 # npm install gitbook -g
 # npm install -g gitbook-cli
 --- 如果没有安装gitbook,此命令会默认同时安装 GitBook
 # gitbook -V
 --- 列出本地所有的gitbook版本
 # gitbook ls
 
 Tips:GitBook常用命令

 gitbook -V 查看版本号
 gitbook ls 列出本地所有的gitbook版本
 gitbook init 初始化
 gitbook install 安装插件
 gitbook serve 预览
 gitbook build 生成
 gitbook build --gitbook=2.6.7 生成时指定gitbook的版本, 本地没有会先下载
 gitbook uninstall 2.6.7 卸载指定版本号的gitbook
 gitbook fetch [version] 获取[版本]下载并安装<版本>
 gitbook --help 显示gitbook-cli帮助文档
 gitbook help 列出 gitbook 所有的命令
 gitbook ls-remote 列出NPM上的可用版本：
 */

/*
 
 % gitbook -V
 CLI version: 2.3.2
 GitBook version: 2.6.9
 
 % gitbook ls-remote
 Available GitBook Versions:

      4.0.0-alpha.6, 4.0.0-alpha.5, 4.0.0-alpha.4, 4.0.0-alpha.3, 4.0.0-alpha.2, 4.0.0-alpha.1, 3.2.3, 3.2.2, 3.2.1, 3.2.0, 3.2.0-pre.1, 3.2.0-pre.0, 3.1.1, 3.1.0, 3.0.3, 3.0.2, 3.0.1, 3.0.0, 3.0.0-pre.15, 3.0.0-pre.14, 3.0.0-pre.13, 3.0.0-pre.12, 3.0.0-pre.11, 3.0.0-pre.10, 3.0.0-pre.9, 3.0.0-pre.8, 3.0.0-pre.7, 3.0.0-pre.6, 3.0.0-pre.5, 3.0.0-pre.4, 3.0.0-pre.3, 3.0.0-pre.2, 3.0.0-pre.1, 2.6.9, 2.6.8, 2.6.7, 2.6.6, 2.6.5, 2.6.4, 2.6.3, 2.6.2, 2.6.1, 2.6.0, 2.5.2, 2.5.1, 2.5.0, 2.5.0-beta.7, 2.5.0-beta.6, 2.5.0-beta.5, 2.5.0-beta.4, 2.5.0-beta.3, 2.5.0-beta.2, 2.5.0-beta.1, 2.4.3, 2.4.2, 2.4.1, 2.4.0, 2.3.3, 2.3.2, 2.3.1, 2.3.0, 2.2.0, 2.1.0, 2.0.4, 2.0.3, 2.0.2, 2.0.1, 2.0.0, 2.0.0-beta.5, 2.0.0-beta.4, 2.0.0-beta.3, 2.0.0-beta.2, 2.0.0-beta.1, 2.0.0-alpha.9, 2.0.0-alpha.8, 2.0.0-alpha.7, 2.0.0-alpha.6, 2.0.0-alpha.5, 2.0.0-alpha.4, 2.0.0-alpha.3, 2.0.0-alpha.2, 2.0.0-alpha.1

 Tags:

      latest : 2.6.9
      pre : 4.0.0-alpha.6
 
 https://blog.csdn.net/Wu_shuxuan/article/details/101292320
 
 
 报错信息：Error loading version latest: Error: Cannot find module ‘internal/util/types’
 问题解决：这个问题原因在于graceful-fs引入了node模块internal/util/types，此模块用处是给vm引入内置js文件，具体作用不可知也不想去考究了，重点在于此法已被废除，只有低版本nodejs和npm可用，但是强行降低node版本有点削足适履的意思，这种天怒人怨的低级bug，graceful-fs开发团队应该早就修复了才对，为什么还会出现报错，去gitbook的git仓库看了一下版本更迭，gitbook-cli默认的版本是2.6.9，最新的版本3.2.2，推测是旧版本没有使用最新版本的graceful-fs导致的问题，更新之后即可正常运行

 % gitbook fetch 3.2.2
 
 % gitbook build SDE
 (node:15139) fs: re-evaluating native module sources is not supported. If you are using the graceful-fs module, please update it to a more recent version.
 
 % npm info graceful-fs | grep 'version:'
   version: '4.2.10',
    { preversion: 'npm test',
      postversion: 'npm publish',
 
 % npm install  -g graceful-fs@^4.0.0
 
 https://blog.csdn.net/iteye_954/article/details/82651867
 graceful-fs 在 node V6 下不支持，需要降级
 
 安装 n 工具，这个工具是专门用来管理node.js版本的
 sudo npm install -g n
 安装并切换至版本 5
 sudo n 5
 
 % node -v
 v5.12.0
 
 查看node安装路径
 % which node
/usr/local/bin/node
 
 更新最新的node稳定版本
 % sudo n stable
 
 % sudo n 8
      copying : node/8.17.0
    installed : v8.17.0 (with npm 6.13.4)
 
 % npm -v
 6.13.4
 
 更新npm版本
 % sudo npm install npm -g
 
 re-evaluating native module sources is not supported. If you are using the graceful-fs module, please update it to a more recent version.
 
 % npm info graceful-fs -v
3.10.10

 % sudo npm i graceful-fs@latest -g
 
 GitBook 是一个基于 Node.js 的命令行工具，可使用 Github/Git 和 Markdown来制作精美的电子书，GitBook 并非关于 [Git]的教程。
 Gitbook 只支持 node 6.x.x版本，node版本不对，使用n或者nvm切换node版本重新安装 gitbook-cli
 % npm install -g gitbook-cli
 */

/*
 https://www.cnblogs.com/aaronthon/p/13612189.html
 
 gitbook在build生成html以后左侧菜单的超链接不能点击了, 主要是gitbook不在支持本地模式了
 既然不能点击, 那就自己修改一下, 添加个js点击事件, 让页面跳转即可
 
 在每个md文件中添加以下代码即可
 
 <script type="text/javascript">
 window.addEventListener("load", function() {
   var click_handle = function() {
     if (this.href.substr(-5) == ".html") {
       location.href = this.href;
     } else {
       location.href = "./index.html";
     }
   };
   var as = document.querySelectorAll(".chapter a, .navigation-prev, .navigation-next");
   for (var i = 0; i < as.length; i++) {
     as[i].addEventListener("click", click_handle, true);
     as[i].title = as[i].innerText;
   }
 });
 </script>
 */

/*
 
 // file:///Users/mountainx/Documents/SDE-Gitbook/Resources/SDE.bundle/考试真题/2019下半年/软件设计/index.html
 // file:///Users/mountainx/Documents/SDE-Gitbook/Resources/SDE.bundle/考试真题/2021上半年/软件设计/
 
 https://blog.csdn.net/weixin_42057852/article/details/81776917
 
 解决办法

 找到js代码，并修改
 
 找到项目目录gitbook
 找到目录下的theme.js文件
 找到下面的代码
 将if(m)改成if(false)
 
 由于代码是压缩后的，会没有空格，搜索的时候可以直接搜索： if(m)for(n.handler&&
 
 https://blog.csdn.net/u013416034/article/details/119299854
 
 当前使用gitbook在写一些文档，但使用导出编译git build 后，生成的静态HTML页面，无法翻页到上下章节。 但放在服务器上线上就正常。于是乎是去查询相关资料。
 
 git build XXX --gitbook=2.6.7
 
 % gitbook --version
CLI version: 2.3.2
GitBook version: 3.2.2

 
 -canOpenURL: failed for URL: "file:///var/containers/Bundle/Application/0D7D4C35-8EB3-4D3E-9C1A-2E8383A8EFD5/SwiftHTML.app/SDE.bundle/index.html#" - error: "This app is not allowed to query for scheme file"
 
 https://www.jianshu.com/p/8f9b778efb5f/
 
 在ios9以上版本我们加载本地html只需要用webView.loadHTMLString加载就可以，但在ios8中是无法用这个方法加载的
 
 将本地的HTML相关文件移动到tmp文件夹下（tmp下的子文件夹也可以），一定要是tmp下，其它文件夹下不可以，然后用webView.load(URLRequest）方法进行加载。而直接用webView.load(URLRequest）加载APP中的HTML文件是无法成功的。
 其实放在tmp的原因很简单webView.load是加载网络html的方法，而网络中的html会缓存在tmp下,也就是说webView.load加载的tmp下的HTML文件被看成是网络加载了
 
 2022-09-05 07:23:29.934924+0800 SwiftHTML[1610:301841] -canOpenURL: failed for URL: "file:///var/mobile/Containers/Data/Application/5AD3132F-C2DA-4C86-88F3-1824B70AEA86/tmp/SDE.bundle/index.html#" - error: "This app is not allowed to query for scheme file"
 
 https://www.jianshu.com/p/72be2db298d1
 
 最后发现是 node 版本的问题，当前本机最新版本为 10.x.x， 而Gitbook 只支持 6.x.x ，我试过将 Gitbook升级最新版，包括pre版也是不行的
 
 % node -v
 v8.6.0
 
 # 查看所有版本
 gitbook ls-remote
  # 升级至最新预览版
 gitbook update pre
 
 安装 n 工具，这个工具是专门用来管理node.js版本的
 sudo npm install -g n
 安装并切换至版本 6
 sudo n 6
 
 */

import UIKit

class TableViewCellHandler: NSObject {
    class func handleNormal(nav: UINavigationController, model: MLCellModel) {
        let vc = WebViewController()
        vc.model = model
        nav.pushViewController(vc, animated: true)
    }
}
