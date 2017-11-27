//
//  ViewController.swift
//  HomeWatch
//
//  Created by Dennis Mathias on 21.07.16.
//  Copyright � 2016 MPMI. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    //UI-Elements
    
    @IBOutlet weak var accountnameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var clientId = "94680176"
    var clientSecret = "LgD1d8mWx0qHkG"
    
    var testAccountname = "WHS"
    var testPassword = "H0chschule!"
    var testSHCSerial = "914100004433"
    
    var accessToken: String = ""
    var refreshToken: String = ""
    
    
    var requestDispatchGroup = DispatchGroup()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //First Funcion
        requestAccessToken(){
            //Wait for Closure of first function
            self.requestInitialize(scope: self.testSHCSerial)
        }
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        print("login-button pressed")
    }
    
    /*  API-Requests  */
    
    // Creating HTTP-Request for the AccessToken and starting the Session
    func requestAccessToken(onCompleted: @escaping () -> ()){
        print("requesting accessToken")
        
        let request = NSMutableURLRequest(url: URL(string:  "https://api.services-smarthome.de/AUTH/token")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Add Basic Authorization
        let loginString = NSString(format: "%@:%@", clientId, clientSecret)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())
        request.setValue(("Basic " + base64LoginString), forHTTPHeaderField: "Authorization")
        
        let json = ["Grant_Type": "password", "UserName": testAccountname, "Password": testPassword, "Scope": testSHCSerial]
        
        
        if(JSONSerialization.isValidJSONObject(json)){
            request.httpBody = jsonToNSData(json as AnyObject)
            //let content : Data = NSData(data: jsonToNSData(json as AnyObject)!) as Data
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                
                // Check for error
                if error != nil
                {
                    print("error")
                    return
                } else
                {
                    // Print out response string
                    let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Response")
                    print(responseString!)
                    
                    do{
                        if let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String:Any] {
                            
                            print("Refresh Token:")
                            let rToken = json["refresh_token"]
                            print(rToken!)
                            self.refreshToken = rToken as! String
                            
                            print("Access Token:")
                            let aToken = json["access_token"]
                            print(aToken!)
                            self.accessToken = aToken as! String
                            
                            onCompleted()
                        }
                    } catch let err{
                        print(err.localizedDescription)
                    }
                }
            }
            task.resume()
            
            
        }else {
            // TODO
            print("Error! Not a Json string")
        }
    }
    
    // Refresh Token
    func requestRefresh(refreshToken: String, CLIENTID: String, CLIENTSECRET: String){
        print("Start refreshing token")
        
        let request = NSMutableURLRequest(url: URL(string:  "https://api.services-smarthome.de/AUTH/token")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Add Basic Authorization
        let loginString = NSString(format: "%@:%@", CLIENTID, CLIENTSECRET)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())
        request.setValue(("Basic " + base64LoginString), forHTTPHeaderField: "Authorization")
        
        
        // Json-String erstellen
        let json = ["Grant_Type": "refresh_token", "Refresh_Token": refreshToken]
        
        
        if(JSONSerialization.isValidJSONObject(json)){
            request.httpBody = jsonToNSData(json as AnyObject)
            let content : Data = NSData(data: jsonToNSData(json as AnyObject)!) as Data
            
            //TODO Return data in connection-method?
            //connection(request as URLRequest, data: content)
            
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
            
            let task = session.uploadTask(with: request as URLRequest, from: content, completionHandler: {
                (data, response, error) in
                guard let _:Data = data, let _:URLResponse = response, error == nil else {
                    print("error with data while connected")
                    return
                }
                //let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                //print(">> dataString:")
                //print(dataString)
                
                //Creating json-string from data
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String:Any] {
                        
                        print("Refresh Token:")
                        let rToken = json["refresh_token"]
                        print(rToken!)
                        self.refreshToken = rToken as! String
                        
                    }
                } catch let err{
                    print(err.localizedDescription)
                }
            })
            
            task.resume()
            
        }else {
            // TODO
            print("Error! Not a Json string")
        }
        
    }
    
    
    // initialize
    func requestInitialize(scope: String){
        print("requesting initialize")
        
        
        
        let request = NSMutableURLRequest(url: URL(string:  "https://api.services-smarthome.de/AUTH/initialize/" + scope)!)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error")
                return
            } else
            {
                // Print out response string
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Response request Initialize")
                print(responseString!)
            }
        }
        task.resume()
        
    }
    
    // Get Devices
    func requestDevices(){
        print("Request Devices")
        
        let request = NSMutableURLRequest(url: URL(string:  "https://api.services-smarthome.de/AUTH/device")!)
        
        print("AccessToken Request Devices:")
        print(accessToken)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("Response")
            print(responseString!)
        }
        task.resume()
        
    }
    
    
    /*  Utility-Functions  */
    
    // Transforming Json to NSData
    func jsonToNSData(_ json: AnyObject) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print("JSONError:")
            print(myJSONError)
        }
        return nil;
    }
    
    //EOF
}



