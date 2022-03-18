//
//  LocationManager.swift
//  uv.identifier
//
//  Created by Tim Baum on 18.03.22.
//

import MapKit

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    @Published var region: MKCoordinateRegion?
    @Published var city: String?
    @Published var country: String?
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        }
        else {
            print("Location Services Unavailable")
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            print("Location is restricted")
        case .denied:
            print("Location is denied")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            updateCityAndCountry()
        @unknown default:
            break
        }
    }
    
    internal func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func updateCityAndCountry() {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: region!.center.latitude, longitude: region!.center.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { [self] (placemarks, error) -> Void in
                        
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            self.country = placeMark.country
            self.city = placeMark.locality
            print(country!, city!)
        })
    }
}
