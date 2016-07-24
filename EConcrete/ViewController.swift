//
//  ViewController.swift
//  EConcrete
//
//  Created by Данияр on 04.05.16.
//  Copyright © 2016 Данияр. All rights reserved.
//
import Foundation
import Alamofire
//import AlamofireObjectMapper
import SwiftyJSON
import XWebView
import FileBrowser

class EDS : NSObject {
    
    private var vc:ViewController
    
    var hasFile:Bool = false
    
    var signXML:String = ""
    var subjectDN = ""
    
    private var Defaults = NSUserDefaults.standardUserDefaults()
    
    init(newVC : ViewController) {
        
        vc = newVC
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        print("path = \(documentsPath)")
        
        if let path = Defaults.valueForKey("eds-filepath") {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(path as! String) {
                print("yes, I see file \(path)")
                self.hasFile = true
                print("FILE AVAILABLE")
            } else {
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("no file selected")
        }
        
    }
    
    func fileExists() -> Bool {
        
        if let path = Defaults.valueForKey("eds-filepath") {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.fileExistsAtPath(path as! String) {
                
                
                self.hasFile = true
                
                self.vc.CRMView!.evaluateJavaScript("ncaMobile.showPassword(true)", completionHandler: { (result, error) in
                    if error == nil {
                        print("результат 1 - \(result)")
                    } else {
                        print("ошибка 1 - \(error)")
                    }
                })
                
            } else {
                print("FILE NOT AVAILABLE")
            }
        } else {
            print("no file selected")
        }
        
        if !self.hasFile {
            
            vc.CRMView!.evaluateJavaScript("alert('Выберите файл ЭЦП (*.p12)')",  completionHandler: { (result, error) in
                if error == nil {
                    print(result)
                }
            })

        }
        return true
    }
    
    func getSubjectDN(password: String) -> String {
        
        // TODO это тестовая строка, удалить
        //self.doSignature("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><root><name>Daniyar</name></root>",ncaPassword: password)
        
        let path = self.Defaults.valueForKey("eds-filepath") as! String
        print(path)
        
        var subjDN:String = getSubDN(path,password)
        		
        if subjDN.containsString("error") || subjDN.isEmpty {
            
            self.subjectDN = subjDN //["errorCode" : "NONE", "result" : subDN]
            vc.CRMView!.evaluateJavaScript("ncaMobile.showError({ errorCode : \"Проверьте пароль и файл.\"})",  completionHandler: { (result, error) in
                if error == nil {
                    print("результат showError - \(result)")
                } else {
                    print("ошибка showError - \(error)")
                }
            })
            return "error"
        }
        
        
        subjDN = subjDN.stringByReplacingOccurrencesOfString(", ", withString: ",", options: NSStringCompareOptions.LiteralSearch, range: nil)
        subjDN = subjDN.stringByReplacingOccurrencesOfString(" = ", withString: "=", options: NSStringCompareOptions.LiteralSearch, range: nil)
        

        
        print("subjectDN = \(subjDN)")
//        subjDN = "TEST=123456\(subjDN)"
        
//        subjDN = "serialNumber=IIN35135138,OU=BIN1351381138183,O=aksjdfkljas asdf as,CN=asdfasd fasdf as,SN=asdfas,L=asdfasf"
        
        self.subjectDN = subjDN //["errorCode" : "NONE", "result" : subDN]
                vc.CRMView!.evaluateJavaScript("ncaMobile.showPerson(true)",  completionHandler: { (result, error) in
            if error == nil {
                print("результат 2 - \(result)")
            } else {
                print("ошибка 2- \(error)")
            }	
        })
        
        let jsonSubDN : JSON = JSON(["result" : subjDN as NSString])
        
        print(jsonSubDN)
        
        vc.CRMView!.evaluateJavaScript("ncaMobile.postGetSubjectDN(\(jsonSubDN))",  completionHandler: { (result, error) in
            if error == nil {
                print("результат 3 - \(result)")
            } else {
                print("ошибка 3 - \(error)")
            }
        })
        
        return subjDN
    }
    
    
    func doSignature(xmlData : String, ncaPassword: String) -> String {
        
        let path = self.Defaults.valueForKey("eds-filepath") as! String
        print("НЕ МОЖЕТ БЫТЬ ОН ЖЕ НА МЕСТЕ - " + path)
        self.signXML = xmlsignersign(path,xmlData,ncaPassword,0);
        
        let jsonXML : JSON = JSON(["result" : signXML])
        
        print(jsonXML)
        
        vc.CRMView!.evaluateJavaScript("ncaMobile.postSignXml(\(jsonXML))", completionHandler: { (result, error) in
            if error == nil {
                print("результат 4 - \(result)")
            } else {
                print("ошибка 4 - \(error)")
            }
        })
        
        return self.signXML
    }
    
}

public class MobileJS : NSObject {
    
    var vc:ViewController
    
    
    init(newVC : ViewController) {
        vc = newVC
    }
    
