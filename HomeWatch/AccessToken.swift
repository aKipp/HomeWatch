//
//  AccessToken.swift
//  HomeWatch
//
//  Created by Dennis Mathias on 25.08.17.
//  Copyright © 2017 MPMI. All rights reserved.
//

import Foundation

struct AccessToken{

    var access_token : String
    var token_type : String
    var expires_in : String
    var refresh_token : String

    init(_access_token : String, _expires_in : String, _refresh_token : String, _token_type : String){
        self.access_token = _access_token
        self.token_type = _token_type
        self.expires_in = _expires_in
        self.refresh_token = _refresh_token
    }
}
