//
//  Item.swift
//  SonicCoolBomb
//
//  Created by ko on 2020/7/29.
//  Copyright © 2020 SM. All rights reserved.
//

import Foundation
import KakaJSON

struct ItemModel: Convertible {
    var mal_id: Int?
    var rank: String?
    var title: String?
    var url: String?
    var image_url: String?
    var type: String?
    var episodes: Int?
    var start_date: String?
    var end_date: String?
    var members: Int?
    var score: Int?
    var favorite: Bool? = false
    
    var name_kanji: String?
    var birthday: String?
    var animeography: Array<Any>?
    /*
    var audioURL: String = ""
    var id : String = ""
    var imageURL: String = ""
    var name: String = ""
     */
}
