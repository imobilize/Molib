
import Foundation
import UIKit

extension UIAlertView {
    
    class func showErrorWithMessage(message: String) {
    
        showError("Error", message: message)
    }
    
    class func showError(title: String, message: String) {
        
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        
        alert.show()
    }
}