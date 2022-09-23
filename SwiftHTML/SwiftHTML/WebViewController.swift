//
//  WebViewController.swift
//  SwiftHTML
//
//  Created by Gavin Xiang on 2022/9/23.
//

import Foundation
import WebKit
import JXPhotoBrowser
import Photos
import Toast_Swift

enum ReadType {
    case learning
    case examination
}

class WebViewController: UIViewController {
    
    static let kObserveKeyPath = "url"
    static let kObserveEstimatedProgress = "estimatedProgress"
    static let kObserveTitle = "title"
    
    var webView: WKWebView?
    
    var progress: UIProgressView?
    
    var model: MLCellModel!
    
    var readType: ReadType = .learning
    
    var switchBtn: UIBarButtonItem?
    
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
        
        if model.type == .none {
            webView?.load(URLRequest(url: URL(string: model.remoteUrlStr ?? "")!))
        } else {
            let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            delegate.httpServer.setDocumentRoot(model?.documentRoot())
            delegate.startServer()
            let localHttpAddress = "http://localhost:\(delegate.httpServer.port())\(model?.relativePath ?? "")"
            webView?.load(URLRequest(url: URL(string: localHttpAddress)!))
        }
        
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.blue, for: .normal)
        btn.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
        btn.setTitle("🔝", for: .normal)
        btn.addTarget(self, action: #selector(self.test), for: .touchUpInside)
        let scrollToTopBtn = UIBarButtonItem(customView: btn)
        
        let btn2 = UIButton(type: .custom)
        btn2.setTitleColor(.blue, for: .normal)
        btn2.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
        btn2.setTitle("答题", for: .normal)
        btn2.addTarget(self, action: #selector(self.switchBtnClicked(sender:)), for: .touchUpInside)
        let readTypeSwitchBtn = UIBarButtonItem(customView: btn2)
        switchBtn = readTypeSwitchBtn
        
        if model.type == .none {
            navigationItem.rightBarButtonItem = scrollToTopBtn
        } else {
//            navigationItem.rightBarButtonItem = readTypeSwitchBtn
        }
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
    
    /*
     用 CSS 隐藏页面元素有许多种方法。你可以将 opacity 设为 0、将 visibility 设为 hidden、将 display 设为 none 或者将 position 设为 absolute 然后将位置设到不可见区域
     
     这里我们只是隐藏，物理位置不变，方便来回切换查看而保持布局不变。
     */
    @objc func switchBtnClicked(sender: UIButton) {
        if readType == .learning {
            readType = .examination
            sender.setTitle("学习", for: .normal)
            let script = "var arrayOfDocFonts = document.getElementsByTagName(\"div\");for (var i = 0; i < arrayOfDocFonts.length; i++) {if (arrayOfDocFonts[i].style.display == \"inline\" && arrayOfDocFonts[i].className != \"back-to-top\"){arrayOfDocFonts[i].style.setProperty('visibility','hidden');}}"
            webView?.evaluateJavaScript(script, completionHandler: nil)
        } else {
            readType = .learning
            sender.setTitle("答题", for: .normal)
            let script = "var arrayOfDocFonts = document.getElementsByTagName(\"div\");for (var i = 0; i < arrayOfDocFonts.length; i++) {if (arrayOfDocFonts[i].style.display == \"inline\" && arrayOfDocFonts[i].className != \"back-to-top\"){arrayOfDocFonts[i].style.setProperty('visibility','visible');}}"
            webView?.evaluateJavaScript(script, completionHandler: nil)
        }
        
    }
    
    func setUpWKwebView() -> WKWebView {
        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = true
        preferences.setValue(true, forKey:"allowFileAccessFromFileURLs")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.allowsInlineMediaPlayback = true
        
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences.javaScriptEnabled = true
        
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = pagePreferences
        
        // register user script
        let js = "var srcArr=[]; var allImage=document.getElementsByTagName('img');for(var i=0;i<allImage.length;i++){var image = allImage[i]; image.index = i;srcArr.push({'pic_url': image.src});image.onclick = function () {console.log('img-click');window.webkit.messageHandlers.\(getHtmlImagesHandlerName()).postMessage({'index':this.index,'srcArr':srcArr});}}"
        let userScript = WKUserScript.init(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: false)//true
        let uservc = WKUserContentController.init()
        uservc.addUserScript(userScript)
        // Adds a script message handler to the main world used by page content itself.
        uservc.add(self, name: getHtmlImagesHandlerName())
        configuration.userContentController = uservc
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        
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
//        print("decidePolicyFor:\n\(url)")
//        guard url.host != "localhost" else {
//            decisionHandler(.allow)//always allow for local navigation action
//            return
//        }
        var policy: WKNavigationActionPolicy = .allow
        if navigationAction.navigationType == .linkActivated {//跳转别的应用如系统浏览器
            if model.type == .none {
                //除了gitbook，其他外链，防止在WKWebView中打开Universal Link，强制禁止跳转其他app，方便在当前app进行了浏览
                policy = WKNavigationActionPolicy(rawValue: 1 + 2)!//返回.allow+2的枚举值 _WKNavigationActionPolicyAllowWithoutTryingAppLink
            } else {
                if  UIApplication.shared.canOpenURL(url) {// 对于跨域，需要手动跳转
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    // 不允许web内跳转
                    policy = .cancel
                }
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
        //test
        if model.type != .none {
            webView.attachImageViewerGesture()
        }
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == getHtmlImagesHandlerName() {
            let bodyTemp = message.body as! [String: Any]
            let index = bodyTemp["index"] as! Int
            
            let images = bodyTemp["srcArr"] as! Array<String>
            
           //下面这个代码是我自己封装的查看网络图片的浏览器
            self.webView?.showWebViewBrowser(index: index, images: images)
        }
    }
    
    func getHtmlImagesHandlerName() -> String {
        return "previewimages"
    }
}

extension WKWebView: UIGestureRecognizerDelegate {
    //这里增加手势的返回，不然会被WKWebView拦截
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func attachImageViewerGesture() {
        if customTapGesture == nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleImageViwerTapAction(sender:)))
            tap.delegate = self
            addGestureRecognizer(tap)
            customTapGesture = tap
        }
        
        if customLongPressGesture == nil {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleImageViwerTapAction(sender:)))
            longPress.delegate = self
            longPress.minimumPressDuration = 0.5
            addGestureRecognizer(longPress)
            customLongPressGesture = longPress
        }
        
        customTapGesture!.require(toFail: customLongPressGesture!)
    }
    
     @objc private func handleImageViwerTapAction(sender: UIGestureRecognizer) {
         if sender is UILongPressGestureRecognizer && sender.state != .ended {
             return
         }
        let touchPoint = sender.location(in: self)
        let imageURLJS = "document.elementFromPoint(\(touchPoint.x), \(touchPoint.y)).src"
        evaluateJavaScript(imageURLJS) { result, error in
            if error == nil {
                let url: String? = result as? String
                guard url?.count ?? 0 > 0 else { return }
                
                let imgUrl = URL(string: url!)
                guard (imgUrl != nil) else { return }
                do {
                    let imageData = try Data(contentsOf: imgUrl!)
                    let image = UIImage(data: imageData)
                    guard (image != nil) else { return }
                    self.showPhotos(photos: [image!])
                } catch let e {
                    print(e.localizedDescription)
                    return
                }
                
            }
        }
    }
    
    private func showPhotos(photos: [UIImage]) {
        let browser = JXPhotoBrowser()
        browser.numberOfItems = {
            photos.count
        }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            let indexPath = IndexPath(item: context.index, section: 0)
            browserCell?.imageView.image = photos[indexPath.item]
            browserCell?.longPressedAction = { cell, _ in
                if (cell.imageView.image != nil) {
                    self.longPress(cell: cell)
                }
            }
        }
        browser.show()
    }
    
    public func showWebViewBrowser(index: NSInteger, images: [String]) {
        let browser = JXPhotoBrowser()
        browser.numberOfItems = {
            images.count
        }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            browserCell?.longPressedAction = { cell, _ in
                if (cell.imageView.image != nil) {
                    self.longPress(cell: cell)
                }
            }
            let url = images[context.index]
            let imgUrl = URL(string: url)
            guard (imgUrl != nil) else { return }
            do {
                let imageData = try Data(contentsOf: imgUrl!)
                let image = UIImage(data: imageData)
                guard (image != nil) else { return }
                browserCell?.imageView.image = image
            } catch let e {
                print(e.localizedDescription)
                return
            }
        }
        browser.pageIndex = index
        browser.show()
    }
    
    private func longPress(cell: JXPhotoBrowserImageCell) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "保存到相册", style: .default, handler: { _ in
            self.saveImage(image: cell.imageView.image!, cell: cell)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        cell.photoBrowser?.present(alert, animated: true, completion: nil)
    }
    
    private func saveImage(image: UIImage, cell: JXPhotoBrowserImageCell) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { (isSuccess, error) in
            DispatchQueue.main.async {
                if isSuccess {// 成功
                    var style = ToastStyle()
                    style.messageColor = .white
                    style.backgroundColor = .gray
                    cell.photoBrowser?.view.makeToast("已保存到系统相册!", duration: 2.0, position: .bottom, style: style)
                }
            }
        })
    }
}

