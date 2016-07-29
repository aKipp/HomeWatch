//
//  RequestToken.swift
//  HomeWatch
//
//  Created by Dennis Mathias on 29.07.16.
//  Copyright © 2016 MPMI. All rights reserved.
//

import Foundation

class RequestToken{
    
    var Grant_Type : String
    var Scope : String
    var UserName : String
    var Password : String
    
    init(Grant_Type : String, Scope : String, UserName : String, Password : String){
        self.Grant_Type = Grant_Type
        self.Scope = Scope
        self.UserName = UserName
        self.Password = Password        
    }
    
}