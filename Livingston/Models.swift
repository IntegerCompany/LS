//
//  Models.swift
//  Livingston
//
//  Created by Max Vitruk on 04.09.15.
//  Copyright (c) 2015 integer. All rights reserved.
//

import Foundation
import RealmSwift


// Person model
class RecordedFish: Object {
    dynamic var userName = ""
    dynamic var dateTime = NSDate(timeIntervalSince1970: 1)
    dynamic var image = NSData()
    dynamic var weight = ""
    dynamic var lenght = ""
    dynamic var note = ""
}