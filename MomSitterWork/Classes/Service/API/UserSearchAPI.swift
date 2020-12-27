//
//  UserSearchAPIInfo.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/18.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import Foundation
import Alamofire

/**
* SearchUser API Request 정보
*/
class UserSearchAPIInfo: RequestInfo {
    var method: String = "GET"
    var url: String = "/search/users"
    var parameters: Parameters
    var headers: HTTPHeaders = ["Accept" : "application/vnd.github.v3+json"]
    init(searchWord: String, perPage: Int, page: Int){
        parameters = ["q" : searchWord, "per_page" : perPage, "page" : page]
    }
}
