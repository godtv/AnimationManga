//
//  MyFavoriteViewControllerTests.swift
//  SonicCoolBombTests
//
//  Created by ko on 2020/9/12.
//  Copyright © 2020 SM. All rights reserved.
//

import XCTest
@testable import SonicCoolBomb
class MyFavoriteViewControllerTests: XCTestCase {
    var myFavVC: MyFavoriteViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        myFavVC = MyFavoriteViewController.init(nibName: nil, bundle: nil)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.myFavVC = nil
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

    func testThatTableViewLoads() {
        XCTAssertNotNil(self.myFavVC.tableView, "TableView not initiated")
    }
    
    func testThatViewConformsToUITableViewDataSource() {
        XCTAssertTrue(self.myFavVC.conforms(to: UITableViewDataSource.self),"View does not conform to UITableView datasource protocol")
    }
    
    func testThatTableViewHasDataSource() {
        XCTAssertNotNil(self.myFavVC.tableView.dataSource, "Table datasource cannot be nil")
    }
    
  
    //MARK: -- testClickFavorite
    func testClickFavorite() {
        // Given, Ready Cancel item
        let jsonExample = """
        [
            {
            "mal_id": 598,
            "rank": 10,
            "title": "Fairy Tail",
            "url": "https://myanimelist.net/manga/598/Fairy_Tail",
            "type": "Manga",
            "volumes": 63,
            "start_date": "Aug 2006",
            "end_date": "Jul 2017",
            "members": 223104,
            "score": 7.68,
            "image_url": "https://cdn.myanimelist.net/images/manga/3/198604.jpg?s=03c4ce0761b0e458e45e2015698aedf9",
            "favorite": true
        }
        ]
    """
        let fakeDatas = jsonExample.kj.modelArray(ItemModel.self)
        self.myFavVC.myFavoriteItems = fakeDatas
        
        XCTAssertTrue(self.myFavVC.myFavoriteItems.count > 0, "List Data cannot be nil")
        
        // When
        let sendTag = 598
        let selectedItems =  self.myFavVC.myFavoriteItems.map { (item: Any) -> ItemModel in
            var cellItem = item as! ItemModel
            if cellItem.mal_id == sendTag {
                
                cellItem.favorite = !cellItem.favorite!
                
            }
            return cellItem
        }.filter { (item: Any) -> Bool in
            (item as! ItemModel).mal_id == sendTag
        }
        let selectedItem =  selectedItems[0]
        
        if let removeIdx = self.myFavVC.myFavoriteItems.firstIndex(where: { ($0.mal_id == selectedItem.mal_id) && (selectedItem.favorite == false) }) {
            self.myFavVC.myFavoriteItems.remove(at: removeIdx)
        }
        
        
        // Then
        XCTAssertTrue(selectedItem.favorite == false, "Cancel Favorite Item Failed")
        
    }
    //MARK: -- testMenu
    func testMenu() {
        
        let menu = TypeMenu()
        menu.typeButton = UIButton(type: .custom)
        menu.typeButton.setTitle("people", for: .normal)
        menu.subTypeButton = UIButton(type: .custom)
        menu.subTypeButton.setTitle("people", for: .normal)
        XCTAssertNotNil(menu)

        self.myFavVC.menu = menu
        let filterDesc = self.myFavVC.menu.typeButton.titleLabel?.text
        if filterDesc == "people" || filterDesc == "characters" {
            changeTypeMenu(0.5, false, menu: self.myFavVC.menu)
        }

        XCTAssertTrue(self.myFavVC.menu.subTypeButton.alpha == 0.5,"operation failed")
    }
    
    func changeTypeMenu(_ alpha: CGFloat, _ enabled: Bool, menu: TypeMenu){
        menu.subTypeButton.alpha = alpha
        menu.subTypeButton.isUserInteractionEnabled = enabled
    }
}
