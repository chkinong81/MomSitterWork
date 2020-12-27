//
//  APIRequestPagingInfo.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/20.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import SwiftyJSON

/**
* API Request 페이징 처리 정보
*/
protocol APIRequestPagingInfo {
    var perPage: Int { get }    //  요청할때 검색되어지는 유저 갯수
    var page: Int { get set }   //  검색 페에지
    var totalCount: Int { get set }                 //  검색된 총 유저 갯수
    var incompleteResults: Bool { get set }         //  페이징이 완료 flag
    var isLoading: Bool { get set }                 //  API 요청중인 상태
    var remainCountForNextPageLoad: Int { get }     //  페이징 리퀘스트 요청 시점(ex. 100 perPage일때 remainCountForNextPageLoad 30일 경우 70번째 Cell에서 리퀘스트 요청
    
    func storageDataWithJSON(_ json: JSON)  //  Response받은 JSON처리
}
