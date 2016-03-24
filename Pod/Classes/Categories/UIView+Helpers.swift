
import Foundation
import UIKit


let kGrayLineColor: CGFloat = 0.88
let kLineThickness: CGFloat = 0.5


extension UIView {
    
    public var height: CGFloat {
    
        get {
            return self.frame.size.height
        }
    }
    
    public var width: CGFloat {
        
        get {
            return self.frame.size.width
        }
    }
    
    public func addDivider() {
    
        addDividerAtLocation(self.height - 1.0)
    }
    
    public func addDividerAtLocation(location: CGFloat, withEdgeInset insets:UIEdgeInsets) {
    
        let grayColor =  UIColor(white: kGrayLineColor, alpha: CGFloat(1.0))
    
        var rect = CGRectMake(0.0, location, self.width, 1.0)
    
        rect = UIEdgeInsetsInsetRect(rect, insets);
    
        let divider = UIView(frame: rect)
        divider.backgroundColor = grayColor
        addSubview(divider)
    }
    
    public func addDividerAtLocation(location: CGFloat) {
    
        let grayColor = UIColor(white: kGrayLineColor, alpha: 1.0)
        addDividerAtLocation(location, withColor:grayColor)
    }
    
    public func addDividerAtLocation(location: CGFloat, withColor color:UIColor) {
    
        let divider = UIView(frame:CGRectMake(0.0, location, self.width, kLineThickness))
    
        divider.backgroundColor = color
    
        addSubview(divider)
    }

    public func addBorderWithColor(color: UIColor) {
    
        self.layer.borderColor = color.CGColor
        self.layer.borderWidth = 1.0
    }
    
    public func roundCorners(corners: UIRectCorner, withRadius radius:CGFloat) {
    
        self.layer.cornerRadius = radius
        
        let maskPath = UIBezierPath(roundedRect:self.bounds, byRoundingCorners:corners, cornerRadii:CGSizeMake(radius, radius))
    
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
        self.layer.mask = maskLayer
    }

    
    class func defaultTableEdgeInsets() -> UIEdgeInsets {
    
        return UIEdgeInsetsMake(0, 14.0, 0, 0)
    }

}

extension UITextField {
    
    @IBInspectable var left_padding: CGFloat {
        
        get {
            return 0
        }
        set (indentation) {
            layer.sublayerTransform = CATransform3DMakeTranslation(indentation, 0, 0)
        }
    }
}
