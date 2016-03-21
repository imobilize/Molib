
import Foundation
import CoreLocation


let kLocationDictionaryUserDefaultsKey = "selectedLocation"
let kLocationDictionaryNameKey = "name"
let kLocationDictionaryLatitudeey = "lat"
let kLocationDictionaryLongitudeKey = "lon"

@objc class MOGeoLocation: NSObject {
    
    var locationName: String
    var geoPoint: CLLocationCoordinate2D
    var location: CLLocation {
        
        get { return CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude) }
    }
    
    convenience init(dictionary: Dictionary<String, AnyObject>) {
    
        let name = dictionary[kLocationDictionaryNameKey] as? String
        let latitudeNumber = dictionary[kLocationDictionaryLatitudeey] as? Double
        let longitudeNumber = dictionary[kLocationDictionaryLongitudeKey] as? Double
    
        let coordinates = CLLocationCoordinate2DMake(latitudeNumber!, longitudeNumber!)
    
        self.init(name: name!, coords:coordinates)
    }
    
    init(name: String, coords:CLLocationCoordinate2D) {
    
        locationName = name
        geoPoint = coords
    }
    
    func toDictionary() -> Dictionary<String, AnyObject> {
    
        let dictonary: Dictionary<String, AnyObject>  = [ kLocationDictionaryNameKey: self.locationName,
                        kLocationDictionaryLatitudeey: self.geoPoint.latitude,
                        kLocationDictionaryLongitudeKey: self.geoPoint.longitude]
    
    
        return dictonary
    }
    

}