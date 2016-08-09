
import Foundation
import CoreLocation
import MapKit

#if os(iOS)

let kLocationErrorCode = 901

@objc public protocol LocationManagerDelegate: NSObjectProtocol {

    func locationServicesDisabled()

    func locationServiceFailed(error: NSError)

    func locationFound(location: CLLocation)
 
    func geoCodeFound(placeMark: CLPlacemark)
    
    func geoCodeFailed(error: NSError)
}


@objc public class LocationManager: NSObject, CLLocationManagerDelegate {
    

    var delegate: LocationManagerDelegate?
    
    private var manager: CLLocationManager
    private var reverseGeocoder:  CLGeocoder?

    private var currentLocation: CLLocation?

    override public init() {
        
        
        manager = CLLocationManager()
            
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
            
        manager.distanceFilter = 1000 // meters
        
        super.init()
    }

    
    public func requestCurrentLocation() {
    
        manager.delegate = self

        let authStatus = CLLocationManager.authorizationStatus()
    
        handleAuthorisationForState(authStatus)
    }
    
    func handleAuthorisationForState(authStatus: CLAuthorizationStatus) {
        
        switch (authStatus) {
            
        case .NotDetermined:
            
            if manager.respondsToSelector("requestWhenInUseAuthorization") {
                
                manager.requestWhenInUseAuthorization()
           
            } else {
                
                manager.startUpdatingLocation()
           
            }
            
            break
        
        case .AuthorizedAlways:
            
            manager.startUpdatingLocation()
            
        case .AuthorizedWhenInUse:
            
            manager.startUpdatingLocation()
            
            
        case .Denied:
            
            let userInfo = [NSLocalizedDescriptionKey: "You currently have all location services for this app disabled. You will need to enable them to get your current location"]
            
            let error = NSError(domain: "LocationManager", code: kLocationErrorCode, userInfo: userInfo)
            
            delegate?.locationServiceFailed(error)

        default:
            break
            
        }

    }
    
    
    //mark: - CLLocationManager Delegate Methods
    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    
        handleAuthorisationForState(status)
    }

    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 
        if let location = locations.last {

            let eventDate = location.timestamp
    
            let howRecent = eventDate.timeIntervalSinceNow
    
            if (abs(howRecent) < 15.0 || self.currentLocation == nil) {
            // If the event is recent, do something with it.
                currentLocation = location
            }

            manager.stopUpdatingLocation()
    
            delegate?.locationFound(currentLocation!)
            
        } else {
            
            let userInfo = [NSLocalizedDescriptionKey: "Unable to determine location"]
            
            let error = NSError(domain: "LocationManager", code: kLocationErrorCode, userInfo: userInfo)
            
            delegate?.locationServiceFailed(error)
        }
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {

        let clErrorCode = CLError(rawValue: error.code)

        switch (clErrorCode!) {
        
        case .Denied:
    
            delegate?.locationServicesDisabled()
            break
    
        default:
    
            delegate?.locationServiceFailed(error)
            break
        }
    
        manager.stopMonitoringSignificantLocationChanges()
    }
    
    
    // mark: - Utils
    
    public func distanceFromCurrentLocationToLocation(coordinate: CLLocationCoordinate2D) -> CLLocationDistance{
    
        var distance: CLLocationDistance = 0
        
        if let myLocation = currentLocation {
            
            let location = CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude)
    
            distance = distanceFrom(myLocation.coordinate, to:location.coordinate)
        }
        
        return distance / 1000;
    }
    
    private func distanceFrom(location1: CLLocationCoordinate2D, to location2:CLLocationCoordinate2D) -> CLLocationDistance {
    
        let start = MKMapPointForCoordinate(location1)
        
        let finish = MKMapPointForCoordinate(location2)

        return MKMetersBetweenMapPoints(start, finish) * 1000
    }
    
//    func reverseGeocodeCurrentLocation() {
//        
//        let currentLocation = manager.location
//        
//        if let location = currentLocation {
//            
//            let reverseGeocoder = CLGeocoder()
//
//            reverseGeocoder.reverseGeocodeLocation(location) { (placeMark: CLPlacemark?, errorOptional: NSError?) -> Void in
//                
//                if placemark != nil {
//                    
//                    delegate.geoCodeFound(placemark!)
//                } else {
//                    
//                    delegate.geoCodeFailed(error!)
//                }
//            }
//            
//        }
//    }
    
}

#endif
