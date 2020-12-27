//
//  SearchUserModel.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/18.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//


import Foundation
import RealmSwift
import RxSwift
import RxDataSources

typealias SearchUserSectionModel = AnimatableSectionModel<Int, SearchUserModel>

struct SearchUserModel:Equatable, IdentifiableType {
    var identity: String
    var login: Int
    var name: String
    var profileImageURL: String
    var favorite: Bool {
        let realm = try! Realm()
        if realm.objects(SearchUserLocalModel.self).filter("identifier == %@", String(self.login)).first != nil {
            return true
        }
        return false
    }
}

