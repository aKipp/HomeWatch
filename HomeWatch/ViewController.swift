//
//  ViewController.swift
//  HomeWatch
//
//  Created by Dennis Mathias on 21.07.16.
//  Copyright © 2016 MPMI. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {

    //UI-Elements
    
    @IBOutlet weak var accountnameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var accessToken: String = ""
    
    
    var requestDispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonAction(_ sender: UIButton) {
        //var name = self.accountnameTextfield.text
        //var pass = self.passwordTextfield.text
        
        
        //TODO Input account-data
        let name = "WHS"
        let pass = "H0chschule!"
        let serial = "914100004433"
        
        //login(accountname: name, password: pass, scope: serial)
        
        //https://home.innogy-smarthome.de/#/auth?code=1d97de9136fe49d7923907a887f59c11&state=f5d844d0-e245-443f-809b-71c1bd6f4911&_k=imogw9

        let code = "1d97de9136fe49d7923907a887f59c11"
        let id = "94680176"
        let sec = "LgD1d8mWx0qHkG"
        
        accessAuthCode(authCode: code, CLIENTID: id, CLIENTSECRET: sec)
        
    }
    
    
    func login(accountname: String, password: String, scope: String){
        //request-methode test
        //request("WHS", password: "H0chschule!", SHCSerial: "914100004433", CLIENTID: "94680176", CLIENTSECRET: "LgD1d8mWx0qHkG")
        
        request(accountname, password: password, SHCSerial: scope, CLIENTID: "94680176", CLIENTSECRET: "LgD1d8mWx0qHkG")
        
        requestDispatchGroup.notify(queue: .main){
            print("finish request")
            //self.initializeRequest(scope: scope)
            //self.getDevices()
            
            
            //redirect
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "overviewViewController") as! ViewController
            self.present(newViewController, animated: true, completion: nil)
            
        }
        
        //print(">> Get Initialize")
        //getInitialize()
        
        //print(">> Get Devices")
        //getDevices()
    }
    
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
    
    // Starting Session for Connection
    func connection(_ request: URLRequest, data: Data){
        // Connection
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = session.uploadTask(with: request, from: data, completionHandler: {
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
                    
                    print(json)
                    
                    //reading Refresh-token from json-String
                    let refreshToken = json["refresh_token"] as! String
                    
                    //TODO Access-Token Object from Json-String
                    self.accessToken = json["access_token"] as! String
                    
                }
            } catch let err{
                print(err.localizedDescription)
            }
            self.requestDispatchGroup.leave()
        })
        
        task.resume()
    }
    
    // Preparing Request for the Session
    func request(_ accountname: String, password: String, SHCSerial: String, CLIENTID: String, CLIENTSECRET: String){
        
        requestDispatchGroup.enter()
        
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
            let content : Data = NSData(data: jsonToNSData(json as AnyObject)!) as Data
            
            connection(request as URLRequest, data: content)
        }else {
           // TODO
            print("Error! Not a Json string")
        }
    }
        
        // Testing methods
        
        //TODO Post Token?
        
        // Refresh Token
    func refreshAccess(refreshToken: String, CLIENTID: String, CLIENTSECRET: String){
        
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
                        
                        print(json)
                        
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
    
    func accessAuthCode(authCode: String, CLIENTID: String, CLIENTSECRET: String){
        
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
        let json = ["Grant_Type": "authorization_code", "Code": authCode, "Redirect_Uri": "home.innogy-smarthome.de/"]
        
        
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
                        
                        print(json)
                        
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
    func initializeRequest(scope: String){
        print("requesting initialize")
        //TODO '/auth/'?
        let request = NSMutableURLRequest(url: URL(string:  "https://api.services-smarthome.de/AUTH/initialize/" + scope)!)
        
        //TODO httpmethod GET?
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        //connection()?
        
        //let session = NSURLSession.sharedSession()
        //let task = session.dataTaskWithRequest(request, completionHandler:completionHandler)
        //task.resume()
        
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
            }
        }
        task.resume()
        
    }
    
        // Get Devices
        func getDevices(){
            
            //TODO '/auth/'?
            let request = NSMutableURLRequest(url: URL(string:  "https://api.services-smarthome.de/AUTH/device")!)
            
            print("AccessToken:")
            print(accessToken)
            
            //TODO httpmethod GET?
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            //connection()?
            
            //let session = NSURLSession.sharedSession()
            //let task = session.dataTaskWithRequest(request, completionHandler:completionHandler)
            //task.resume()
            
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
    
    
    
    func testTokenRequest(){
        print("requesting initialize")
        
        let CLIENTID = "94680176"
        let CLIENTSECRET = "LgD1d8mWx0qHkG"
        let accountname = "WHS"
        let password = "H0chschule!"
        let SHCSerial = "914100004433"
        
        
        let request = NSMutableURLRequest(url: URL(string:  "https://api.services-smarthome.de/AUTH/token")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        // Add Basic Authorization
        let loginString = NSString(format: "%@:%@", CLIENTID, CLIENTSECRET)
        let loginData: Data = loginString.data(using: String.Encoding.utf8.rawValue)!
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())
        request.setValue(("Basic " + base64LoginString), forHTTPHeaderField: "Authorization")
        
        let json = ["Grant_Type": "password", "UserName": accountname, "Password": password, "Scope": SHCSerial]
        
        
        if(JSONSerialization.isValidJSONObject(json)){
            request.httpBody = jsonToNSData(json as AnyObject)
            let content : Data = NSData(data: jsonToNSData(json as AnyObject)!) as Data
            
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
                }
            }
            task.resume()
            
            
        }else {
            // TODO
            print("Error! Not a Json string")
        }
    }
    
    
//EOF
}




