
import Foundation
import UIKit

public enum UIViewControllerTransition {
    
    case FlowFromRight
    case PushToBack
}

extension UIStoryboard {
    
    public class func controllerWithIdentifier(identifier: String) -> AnyObject {
        
        let application = UIApplication.sharedApplication()
        
        let backWindow = application.windows[0]
        
        let storyBoard = backWindow.rootViewController!.storyboard
        
        return storyBoard!.instantiateViewControllerWithIdentifier(identifier)
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
    
    
    public func insertViewController(controller: UIViewController, belowViewController: UIViewController, withTransition: UIViewControllerTransition, duration: NSTimeInterval) {
        
        
    }
    
    public func presentViewControllerNonAnimated(viewController: UIViewController) {
        
        presentViewController(viewController, animated: false, completion: nil)

    }

    public func presentViewController(viewController: UIViewController) {
        
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    public func dismissViewController() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    public func addViewController(viewController: UIViewController, inView:UIView) {
        
        addViewController(viewController, inView: inView, underView:nil, parentController:self)
    }
    
    public func addViewController(viewController: UIViewController, inView:UIView, fromController:UIViewController) {
        
        addViewController(viewController, inView: inView, underView: nil, parentController: fromController)
    }
    
    public func removeViewController(viewController: UIViewController) {
        
        viewController.willMoveToParentViewController(nil)
        
        viewController.view.removeFromSuperview()
        
        viewController.removeFromParentViewController()
    }
    
    
    public func addViewController(viewController: UIViewController, inView:UIView, underView:UIView?, parentController:UIViewController) {
        
        viewController.willMoveToParentViewController(parentController)
        
        parentController.addChildViewController(viewController)
        
        viewController.view.frame = inView.frame
        
        if let topView = underView {
            
            inView.insertSubview(viewController.view, belowSubview:topView)
            
        } else {
            
            inView.addSubview(viewController.view)
        }
        
        let myView = viewController.view
        
        myView.translatesAutoresizingMaskIntoConstraints = false
        
        let viewDict = ["myView": myView]
        
        let constraint1 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[myView]-0-|",
            options: [NSLayoutFormatOptions.AlignAllTop, NSLayoutFormatOptions.AlignAllBottom], metrics:nil, views:viewDict)
        
        let constraint2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[myView]-0-|",
            options:[NSLayoutFormatOptions.AlignAllLeft, NSLayoutFormatOptions.AlignAllRight], metrics:nil, views:viewDict)
        
        inView.addConstraints(constraint1)
        inView.addConstraints(constraint2)
        
        viewController.didMoveToParentViewController(parentController)
        
    }
    
    
    public func rootViewController() -> UIViewController {
        
        let window: UIWindow = UIApplication.sharedApplication().windows[0] 
        
        return window.rootViewController!
    }

}
