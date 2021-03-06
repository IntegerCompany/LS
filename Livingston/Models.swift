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
    dynamic var lon = 0.0
    dynamic var lat = 0.0
    dynamic var lureName = ""
    dynamic var lureSound = ""
}

class LureData : Object {
    
    dynamic var LURE_ITEM_CODE = ""
    dynamic var LURE_CODE = ""
    dynamic var LURE_NAME = ""
    dynamic var LURE_WATER_TYPE = ""
    dynamic var LURE_STYLE = ""
    dynamic var LURE_IMAGE_URL = ""
    dynamic var LURE_UUID = ""
    dynamic var LURE_SOUND = ""
    
}