    func showDriverOnMap (id:String) {
        
        vc.ttnID = Int(id)!
        vc.traking = false
        vc.performSegueWithIdentifier("map", sender: self)
    }
    
    func startDriverOnMap () {
        vc.traking = true
        vc.performSegueWithIdentifier("map", sender: self)
    }
}

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    @IBOutlet var OpenMenu: UIBarButtonItem!
    var CRMView : WKWebView?
    var MenuArray : JSON = []
    var menuId : Int = 0
    var isReadyToPerform : Bool = false;
    var ttnID:Int = 0
    var traking:Bool = false
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
            
        if self.revealViewController() != nil {
        
            OpenMenu.target = self.revealViewController()
            OpenMenu.action = #selector(SWRevealViewController.revealToggle(_:))
        
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
//
//        let dateStore = WKWebsiteDataStore.defaultDataStore()
//        dateStore.fetchDataRecordsOfTypes([WKWebsiteDataTypeCookies], completionHandler: {
//            (records) -> Void in
//                for (_,record) in records.enumerate(){
//                    WKWebsiteDataStore.defaultDataStore().removeDataOfTypes([WKWebsiteDataTypeCookies],forDataRecords:records,completionHandler: { () -> Void in
//                        if Global.URL.containsString(record.displayName) {
//                            print("Cookies for \(record.displayName) deleted successfully")
//                        }
//                    })
//
//                }
//            }
//        )	
        
        let webViewConfig = WKWebViewConfiguration()

        let userContentController = WKUserContentController()
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            let script = getJSCookiesString(cookies)
            let cookieScript = WKUserScript(source: script, injectionTime: WKUserScriptInjectionTime.AtDocumentStart, forMainFrameOnly: false)
            userContentController.addUserScript(cookieScript)
        }
        webViewConfig.userContentController = userContentController
        
        let mobileJS = MobileJS(newVC: self)
        let edsObj = EDS(newVC: self)
        
        CRMView = WKWebView(frame: view.frame, configuration: webViewConfig)
        CRMView!.loadPlugin(mobileJS, namespace: "MobileMap")
        CRMView!.loadPlugin(edsObj, namespace: "Mobile")

        view.addSubview(CRMView!)
        CRMView!.UIDelegate = self
    }
    
    ///Generates script to create given cookies
    func getJSCookiesString(cookies: [NSHTTPCookie]) -> String {
        var result = ""
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.stringFromDate(date)); "
            }
            if (cookie.secure) {
                result += "secure; "
            }
            result += "'; "
        }
        return result
    }
    
    // show Errors
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error)
        if(error.code == NSURLErrorNotConnectedToInternet){
            
            webView.loadHTMLString("Отсутствует соединение с сетью Интернет!",baseURL:  nil)
        }
    }
    
    // display alert dialog
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        
        let alertController = UIAlertController(title: "E-Concrete: Внимание!", message: message, preferredStyle: .Alert)
        let otherAction = UIAlertAction(title: "OK", style: .Default) {
            action in completionHandler()
        }
        alertController.addAction(otherAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // display confirm dialog
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        let alertController = UIAlertController(title: "E-Concrete: Внимание!", message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            action in completionHandler(false)
        }
        let okAction = UIAlertAction(title: "OK", style: .Default) {
            action in completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // display prompt dialog
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        
        // variable to keep a reference to UIAlertController
        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .Alert)
        
        let okHandler: () -> Void = { handler in
            if let textField = alertController.textFields?.first {
                completionHandler(textField.text)
            } else {
                completionHandler("")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            action in completionHandler("")
        }
        let okAction = UIAlertAction(title: "OK", style: .Default) {
            action in okHandler()
        }
        alertController.addTextFieldWithConfigurationHandler() { $0.text = defaultText }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        MenuArray = JSON.parse(defaults.valueForKey("main-menu") as! String)
        
        loadCRMView ()
        

    }

    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadCRMView () {
        
        let menu = MenuArray[menuId]["url"].rawString()!
        let url = NSURL(string: Global.URL + Global.STATIC_PAGE + menu)
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(url!)
        var cookstr = ""
        for(_,cookie) in (cookies?.enumerate())! {
            cookstr = cookstr + cookie.name + "=" + cookie.value + ";"
        }
        
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        request.addValue(cookstr, forHTTPHeaderField: "Cookie")
        
        CRMView!.loadRequest(request)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "map" {
            
            let NavVC = segue.destinationViewController as! UINavigationController
            let MapVC = NavVC.topViewController as! MapViewController
            
            MapVC.tracking = self.traking
            MapVC.ttnID = self.ttnID
        }

    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
                
        if !isReadyToPerform && identifier == "exit" {
            Alamofire
                .request(.GET, Global.URL + "auth/logout")
                .responseJSON {response -> Void in
                    
                    if let json:JSON = JSON(data:response.data!) {
                        print("Пришли данные пользователя: \(json)")
                        print("Got user info")
                        self.isReadyToPerform = true
                        self.performSegueWithIdentifier("exit", sender: self)
                    }
                }
        }
        return isReadyToPerform
    }
}

