//
//  APISearchViewModel.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/19.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON
import RxSwift
import RxCocoa
import Action

/**
* APISearchViewModel
*/
class APISearchViewModel {
    var searchWord: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var localSearchWord: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    var localStorage: LocalSearchUserStorage
    var apiStorage: APISearchUserStorage
    var APISearchWord: String?
    
    init(apiStorage: APISearchUserStorage, localStorage: LocalSearchUserStorage) {
        self.apiStorage = apiStorage
        self.localStorage = localStorage
    }
    
    public func enableFetchNextPageAPISearchUser(_ index: Int) -> Bool {
        if apiStorage.isLoading || apiStorage.incompleteResults {
            return false
        }
        
        let currentUserCount = apiStorage.searchUesrCount()
        let remainCount = apiStorage.remainCountForNextPageLoad
        if currentUserCount - index <= remainCount {
            self.apiStorage.isLoading = true
            self.apiStorage.page += 1
            return true
        }

        return false
    }
    
    public func APISearchUserChangeNotifcationToken(_ block: @escaping NotificationBlock) -> NotificationToken {
        return localStorage.realm.observe(block)
    }
    
    public func loacalFavoriteUserReload() {
        localStorage.loadLocalDBFavoriteUser(localSearchWord.value)
    }
    
    public func loacalFavoriteUserReload(_ searchWord: String) {
        localStorage.loadLocalDBFavoriteUser(searchWord)
    }
    
    public func deleteLocalFavoriteUser(_ section: Int, index: Int) {
        localStorage.deleteFavoriteSearchUser(section, index: index)
    }
    
    public func localSearchUserChangeNotifcationToken(_ block: @escaping NotificationBlock) -> NotificationToken {
        return localStorage.realm.observe(block)
    }
    
    public func requestAPISearchUser(_ searchText: String?) {
        guard let text = searchText else {
            return
        }
        
        if text == APISearchWord {
            return
        }
        
        let requestInfo = UserSearchAPIInfo(searchWord: text, perPage: apiStorage.perPage, page: 0)
        apiStorage.isLoading = true
        APISearchWord = text
        
        APIService.shared.request(requestInfo: requestInfo) { [weak self] result in
            switch result {
            case .success(let json):
                self?.apiStorage.setSearchUserList(list: [])
                self?.apiStorage.storageDataWithJSON(json)
                self?.apiStorage.page += 1
                
                break
            case .failure(let error):
                print(error)
                break
            }
            self?.apiStorage.isLoading = false
        }
    }
    
    var searchUserList: Observable<[SearchUserSectionModel]> {
        return apiStorage.searchUserList()
    }
    
    var localSearchUserList: Observable<[SearchUserSectionModel]> {
        return localStorage.searchUserList()
    }
    
    public func fetchNextPageAPISearchUser(_ index: Int) {
        guard let text = APISearchWord else {
            return
        }
        
        if !enableFetchNextPageAPISearchUser(index) {
            return
        }

        let requestInfo = UserSearchAPIInfo(searchWord: text, perPage: apiStorage.perPage, page: apiStorage.page)
        APIService.shared.request(requestInfo: requestInfo) { [weak self] result in
            switch result {
            case .success(let json):
                self?.apiStorage.storageDataWithJSON(json)
            case .failure(let error):
                self?.apiStorage.page -= 1
                print(error)
            }
            self?.apiStorage.isLoading = false
        }
    }
    
    lazy var insertUserToLocalDB: Action<(SearchUserModel, IndexPath), Swift.Never> = {
        return Action { user, indexPath in
            if user.favorite {
                self.localStorage.deleteDBFavoriteSearchUser(String(user.login))
            }else {
                self.localStorage.insertLocalDBWithSearchUser(user.name, profileImageURL: user.profileImageURL, identifier: String(user.login))
            }
            
            self.localStorage.loadLocalDBFavoriteUser(self.localSearchWord.value)
            self.toggleFavoriteOutput.onNext((!user.favorite, indexPath))
            
            return Observable.empty()
        }
    }()
    
    lazy var deleteFavoriteUserToLocalDB: Action<(SearchUserModel, IndexPath), Swift.Never> = {
        return Action { user, indexPath in
            self.localStorage.deleteFavoriteSearchUser(indexPath.section, index: indexPath.row)
            return Observable.empty()
        }
    }()
    
    var toggleFavoriteOutput = PublishSubject<(Bool, IndexPath)>()
}
