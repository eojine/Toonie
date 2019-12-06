//
//  FavoriteToon.swift
//  Toonie
//
//  Created by 이재은 on 28/04/2019.
//  Copyright © 2019 Yapp. All rights reserved.
//

struct WorkList: Codable {
    let success: Bool?
    let workListName: String?
    let workListInfo: String?
    let toonId: String?
    let toonList: [ToonList]?
}
