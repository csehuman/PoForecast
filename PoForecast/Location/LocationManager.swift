//
//  LocationManager.swift
//  PoForecast
//
//  Created by Paul Lee on 2022/08/30.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
    private override init() {
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        super.init()
        
        manager.delegate = self
    }
    
    let manager: CLLocationManager
    
    var currentLocationTitle: String? {
        didSet {
            var userInfo = [AnyHashable: Any]()
            if let location = currentLocation {
                userInfo["location"] = location
            }
            
            NotificationCenter.default.post(name: Self.currentLocationDidUpdate, object: nil, userInfo: userInfo)
        }
    }
    var currentLocation: CLLocation?
    
    static let currentLocationDidUpdate = Notification.Name(rawValue: "currentLocationDidUpdate")
    
    func updateLocation() {
        let status: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            requestAuthorization()
        case .denied, .restricted:
            print("Not Available")
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        default:
            print("Unknown")
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    private func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    private func requestCurrentLocation() {
        // manager.startUpdatingLocation()
        manager.requestLocation()
    }
    
    private func updateAddress(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print(error)
                self?.currentLocationTitle = "Unknown"
                return
            }
            
            if let placemark = placemarks?.first {
                if let city = placemark.locality {
                    self?.currentLocationTitle = "\(city)"
                } else {
                    self?.currentLocationTitle = placemark.name ?? "Unknown"
                }
            }
        }
    }
    
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case .notDetermined, .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    
    // For < 14.0
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case .notDetermined, .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // print(locations.last)
        
        if let location = locations.last {
            currentLocation = location
            updateAddress(from: location)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
