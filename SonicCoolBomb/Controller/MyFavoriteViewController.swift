//
//  MyFavoriteViewController.swift
//  SonicCoolBomb
//
//  Created by ko on 2020/9/9.
//  Copyright © 2020 SM. All rights reserved.
//

import UIKit
import KakaJSON
import MJRefresh
import SDWebImage
import FTPopOverMenu_Swift
import MBProgressHUD
 
 
class MyFavoriteViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, favoriteDelegate {
    
    
    let cellID = "Cell"
    var pageIndex: Int = 0
    var mIsNoMoreData: Bool = false
    var typeKey: String!
    var subTypeKey: String!
    
    
    //    var myFavoriteItems: Array<Dictionary<String, Any>> = [Dictionary<String, Any>]()
    var myFavoriteItems: Array<ItemModel> = [ItemModel]()
    
    var safeLayoutGuide:UILayoutGuide {
        return self.view.safeAreaLayoutGuide
    }
    
    var typeArray: Array = ["anime" ,"manga","people", "characters"]
    
    func getSubTypeArray(input: String?) -> Array<String>? {
        if input == "anime" {
            return ["airing", "upcoming", "tv", "movie", "ova", "special", "bypopularity","favorite"]
        }
        else if input == "manga" {
            return ["manga", "novels", "oneshots", "doujin", "manhwa", "manhua", "bypopularity","favorite"]
        }
        else {
            return [""]
        }
    }
    
    
    lazy var tableView: UITableView! = {
        let view = UITableView.init(frame: .zero, style: .plain)
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = UIScreen.main.bounds.size.height/4
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    //MARK: -- combineKey
    func combineKey() -> String {
        let filterDesc = self.menu.typeButton.titleLabel?.text
        if filterDesc == "anime" || filterDesc == "manga" {
            changeMenu(1, true)
            return (self.menu.typeButton.titleLabel?.text)! + (self.menu.subTypeButton.titleLabel?.text)!
        }
        else {
            changeMenu(0.5, false)
            return (self.menu.typeButton.titleLabel?.text)!
            
        }
    }
    func changeMenu(_ alpha: CGFloat, _ enabled: Bool){
        self.menu.subTypeButton.alpha = alpha
        self.menu.subTypeButton.isUserInteractionEnabled = enabled
    }
    
    //MARK: -- filterFavoriteList
    func filterFavoriteList() -> Array<Dictionary<String,Any>>? {
        let favoriteDatas = UserDefaults.standard.object(forKey: self.combineKey())
        var array:Array<Dictionary<String, Any>> = Array<Dictionary<String, Any>>()
        if favoriteDatas != nil {
            let receive = (favoriteDatas as?  String)
            let data = receive!.data(using: .utf8)!
            do{
                let favoriteArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Array<Dictionary<String,Any>>
                
                //favorite
                array = favoriteArray?.filter({ (item: Dictionary<String, Any>) -> Bool in
                    item["favorite"] as? Int == 1
                }) as! Array<Dictionary<String, Any>>
                
            }
            catch {
                print (error)
            }
            return array
        }
        return nil
    }
    
    func reloadListWhenSelectedMenu() {
        let favoriteDatas = self.filterFavoriteList()
        self.myFavoriteItems.removeAll()
        favoriteDatas?.forEach { itemDict in
            let item = itemDict.kj.model(type: ItemModel.self)
            self.myFavoriteItems.append(item as! ItemModel)
        }
        self.tableView.reloadData()
    }
    
    lazy var menu: TypeMenu = {
        
        let topMenu: TypeMenu = TypeMenu(typeInit: self.typeKey, subTypeInit: self.subTypeKey, selectType: { [weak self]typeButton in
            guard let self = self else { return }

            FTPopOverMenu.showForSender(sender: typeButton,
                                        with: self.typeArray,
                                        done: { (selectedIndex) -> () in

                                            //When switching types, initialize subtype
                                            typeButton.setTitle(self.typeArray[selectedIndex], for: .normal)
                                            self.menu.subTypeButton.setTitle("bypopularity", for: .normal)

                                            let subTypeArray = self.getSubTypeArray(input: self.menu.typeButton.titleLabel?.text)
                                            self.reloadListWhenSelectedMenu()

            }) {

            }
            }, selectSubType: { [weak self] subTypeButton in
                guard let self = self else { return }

                //print("type is: " + (self.menu.typeButton.titleLabel?.text)!)
                let subTypeArray = self.getSubTypeArray(input: self.menu.typeButton.titleLabel?.text)

                FTPopOverMenu.showForSender(sender: subTypeButton,
                                            with: subTypeArray!,
                                            done: { (selectedIndex) -> () in

                                                subTypeButton.setTitle(subTypeArray![selectedIndex], for: .normal)
                                                self.reloadListWhenSelectedMenu()

                }) {}


        })
      
        
        return topMenu
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Favorite"
        
        self.tableView.register(ItemCell.self, forCellReuseIdentifier: self.cellID)
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        self.menu.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.menu)
        
        
        NSLayoutConstraint.activate([
            
            menu.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            menu.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            menu.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            view.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: menu.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor)
        ])
        
        
        // Do any additional setup after loading the view.
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(combineKey())
        
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myFavoriteItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! ItemCell
        cell.delegate = self
        
