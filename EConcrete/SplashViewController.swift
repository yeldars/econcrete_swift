//
//  SplashViewController.swift
//  EConcrete
//
//  Created by Данияр on 06.05.16.
//  Copyright © 2016 Данияр. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SplashViewController: UIViewController {
    
    var Defaults = NSUserDefaults.standardUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Alamofire
            .request(.GET, Global.URL + "restapi/query/get?code=sessioninfo")
            .responseJSON {response -> Void in
                
                if response.result.isSuccess {
                    
                    let json = JSON(data:response.data!)
                    print("Пришли данные пользователя: \(json)")
                    
                    if json["error"].rawString() == "0" {
                        self.Defaults.setValue(json["items"][0].rawString(), forKey: "user-info")
                        self.Defaults.synchronize()
                        print("Got user info \(json["items"][0])")
                    
                        Alamofire
                            .request(.GET, Global.URL + "restapi/menus/tree")
                            .responseJSON {response in
                                if response.result.isSuccess {
                                    let json = JSON(data:response.data!)
                                    print("Пришли данные меню: \(json)")
                                    print("Got menu")
                                    self.Defaults.setValue(json.rawString(), forKey: "main-menu")
                                    self.Defaults.synchronize()
                                
                                    self.performSegueWithIdentifier("enter", sender: self)
                                } else {
                                    self.performSegueWithIdentifier("attempt", sender: self)
                                }
                            }
                    } else {
                        self.performSegueWithIdentifier("attempt", sender: self)
                    }
                } else {
                    self.performSegueWithIdentifier("attempt", sender: self)
                }
            }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
