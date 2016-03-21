
import Foundation
import UIKit
import MapKit

protocol LocationCoordinatorDelegate {
    
    func locationCoordinatorDidFindCurrentLocation(coordinator: LocationCoordinator, location: MOGeoLocation)

    func locationCoordinatorDidFail(coordinator: LocationCoordinator, alertController: UIViewController)
    
}


@objc class LocationCoordinator: NSObject, LocationManagerDelegate {
    
    var delegate: LocationCoordinatorDelegate?
    
    
    private var preferredLocation: MOGeoLocation
    
    private var actualLocation: MOGeoLocation
    
    private var locationManager: LocationManager
    
    private var userDefaults: UserDefaults
    
    private var alertController: UIAlertController!
    
    
    init(locationManager: LocationManager, userDefaults: UserDefaults) {
        
        self.locationManager = locationManager
        self.userDefaults = userDefaults
        
        let dictionaryOptional = userDefaults.dictionaryForKey(kLocationDictionaryUserDefaultsKey)
        
        if let dictionary = dictionaryOptional {
        
            self.preferredLocation = MOGeoLocation(dictionary: dictionary)
        
        } else {
            
            self.preferredLocation = MOGeoLocation(name: "Unknown Location", coords: CLLocationCoordinate2DMake(999, 999))
        }
        
        self.actualLocation = self.preferredLocation
        
        super.init()

        self.locationManager.delegate = self
    }
    
    func currentLocation() -> MOGeoLocation {
        
        return actualLocation
    }
    
    func usersPreferredLocation() -> MOGeoLocation {
        
        return self.preferredLocation
    }
    
    func setUsersPreferredLocation(location: MOGeoLocation) {
        
        self.preferredLocation = location
    }
    
    func requestCurrentLocation() {
        
        self.locationManager.requestCurrentLocation()
    }
    
    func setCurrentLocation(geoLocation: MOGeoLocation) {
        
        let locationDictionary = geoLocation.toDictionary()
        
        self.userDefaults.setDictionary(locationDictionary, forKey: kLocationDictionaryUserDefaultsKey)
        
        self.actualLocation.locationName = geoLocation.locationName
        self.actualLocation.geoPoint = geoLocation.geoPoint
        
        self.delegate?.locationCoordinatorDidFindCurrentLocation(self, location: self.actualLocation)
    }
    
    //mark: - Location Manager Delegates
    
    func locationFound(location: CLLocation) {
        
        let geoLocation = MOGeoLocation(name: NSLocalizedString("Current location", comment: ""), coords: location.coordinate)

        setCurrentLocation(geoLocation)
    }
    
    
    func locationServicesDisabled() {
        
        let title = NSLocalizedString("Location Services Disabled", comment: "")
        let message = NSLocalizedString("You currently have all location services for this app disabled. You will need to enable them to get your current location", comment: "")
        
       showFailedAlert(title, message: message)
    }
    
    func locationServiceFailed(error: NSError) {
        
        let title = NSLocalizedString("Location Services Error", comment: "")
        let message = error.localizedDescription
        
        showFailedAlert(title, message: message)

    }
    
    func showFailedAlert(title: String, message: String) {
        
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        self.alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        self.delegate?.locationCoordinatorDidFail(self, alertController: self.alertController)

    }
    
    func geoCodeFound(placeMark: CLPlacemark) {
        
    }
    
    func geoCodeFailed(error: NSError) {
        
    }
    

}