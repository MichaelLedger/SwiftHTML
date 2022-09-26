//
//  ViewController.swift
//  SwiftHTML
//
//  Created by MTX on 2022/9/4.
//

import UIKit
import SnapKit

enum MLCellType {
    case none
    
    // gitbook
    case android_alibaba_java
    case ios
    case ios_interview
    case pdf_instant_opencv_for_ios
    case pdf_the_art_of_computer_programming
    case sde
    
    //blog
    case english //WARNING: Resources is too big, so there is no music. Advise to use normal http to load it.
    case developer
    case academic
    case korean
    case japan
}

class MLCellModel: NSObject {
    var type: MLCellType = .none
    var title: String = ""
    var bundleName: String = ""
    var relativePath: String = ""
    var remoteUrlStr: String?
    
    convenience init(type: MLCellType, title: String, bundleName: String, relativePath: String, remoteUrlStr: String?) {
        self.init()
        self.type = type
        self.title = title
        self.bundleName = bundleName
        self.relativePath = relativePath
        self.remoteUrlStr = remoteUrlStr
    }
    
    func documentRoot() -> String {
        let bundlePath = Bundle.main.path(forResource: bundleName, ofType: "bundle")
        return bundlePath ?? ""
    }
    
    override var description: String {
        return "type:\(type),title:\(title),bundleName:\(bundleName),relativePath:\(relativePath)"
    }
}

class ViewController: UIViewController {
    
    let tableView = UITableView()
    var dataArray: [MLCellModel] = NSMutableArray() as! [MLCellModel]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Swift HTML"
        
        // 添加tableView的控件
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        // 设置数据源,设置数据
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 60
        
        self.initData()
    }
    
    func initData() {
        let types: [MLCellType] = [.sde,
                                   .none,
                                   .none]
        /*[.android_alibaba_java,
                                   .ios,
                                   .ios_interview,
                                   .pdf_instant_opencv_for_ios,
                                   .pdf_the_art_of_computer_programming,
                                   .sde,
                                   .english,
                                   .developer,
                                   .academic,
                                   .korean,
                                   .japan]*/
        
        let titles: [String] = ["《软件设计工程师 (Software Design Engineer)》",
                                "百度",
                                "微博热搜榜"
                                ]
            /*["《阿里巴巴Java开发手册》",
                                "《iOS》",
                                "《iOS 工程师技能树》",
                                "《Instant OpenCV for iOS》",
                                "《The Art of Computer Programming》",
                                "《软件设计工程师 (Software Design Engineer)》",
                                "Blog - English",
                                "Blog - Developer",
                                "Blog - Academic",
                                "Blog - Korean",
                                "Blog - Japan"]*/
        
        let bundleName = "gitbook"
        
        let relativePaths = ["/sde/index.html","",""]
            /*["/gitbook/Android-Alibaba-Java/index.html",
                             "/gitbook/iOS/index.html",
                             "/gitbook/iOS-interview/index.html",
                             "/gitbook/PDF/Instant-OpenCV-for-iOS/index.html",
                             "/gitbook/PDF/The-Art-of-Computer-Programming-Volume-1/index.html",
                             "/gitbook/SDE/index.html",
                             "/blog/index.html",
                             "/blog/developer.html",
                             "/blog/academic.html",
                             "/blog/korean.html",
                             "/blog/japan.html"]*/
        
        let remoteUrlStrs = ["", "https://www.baidu.com", "https://s.weibo.com/top/summary"]
        
        for i in 0..<types.count {
            let model = MLCellModel(type: types[i], title: titles[i], bundleName: bundleName, relativePath: relativePaths[i], remoteUrlStr: remoteUrlStrs[i])
            dataArray.append(model)
        }
        tableView.reloadData()
    }
}

// 相当于OC中的category
extension ViewController : UITableViewDataSource
{
    // MARK:- 实现数据源方法
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID : String = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: ID)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: ID)
        }
        
        let model = dataArray[indexPath.row]
        cell?.textLabel?.text = model.title
        
        return cell!
    }
}

extension ViewController : UITableViewDelegate
{
    // MARK:- 实现代理方法
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        print(model)
        TableViewCellHandler.handleNormal(nav: self.navigationController!, model: model)
    }
}

