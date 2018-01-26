
import UIKit
import SVProgressHUD


public protocol ProgressHUD {
    
    func showSuccessWithMessage(message: String)
    
    func showSuccess()
    
    func showError()
    
    func showErrorWithMessage(message: String)
    
    func showLoading()
    
    func dismiss()
}

public protocol ProgressHUDPresenter {
    
    var progressHUD: ProgressHUD { get }

}

struct MOHUDController: ProgressHUD {
    
    func showSuccessWithMessage(message: String) {
     
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    func showSuccess() {
        
        SVProgressHUD.showSuccess(withStatus: "Success")
    }
    
    func showError() {
        
        SVProgressHUD.showError(withStatus: "Error")
    }
    
    func showErrorWithMessage(message: String) {
        
        SVProgressHUD.showError(withStatus: message)
    }
    
    func showLoading() {
        
        SVProgressHUD.setDefaultMaskType(.black)
        
        SVProgressHUD.show()
    }
 
    func dismiss() {
        
        SVProgressHUD.dismiss()
    }
}

extension UIViewController:ProgressHUDPresenter {
    
    public var progressHUD: ProgressHUD {
        
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
    
    public func showOkAlertWithTitle(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.`default`, handler: nil))
        
        self.presentViewController(viewController: alertController)
    }
}
