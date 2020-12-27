//
//  LocalSearchUserStorage.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/19.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import RxSwift

class LocalSearchUserStorage {
    lazy var realm = try! Realm()
    
    private var list: Array<SearchUserModel> = []
    private lazy var sectionModel: [SearchUserSectionModel] = []
    private lazy var store = BehaviorSubject<[SearchUserSectionModel]>(value: sectionModel)
    
    func searchUserList() -> Observable<[SearchUserSectionModel]> {
        return store
    }
    
    public func loadLocalDBFavoriteUser(_ name: String?) {
        guard let searchName = name else {
            return
        }
        
        let sortProperties = [SortDescriptor(keyPath: "name", ascending: true),
                              SortDescriptor(keyPath: "sortPriority", ascending: true),     SortDescriptor(keyPath: "firstChoseong", ascending: true)]
        
        let results = self.realm.objects(SearchUserLocalModel.self).filter("name CONTAINS [c] %@", searchName).sorted(by: sortProperties)
        
        
        let items = Array(results).enumerated().compactMap { (index, favorite) in
            return SearchUserSectionModel(model: index, items: [SearchUserModel(identity: UUID().uuidString, login: Int(favorite.identifier)!, name: favorite.name, profileImageURL: favorite.profileImageURL)])
        }
        sectionModel = items
        store.onNext(sectionModel)
    }
    
    private func findFavoriteSearchUser(identifier: String) -> SearchUserLocalModel? {
        return realm.objects(SearchUserLocalModel.self).filter("identifier == %@", identifier).first
    }

    public func deleteFavoriteSearchUser(_ section: Int, index: Int) {
        let searchUser = sectionModel[section].items[index]
        
        if deleteDBFavoriteSearchUser(String(searchUser.login)) {
            sectionModel[section].items.remove(at: index)
            store.onNext(sectionModel)
        }
    }
    
    public func removeAllSearchUser() {
        sectionModel = []
        store.onNext(sectionModel)
    }
    
    @discardableResult
    public func insertLocalDBWithSearchUser(_ name: String, profileImageURL: String, identifier: String) -> SearchUserLocalModel? {
        if let saveSearchUser = findFavoriteSearchUser(identifier: identifier) {
            return saveSearchUser
        }
        
        let searchUser =  SearchUserLocalModel()
        searchUser.name = name
        searchUser.profileImageURL = profileImageURL
        searchUser.identifier = identifier
        
        //  firstChoseong로 section이 구분되기때문에 ㄱ~ㅎ과 A-Z,a-z만 확인하여 정렬하기 위한 우선값 설정
        let firstString = String(searchUser.name[searchUser.name.startIndex])
        let hangulStringDecomposition = HangulStringDecomposition()
        searchUser.firstChoseong = hangulStringDecomposition.getStringConsonant(string: firstString, consonantType: .Initial)
        searchUser.sortPriority = searchUser.firstChoseong.sortChoSeongPriority()
        try! realm.write {
            realm.add(searchUser)
        }

        return searchUser
    }
    
    @discardableResult
    public func deleteDBFavoriteSearchUser(_ identifier: String) -> Bool {
        guard let saveSearchUser = findFavoriteSearchUser(identifier: identifier) else {
            return false
        }
        
        try! realm.write {
            realm.delete(saveSearchUser)
        }
        
        return true
    }
}

extension String {
    func sortChoSeongPriority() -> Int {
        let CHO = [
            "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
            "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
        ]
        
        let ENG = [
            "a","b","c","d","e","f","g","h","i","j",
            "k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
            "A","B","C","D","E","F","G","H","I","J",
            "K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
        ]
    
        if CHO.filter({$0 == self}).count > 0 {
            return 0
        }else if ENG.filter({$0 == self}).count > 0 {
            return 1
        }
        
        return 100
    }
    
    func choseong() -> String {
        return String(self[self.startIndex])
    }
}
