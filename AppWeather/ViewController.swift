//
//  ViewController.swift
//  AppWeather
//
//  Created by Danilo Requena on 23/07/19.
//  Copyright © 2019 Danilo Requena. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var conditionsImageView: UIImageView!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    let gradientLayer = CAGradientLayer()
    
    let apiKey = "8100973e52edece630d3b8f5a8b4cacc"
    var lat = 11.344533
    var lon = 104.33322
    var activityIndicator : NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(gradientLayer)
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        locationManager.requestWhenInUseAuthorization()
        activityIndicator.startAnimating()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setGrayGradientBackground()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        let urlApi = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric"
        Alamofire.request(urlApi).responseJSON {
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                print("Response = ", jsonResponse)
                guard let jsonWeather = jsonResponse["weather"].array?[0] else { return }
                let iconName = jsonWeather["icon"].stringValue
                let jsonTemp = jsonResponse["main"]
                
                
                self.locationLabel.text = jsonResponse["name"].stringValue
                self.conditionsImageView.image = UIImage(named: iconName)
                self.conditionsLabel.text = jsonWeather["main"].stringValue
                self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                let date = Date()
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "EEEE"
                self.dayLabel.text = dateFormat.string(from: date)
                
                let suffix = iconName.suffix(1)
                if (suffix == "n") {
                    self.setGrayGradientBackground()
                } else {
                    self.setBlueGradientBackground()
                }
            }
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func setBlueGradientBackground() {
        let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 114.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func setGrayGradientBackground() {
        let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
}

