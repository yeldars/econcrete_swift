//
//  BackTableVC.swift
//  EConcrete
//
//  Created by Данияр on 04.05.16.
//  Copyright © 2016 Данияр. All rights reserved.
//

import Alamofire
import SwiftyJSON
import FileBrowser

//struct MenuItem  {
//    var id : Int = -1
//    var hi_id : Int = 0
//    var url : String = "#/dashboard.html"
//    var title : String = "Main"
//    var title_ru : String = "Главная"
//    var title_kk : String = "Главная kk"
//    var title_en : String = "Main"
//    var icon : String = "icon-home"
//}

class BackTableVC: UITableViewController {
    
    var MenuArray : JSON = [] //[MenuItem]()
    var UserInfo : JSON = []
    var Defaults = NSUserDefaults.standardUserDefaults()
    
    
    
    override func viewDidLoad() {
        //
        
        MenuArray = JSON.parse(self.Defaults.valueForKey("main-menu") as! String)
        UserInfo = JSON.parse(self.Defaults.valueForKey("user-info") as! String)
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        var title = self.MenuArray[indexPath.row]["title_ru"].rawString()!
        
        if(title == "") {
            title = self.MenuArray[indexPath.row]["title"].rawString()!
        }
        
        cell.textLabel?.text = title
        
        return cell;
    
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let revealer = self.revealViewController()
        let revVC = revealer.frontViewController as! UINavigationController
        let destVC = revVC.topViewController as! ViewController
        destVC.menuId = indexPath.row
        destVC.loadCRMView()
        revealer.revealToggle(self)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 210
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header: UIView = UIView()
        
        header.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 150)
        Alamofire.request(.GET, Global.URL + "getfile?code=" + UserInfo["user_pic_file"].rawString()!).response { (_, _, data, error) in
            if error == nil {
                let avatar : UIImageView = UIImageView(frame: CGRectMake(16, 16, tableView.frame.width / 2 , 100))
                avatar.image = UIImage(data: data!) ?? UIImage(named: "md-logo.png")
                avatar.contentMode = UIViewContentMode.ScaleAspectFit
                header.addSubview(avatar)
            }
        }
        
        let username = UILabel(frame: CGRectMake(16, 124, header.frame.width, 21))
        username.text = self.UserInfo["title"].rawString()
        header.addSubview(username)
        
        let email : UILabel = UILabel(frame: CGRectMake(16, 150, header.frame.width, 21))
        email.text = self.UserInfo["email"].rawString()
        header.addSubview(email)
        
        let edsBtn : UIButton = UIButton(frame: CGRectMake(16,176,150,21))
        edsBtn.setTitle("Файл-ЭЦП (*.p12)", forState: .Normal)
        edsBtn.addTarget(self, action: #selector(self.setEDS), forControlEvents: .TouchUpInside)
        
        header.addSubview(edsBtn)
        
        header.backgroundColor = UIColor.blueColor()

        return header

    }
    
    func setEDS() {
        
        let fileBrowser = FileBrowser()
        
//        if let path = self.Defaults.valueForKey("eds-filepath") {
//            let path:NSURL = NSURL(fileURLWithPath: path as! String)
//            fileBrowser = FileBrowser(initialPath: path)
//        }
        
        self.presentViewController(fileBrowser, animated: true, completion: nil)
        
        fileBrowser.didSelectFile = { (file: FBFile) -> Void in
                        let path = file.filePath.absoluteString
            let index = path.startIndex.advancedBy(7)
            print("ЭТО ПУТЬ К ФАЙЛУ P12 - \(path.substringFromIndex(index))")
            
            self.Defaults.setValue(path.substringFromIndex(index), forKey: "eds-filepath")
            self.Defaults.synchronize()

        }

    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        
//        if (segue.identifier == "goweb") {
//            let navController = segue.destinationViewController as! UINavigationController
//            let DestVC = navController.topViewController as! ViewController
//            
//            let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow!
//            
//            DestVC.menuId = indexPath.row
//
//        }
//    }
}