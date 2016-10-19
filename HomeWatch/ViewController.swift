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
        
        print("Start!")
        
        //request-methode test
        request("WHS", password: "H0chschule!", SHCSerial: "914100004433", CLIENTID: "94680176", CLIENTSECRET: "LgD1d8mWx0qHkG")

    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func request(accountname: String, password: String, SHCSerial: String, CLIENTID: String, CLIENTSECRET: String){
    
        let request = NSMutableURLRequest(URL: NSURL(string:  "https://api.services-smarthome.de/AUTH/token")!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Add Basic Authorization
        let loginString = NSString(format: "%@:%@", CLIENTID, CLIENTSECRET)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
        request.setValue(base64LoginString, forHTTPHeaderField: "Authorization")

        /* Payload is
        {Grant_Type: "password", UserName: "/* UN */", Password: "/* PWD */", Scope: ""}

        let token = RequestToken(Grant_Type: "password", Scope: SHCSerial, UserName: accountname, Password: password)
        */
        
        
        let token = RequestToken(Grant_Type: "password", UserName: accountname, Password: password, Scope: SHCSerial);
        
        // Json-String erstellen
        let json = ["Grant_Type": "password", "UserName": accountname, "Password": password, "Scope": SHCSerial]
        

        
        
        let data : NSData = NSKeyedArchiver.archivedDataWithRootObject(json)

        
        if(NSJSONSerialization.isValidJSONObject(json)){
            request.HTTPBody = data
            print(request)
        }else {
           // TODO
            print("Error!")
        }
        
        
        // Connection
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error")
                return
            }
            
            let dataString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(dataString)
            
        }
        
        task.resume()
    }

}




