//
//  AppDelegate.swift
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
 
 可以使用Safari开发中的网页检查器工具调试当前真机上显示的webview的内容和终端日志！
 
 URL在线转码工具：https://www.sojson.com/encodeurl.html
 
 Cross origin requests are only supported for HTTP.
 SecurityError: Blocked attempt to use history.pushState() to change session history URL from file:///var/mobile/Containers/Data/Application/5B1847C7-FEFF-42C5-A735-6E6B417B8514/tmp/SDE.bundle/index.html to file:///var/mobile/Containers/Data/Application/5B1847C7-FEFF-42C5-A735-6E6B417B8514/tmp/SDE.bundle/%E8%80%83%E8%AF%95%E5%A4%A7%E7%BA%B2/index.html. Paths and fragments must match for a sandboxed document.
 
 SecurityError: Blocked attempt to use history.pushState() to change session history URL from file:///var/mobile/Containers/Data/Application/9159B41D-EBEF-44BE-8884-A328B065B9C1/tmp/SDE.bundle/index.html to file:///var/mobile/Containers/Data/Application/9159B41D-EBEF-44BE-8884-A328B065B9C1/tmp/SDE.bundle/Summary/index.html. Paths and fragments must match for a sandboxed document.
 */

/*
 https://blog.csdn.net/lrbtony/article/details/114373443
 http://wjhsh.net/yajunLi-p-8488946.html
 
 主要是解决沙盒文件加载的权限问题，搭建一下本地服务器
 */

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let httpServer = HTTPServer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        sleep(1)//show launch screen too fast
        openServer()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: HTTP Server
    func openServer() {
        httpServer.setType("_http._tcp.")
        httpServer.setPort(6080)
        
//        let htmlBundlePath = Bundle.main.path(forResource: "MichaelLedger", ofType: "bundle")
//        httpServer.setDocumentRoot(htmlBundlePath!)
    }
    
    func startServer() {
        guard (httpServer.documentRoot() != nil) else {
            return
        }
        do {
            try httpServer.start()
        } catch let e {
            print(e)
            return
        }
        print("HTTP服务器启动成功端口号为：\(httpServer.listeningPort())")
    }
    
    func stopServer() {
        httpServer.stop()
    }

}

