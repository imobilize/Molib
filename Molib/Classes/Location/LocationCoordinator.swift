
import Foundation
import UIKit
import MapKit

#if os(iOS)
public protocol LocationCoordinatorDelegate {
    
    func locationCoordinatorDidFindCurrentLocation(coordinator: LocationCoordinator, location: MOGeoLocation)

    func locationCoordinatorDidFail(coordinator: LocationCoordinator, alertController: UIViewController)
    
}


@objc public class LocationCoordinator: NSObject, LocationManagerDelegate {
    
    public var delegate: LocationCoordinatorDelegate?
    
    
    private var preferredLocation: MOGeoLocation
    
    private var actualLocation: MOGeoLocation
    
    private var locationManager: LocationManager
    
    private var userDefaults: UserConfig
    
    private var alertController: UIAlertController!
    
    
    public init(locationManager: LocationManager, userDefaults: UserConfig) {
        
        self.locationManager = locationManager
        self.userDefaults = userDefaults
        
        let dictionaryOptional = userDefaults.dictionaryForKey(key: kLocationDictionaryUserDefaultsKey)
        
        if let dictionary = dictionaryOptional {
        
            self.preferredLocation = MOGeoLocation(dictionary: dictionary)
        
        } else {
            
            self.preferredLocation = MOGeoLocation(name: "Unknown Location", coords: CLLocationCoordinate2DMake(999, 999))
        }
        
        self.actualLocation = self.preferredLocation
        
        super.init()

        self.locationManager.delegate = self
    }
    
    public func currentLocation() -> MOGeoLocation {
        
        return actualLocation
    }
    
    public func usersPreferredLocation() -> MOGeoLocation {
        
        return self.preferredLocation
    }
    
    public func setUsersPreferredLocation(location: MOGeoLocation) {
        
        self.preferredLocation = location
    }
    
    public func requestCurrentLocation() {
        
        self.locationManager.requestCurrentLocation()
    }
    
    public func setCurrentLocation(geoLocation: MOGeoLocation) {
        
        let locationDictionary = geoLocation.toDictionary()
        
        self.userDefaults.setDictionary(value: locationDictionary, forKey: kLocationDictionaryUserDefaultsKey)
        
        self.actualLocation.locationName = geoLocation.locationName
        self.actualLocation.geoPoint = geoLocation.geoPoint
        
        self.delegate?.locationCoordinatorDidFindCurrentLocation(coordinator: self, location: self.actualLocation)
    }
    
    //mark: - Location Manager Delegates
    
    public func locationFound(location: CLLocation) {
        
        let geoLocation = MOGeoLocation(name: NSLocalizedString("Unknown Location", comment: ""), coords: location.coordinate)

        setCurrentLocation(geoLocation: geoLocation)
    }
    
    
    public func locationServicesDisabled() {
        
        let title = NSLocalizedString("Location Services Disabled", comment: "")
        let message = NSLocalizedString("You currently have all location services for this app disabled. You will need to enable them to get your current location", comment: "")
        
        showFailedAlert(title: title, message: message)
    }
    
    public func locationServiceFailed(error: Error) {
        
        let title = NSLocalizedString("Location Services Error", comment: "")
        let message = error.localizedDescription
        
        showFailedAlert(title: title, message: message)

    }
    
    func showFailedAlert(title: String, message: String) {
        
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        self.alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.`default`, handler: nil))
        
        self.delegate?.locationCoordinatorDidFail(coordinator: self, alertController: self.alertController)

    }
    
    public func geoCodeFound(placeMark: CLPlacemark) {
        
        if let name = placeMark.name {
            
            let geoLocation = MOGeoLocation(name: name, coords: placeMark.location!.coordinate)
            
            setCurrentLocation(geoLocation: geoLocation)
        }
    }
    
    public func geoCodeFailed(error: Error) {
        
    }
    

}

#endif
