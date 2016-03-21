
import UIKit
import SVProgressHUD


protocol ProgressHUD {
    
    func showSuccessWithMessage(message: String)
    
    func showSuccess()
    
    func showError()
    
    func showErrorWithMessage(message: String)
    
    func showLoading()
    
    func dismiss()
}

protocol ProgressHUDPresenter {
    
    var progressHUD: ProgressHUD { get }

}

struct MOHUDController: ProgressHUD {
    
    func showSuccessWithMessage(message: String) {
     
        SVProgressHUD.showSuccessWithStatus(message)
    }
    
    func showSuccess() {
        
        SVProgressHUD.showSuccessWithStatus("Success")
    }
    
    func showError() {
        
        SVProgressHUD.showErrorWithStatus("Error")
    }
    
    func showErrorWithMessage(message: String) {
        
        SVProgressHUD.showErrorWithStatus(message)
    }
    
    func showLoading() {
        
        SVProgressHUD.show()
    }
 
    func dismiss() {
        
        SVProgressHUD.dismiss()
    }
}

extension UIViewController:ProgressHUDPresenter {
    
    var progressHUD: ProgressHUD {
        
        get {
            var hud: MOHUDController?
            
            if (hud == nil) {
                
                hud = MOHUDController()
            }
            
            return hud!
        }
    }
    
}


extension UIViewController {
    
    func showOkAlertWithTitle(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alertController)
    }
}