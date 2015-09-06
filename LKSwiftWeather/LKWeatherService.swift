//
//  LKWeatherService.swift
//  LKSwiftWeather
//
//  Created by Likid on 7/15/15.
//  Copyright (c) 2015 Likid. All rights reserved.
//

import CoreLocation
import SwiftyJSON
import Alamofire

/*!
WeatherCondition

- Thunderstorm:   Thunderstorm
- Drizzle:        Drizzle
- Rain:           Rain / Freezing rain / Shower rain
- Snow:           Snow
- Fog:            Fog / Mist / Haze / etc.
- Tornado:        Tornado / Squalls
- Sunny:          Sky is clear
- Cloudy:         few / scattered / broken clouds
- OvercastCloudy: overcast clouds
- Cold:           Extreme
- Hot:            Cold
- Extreme:        Hot
*/
enum WeatherCondition: Int {
    case Thunderstorm = 300
    case Drizzle = 500
    case Rain = 600
    case Snow = 700
    case Fog = 771
    case Tornado = 799
    case Sunny = 800
    case Cloudy = 803
    case OvercastCloudy = 804
    case Cold = 903
    case Hot = 904
    case Extreme1 = 900
    case Extreme2 = 902
    case Extreme3 = 905
    case Extreme4 = 1000
}

enum LKStatus {
    case success
    case failure
}

class LKResponse {
    var status: LKStatus = LKStatus.failure
    var object: JSON? = nil
    var error: NSError? = nil
}

class LKWeatherService {
    init() {
        
    }
    
    func retrieveForecast(latitude: CLLocationDegrees, logitude: CLLocationDegrees, success: (response: LKResponse) -> (), failure: (response: LKResponse) -> ()) {
        
        let url = "http://api.openweathermap.org/data/2.5/forecast"
        let params = ["lat": latitude, "lon": logitude]
        println(params)
        
        Alamofire.request(.GET, url, parameters: params).response { (request, response, json, error) -> Void in
            if error != nil {
                println("Error: \(error)")
                println(request)
                println(response)
                
                var resp = LKResponse()
                resp.status = LKStatus.failure
                resp.error = error
                failure(response: resp)
            } else {
                println("Success: \(url)")
                var jsonObject = JSON(json!)
                var resp = LKResponse()
                resp.status = LKStatus.success
                resp.object = jsonObject
                success(response: resp)
            }
        }
    }
    
    class func updateWeatherIcon(condition: Int, nightTime: Bool) -> String {

        var name = ""
        
        if condition < WeatherCondition.Thunderstorm.rawValue {
            name = LKWeatherService.imageName("tstorm1", isNight: nightTime)
        } else if condition < WeatherCondition.Drizzle.rawValue {
            name = "light_rain"
        } else if condition < WeatherCondition.Rain.rawValue {
            name = "shower3"
        } else if condition < WeatherCondition.Snow.rawValue {
            name = "snow4"
        } else if condition < WeatherCondition.Fog.rawValue {
            name = LKWeatherService.imageName("fog", isNight: nightTime)
        } else if condition <= WeatherCondition.Tornado.rawValue {
            name = "tstorm3"
        } else if condition == WeatherCondition.Sunny.rawValue {
            name = LKWeatherService.imageName("sunny", isNight: nightTime)
        } else if condition <= WeatherCondition.Cloudy.rawValue {
            name = LKWeatherService.imageName("cloudy2", isNight: nightTime)
        } else if condition == WeatherCondition.OvercastCloudy.rawValue {
            name = "overcase"
        } else if condition == WeatherCondition.Cold.rawValue {
            name = "snow5"
        } else if condition == WeatherCondition.Hot.rawValue {
            name = "sunny"
        } else if (condition >= WeatherCondition.Extreme1.rawValue && condition <= WeatherCondition.Extreme2.rawValue) ||
            (condition >= WeatherCondition.Extreme3.rawValue && condition < WeatherCondition.Extreme4.rawValue) {
                name = "tstorm3"
        } else {
            // Weather condition is not available
            name = "dunno"
        }
        
        return name
    }
    
    class func convertTemperatur(country: String, temperatrue: Double) -> Double {
        if country == "US" {
            // Convert temperature to Fahrenheit if user is within the US
            return round(((temperatrue - 273.15) * 1.8) + 32)
        } else {
            // Otherwise, convert temperature to Celsius
            return round(temperatrue - 273.15)
        }
    }
    
    class func isNightTime(icon: String) -> Bool {
        return icon.rangeOfString("n") != nil
    }
    
    class func imageName(name: String, isNight: Bool) -> String {
        return isNight ? nightImageName(name) : name
    }
    
    class func nightImageName(name: String) -> String {
        return name.stringByAppendingString("_night")
    }
}
