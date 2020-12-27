//
//  APIService.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/18.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//


import Foundation
import Alamofire
import SwiftyJSON
import RxSwift

protocol RequestInfo {
    var method: String { get }
    var url: String { get }
    var parameters: Parameters { get }
    var headers: HTTPHeaders { get }
}

enum APIError: Error {
    case data
    case decodingJSON
}

/**
* APIService
*/
class APIService {
    static let shared = APIService()
    private init() {}
    let host:String = "https://api.github.com"
    
    func request(requestInfo: RequestInfo, completionHandler: @escaping (Result<JSON, APIError>) -> Void ) {
        AF.request(host + requestInfo.url, method: HTTPMethod(rawValue: requestInfo.method), parameters: requestInfo.parameters, headers: requestInfo.headers)
            .validate(statusCode: 200..<300).responseJSON() { response in
                guard let data = response.data else {
                    return completionHandler(.failure(.data))
                }
                
                guard let json = try? JSON(data: data) else {
                    return completionHandler(.failure(.decodingJSON))
                }
                
                completionHandler(.success(json))
        }
    }
}
