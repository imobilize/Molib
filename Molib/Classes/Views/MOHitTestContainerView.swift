
import Foundation
import UIKit

public class MOHitTestContainerView: UIView {
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        var hitView: UIView? = super.hitTest(point, with: event)
    
        if let view = hitView {
            
            if ((view === self) || view.isKind(of: UIScrollView.self)) {
    
                hitView = nil
            }
        }
    
        return hitView
    }
}
