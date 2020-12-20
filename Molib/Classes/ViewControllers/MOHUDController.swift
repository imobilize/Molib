
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
     
        if Thread.isMainThread {
            SVProgressHUD.showSuccess(withStatus: message)
        } else {
            
            DispatchQueue.main.async {
                
                SVProgressHUD.showSuccess(withStatus: message)
            }
        }
    }
    
    func showSuccess() {
        if Thread.isMainThread {
            SVProgressHUD.showSuccess(withStatus: "Success")
        } else {
            
            DispatchQueue.main.async {
                
                SVProgressHUD.showSuccess(withStatus: "Success")
            }
        }
    }
    
    func showError() {
        if Thread.isMainThread {
            SVProgressHUD.showError(withStatus: "Error")
        } else {
            
            DispatchQueue.main.async {
                
                SVProgressHUD.showError(withStatus: "Error")
            }
        }
    }
    
    func showErrorWithMessage(message: String) {
        if Thread.isMainThread {
            SVProgressHUD.showError(withStatus: message)
        } else {
            
            DispatchQueue.main.async {
                
                SVProgressHUD.showError(withStatus: message)
            }
        }
    }
    
    func showLoading() {
        if Thread.isMainThread {
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.show()
            
        } else {
            
            DispatchQueue.main.async {
                
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.show()            }
        }
    }
 
    func dismiss() {
        if Thread.isMainThread {
            SVProgressHUD.dismiss()
        } else {
            
            DispatchQueue.main.async {
                
                SVProgressHUD.dismiss()
            }
        }
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
