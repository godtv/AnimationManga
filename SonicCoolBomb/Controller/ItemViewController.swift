////
////  ItemViewController.swift
////  SonicCoolBomb
////
////  Created by ko on 2020/7/29.
////  Copyright © 2020 SM. All rights reserved.
////

import UIKit
import KakaJSON
import MJRefresh
import SDWebImage
import FTPopOverMenu_Swift
import MBProgressHUD

class ItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, favoriteDelegate {
    
    var apiWorker = AllenRequestCenter.sharedInstance
    
    let cellID = "Cell"
    var pageIndex: Int = 0
    var mIsNoMoreData: Bool = false
    
    lazy var datas: Array<Any> = {
        let array: Array  = Array<Any>()
        return array
    }()
    
    var myFavoriteItems: Array<Dictionary<String, Any>> = [Dictionary<String, Any>]()
    
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
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var menu: TypeMenu = {
        
        let topMenu: TypeMenu = TypeMenu(typeInit: "anime", subTypeInit: "bypopularity", selectType: { [weak self]typeButton in
            guard let self = self else { return }
            
            FTPopOverMenu.showForSender(sender: typeButton,
                                        with: self.typeArray,
                                        done: { (selectedIndex) -> () in
                                            
                                            //When switching types, initialize subtype
                                            typeButton.setTitle(self.typeArray[selectedIndex], for: .normal)
                                            
                                            self.menu.subTypeButton.setTitle("bypopularity", for: .normal)
                                            
                                            let subTypeArray = self.getSubTypeArray(input: self.menu.typeButton.titleLabel?.text)
                                            self.loadDataForRefresh(refreshStatus: ACTION_DESC.Header)
                                            
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
                                                self.loadDataForRefresh(refreshStatus: ACTION_DESC.Header)
                }) {}
                
                
        })
        
        
        return topMenu
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Top List"
        setupFavoriteBarButtonItem()
        
        self.tableView.register(ItemCell.self, forCellReuseIdentifier: self.cellID)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        self.menu.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.menu)
        
