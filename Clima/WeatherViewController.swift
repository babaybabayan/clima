//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

protocol ChangeCityDelegate {
    func updateWeatherCity(city: String)
}

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    //    let WEATHER_URL_DUA = "https://samples.openweathermap.org/data/2.5/weather"
    //    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let MY_APP_ID = "c213b1620f887c821c9f76d8f588ef1a"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameter: [String:String]){
        Alamofire.request(url, method: .get, parameters: parameter).responseJSON {
            response in
            if response.result.isSuccess {
                print(response.request!)
                let weatherData = JSON(response.result.value!)
                //                let weatherData: JSON = JSON(response.result.value!)
                //                print(weatherData)
                self.updateWeatherData(weatherData)
                
            } else {
                self.cityLabel.text = "Connection Unavailable"
            }
        }
    }
    
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
    func updateWeatherData(_ json: JSON){
        
        if let tempResult = json["main"]["temp"].double {
            let cityName = json["name"].stringValue
            let condition = json["weather"][0]["id"].intValue
            weatherDataModel.temperature = Int(Double(tempResult - 273.15))
            weatherDataModel.city = cityName
            weatherDataModel.condition = condition
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather unavailable"
            weatherIcon.image = UIImage(named: "dunno")
            temperatureLabel.text = "\(0)℃"
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("Lat : \(location.coordinate.latitude), Long : \(location.coordinate.longitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params: [String: String] = ["lat": latitude, "lon": longitude, "appid": MY_APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameter: params)
        }
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "location unavailable"
    }
    
    
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func updateWeatherCity(city: String) {
        let params: [String: String] = ["q": city, "appid": MY_APP_ID]
        getWeatherData(url: WEATHER_URL, parameter: params)
    }
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
}


