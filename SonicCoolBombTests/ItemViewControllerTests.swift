//
//  SonicCoolBombTests.swift
//  SonicCoolBombTests
//
//  Created by ko on 2020/9/10.
//  Copyright © 2020 SM. All rights reserved.
//

import XCTest
import Alamofire
 
@testable import SonicCoolBomb

class ItemViewControllerTests: XCTestCase {

    var itemVC: ItemViewController!
    var didSelectCell: Bool = false
    
    var userDefaults: UserDefaults?
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try! super.setUpWithError()
        itemVC = ItemViewController.init(nibName: nil, bundle: nil)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.itemVC = nil
        try! super.tearDownWithError()
        
    }
    
   

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testDoGetJikanItemList()
    {
        let ex = expectation(description: "Expecting a JSON data not nil")
        //Given
        let apiWorker = AllenRequestCenter.sharedInstance
        itemVC.apiWorker = apiWorker
        
        //When
        callAPI(success: { (params: Dictionary, code: Int) in
            XCTAssertNotNil(params)
            ex.fulfill()
            
        }) { (error, code ,desc) in
            
            XCTAssertNil(error)
        }
        //TimeOut
        waitForExpectations(timeout: 15) { (error) in
            if let error = error {
                XCTFail("error: \(error)")
            }
        }
        
        
        
    }
    //MARK: -- testViewController
    func testThatViewLoads() {
        XCTAssertNotNil(self.itemVC.view, "View not initiated properly")
    }
    
    func testParentViewHasTableViewSubview() {
        let subviews = self.itemVC.view.subviews
        XCTAssertTrue(subviews.contains(self.itemVC.tableView), "View does not have a table subview")
    }
    
    func testThatTableViewLoads() {
        XCTAssertNotNil(self.itemVC.tableView, "TableView not initiated")
    }
    
     // MARK: -  UITableView tests
    func testThatViewConformsToUITableViewDataSource() {
        XCTAssertTrue(self.itemVC.conforms(to: UITableViewDataSource.self),"View does not conform to UITableView datasource protocol")
    }
    
    func testThatTableViewHasDataSource() {
        XCTAssertNotNil(self.itemVC.tableView.dataSource, "Table datasource cannot be nil")
    }
    
    func testThatViewConformsToUITableViewDelegate() {
        XCTAssertTrue(self.itemVC.conforms(to: UITableViewDelegate.self), "View does not conform to UITableView delegate protocol")
    }
    
    func testTableViewIsConnectedToDelegate() {
        XCTAssertNotNil(self.itemVC.tableView.delegate, "Table delegate cannot be nil")
    }
    
    func testTableViewNumberOfRowsInSection() {
        let expectedRows = 50
        
        callAPI(success: { [weak self] (params: Dictionary, code: Int) in
            guard let self = self else { return }
            
            XCTAssertNotNil(params)
            XCTAssertTrue((params.count) == expectedRows, "Table has \(self.itemVC.tableView(self.itemVC.tableView, numberOfRowsInSection: 0)) rows but it should have \(expectedRows) ")
            
            let actualHeight = self.itemVC.tableView.rowHeight
            //The height we use is automaticDimension
            XCTAssertGreaterThan(actualHeight, 10)
            
        }) { (error, code ,desc) in
            
            XCTAssertNil(error)
        }
         
    }
    func testTableViewCellCreateCellsWithReuseIdentifier() {
        let indexPath = IndexPath.init(row: 0, section: 0)
        self.itemVC.tableView.register(ItemCell.self, forCellReuseIdentifier: self.itemVC.cellID)
 
        let cell = self.itemVC.tableView.dequeueReusableCell(withIdentifier: self.itemVC.cellID, for: indexPath) as! ItemCell
        XCTAssertTrue(cell.reuseIdentifier == self.itemVC.cellID)
    }
    
    
    func testTableViewDidSelectedCell() {
        let indexPath = IndexPath.init(row: 0, section: 0)
        self.itemVC.tableView.register(ItemCell.self, forCellReuseIdentifier: self.itemVC.cellID)

        callAPI(success: { [weak self] (params: Dictionary, code: Int) in
            guard let self = self else { return }
            
            self.itemVC.tableView(self.itemVC.tableView, didSelectRowAt: indexPath)
            
            XCTAssertTrue(!self.didSelectCell,"not true")
            
            self.didSelectCell = true
            let selectedData = self.itemVC.datas[indexPath.row] as! ItemModel
            
            XCTAssertTrue((selectedData.url != nil),"Null")


        }) { (error, code ,desc) in

            XCTAssertNil(error)
        }
        
        
    }
    
    func testUserDefault() {
        
        let userDefaultsSuiteName = (self.itemVC.menu.typeButton.titleLabel?.text)!+(self.itemVC.menu.subTypeButton.titleLabel?.text)!
        UserDefaults().removePersistentDomain(forName: userDefaultsSuiteName)
        userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
        

    }
    //MARK: -- testClickFavorite
    func testClickFavorite() {
        // Given
        let jsonExample = """
        [
            {
                "mal_id": 23390,
                "rank": 1,
                "title": "Shingeki no Kyojin",
                "url": "https://myanimelist.net/manga/23390/Shingeki_no_Kyojin",
                "type": "Manga",
                "volumes": null,
                "start_date": "Sep 2009",
                "end_date": null,
                "members": 323130,
                "score": 8.62,
                "image_url": "https://cdn.myanimelist.net/images/manga/2/37846.jpg?s=bdda4d1c1d85237aead7d545f876c077",
                 "favorite": false
        }
        ]
    """
        let fakeDatas = jsonExample.kj.modelArray(ItemModel.self)
        self.itemVC.datas = fakeDatas
        
        XCTAssertTrue(self.itemVC.datas.count > 0, "List Data cannot be nil")
        
        // When
        let sendTag = 23390
        let selectedItems =  self.itemVC.datas.map { (item: Any) -> ItemModel in
            var cellItem = item as! ItemModel
            if cellItem.mal_id == sendTag {
                
                cellItem.favorite = !cellItem.favorite!
                
            }
            return cellItem
        }.filter { (item: Any) -> Bool in
            (item as! ItemModel).mal_id == sendTag
        }
        let selectedItem =  selectedItems[0]
        // Then
        XCTAssertTrue(selectedItem.favorite == true, "Click Favorite Button Failed")
        
 
    }
    //MARK: -- testMenu
    func testMenu() {
        let menu = TypeMenu(typeInit: "anime", subTypeInit: "bypopularity", selectType: {  typeButton in
             
           XCTAssertNotNil(typeButton)
            
            }, selectSubType: {   subTypeButton in
            XCTAssertNotNil(subTypeButton)
                
        })
        menu.typeButton.sendActions(for: .touchUpInside)
        XCTAssertNotNil(menu)
    }
    
    //MARK: -- callWebAPI
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
