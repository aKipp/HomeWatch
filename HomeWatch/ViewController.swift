//
//  ViewController.swift
//  HomeWatch
//
//  Created by Dennis Mathias on 21.07.16.
//  Copyright © 2016 MPMI. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

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
    
    // Transforming Json to NSData
    func jsonToNSData(_ json: AnyObject) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
    
    // Starting Session for Connection
    func connection(_ request: URLRequest, data: Data){
        // Connection
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = session.uploadTask(with: request, from: data, completionHandler: {
            (data, response, error) in
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString)
        })
        
        task.resume()
    }
    
    // Preparing Request for the Session
    func request(_ accountname: String, password: String, SHCSerial: String, CLIENTID: String, CLIENTSECRET: String){
    
        let request = NSMutableURLRequest(url: URL(string:  "https://api.services-smarthome.de/AUTH/token")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Add Basic Authorization
        let loginString = NSString(format: "%@:%@", CLIENTID, CLIENTSECRET)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())
        request.setValue(("Basic " + base64LoginString), forHTTPHeaderField: "Authorization")

        /* Payload is
        {Grant_Type: "password", UserName: "/* UN */", Password: "/* PWD */", Scope: ""}

        let token = RequestToken(Grant_Type: "password", Scope: SHCSerial, UserName: accountname, Password: password)
        */
        
        //        let token = RequestToken(Grant_Type: "password", UserName: accountname, Password: password, Scope: SHCSerial);
        
        
        // Json-String erstellen
        let json = ["Grant_Type": "password", "UserName": accountname, "Password": password, "Scope": SHCSerial]

        
        if(JSONSerialization.isValidJSONObject(json)){
            request.httpBody = jsonToNSData(json as AnyObject)
            print(json)
            let content : Data = NSData(data: jsonToNSData(json as AnyObject)!) as Data
            
            connection(request as URLRequest, data: content)
        }else {
           // TODO
            print("Error! Not a Json string")
        }
        
    }

}




