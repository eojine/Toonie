//
//  DetailToon.swift
//  Toonie
//
//  Created by 이재은 on 21/04/2019.
//  Copyright © 2019 Yapp. All rights reserved.
//

struct DetailToon: Codable {
    let toonID: String?
    let toonName: String?
    let instaID: String?
    let instaUrl: String?
    let instaThumnailUrl: String?
    let instaInfo: String?
    let instaFollowerCount: String?
    let instaPostCount: String?
    let toonTagList: [String]?
    let curationTagList: [String]?
    
    enum CodingKeys: String, CodingKey {
        
        case toonID, toonName, instaID, instaUrl,
        instaThumnailUrl, instaInfo, toonTagList, curationTagList
        case instaFollowerCount = "instafollowerCnt"
        case instaPostCount = "instaPostCnt"
    }
}
