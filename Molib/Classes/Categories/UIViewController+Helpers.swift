
import Foundation
import UIKit

public enum UIViewControllerTransition {
    
    case FlowFromRight
    case PushToBack
}

extension UIStoryboard {
    
    public class func controllerWithIdentifier(identifier: String) -> AnyObject {
        
        let application = UIApplication.shared
        
        let backWindow = application.windows[0]
        
        let storyBoard = backWindow.rootViewController!.storyboard
        
        return storyBoard!.instantiateViewController(withIdentifier: identifier)
    }
}


extension UIViewController {
    
    public var navController: UINavigationController {
        
        get {
            return self.navigationController!
        }
    }

    public func setRightButtonItem(item: UIBarButtonItem?) {
        
        self.navigationItem.rightBarButtonItem = item
    }
    
    public func setLeftButtonItem(item: UIBarButtonItem?) {
        
        self.navigationItem.leftBarButtonItem = item
    }
    
    public func pushViewController(viewController: UIViewController) {
        
        if self is UINavigationController {
            
            let controller = self as! UINavigationController
            controller.pushViewController(viewController, animated: true)
        } else {
            
            self.navController.pushViewController(viewController, animated: true)

        }
    }
    
    
    public func insertViewController(controller: UIViewController, belowViewController: UIViewController, withTransition: UIViewControllerTransition, duration: TimeInterval) {
        
        
    }
    
    public func presentViewControllerNonAnimated(viewController: UIViewController) {
        
        present(viewController, animated: false, completion: nil)

    }

    public func presentViewController(viewController: UIViewController) {
        
        present(viewController, animated: true, completion: nil)
    }
    
    public func dismissViewController() {
        
        self.dismiss(animated: true, completion: nil)
    }
    

    
    public func addViewController(viewController: UIViewController, inView:UIView) {
        
        addViewController(viewController: viewController, inView: inView, underView:nil, parentController:self)
    }
    
    public func addViewController(viewController: UIViewController, inView:UIView, fromController:UIViewController) {
        
        addViewController(viewController: viewController, inView: inView, underView: nil, parentController: fromController)
    }
    
    public func removeViewController(viewController: UIViewController) {
        
        viewController.willMove(toParentViewController: nil)
        
        viewController.view.removeFromSuperview()
        
        viewController.removeFromParentViewController()
    }
    
    
    public func addViewController(viewController: UIViewController, inView:UIView, underView:UIView?, parentController:UIViewController) {
        
        viewController.willMove(toParentViewController: parentController)
        
        parentController.addChildViewController(viewController)
        
        if let topView = underView {
            
            inView.insertSubview(viewController.view, belowSubview:topView)
            
        } else {
            
            inView.addSubview(viewController.view)
        }
        
        let myView = viewController.view
        
        myView?.translatesAutoresizingMaskIntoConstraints = false

        myView?.pinToSuperview([.top, .bottom, .left, .right])

        viewController.didMove(toParentViewController: parentController)
    }
    
    
    public func rootViewController() -> UIViewController {
        
        let window: UIWindow = UIApplication.shared.windows[0] 
        
        return window.rootViewController!
    }

}
