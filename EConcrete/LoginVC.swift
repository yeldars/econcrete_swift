//
//  LoginVC.swift
//  EConcrete
//
//  Created by Данияр on 05.05.16.
//  Copyright © 2016 Данияр. All rights reserved.
//

//import Cocoa
import Alamofire
import SwiftyJSON

class LoginVC: UIViewController {
    
    @IBOutlet var Logo: UIImageView!
    @IBOutlet var PasswordInput: UITextField!
    @IBOutlet var EnterButton: UIButton!
    @IBOutlet var LoginInput: UITextField!
    @IBOutlet var MessageLabel: UILabel!
    
    var isReadyToPerform: Bool = false
    var env = NSProcessInfo.processInfo().environment
    var Defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        Defaults.setValue(nil, forKey: "main-menu")
        Defaults.setValue(nil, forKey: "user-info")
    }
    
    override func viewDidLayoutSubviews() {
        Logo.frame = CGRect(x:40,y:Logo.frame.minY,width: view.bounds.width - 80,height: Logo.bounds.height)
        LoginInput.frame = CGRect(x: 40, y: LoginInput.frame.minY, width: view.bounds.width - 80,height: 30)
        PasswordInput.frame = CGRect(x: 40, y: PasswordInput.frame.minY, width: view.bounds.width - 80,height: 30)
        EnterButton.frame = CGRect(x: 40, y: EnterButton.frame.minY, width: view.bounds.width - 80,height: 30)
        MessageLabel.frame = CGRect(x: 40, y: MessageLabel.frame.minY, width: view.bounds.width - 80,height: 30)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        if !isReadyToPerform && identifier == "login" {
            (sender as! UIButton).enabled = false
            let request = NSMutableURLRequest(URL: NSURL(string:Global.URL + "restapi/login")!)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let values = ["login" : LoginInput.text!, "password":PasswordInput.text!, "system" : "android"]
            
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(values, options: [])
            
            print("Log In \(request.URL?.absoluteString)")
            
            Alamofire
                .request(request)
                .responseJSON {response in
                    
                    if response.result.isSuccess {
                        let json = JSON(data:response.data!)
                        print("Пришли данные авторизации: \(json)")
                        (sender as! UIButton).enabled = false
                        if json["Result"].rawString()!.uppercaseString == "OK" {
                            
                            print("Logged in")
                            self.isReadyToPerform = true
                            self.performSegueWithIdentifier("login", sender: self)
                        }
                    }

                }
        }
        
        return isReadyToPerform
    }
}