        let data = self.myFavoriteItems[indexPath.row]
        
        cell.cellImgv.sd_setImage(with: URL(string: data.image_url!), placeholderImage: UIImage(named: "defaultImage"))
        
        cell.titleLabel.text =   data.title ?? "N/A"
        cell.rankLabel.text =  ("Ranked #\(data.rank ?? "N/A")")
        cell.startDateLabel.text = ("Aired \(data.start_date ?? "N/A")")
        cell.endDateLabel.text = ("Ended \(data.end_date ?? "N/A")")
        cell.typeLabel.text = ("Type ：\(data.type ?? "N/A")")
        
        cell.favoirteButton.tag = ((data.mal_id != nil) ? data.mal_id : 0)!
        cell.selectionStyle = .none
        
        cell.favoirteButton.setImage((data.favorite == true) ? UIImage(named: "heart") : UIImage(named: "heart_white"), for: .normal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.myFavoriteItems[indexPath.row]
        
        let itemDetailVC: ItemDetailViewController = ItemDetailViewController()
        itemDetailVC.itemUrl = data.url
        navigationController?.pushViewController(itemDetailVC, animated: true)
        
    }
    
    //MARK: -- clickFavoriteButton
    //On this page the func is remove cell
      func clickFavorite(sender: UIButton) {
        
        let mapDatas =  self.myFavoriteItems.map { (item: Any) -> ItemModel in
            var cellItem = item as! ItemModel
            if cellItem.mal_id == sender.tag {
                cellItem.favorite = !cellItem.favorite!
            }
            return cellItem
        }
        
        let selectedWhichItems = mapDatas.filter { (item: Any) -> Bool in
            (item as! ItemModel).mal_id == sender.tag
        }
        
        //remove and update
        let localFavs =  UserDefaults.standard.object(forKey: combineKey())
        
        if  localFavs != nil {
            
            var localFavItems = (localFavs as! String).kj.modelArray(ItemModel.self)
            
            for (_, clickItem) in selectedWhichItems.enumerated() {
                
                if !localFavItems.contains(where: {($0.mal_id == clickItem.mal_id)}) {
                    if (clickItem.favorite == true) {
                        localFavItems.append(clickItem)
                    }
                }
                
                if let removeIdx = localFavItems.firstIndex(where: { ($0.mal_id == clickItem.mal_id) && (clickItem.favorite == false) }) {
                    localFavItems.remove(at: removeIdx)
                }
                
                if let removeIdx = self.myFavoriteItems.firstIndex(where: { ($0.mal_id == clickItem.mal_id) && (clickItem.favorite == false) }) {
                    self.myFavoriteItems.remove(at: removeIdx)
                    
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesIn: range)
                    self.tableView.reloadSections(sections as IndexSet, with: .automatic)
                }
                
            }
            UserDefaults.standard.setValue(JSONString(from: localFavItems), forKey: combineKey())
            
        }
        
    }

}
