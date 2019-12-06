//
//  File.swift
//  Toonie
//
//  Created by 박은비 on 31/03/2019.
//  Copyright © 2019 Yapp. All rights reserved.
//

struct Keywords: Codable {
    let success: Bool?
    let keywords: [String]?
}

struct Categorys: Codable {
    let idx: Int?
    let name: String?
}

struct MyKeywords: Codable {
    let success: Bool?
    let myKeywords: [String]?
    let token: String?
}

struct KeywordToonList: Codable {
    let toonKeyword: String?
    let toonTags: [String]?
}