        NSLayoutConstraint.activate([
            menu.topAnchor.constraint(equalTo: safeLayoutGuide.topAnchor),
            menu.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            menu.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: menu.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeLayoutGuide.bottomAnchor)
        ])
    
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let header = MJRefreshNormalHeader { [weak self] in
            guard let self = self else { return }
            self.loadDataForRefresh(refreshStatus: ACTION_DESC.Header)
        }
        
        header?.setTitle(ACTION_DESC.PullDownUdp, for: .idle)
        header?.setTitle(ACTION_DESC.ReleaseUdp, for: .pulling)
        self.tableView.mj_header = header
        self.tableView.mj_header.beginRefreshing()
         
    }
    
    func addFooter() {
        let footer = MJRefreshAutoNormalFooter {
            self.loadDataForRefresh(refreshStatus: ACTION_DESC.Footer)
        }
        footer?.setTitle(ACTION_DESC.PullupUdp, for: .idle)
        footer?.setTitle(ACTION_DESC.ReleaseUdp, for: .pulling)
        footer?.setTitle(ACTION_DESC.Loading, for: .refreshing)
        footer?.setTitle(ACTION_DESC.NoData, for: .noMoreData)
        self.tableView.mj_footer = footer
        
    }
    
    // MARK: - setupFavoriteBarButtonItem
    private func setupFavoriteBarButtonItem() {
        let titleLab = UILabel()
        titleLab.font = UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize)
        titleLab.text = "My Favorite"
        titleLab.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toFavoritePage(_:)))
        tap.numberOfTapsRequired = 1
        titleLab.addGestureRecognizer(tap)
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "myFav"), for: .normal)
        button.addTarget(self, action: #selector(toFavoritePage(_:)), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [titleLab, button])
        stackView.spacing = 8
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
    }
    
    private func getFavoriateItems() {
        if let favoriteDatas = UserDefaults.standard.object(forKey: self.mainKey()) {
            let receive = (favoriteDatas as?  String)
            let data = receive!.data(using: .utf8)!
            do{
                let favoriteArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Array<Dictionary<String,Any>>
                
                //favorite
                self.myFavoriteItems = favoriteArray!
            }
            catch {
                print (error)
            }
            
        }
        else {
            self.myFavoriteItems.removeAll()
        }
    }
    
    @objc func toFavoritePage(_ sender: Any) {
        let vc = MyFavoriteViewController(nibName: nil, bundle: nil)
       
        let favoriteItems = self.myFavoriteItems
        var array :Array<ItemModel> = [ItemModel]()
        if favoriteItems.count > 0 {
            favoriteItems.forEach { itemDict in
                let item = itemDict.kj.model(type: ItemModel.self)
                array.append(item as! ItemModel)
            }
        }
    
        vc.myFavoriteItems = array.sorted(by: { (one: ItemModel, two: ItemModel) -> Bool in
            let a:Int! = Int(one.rank!)
            let b:Int! = Int(two.rank!)
            return a < b
        })
        
        vc.typeKey = self.menu.typeButton.titleLabel?.text
        vc.subTypeKey = self.menu.subTypeButton.titleLabel?.text
        vc.view.backgroundColor = .white
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - loadDataForRefresh
    func loadDataForRefresh(refreshStatus: String) {
        
        let type =  menu.typeButton.titleLabel?.text
        let subType = menu.subTypeButton.titleLabel?.text
      //pageIndex Config
        if refreshStatus == ACTION_DESC.Header {
            self.pageIndex = 1
        }
        else if refreshStatus ==  ACTION_DESC.Footer {
            if mIsNoMoreData {
                self.tableView.mj_footer = nil
                return
            }
            if self.datas.count%50 == 0 { //Pagination: 50 pages per page
                self.pageIndex+=1
            }
            else {
                return
            }
        }
       //URL config
        var url = APPURL.Company.Jikan + "top/\(type ?? "anime")/\(self.pageIndex)/\(subType ?? "")"
        if type == "people" || type  == "characters" {
            url = APPURL.Company.Jikan + "top/\(type ?? "anime")/\(self.pageIndex)"
        }
        print("url is: " + url)
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        apiWorker.getWithUrl(url: url , success: { [weak self] (params: Dictionary, code: Int) in
            
            guard let self = self else { return }
            
            if code > 200 {
                let msg =  params["message"] as? String
                self.warningAlert(code, "\(String(describing: msg)), please pull down update")
                return
            }
            
            if self.datas.count < 1 && refreshStatus == ACTION_DESC.Footer {
                let footer = MJRefreshAutoNormalFooter()
                footer.setTitle("", for: .idle)
                footer.setTitle("", for: .pulling)
                footer.setTitle("", for: .refreshing)
                footer.setTitle("", for: .noMoreData)
                self.tableView.mj_footer = footer
                self.mIsNoMoreData = true
                self.tableView.mj_footer = nil
                return
            }
            if refreshStatus == ACTION_DESC.Header { self.datas.removeAll() }
            
            print("This is the console output: \(params as Any)")
            
            let dictionary = params
            let itemArray: Array = dictionary["top"] as! Array<Dictionary<String,Any>>
            
            //Get the storage list and select the items whose favorite is true
            if type == "animation" || type == "manga", self.mainKey() == (self.menu.typeButton.titleLabel?.text)! + (self.menu.subTypeButton.titleLabel?.text)! {
                self.getFavoriateItems()
            }
            else {
               self.getFavoriateItems()
            }
           
            print("self.myFavoriteItems UserDefaults: \(self.myFavoriteItems)")
            
            //Compare the list obtained from the api and update the item with the favorite value of true
            var copyitemArray = itemArray
            if self.myFavoriteItems.count > 0 {
                for (index, item) in copyitemArray.enumerated() {
                    self.myFavoriteItems.map { (favoritem: Dictionary<String,Any>) -> Dictionary<String,Any>  in
                        if (favoritem["mal_id"] as! Int) == item["mal_id"] as! Int? {
                            
                            copyitemArray[index]["favorite"] = favoritem["favorite"]
                            
                        }
                        return favoritem
                    }
                    
                }
            }
            
            if copyitemArray.count > 0 {
                copyitemArray.forEach { itemDict in
                    let item = itemDict.kj.model(type: ItemModel.self)
                    self.datas.append(item)
                }
            }
            else {
                itemArray.forEach { itemDict in
                    let item = itemDict.kj.model(type: ItemModel.self)
                    self.datas.append(item)
                }
            }
            
            self.tableView.mj_header.endRefreshing()
            
            if (self.tableView!.mj_footer != nil) { self.tableView.mj_footer.endRefreshing() }
            
            if self.datas.count%50==0 {
                self.addFooter()
            }
            else {
                self.tableView.mj_footer.endRefreshingWithNoMoreData()
            }
            
            self.tableView.reloadData()
            self.mIsNoMoreData = false
            MBProgressHUD.hide(for: self.view, animated: false)
            
            }, failure: {(AFError, code ,desc) in
                
                self.warningAlert(code, "\(String(describing: desc)), please pull down update")
        })
        
    }
    
    // MARK: - warningAlert
    func warningAlert(_ code: Int, _ errorMessage: String?) {
        
        let alertController = UIAlertController(title: "Http Response\(String(code))",
            message: errorMessage,
            preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "Confirm", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
        self.pageIndex-=1
        self.tableView.mj_header.endRefreshing()
        if (self.tableView!.mj_footer != nil) { self.tableView.mj_footer.endRefreshing() }
        MBProgressHUD.hide(for: self.view, animated: false)
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
        return self.datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellID, for: indexPath) as! ItemCell
        cell.delegate = self
        
        let data = self.datas[indexPath.row] as! ItemModel
        
        
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
        let data = self.datas[indexPath.row] as! ItemModel
        
        let itemDetailVC: ItemDetailViewController = ItemDetailViewController()
        itemDetailVC.itemUrl = data.url
        navigationController?.pushViewController(itemDetailVC, animated: true)
        
    }
    
    //MARK: -- mainKey
    func mainKey() -> String {
        let filterDesc = self.menu.typeButton.titleLabel?.text
        if filterDesc == "anime" || filterDesc == "manga" {
            changeTypeMenu(1, true)
            return (self.menu.typeButton.titleLabel?.text)! + (self.menu.subTypeButton.titleLabel?.text)!
        }
        else {
            changeTypeMenu(0.5, false)
            return (self.menu.typeButton.titleLabel?.text)!
            
        }
            
    }
    
    func changeTypeMenu(_ alpha: CGFloat, _ enabled: Bool){
        self.menu.subTypeButton.alpha = alpha
        self.menu.subTypeButton.isUserInteractionEnabled = enabled
    }
    
    
    //MARK: -- clickFavoriteButton
    func clickFavorite(sender: UIButton) {
     
        var selectedItems_jsonStr: String = ""
        var selectedItems =  self.datas.map { (item: Any) -> ItemModel in
            var cellItem = item as! ItemModel
            if cellItem.mal_id == sender.tag {
                cellItem.favorite = !cellItem.favorite!
            }
            return cellItem
        }
        self.datas = selectedItems
        selectedItems = selectedItems.filter { (item: Any) -> Bool in
            (item as! ItemModel).mal_id == sender.tag
        }
   
        selectedItems_jsonStr = JSONString(from: selectedItems)
        
        let localFavs =  UserDefaults.standard.object(forKey: mainKey())
        if  localFavs != nil {
            
            var localFavItems = (localFavs as! String).kj.modelArray(ItemModel.self)
            _ = selectedItems_jsonStr.kj.modelArray(ItemModel.self)
            
            for (_, clickItem) in selectedItems.enumerated() {
               
                if !localFavItems.contains(where: {($0.mal_id == clickItem.mal_id)}) {
                    if (clickItem.favorite == true) {
                        localFavItems.append(clickItem)
                    }
                }
                 
                if let removeIdx = localFavItems.firstIndex(where: { ($0.mal_id == clickItem.mal_id) && (clickItem.favorite == false) }) {
                    localFavItems.remove(at: removeIdx)
                }
 
            }
            UserDefaults.standard.setValue(JSONString(from: localFavItems), forKey: mainKey())
           
        }
        else if  localFavs == nil {
            if selectedItems_jsonStr.count > 0 {
                UserDefaults.standard.setValue(selectedItems_jsonStr, forKey: mainKey())
            }
        }
        
        self.loadDataForRefresh(refreshStatus: ACTION_DESC.Footer)
 
    }
    
}



