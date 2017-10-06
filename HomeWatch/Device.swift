//
//  Device.swift
//  HomeWatch
//
//  Created by Dennis Mathias on 06.10.17.
//  Copyright © 2017 MPMI. All rights reserved.
//

import Foundation

class Device{
    
    var id: String
    var type: String
    var name: String
    var category: String
    
    init(_id: String, _type: String, _name: String, _category: String){
        self.id = _id
        self.type = _type
        self.name = _name
        self.category = _category
    }
    
}
