//
//  MapViewController.swift
//  EConcrete
//
//  Created by Данияр on 11.05.16.
//  Copyright © 2016 Данияр. All rights reserved.
//

import MapKit
import CoreLocation
import Alamofire
import SwiftyJSON


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var MapView: MKMapView!
    
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    var tracking = false
    var ttnID:Int = 0
    var Defaults = NSUserDefaults.standardUserDefaults()
    var isInSaving = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.MapView = MKMapView(frame: self.view.bounds)

            //Setup our Map View

            self.MapView.delegate = self
            self.MapView.mapType = MKMapType.Standard
            self.MapView.showsUserLocation = self.tracking
            self.view.addSubview(self.MapView)
            
            if self.tracking {
                //Setup our Location Manager
                self.manager = CLLocationManager()
                self.manager.delegate = self
                self.manager.desiredAccuracy = kCLLocationAccuracyBest
                self.manager.requestAlwaysAuthorization()
                self.manager.startUpdatingLocation()
            } else {
                self.getDriverOnMap()
            }

        }
    }
    
    func getDriverOnMap() {
        
        Alamofire
            .request(.GET, Global.URL + "restapi/detail?code=bi_beton_invoice&id=\(self.ttnID)")
            .responseJSON {response in
                if response.result.isSuccess {
                    let json = JSON(data:response.data!)
//                    print("Пришли данные о движении авто: \(json)")
                    self.drawDriverMoving(json["bi_driver_locs"])
                    
                    let seconds = 5.0
                    let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                
                    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                        self.getDriverOnMap()
                    })
                } else {
                    // TODO: make alert
                    print("Нет данных для отслеживания, да и вообще ошибка")
                }
        }
    }
    
    func drawDriverMoving(json:JSON) {
        for(index,_) in json.enumerate() {
            if index > 0 {
                let oldIndex = index - 1
                
                let c1 = CLLocationCoordinate2D(
                    latitude: Double(json[oldIndex]["lat"].rawString()!)!,
                    longitude: Double(json[oldIndex]["lon"].rawString()!)!
                )
                
                let c2 = CLLocationCoordinate2D(
                    latitude: Double(json[index]["lat"].rawString()!)!,
                    longitude: Double(json[index]["lon"].rawString()!)!
                )
                
                var a = [c1, c2]
                let polyline = MKPolyline(coordinates: &a, count: a.count)
                MapView.addOverlay(polyline)
            }
        }
        
        

        let spanX = 0.007
        let spanY = 0.007

        let location = CLLocationCoordinate2D(
            latitude: Double(json[json.count - 1]["lat"].rawString()!)!,
            longitude: Double(json[json.count - 1]["lon"].rawString()!)!
        )

        let newRegion = MKCoordinateRegion(center: location, span: MKCoordinateSpanMake(spanX, spanY))
        MapView.setRegion(newRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //theLabel.text = "\(locations[0])"
        //print(locations[0])
        myLocations.append(locations[0] )
        
        let spanX = 0.007
        let spanY = 0.007
        let newRegion = MKCoordinateRegion(center: MapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        MapView.setRegion(newRegion, animated: true)
        
        
        if (myLocations.count > 1) {
            let sourceIndex = myLocations.count - 1
            let destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            let polyline = MKPolyline(coordinates: &a, count: a.count)
            MapView.addOverlay(polyline)
            
            if c1.latitude != c2.latitude || c1.longitude != c2.longitude {
                print(locations[0])
                sendLatLon(c1.latitude,lon: c1.longitude)
            }
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error.description)")
        
        let alertController = UIAlertController(title: "E-Concrete: Внимание!", message: "Не удалось получить данные о вашем местоположении", preferredStyle: .Alert)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 4
            return polylineRenderer
        }
        
        return nil
    }
    
    func sendLatLon(lat:Double,lon:Double) {
        
        
        let request = NSMutableURLRequest(URL: NSURL(string:Global.URL + "restapi/update_v_1_1")!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateString = dayTimePeriodFormatter.stringFromDate(NSDate())
        
        let value = ["lat" : lat, "lon":lon, "created_at": dateString]
        
        let arr = Defaults.valueForKey("locations")
        
        var values:[AnyObject!] = []
        
        if arr != nil {
            values = Defaults.objectForKey("locations")! as! [AnyObject!]
        }
        
        values.append(value)

        /* ---------- ------------ ------------ */
        if !isInSaving {
            
            isInSaving = true
            
            let item = ["table_name": "bi_driver_locs", "action" : "insert", "values" : values]
            let items = ["items" : [item]]
            
            
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(items, options: [])
            
            Alamofire
                .request(request)
                .responseJSON {response in
                    
                    if response.result.isSuccess {
                        let json = JSON(data:response.data!)
                        
    //                    print("Пришли данные о сохранении данных: \(json)")
                        
                        if json["error_text"].rawString()!.uppercaseString == "OK" {
                            self.Defaults.setObject([], forKey: "locations")
                            print("Сохранено")
                        } else {
                            self.Defaults.setObject(values, forKey: "locations")
                        }
                        self.Defaults.synchronize()
                    }
                    
                    self.isInSaving = false
                }
        }

    }
}
