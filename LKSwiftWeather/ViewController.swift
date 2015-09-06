//
//  ViewController.swift
//  LKSwiftWeather
//
//  Created by Likid on 7/3/15.
//  Copyright (c) 2015 Likid. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
                      CLLocationManagerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var todayTemperatureLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    
    var country = ""
    var itemDatas = Array<JSON>();
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        
        let background = UIImage(named: "background")!
        view.backgroundColor = UIColor(patternImage: background)
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: "onTapedView:")
        view.addGestureRecognizer(singleFingerTap)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func onTapedView(recognizer: UITapGestureRecognizer) {
        locationManager.startUpdatingLocation()
    }
    
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let url = "http://api.openweathermap.org/data/2.5/forecast"
        let params = ["lat":latitude, "lon":longitude]
        println(params)
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { (request, response, json, error) in
                if(error != nil) {
                    println("Error: \(error)")
                    println(request)
                    println(response)
                }
                else {
                    println("Success: \(url)")
                    println(request)
                    var json = JSON(json!)
                    self.updateUISuccess(json)
                }
        }
    }
    
    // MARK: - UICollectionViewDelegate && UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemDatas.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LKDailyReportCellID, forIndexPath: indexPath) as! LKDailyReportCell;
        
        let weatherJSON = itemDatas[indexPath.row]
        
        
        if let tempResult = weatherJSON["main"]["temp"].double {
            var temperature = LKWeatherService.convertTemperatur(country, temperatrue: tempResult)
            cell.temperatureLabel.text = "\(temperature)°"
            
            // Get and set icon
            let weather = weatherJSON["weather"][0]
            let condition = weather["id"].intValue
            var icon = weather["icon"].stringValue
            var nightTime = LKWeatherService.isNightTime(icon)
            let imageName = LKWeatherService.updateWeatherIcon(condition, nightTime: nightTime)
            
            cell.imageView.image = UIImage(named: imageName)
            
            // Get forecast time
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let rawDate = weatherJSON["dt"].doubleValue
            let date = NSDate(timeIntervalSince1970: rawDate)
            let forecastTime = dateFormatter.stringFromDate(date)
            
            cell.timeLabel.text = forecastTime
        }
        
        return cell;
    }
    
    // MARK: - Private
    
    func updateUISuccess(json: JSON) {
        loadingLabel.text = nil
        
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        
        locationLabel.hidden = false
        weatherImageView.hidden = false
        todayTemperatureLabel.hidden = false
        
        if let tempResult = json["list"][0]["main"]["temp"].double {
            country = json["city"]["country"].stringValue
            
            var temperature = LKWeatherService.convertTemperatur(country, temperatrue: tempResult)
            self.todayTemperatureLabel.text = "\(temperature)°"
            
            self.locationLabel.text = json["city"]["name"].stringValue
            
            itemDatas.removeAll(keepCapacity: true)
            
            for index in 1...4 {
                
                println(json["list"][index])
                
                itemDatas.append(json["list"][index])
            }
            
            collectionView.reloadData()
            
        } else {
            self.loadingLabel.text = "Weather info is not available!"
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location:CLLocation = locations[locations.count - 1] as! CLLocation
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            println(location.coordinate)
            updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
        self.loadingLabel.text = "Can't get your location!"
    }
}