protocol PropertyStoring {

    associatedtype T

    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T
    func getAssociatedObject(_ key: UnsafeRawPointer!) -> UITapGestureRecognizer?
}

extension PropertyStoring {
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T {
        guard let value = objc_getAssociatedObject(self, key) as? T else {
            return defaultValue
        }
        return value
    }
    func getAssociatedObject(_ key: UnsafeRawPointer!) -> UITapGestureRecognizer? {
        guard let value = objc_getAssociatedObject(self, key) as? UITapGestureRecognizer else {
            return nil
        }
        return value
    }
    func getAssociatedObject(_ key: UnsafeRawPointer!) -> UILongPressGestureRecognizer? {
        guard let value = objc_getAssociatedObject(self, key) as? UILongPressGestureRecognizer else {
            return nil
        }
        return value
    }
}

extension WKWebView: PropertyStoring {

    typealias T = Bool

    private struct AssociatedKeys {
        static var kUsedAsTableHeaderView = "kUsedAsTableHeaderView"
        static var kCustomTapGesture = "kCustomTapGesture"
        static var kCustomLongPressGesture = "kCustomLongPressGesture"
    }

    public var qmui_usedAsTableHeaderView: Bool? {
        get {
            return getAssociatedObject(&AssociatedKeys.kUsedAsTableHeaderView, defaultValue: false)
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.kUsedAsTableHeaderView, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public var customTapGesture: UITapGestureRecognizer? {
        get {
            return getAssociatedObject(&AssociatedKeys.kCustomTapGesture)
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.kCustomTapGesture, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public var customLongPressGesture: UILongPressGestureRecognizer? {
        get {
            return getAssociatedObject(&AssociatedKeys.kCustomLongPressGesture)
        }
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.kCustomLongPressGesture, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
