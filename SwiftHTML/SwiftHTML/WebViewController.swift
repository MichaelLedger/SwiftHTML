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
    
    var scrollTopBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.view.backgroundColor = .white
        
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.isTranslucent = false
        edgesForExtendedLayout = UIRectEdge.bottom//UIRectEdge.init(rawValue: 0)
        
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
            guard let url = URL(string: model.remoteUrlStr ?? "") else {
                return
            }
            webView?.load(URLRequest(url: url))
        } else if model.type == .pdf {
            navigationItem.title = model.title
            let filePath: String = Bundle.main.path(forResource: model.relativePath, ofType: nil) ?? ""
            
            //iOS14?????????wkwebview??????PDF???????????????????????????
//            do {
//                let data = NSData(contentsOfFile: filePath)
//                let accessURL = fileURL.deletingLastPathComponent()
//                webView?.load(data as! Data, mimeType: "application/pdf", characterEncodingName: "utf-8", baseURL: nil)
//            } catch let e {
//                print(e)
//            }
            
            let fileURL = URL(fileURLWithPath: filePath)//??????????????????
            let accessURL = fileURL.deletingLastPathComponent()
            webView?.loadFileURL(fileURL, allowingReadAccessTo: accessURL)//iOS10????????????
        } else {
            let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            delegate.httpServer.setDocumentRoot(model?.documentRoot())
            delegate.startServer()
            let localHttpAddress = "http://localhost:\(delegate.httpServer.port())\(model?.relativePath ?? "")"
            webView?.load(URLRequest(url: URL(string: localHttpAddress)!))
        }
        
        if model.type == .none {
            let btn = UIButton(type: .custom)
            btn.setTitleColor(.black, for: .normal)
            btn.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
            btn.setTitle("????", for: .normal)
            btn.addTarget(self, action: #selector(self.scrollToTop), for: .touchUpInside)
            btn.layer.cornerRadius = 22
            btn.clipsToBounds = true
            btn.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5)
            view.addSubview(btn)
            scrollTopBtn = btn
            btn.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaInsets.bottom).offset(-60)
                make.trailing.equalTo(view.snp.trailing).offset(-view.safeAreaInsets.right - 20)
                make.width.height.equalTo(44)
            }
    //        let scrollToTopBtn = UIBarButtonItem(customView: btn)
        }
        
        let btn2 = UIButton(type: .custom)
        btn2.setTitleColor(.blue, for: .normal)
        btn2.frame = CGRect(origin: .zero, size: CGSize(width: 44, height: 44))
        btn2.setTitle("??????", for: .normal)
        btn2.addTarget(self, action: #selector(self.switchBtnClicked(sender:)), for: .touchUpInside)
        let readTypeSwitchBtn = UIBarButtonItem(customView: btn2)
        switchBtn = readTypeSwitchBtn
        
//        if model.type == .none {
//            navigationItem.rightBarButtonItem = scrollToTopBtn
//        } else {
//            navigationItem.rightBarButtonItem = readTypeSwitchBtn
//        }
        
        
        let backCustomBtn = UIButton(type: .custom)
        backCustomBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 44)
        backCustomBtn.imageView?.tintColor = .black
        backCustomBtn.contentHorizontalAlignment = .leading
        backCustomBtn.setImage(UIImage(named: "back_normal")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backCustomBtn.setImage(UIImage(named: "back_pressed")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        backCustomBtn.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        let backBtn = UIBarButtonItem(customView: backCustomBtn)
        
        navigationItem.leftBarButtonItems = [backBtn]
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
    
    override func viewSafeAreaInsetsDidChange() {
        print(view.safeAreaInsets)
        scrollTopBtn?.snp.remakeConstraints { make in
            make.bottom.equalTo(view.safeAreaInsets.bottom).offset(-60)
//            make.trailing.equalTo(view.safeAreaInsets.right).offset(-20)
            make.trailing.equalTo(view.snp.trailing).offset(-view.safeAreaInsets.right-20)
            make.width.height.equalTo(44)
        }
    }
    
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
        ??? Optional<String>
          - some : "/private/var/containers/Bundle/Application/50D0BF1C-D140-406A-BE1E-32DC79717780/SwiftHTML.app/SDE.bundle"

        (lldb) po htmlBundleLocalPath
        ??? Optional<String>
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
         Error Domain=NSCocoaErrorDomain Code=513 "You don???t have permission to save the file ???SDE.bundle??? in the folder ???tmp???." UserInfo={NSFilePath=file:///private/var/mobile/Containers/Data/Application/E1D17304-E01B-44E0-938A-EC4ACE1A8282/tmp/SDE.bundle, NSUnderlyingError=0x281938bd0 {Error Domain=NSPOSIXErrorDomain Code=1 "Operation not permitted"}}
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
                // Error Domain=NSCocoaErrorDomain Code=513 "???SDE.bundle??? couldn???t be moved because you don???t have permission to access ???tmp???."
//                try fileManager.moveItem(atPath: htmlBundlePath ?? "", toPath: tempBundlePath)
                try fileManager.copyItem(atPath: htmlBundlePath ?? "", toPath: tempBundlePath)
            } catch let e {
                print("\(e)")
                success = false
            }
//        }
        return (tempBundlePath, success)
    }
    
    @objc func scrollToTop() {
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
        
        // 10.2.1??????ios????????????????????? this.$refs.container.scrollTo is undefined,????????????????????????13.6.1 ????????????????????????????????????????????????10.2.1??????????????????scrollTo ?????????????????????scrollTop?????????
//        let script = "var scrollTop = document.documentElement.scrollTop || window.pageYOffset || document.body.scrollTop;window.scrollTo(0,0);var rs = document.getElementById('book-search-results');window.scrollTo({'behavior': 'smooth', 'top': rs.offsetTop});console.log('scrollToTopTest');"
//        let script = "var rs=document.getElementById('book-search-results');rs.scrollTop=1;console.log(\"%o\",rs.scrollTop);"
        webView?.evaluateJavaScript(script, completionHandler: nil)
        
        //gitbookb??????????????????????????????????????????????????????
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
         ????????? gitbook-plugin-back-to-top-button@0.1.4

         info: >> plugin "back-to-top-button" installed with success
         */
    }
    
    private func registerImageClickAndHandler() {
        let js = "var srcArr=[]; var allImage=document.getElementsByTagName('img');for(var i=0;i<allImage.length;i++){var image = allImage[i]; image.index = i;srcArr.push({'pic_url': image.src});image.onclick = function () {console.log('img-click');window.webkit.messageHandlers.\(getHtmlImagesHandlerName()).postMessage({'index':this.index,'srcArr':srcArr});}}"
        webView?.evaluateJavaScript(js) { result, err in
            if err != nil {
                print(err?.localizedDescription ?? "")
            }
        }
    }
    
    /*
     ??? CSS ??????????????????????????????????????????????????? opacity ?????? 0?????? visibility ?????? hidden?????? display ?????? none ????????? position ?????? absolute ????????????????????????????????????
     
     ????????????????????????????????????????????????????????????????????????????????????????????????
     */
    @objc func switchBtnClicked(sender: UIButton) {
        if readType == .learning {
            readType = .examination
            sender.setTitle("??????", for: .normal)
            let script = "var arrayOfDocFonts = document.getElementsByTagName(\"div\");for (var i = 0; i < arrayOfDocFonts.length; i++) {if (arrayOfDocFonts[i].style.display == \"inline\" && arrayOfDocFonts[i].className != \"back-to-top\"){arrayOfDocFonts[i].style.setProperty('visibility','hidden');}}"
            webView?.evaluateJavaScript(script, completionHandler: nil)
        } else {
            readType = .learning
            sender.setTitle("??????", for: .normal)
            let script = "var arrayOfDocFonts = document.getElementsByTagName(\"div\");for (var i = 0; i < arrayOfDocFonts.length; i++) {if (arrayOfDocFonts[i].style.display == \"inline\" && arrayOfDocFonts[i].className != \"back-to-top\"){arrayOfDocFonts[i].style.setProperty('visibility','visible');}}"
            webView?.evaluateJavaScript(script, completionHandler: nil)
        }
        
    }
    
    func setUpWKwebView() -> WKWebView {
        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = true
        preferences.setValue(true, forKey:"allowFileAccessFromFileURLs")
        preferences.javaScriptCanOpenWindowsAutomatically = true
//        preferences.javaScriptEnabled = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.allowsInlineMediaPlayback = true
        
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = pagePreferences
        
        // register user script
        let js = "var srcArr=[]; var allImage=document.getElementsByTagName('img');for(var i=0;i<allImage.length;i++){var image = allImage[i]; image.index = i;srcArr.push({'pic_url': image.src});image.onclick = function () {console.log('img-click');window.webkit.messageHandlers.\(getHtmlImagesHandlerName()).postMessage({'index':this.index,'srcArr':srcArr});}}"
        let userScript = WKUserScript.init(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
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
            registerImageClickAndHandler()
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
            registerImageClickAndHandler()
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
        if navigationAction.navigationType == .linkActivated {//????????????????????????????????????
            if model.type == .none {
                //??????gitbook???????????????????????????WKWebView?????????Universal Link???????????????????????????app??????????????????app???????????????
                policy = WKNavigationActionPolicy(rawValue: 1 + 2)!//??????.allow+2???????????? _WKNavigationActionPolicyAllowWithoutTryingAppLink
            } else {
                if  UIApplication.shared.canOpenURL(url) {// ?????????????????????????????????
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    // ?????????web?????????
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
        
        let js = "var srcArr=[]; var allImage=document.getElementsByTagName('img');for(var i=0;i<allImage.length;i++){var image = allImage[i]; image.index = i;srcArr.push({'pic_url': image.src});image.onclick = function () {console.log('img-click');window.webkit.messageHandlers.\(getHtmlImagesHandlerName()).postMessage({'index':this.index,'srcArr':srcArr});}}"
        webView.evaluateJavaScript(js) { result, err in
            if err != nil {
                print(err?.localizedDescription ?? "")
            }
            print(result ?? "")
        }

//        if model.type != .none {
//            webView.attachImageViewerGesture()
//        }
        
        
        let closeCustomBtn = UIButton(type: .custom)
        closeCustomBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 44)
        closeCustomBtn.imageView?.tintColor = .black
        closeCustomBtn.contentHorizontalAlignment = .leading
        closeCustomBtn.setImage(UIImage(named: "close_normal")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeCustomBtn.setImage(UIImage(named: "close_pressed")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        closeCustomBtn.addTarget(self, action: #selector(closeAction(sender:)), for: .touchUpInside)
        let closeBtn = UIBarButtonItem(customView: closeCustomBtn)
        
        //https://www.freesion.com/article/7266944264/
        //iOS 11??????????????????????????????????????????,?????????????????????????????????????????????????????????????????????!
        // _UINavigationBarContentView???_UIButtonBarStackView???_UITAMICAdaptorView
        // ??????????????????leftBarButtonItem?????????????????????UIButtonBarStackView??????
//        let spaceBtn = UIBarButtonItem(systemItem: .fixedSpace)
//        spaceBtn.width = -8
        
        let backCustomBtn = UIButton(type: .custom)
        backCustomBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 44)
        backCustomBtn.imageView?.tintColor = .black
        backCustomBtn.contentHorizontalAlignment = .leading
        backCustomBtn.setImage(UIImage(named: "back_normal")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backCustomBtn.setImage(UIImage(named: "back_pressed")?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        backCustomBtn.addTarget(self, action: #selector(backAction(sender:)), for: .touchUpInside)
        let backBtn = UIBarButtonItem(customView: backCustomBtn)
        
        if webView.canGoBack || (model.type != .none && model.type != .pdf) {
            navigationItem.leftBarButtonItems = [backBtn, closeBtn]
        } else {
            navigationItem.leftBarButtonItems = [backBtn]
        }
    }
    
    @objc func closeAction(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func backAction(sender: UIBarButtonItem) {
        if webView!.canGoBack {
            webView?.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == getHtmlImagesHandlerName() {
            let bodyTemp = message.body as! [String: Any]
            let index = bodyTemp["index"] as! Int
            
            let images = bodyTemp["srcArr"] as! [Dictionary<String, Any>]
            var imageUrls: [String] = []
            for dic in images {
                let url = dic["pic_url"]
                imageUrls.append(url as! String)
            }
            
            
           //?????????????????????????????????????????????????????????????????????
            self.webView?.showWebViewBrowser(index: index, images: imageUrls)
        }
    }
    
    func getHtmlImagesHandlerName() -> String {
        return "previewimages"
    }
}

extension WKWebView: UIGestureRecognizerDelegate {
    //??????????????????????????????????????????WKWebView??????
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
        alert.addAction(UIAlertAction(title: "???????????????", style: .default, handler: { _ in
            self.saveImage(image: cell.imageView.image!, cell: cell)
        }))
        alert.addAction(UIAlertAction(title: "??????", style: .cancel, handler: nil))
        cell.photoBrowser?.present(alert, animated: true, completion: nil)
    }
    
    private func saveImage(image: UIImage, cell: JXPhotoBrowserImageCell) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { (isSuccess, error) in
            DispatchQueue.main.async {
                if isSuccess {// ??????
                    var style = ToastStyle()
                    style.messageColor = .white
                    style.backgroundColor = .gray
                    cell.photoBrowser?.view.makeToast("????????????????????????!", duration: 2.0, position: .bottom, style: style)
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
