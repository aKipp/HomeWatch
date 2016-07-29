//
//  ViewController.swift
//  HomeWatch
//
//  Created by Dennis Mathias on 21.07.16.
//  Copyright © 2016 MPMI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    func request(accountname: String, password: String, SHCSerial: String){
    
        let request = NSMutableURLRequest(URL: NSURL(string:  "https://api.services-smarthome.de/AUTH/token")!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "ContentType")
        
        // Add Basic Authorization
        let CLIENTID = "clientId"
        let CLIENTSECRET = "clientPass"
        let loginString = NSString(format: "%@:%@", CLIENTID, CLIENTSECRET)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        request.setValue(base64LoginString, forHTTPHeaderField: "Authorization")

        /* Payload is
        {Grant_Type: "password", UserName: "/* UN */", Password: "/* PWD */", Scope: ""}

        let token = RequestToken(Grant_Type: "password", Scope: SHCSerial, UserName: accountname, Password: password)
        */
        
        // Json-String erstellen
        let json = ["Grant_Type": "password", "UserName": accountname, "Password": password, "Scope": SHCSerial]
        let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(json)
        
        if(NSJSONSerialization.isValidJSONObject(json)){
            request.HTTPBody = data
        }else {
           // TODO
        }
        
        /* Connection
        let connection = NSURLConnection(request: request, delegate: nil, startImmediately: false)
        connection!.start()
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    

}

