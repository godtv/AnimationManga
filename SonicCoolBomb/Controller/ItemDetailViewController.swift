//
//  ItemDetailViewController.swift
//  SonicCoolBomb
//
//  Created by ko on 2020/9/8.
//  Copyright © 2020 SM. All rights reserved.
//

import UIKit
import WebKit

class ItemDetailViewController: UIViewController, UIViewControllerRestoration {
    var activity = UIActivityIndicatorView()
    weak var wv : WKWebView!
    var decoded = false
    var itemUrl: String!
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.restorationIdentifier = "wvc"
        self.restorationClass = type(of:self)
        self.edgesForExtendedLayout = []
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
 
    class func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        return self.init(nibName:nil, bundle:nil)
    }
        
    override func applicationFinishedRestoringState() {
        print("finished restoring state", self.wv.url as Any)
    }
    
    override func loadView() {
        print("loadView")
        super.loadView()
    }
    
    var obs = Set<NSKeyValueObservation>()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        let wv = WKWebView(frame: CGRect.zero)
        wv.restorationIdentifier = "wv"
         
        wv.scrollView.backgroundColor = .black
        self.view.addSubview(wv)
        wv.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            wv.topAnchor.constraint(equalTo: self.view.topAnchor),
            wv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            wv.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            wv.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        
        self.wv = wv
        
        wv.allowsBackForwardNavigationGestures = true
        
        //loading
        let act = UIActivityIndicatorView(style:.large)
        act.backgroundColor = UIColor(white:0.1, alpha:0.5)
        self.activity = act
        wv.addSubview(act)
        act.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            act.centerXAnchor.constraint(equalTo:wv.centerXAnchor),
            act.centerYAnchor.constraint(equalTo:wv.centerYAnchor)
        ])
        obs.insert(wv.observe(\.isLoading, options: .new) { [unowned self] wv, ch in
            if let val = ch.newValue {
                if val {
                    self.activity.startAnimating()
                } else {
                    self.activity.stopAnimating()
                }
            }
      
        })
        
        obs.insert(wv.observe(\.title, options: .new) { [unowned self] wv, change in
            if let val = change.newValue, let title = val {
                self.navigationItem.title = title
            }
        })
        wv.navigationDelegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         
        
        let b = UIBarButtonItem(title:"WebBack", style:.plain, target:self, action:#selector(goBack))
        self.navigationItem.rightBarButtonItems = [b]
        
        if let url = URL(string: self.itemUrl) {
            self.wv.load(URLRequest(url:url))
        }
        else {
            let alertController = UIAlertController(title: "Failed to load url",
                message: "",
                preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Confirm", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    deinit {
        print("dealloc")
    }
    
    @objc func goBack(_ sender: Any) {
        self.wv.goBack()
    }
    
    
}
 

extension ItemDetailViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation) {
        print("did commit \(navigation)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("fail")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("fail provisional")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start provisional")
    }
}
