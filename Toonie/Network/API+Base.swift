//
//  API+Base.swift
//  Toonie
//
//  Created by 양어진 on 23/03/2019.
//  Copyright © 2019 Yapp. All rights reserved.
//

import Foundation
/*
 API의 기본 형태
 Base URL과 JSONDecoder의 디코딩 전략 설정
 */
class API {
    static let baseURL = "http://220.76.238.7:10"
    //    static let baseURL = "http://172.30.1.12:8080"
    
    static let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    static let toonieUpdateChk = {
        return "http://eunbi6431.cafe24.com/Toonie/toonieUpdateChk.json"
    }()

    
    static let token = {
        return baseURL + "/token"
    }()
    
    static let keywords = {
        return baseURL + "/keywords"
    }()
    
    //    static let myKeywords = {
    //        return baseURL + "/mykeywords/\(String(describing: CommonUtility.userToken))"
    //    }()
    
    static let myKeywords = {
        return baseURL + "/mykeywords"
    }()
    
    static let tags = {
        return baseURL + "/tags"
    }()
    
    static let forYouToons = {
        return baseURL + "/tags/token/\(CommonUtility.userToken)"
    }()
    
    static let toons = {
        return baseURL + "/toons"
    }()
    
    //mykeywords/:token
    static let myKeywordsToken = { (token) in
        return myKeywords + "/" + token
    }
    
    //kewords/:keyword
    static let keywordInfo = { (keyword) in
        return keywords + "/" + keyword
    }
    
    static let worklist = {
        return baseURL + "/worklist"
    }()
    
    static let myFavoriteList = {
        return baseURL + "/worklist/\(CommonUtility.userToken)/default"
    }()
    
    static let myLatestList = {
        return baseURL + "/worklist/\(CommonUtility.userToken)/latest"
    }()
    
}
