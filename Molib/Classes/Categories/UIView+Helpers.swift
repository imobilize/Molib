
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

        addDividerAtLocation(location: self.height - 1.0)
    }
    
    public func addDividerAtLocation(location: CGFloat, withEdgeInset insets:UIEdgeInsets) {

        let grayColor =  UIColor(white: kGrayLineColor, alpha: CGFloat(1.0))

        let separator = UIView()
        separator.backgroundColor = grayColor
        self.addSubview(separator)
        separator.addHeightConstraint(withConstant: 0.5)
        separator.pinToSuperview([.left], constant: insets.left)
        separator.pinToSuperview([.right], constant: insets.right)
        separator.pinToSuperview([.top], constant: location)
    }
    
    public func addDividerAtLocation(location: CGFloat) {

        let grayColor = UIColor(white: kGrayLineColor, alpha: 1.0)
        addDividerAtLocation(location: location, withColor:grayColor)
    }
    
    public func addDividerAtLocation(location: CGFloat, withColor color:UIColor) {
        
        let separator = UIView()
        separator.backgroundColor = color
        self.addSubview(separator)
        separator.addHeightConstraint(withConstant: 0.5)
        separator.pinToSuperview([.left, .right])
        separator.pinToSuperview([.top], constant: location)
    }

    public func addBorderWithColor(color: UIColor) {

        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1.0
    }
    
    public func roundCorners(corners: UIRectCorner, withRadius radius:CGFloat) {

        self.layer.cornerRadius = radius
        
        let maskPath = UIBezierPath(roundedRect:self.bounds, byRoundingCorners:corners, cornerRadii:CGSize(width: radius, height: radius))

        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
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
