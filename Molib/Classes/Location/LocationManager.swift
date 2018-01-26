
import Foundation
import CoreLocation
import MapKit

#if os(iOS)

let kLocationErrorCode = 901

@objc public protocol LocationManagerDelegate: NSObjectProtocol {

    func locationServicesDisabled()

    func locationServiceFailed(error: Error)

    func locationFound(location: CLLocation)
 
    func geoCodeFound(placeMark: CLPlacemark)
    
    func geoCodeFailed(error: Error)
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
    
        handleAuthorisationForState(authStatus: authStatus)
    }
    
    func handleAuthorisationForState(authStatus: CLAuthorizationStatus) {
        
        switch (authStatus) {
            
        case .notDetermined:
            
            if manager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
                
                manager.requestWhenInUseAuthorization()
           
            } else {
                
                manager.startUpdatingLocation()
           
            }
            
            break
        
        case .authorizedAlways:
            
            manager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
            
            manager.startUpdatingLocation()
            
            
        case .denied:
            
            let userInfo = [NSLocalizedDescriptionKey: "You currently have all location services for this app disabled. You will need to enable them to get your current location"]
            
            let error = NSError(domain: "LocationManager", code: kLocationErrorCode, userInfo: userInfo)
            
            delegate?.locationServiceFailed(error: error)

        default:
            break
            
        }

    }
    
    
    //mark: - CLLocationManager Delegate Methods
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        handleAuthorisationForState(authStatus: status)
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let location = locations.last {

            let eventDate = location.timestamp
    
            let howRecent = eventDate.timeIntervalSinceNow
    
            if (abs(howRecent) < 15.0 || self.currentLocation == nil) {
            // If the event is recent, do something with it.
                currentLocation = location
                
                delegate?.locationFound(location: currentLocation!)
                
                reverseGeocodeLocation(geoLocation: currentLocation!)
            }

            manager.stopUpdatingLocation()
            
        } else {
            
            let userInfo = [NSLocalizedDescriptionKey: "Unable to determine location"]
            
            let error = NSError(domain: "LocationManager", code: kLocationErrorCode, userInfo: userInfo)
            
            delegate?.locationServiceFailed(error: error)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        let nsError = error as NSError

        let clErrorCode = CLError(_nsError: nsError) // (_nsError: error._code)

        switch (clErrorCode) {
        
        case CLError.denied:
    
            delegate?.locationServicesDisabled()
            break
    
        default:
    
            delegate?.locationServiceFailed(error: error)
            break
        }
    
        manager.stopMonitoringSignificantLocationChanges()
    }
    
    
    // mark: - Utils
    
    public func distanceFromCurrentLocationToLocation(coordinate: CLLocationCoordinate2D) -> CLLocationDistance{
    
        var distance: CLLocationDistance = 0
        
        if let myLocation = currentLocation {
            
            let location = CLLocation(latitude:coordinate.latitude, longitude:coordinate.longitude)
    
            distance = distanceFrom(location1: myLocation.coordinate, to:location.coordinate)
        }
        
        return distance / 1000;
    }
    
    private func distanceFrom(location1: CLLocationCoordinate2D, to location2:CLLocationCoordinate2D) -> CLLocationDistance {
    
        let start = MKMapPointForCoordinate(location1)
        
        let finish = MKMapPointForCoordinate(location2)

        return MKMetersBetweenMapPoints(start, finish) * 1000
    }
    
    func reverseGeocodeLocation(geoLocation: CLLocation) {
        
        let reverseGeocoder = CLGeocoder()
            
        reverseGeocoder.reverseGeocodeLocation(geoLocation) { (placeMarks: [CLPlacemark]?, error: Error?) in
            
                if placeMarks != nil {
                    
                    if let placeMark = placeMarks?.first {
                        self.delegate?.geoCodeFound(placeMark: placeMark)
                    }
                } else {
                    
                    self.delegate?.geoCodeFailed(error: error!)
                }
            }
    }
    
    func reverseGeocodeCurrentLocation() {
        
        if let location = self.currentLocation {
            
            self.reverseGeocodeLocation(geoLocation: location)
        }
    }
}

#endif
