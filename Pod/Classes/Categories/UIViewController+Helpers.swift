
import Foundation
import UIKit

enum UIViewControllerTransition {
    
    case FlowFromRight
    case PushToBack
}

extension UIStoryboard {
    
    class func controllerWithIdentifier(identifier: String) -> AnyObject {
        
        let application = UIApplication.sharedApplication()
        
        let backWindow = application.windows[0]
        
        let storyBoard = backWindow.rootViewController!.storyboard
        
        return storyBoard!.instantiateViewControllerWithIdentifier(identifier)
    }
}


extension UIViewController {
    
    var navController: UINavigationController {
        
        get {
            return self.navigationController!
        }
    }

    func setRightButtonItem(item: UIBarButtonItem?) {
        
        self.navigationItem.rightBarButtonItem = item
    }
    
    func setLeftButtonItem(item: UIBarButtonItem?) {
        
        self.navigationItem.leftBarButtonItem = item
    }
    
    func pushViewController(viewController: UIViewController) {
        
        self.navController.pushViewController(viewController, animated: true)
    }
    
    
    func insertViewController(controller: UIViewController, belowViewController: UIViewController, withTransition: UIViewControllerTransition, duration: NSTimeInterval) {
        
        
    }
    
    func presentViewControllerNonAnimated(viewController: UIViewController) {
        
        presentViewController(viewController, animated: false, completion: nil)

    }

    func presentViewController(viewController: UIViewController) {
        
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    func dismissViewController() {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    func addViewController(viewController: UIViewController, inView:UIView) {
        
        addViewController(viewController, inView: inView, underView:nil, parentController:self)
    }
    
    func addViewController(viewController: UIViewController, inView:UIView, fromController:UIViewController) {
        
        addViewController(viewController, inView: inView, underView: nil, parentController: fromController)
    }
    
    func removeViewController(viewController: UIViewController) {
        
        viewController.willMoveToParentViewController(nil)
        
        viewController.view.removeFromSuperview()
        
        viewController.removeFromParentViewController()
    }
    
    
    func addViewController(viewController: UIViewController, inView:UIView, underView:UIView?, parentController:UIViewController) {
        
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
    
    
    func rootViewController() -> UIViewController {
        
        let window: UIWindow = UIApplication.sharedApplication().windows[0] 
        
        return window.rootViewController!
    }

}
