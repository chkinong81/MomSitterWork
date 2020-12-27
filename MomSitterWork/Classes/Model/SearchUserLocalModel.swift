//
//  SearchUserLocalModel.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/19.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import Foundation
import RealmSwift

class SearchUserLocalModel: Object {
    @objc dynamic var identifier: String
    @objc dynamic var name: String
    @objc dynamic var profileImageURL: String
    @objc dynamic var firstChoseong: String
    @objc dynamic var sortPriority: Int
    
    override required init() {
        self.identifier = UUID().uuidString
        self.name = ""
        self.profileImageURL = ""
        self.firstChoseong = ""
        self.sortPriority = 100
    }
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
}
