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
import WebKit

class WebViewController: UIViewController {
    
    static let kObserveKeyPath = "url"
    static let kObserveEstimatedProgress = "estimatedProgress"
    static let kObserveTitle = "title"
    
    var webView: WKWebView?
    
    var progress: UIProgressView?
    
    var model: MLCellModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        let web = setUpWKwebView()
        web.navigationDelegate = self
        web.addObserver(self, forKeyPath: WebViewController.kObserveKeyPath, options: .new, context: nil)
        web.addObserver(self, forKeyPath: WebViewController.kObserveEstimatedProgress, options: .new, context: nil)
        web.addObserver(self, forKeyPath: WebViewController.kObserveTitle, options: .new, context: nil)
        view.addSubview(web)
        web.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        webView = web
        
        progress = UIProgressView(progressViewStyle: .default)
        progress?.trackTintColor = .white
        progress?.tintColor = .systemBlue
        view.addSubview(progress!)
        progress!.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(2)
        }
        
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.blue, for: .normal)
        btn.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
        btn.setTitle("Top", for: .normal)
        btn.addTarget(self, action: #selector(self.test), for: .touchUpInside)
        let rightBarItem = UIBarButtonItem(customView: btn)
        navigationItem.rightBarButtonItem = rightBarItem
        
//        let result = moveAppBundleToTempDir()
//        if result.success {
//            let htmlBundle = Bundle.init(path: result.path!)
//            let htmlFilePath = htmlBundle?.path(forResource: "index", ofType: "html")
//            let htmlUrl = URL(fileURLWithPath: htmlFilePath!)
//            print("htmlUrl:\(htmlUrl)")
//            webView?.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
//        }
        
        guard (model != nil) else {
            return
        }
        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        delegate.httpServer.setDocumentRoot(model?.documentRoot())
        delegate.startServer()
        let localHttpAddress = "http://localhost:\(delegate.httpServer.port())\(model?.relativePath ?? "")"
//        let localHttpAddress = "https://www.baidu.com"//test
        print(localHttpAddress)
        webView?.load(URLRequest(url: URL(string: localHttpAddress)!))
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        delegate.startServer()
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        delegate.stopServer()
//    }
    
    func moveAppBundleToTempDir() -> (path: String?, success: Bool) {
        let htmlBundlePath = Bundle.main.path(forResource: "SDE", ofType: "bundle")
//        let htmlBundle = Bundle.init(path: htmlBundlePath!)
//        let htmlFilePath = htmlBundle?.path(forResource: "index", ofType: "html")
        
        guard (htmlBundlePath != nil) && FileManager.default.fileExists(atPath: htmlBundlePath!) else {
            print("File not exists at path: \(htmlBundlePath ?? "")")
            return (nil, false)
        }
        
        /*
        (lldb) po htmlBundlePath
        ▿ Optional<String>
          - some : "/private/var/containers/Bundle/Application/50D0BF1C-D140-406A-BE1E-32DC79717780/SwiftHTML.app/SDE.bundle"

        (lldb) po htmlBundleLocalPath
        ▿ Optional<String>
          - some : "file:///private/var/containers/Bundle/Application/50D0BF1C-D140-406A-BE1E-32DC79717780/SwiftHTML.app/SDE.bundle/"
         */
//        let htmlBundleLocalPath = NSURL(fileURLWithPath: htmlBundlePath!).absoluteString
//        let htmlBundleLocalPath = "file://\(htmlBundlePath!)"
        
        var success = true
        let temp = NSTemporaryDirectory()
//        let tempBundlePath = NSURL.fileURL(withPath: temp).appendingPathComponent("SDE.bundle").absoluteString
        let tempBundlePath = temp.appending("/SDE.bundle")
        
        print("htmlBundleLocalPath:\(htmlBundlePath ?? "")\ntempBundlePath:\(tempBundlePath)")
        let fileManager = FileManager.default
        
        /*
         Error Domain=NSCocoaErrorDomain Code=513 "You don’t have permission to save the file “SDE.bundle” in the folder “tmp”." UserInfo={NSFilePath=file:///private/var/mobile/Containers/Data/Application/E1D17304-E01B-44E0-938A-EC4ACE1A8282/tmp/SDE.bundle, NSUnderlyingError=0x281938bd0 {Error Domain=NSPOSIXErrorDomain Code=1 "Operation not permitted"}}
         */
//        do {
//            try fileManager.createDirectory(atPath: tempBundlePath, withIntermediateDirectories: true, attributes: nil)
//        } catch let e {
//            print("\(e)")
//            success = false
//        }
        if fileManager.fileExists(atPath: tempBundlePath) {
            do {
                try fileManager.removeItem(atPath: tempBundlePath)
            } catch let e {
                print("\(e)")
            }
        }
//        if success {
            do {
                // Error Domain=NSCocoaErrorDomain Code=513 "“SDE.bundle” couldn’t be moved because you don’t have permission to access “tmp”."
//                try fileManager.moveItem(atPath: htmlBundlePath ?? "", toPath: tempBundlePath)
                try fileManager.copyItem(atPath: htmlBundlePath ?? "", toPath: tempBundlePath)
            } catch let e {
                print("\(e)")
                success = false
            }
//        }
        return (tempBundlePath, success)
    }
    
    @objc func test() {
//        print("\(String(describing: webView?.url))")
//        webView?.evaluateJavaScript("window.scrollTo(0,0)", completionHandler: nil)
//        webView?.scrollView.setContentOffset(.zero, animated: true)
//        webView?.evaluateJavaScript("document.getElementById('book-search-results').scrollTo(0,0)", completionHandler: nil)
//        webView?.evaluateJavaScript("console.log('123');", completionHandler: { (result, err) in
//            if (err != nil) {
//                print(err?.localizedDescription as Any)
//            } else {
//                print(result as Any)
//            }
//        })
//        let script = "$(window).scrollTop(200);"
//        let script = "window.scrollTo(0,0);"
        let script = "window.scrollTo({'behavior': 'smooth', 'top': 0});"
        // 10.2.1系统ios控制台一直报错 this.$refs.container.scrollTo is undefined,我自己手机系统是13.6.1 可以正常滚动，我分别打出来发现，10.2.1系统手机没有scrollTo 方法，但是有个scrollTop属性！
//        let script = "var scrollTop = document.documentElement.scrollTop || window.pageYOffset || document.body.scrollTop;window.scrollTo(0,0);var rs = document.getElementById('book-search-results');window.scrollTo({'behavior': 'smooth', 'top': rs.offsetTop});console.log('scrollToTopTest');"
//        let script = "var rs=document.getElementById('book-search-results');rs.scrollTop=1;console.log(\"%o\",rs.scrollTop);"
        webView?.evaluateJavaScript(script, completionHandler: nil)
        
        //gitbookb布局比较特殊，只好用专门的插件解决了
        //https://cloud.tencent.com/developer/article/1441115
        //https://github.com/stuebersystems/gitbook-plugin-back-to-top-button/blob/master/README.md
        /*
         mountainx@MountainXs SDE % touch book.json
         mountainx@MountainXs SDE % vim book.json
         mountainx@MountainXs SDE % gitbook install
         info: installing 1 plugins using npm@3.9.2
         info:
         info: installing plugin "back-to-top-button"
         info: install plugin "back-to-top-button" (*) from NPM with version 0.1.4
         /Users/mountainx/Documents/SDE-Gitbook/SDE
         └── gitbook-plugin-back-to-top-button@0.1.4

         info: >> plugin "back-to-top-button" installed with success
         */
    }
    
    func setUpWKwebView() -> WKWebView {
        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = true
        preferences.setValue(true, forKey:"allowFileAccessFromFileURLs")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.allowsInlineMediaPlayback = true
        
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
//        configuration.preferences.javaScriptEnabled = true
        
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = pagePreferences
        
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        //let myURL = URL(string: "https://weibo.com")
        //let myRequest = URLRequest(url: myURL!)
        //webView.load(myRequest)
        
//        let htmlBundlePath = Bundle.main.path(forResource: "SDE", ofType: "bundle")
//        let htmlBundle = Bundle.init(path: htmlBundlePath!)
//        let htmlFilePath = htmlBundle?.path(forResource: "index", ofType: "html")
//        let htmlUrl = URL(fileURLWithPath: htmlFilePath!)
//        webView.loadFileURL(htmlUrl, allowingReadAccessTo: htmlUrl)
        
        return webView
    }
    
    // Cannot override 'dealloc' which has been marked unavailable: use 'deinit' to define a de-initializer
    deinit {
        webView?.removeObserver(self, forKeyPath: WebViewController.kObserveKeyPath)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == WebViewController.kObserveKeyPath {
            print("URL changed to:\n\(String(describing: webView?.url?.absoluteString))")
        } else if keyPath == WebViewController.kObserveEstimatedProgress {
            progress?.progress = Float(webView!.estimatedProgress)
            if progress?.progress == 1 {
                UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseOut) {
                    self.progress?.transform = CGAffineTransform(scaleX: 1, y: 1)
                } completion: { (finished) in
                    self.progress?.isHidden = true
                }
            }
        } else if keyPath == WebViewController.kObserveTitle {
            navigationItem.title = webView!.title
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        print("decidePolicyFor:\n\(url)")
        guard url.host != "localhost" else {
            decisionHandler(.allow)//always allow for local navigation action
            return
        }
        var policy: WKNavigationActionPolicy = .allow
        if navigationAction.navigationType == .linkActivated {
            if  UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                policy = .cancel
            }
        }
        decisionHandler(policy)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progress?.isHidden = false
        progress?.transform = CGAffineTransform(scaleX: 1, y: 1.5)
        view.bringSubviewToFront(progress!)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseOut) {
            self.progress?.transform = CGAffineTransform(scaleX: 1, y: 1)
        } completion: { (finished) in
            self.progress?.isHidden = true
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseOut) {
            self.progress?.transform = CGAffineTransform(scaleX: 1, y: 1)
        } completion: { (finished) in
            self.progress?.isHidden = true
        }
    }
}

class TableViewCellHandler: NSObject {
    class func handleNormal(nav: UINavigationController, model: MLCellModel) {
        let vc = WebViewController()
        vc.model = model
        nav.pushViewController(vc, animated: true)
    }
}
