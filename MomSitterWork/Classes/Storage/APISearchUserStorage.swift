//
//  APISearchUserStorage.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/19.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RealmSwift
import SwiftyJSON


class APISearchUserStorage: APIRequestPagingInfo {
    //  APIRequestPagingInfo
    var page: Int = 0
    var perPage: Int = 100
    var totalCount: Int = 0
    var incompleteResults: Bool = false
    var isLoading: Bool = false
    var remainCountForNextPageLoad: Int = 30
    
    private var list: Array<SearchUserModel> = []
    private lazy var sectionModel = SearchUserSectionModel(model: 0, items: list)
    private lazy var store = BehaviorSubject<[SearchUserSectionModel]>(value: [sectionModel])
    
    func searchUesrCount() -> Int {
        return sectionModel.items.count
    }
    
    func searchUserList() -> Observable<[SearchUserSectionModel]> {
        return store
    }
    
    func setSearchUserList(list: [SearchUserModel]) {
        sectionModel.items = list
        store.onNext([sectionModel])
    }
    
    func appendSearchUserList(list: [SearchUserModel]) {
        sectionModel.items += list
        store.onNext([sectionModel])
    }
    
    func storageDataWithJSON(_ json: JSON) {
        if let incomplete_results = json["incomplete_results"].bool {
            incompleteResults = incomplete_results
        }
        
        if let total_count = json["total_count"].int {
            totalCount = total_count
        }
        
        if let items = json["items"].array {
            let searchUserList: [SearchUserModel] = items.map { item in
                SearchUserModel(identity: UUID().uuidString, login: item["id"].int ?? 1, name: item["login"].string ?? "Unknown", profileImageURL: item["avatar_url"].string ?? "")
            }
            
            self.appendSearchUserList(list: searchUserList)
        }
    }
}
