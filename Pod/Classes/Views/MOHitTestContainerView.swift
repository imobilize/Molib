//
//  MOHitTestContainerView.swift
//  themixxapp
//
//  Created by Andre Barrett on 14/02/2016.
//  Copyright © 2016 MixxLabs. All rights reserved.
//

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