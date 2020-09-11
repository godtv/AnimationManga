//
//  ItemDetailViewControllerTests.swift
//  SonicCoolBombTests
//
//  Created by ko on 2020/9/10.
//  Copyright © 2020 SM. All rights reserved.
//

import XCTest
import WebKit
import Alamofire
@testable import SonicCoolBomb

class ItemDetailViewControllerTests: XCTestCase {
    var itemVC: ItemViewController!
    var itemDetailVC: ItemDetailViewController!
    var didSelectCell: Bool = false
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
         try! super.setUpWithError()
        itemVC = ItemViewController.init(nibName: nil, bundle: nil)
        itemDetailVC = ItemDetailViewController.init(nibName: nil, bundle: nil)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.itemVC = nil
        self.itemDetailVC = nil
        try! super.tearDownWithError()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    
     // MARK: -  WKWebView tests
    func testWebViewLoads() {
        let subviews = self.itemDetailVC.view.subviews
        XCTAssertTrue(subviews.contains(self.itemDetailVC.wv), "View does not have a webview subview")
    }
    //WKNavigationDelegate
    func testThatViewConformsToWKNavigationDelegate(){
        XCTAssertTrue(self.itemDetailVC.conforms(to: WKNavigationDelegate.self),"View does not conform to WKNavigationDelegate protocol")
    }
    
    func testWebViewLoad() {
 
        let indexPath = IndexPath.init(row: 0, section: 0)
        self.itemVC.tableView.register(ItemCell.self, forCellReuseIdentifier: self.itemVC.cellID)
        
        callAPI(success: { [weak self] (params: Dictionary, code: Int) in
            guard let self = self else { return }
            
            self.itemVC.tableView(self.itemVC.tableView, didSelectRowAt: indexPath)
             
            self.didSelectCell = true
            let selectedData = self.itemVC.datas[indexPath.row] as! ItemModel
            self.itemDetailVC.itemUrl = selectedData.url
            
            let url = URL(string: self.itemDetailVC.itemUrl)!
            self.itemDetailVC.wv.load(URLRequest(url:url))
            
            //FakeWebNav
            let fakeNavigation = WKNavigation()
            self.itemDetailVC.webView(self.itemDetailVC.wv, didFinish: fakeNavigation)
            XCTAssertTrue(self.itemDetailVC.wv.isLoading)
       
        }) { (error, code ,desc) in
            
            XCTAssertNil(error)
        }
    }
    
    
 
 
    private func callAPI(success successCallback: @escaping (Dictionary<String,Any>, _ code: Int) -> (),
                         failure failureCallbac:@escaping (AFError, _ code: Int, _ desc: String) -> ()) {
        
        let apiWorker = AllenRequestCenter.sharedInstance
        itemVC.apiWorker = apiWorker
        
        let type =  self.itemVC.menu.typeButton.titleLabel?.text
        let subType = self.itemVC.menu.subTypeButton.titleLabel?.text
        let url = APPURL.Company.Jikan + "top/\(type ?? "anime")/\(self.itemVC.pageIndex)/\(subType ?? "")"
        
        apiWorker.getWithUrl(url: url, success: {  (params: Dictionary, code: Int) in
            
            successCallback(params, code)
            
        }, failure: {(error, code ,desc) in
            
            failureCallbac(error, code, desc)
            
        })
    }
 
    
}
