
import Foundation
import UIKit

public class MOHitTestContainerView: UIView {
    
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        var hitView: UIView? = super.hitTest(point, withEvent: event)
    
        if let view = hitView {
            
            if ((view === self) || view.isKindOfClass(UIScrollView.self)) {
    
                hitView = nil
            }
        }
    
        return hitView
    }
}