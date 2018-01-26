import UIKit

/*
 
 // CENTER BOTTOM

 let btn1: UIButton = UIButton()

 self.menu = Menu(origin: CGPointMake(view.center.x - menuIconSize / 2, view.bounds.height - menuIconSize - 16))
 
 self.menu.direction = .Circle
 
 self.menu.baseViewSize = CGSizeMake(menuIconSize, menuIconSize)
 
 self.menu.views = [btn1, btn2, btn3, btn4]
 
 */

public enum MenuDirection {
    case Up
    case Down
    case Left
    case Right
    case Circle
}

public class Menu {
    
    public private(set) var opened: Bool = false
    
    public var radius: CGFloat = 90 {
        didSet {
            reloadLayout()
        }
    }
    
    public var origin: CGPoint {
        didSet {
            reloadLayout()
        }
    }
    
    public var spacing: CGFloat {
        didSet {
            reloadLayout()
        }
    }
    
    public var enabled: Bool = true
    
    public var direction: MenuDirection = .Up {
        didSet {
            reloadLayout()
        }
    }
    
    public var views: Array<UIView>? {
        didSet {
            reloadLayout()
        }
    }
    
    public var itemViewSize = CGSize(width: 48, height: 48)
    
    public var baseViewSize: CGSize?
    
    public init(origin: CGPoint, spacing: CGFloat = 16) {
        self.origin = origin
        self.spacing = spacing
    }
    
    public func reloadLayout() {
        opened = false
        layoutButtons()
    }
    
    public func open(duration: TimeInterval = 0.15, delay: TimeInterval = 0, usingSpringWithDamping: CGFloat = 0.5, initialSpringVelocity: CGFloat = 0, options: UIViewAnimationOptions = [], animations: ((UIView) -> Void)? = nil, completion: ((UIView) -> Void)? = nil) {
        if enabled {
            disable()
            switch direction {
            case .Up:
                openUpAnimation(duration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            case .Down:
                openDownAnimation(duration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            case .Left:
                openLeftAnimation(duration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            case .Right:
                openRightAnimation(duration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            case .Circle:
                openCircleAnimation(duration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            }
        }
    }
    
    public func close(duration: TimeInterval = 0.15, delay: TimeInterval = 0, usingSpringWithDamping: CGFloat = 0.5, initialSpringVelocity: CGFloat = 0, options: UIViewAnimationOptions = [], animations: ((UIView) -> Void)? = nil, completion: ((UIView) -> Void)? = nil) {
        if enabled {
            disable()
            switch direction {
            case .Up:
                closeUpAnimation(duration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            case .Down:
                closeDownAnimation(duration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            case .Left:
                closeLeftAnimation(duration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            case .Right:
                closeRightAnimation(duration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            case .Circle:
                closeCircleAnimation(duration: duration, delay: delay, usingSpringWithDamping: usingSpringWithDamping, initialSpringVelocity: initialSpringVelocity, options: options, animations: animations, completion: completion)
            }
        }
    }
    
    private func openUpAnimation(duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions, animations: ((UIView) -> Void)?, completion: ((UIView) -> Void)?) {
        if let v: Array<UIView> = views {
            var base: UIView?
            for i in 1..<v.count {
                if nil == base {
                    base = v[0]
                }
                let view: UIView = v[i]
                view.isHidden = false
                
                UIView.animate(withDuration: Double(i) * duration,
                                           delay: delay,
                                           usingSpringWithDamping: usingSpringWithDamping,
                                           initialSpringVelocity: initialSpringVelocity,
                                           options: options,
                                           animations: { [unowned self] in
                                            view.alpha = 1
                                            view.frame.origin.y = base!.frame.origin.y - CGFloat(i) * self.itemViewSize.height - CGFloat(i) * self.spacing
                                            animations?(view)
                }) { [unowned self] _ in
                    completion?(view)
                    self.enable(view: view)
                }
            }
            opened = true
        }
    }
    
    public func closeUpAnimation(duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions, animations: ((UIView) -> Void)?, completion: ((UIView) -> Void)?) {
        if let v: Array<UIView> = views {
            for i in 1..<v.count {
                let view: UIView = v[i]
                
                UIView.animate(withDuration: Double(i) * duration,
                                           delay: delay,
                                           usingSpringWithDamping: usingSpringWithDamping,
                                           initialSpringVelocity: initialSpringVelocity,
                                           options: options,
                                           animations: { [unowned self] in
                                            view.alpha = 0
                                            view.frame.origin.y = self.origin.y
                                            animations?(view)
                }) { [unowned self] _ in
                    view.isHidden = true
                    completion?(view)
                    self.enable(view: view)
                }
            }
            opened = false
        }
    }
    
    private func openDownAnimation(duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions, animations: ((UIView) -> Void)?, completion: ((UIView) -> Void)?) {
        if let v: Array<UIView> = views {
            var base: UIView?
            for i in 1..<v.count {
                if nil == base {
                    base = v[0]
                }
                
                let view: UIView = v[i]
                view.isHidden = false
                
                let h: CGFloat = nil == baseViewSize ? itemViewSize.height : baseViewSize!.height
                UIView.animate(withDuration: Double(i) * duration,
                                           delay: delay,
                                           usingSpringWithDamping: usingSpringWithDamping,
                                           initialSpringVelocity: initialSpringVelocity,
                                           options: options,
                                           animations: { [unowned self] in
                                            view.alpha = 1
                                            view.frame.origin.y = base!.frame.origin.y + h + CGFloat(i - 1) * self.itemViewSize.height + CGFloat(i) * self.spacing
                                            animations?(view)
                }) { [unowned self] _ in
                    completion?(view)
                    self.enable(view: view)
                }
            }
            opened = true
        }
    }
    
    public func closeDownAnimation(duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions, animations: ((UIView) -> Void)?, completion: ((UIView) -> Void)?) {
        if let v: Array<UIView> = views {
            for i in 1..<v.count {
                let view: UIView = v[i]
                
                let h: CGFloat = nil == baseViewSize ? itemViewSize.height : baseViewSize!.height
                UIView.animate(withDuration: Double(i) * duration,
                                           delay: delay,
                                           usingSpringWithDamping: usingSpringWithDamping,
                                           initialSpringVelocity: initialSpringVelocity,
                                           options: options,
                                           animations: { [unowned self] in
                                            view.alpha = 0
                                            view.frame.origin.y = self.origin.y + h
                                            animations?(view)
                }) { [unowned self] _ in
                    view.isHidden = true
                    completion?(view)
                    self.enable(view: view)
                }
            }
            opened = false
        }
    }
    
    private func openLeftAnimation(duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions, animations: ((UIView) -> Void)?, completion: ((UIView) -> Void)?) {
        if let v: Array<UIView> = views {
            var base: UIView?
            for i in 1..<v.count {
                if nil == base {
                    base = v[0]
                }
                
                let view: UIView = v[i]
                view.isHidden = false
                
                UIView.animate(withDuration: Double(i) * duration,
                                           delay: delay,
                                           usingSpringWithDamping: usingSpringWithDamping,
                                           initialSpringVelocity: initialSpringVelocity,
                                           options: options,
                                           animations: { [unowned self] in
                                            view.alpha = 1
                                            view.frame.origin.x = base!.frame.origin.x - CGFloat(i) * self.itemViewSize.width - CGFloat(i) * self.spacing
                                            animations?(view)
                }) { [unowned self] _ in
                    completion?(view)
                    self.enable(view: view)
                }
            }
            opened = true
        }
    }
    
    public func closeLeftAnimation(duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions, animations: ((UIView) -> Void)?, completion: ((UIView) -> Void)?) {
        if let v: Array<UIView> = views {
            for i in 1..<v.count {
                let view: UIView = v[i]
                UIView.animate(withDuration: Double(i) * duration,
                                           delay: delay,
                                           usingSpringWithDamping: usingSpringWithDamping,
                                           initialSpringVelocity: initialSpringVelocity,
                                           options: options,
                                           animations: { [unowned self] in
                                            view.alpha = 0
                                            view.frame.origin.x = self.origin.x
                                            animations?(view)
                }) { [unowned self] _ in
                    view.isHidden = true
                    completion?(view)
                    self.enable(view: view)
                }
            }
            opened = false
        }
    }
    
    private func openRightAnimation(duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions, animations: ((UIView) -> Void)?, completion: ((UIView) -> Void)?) {
        if let v: Array<UIView> = views {
            var base: UIView?
            for i in 1..<v.count {
                if nil == base {
                    base = v[0]
                }
                let view: UIView = v[i]
                view.isHidden = false
                
                let h: CGFloat = nil == baseViewSize ? itemViewSize.height : baseViewSize!.height
                UIView.animate(withDuration: Double(i) * duration,
                                           delay: delay,
                                           usingSpringWithDamping: usingSpringWithDamping,
                                           initialSpringVelocity: initialSpringVelocity,
                                           options: options,
                                           animations: { [unowned self] in
                                            view.alpha = 1
                                            view.frame.origin.x = base!.frame.origin.x + h + CGFloat(i - 1) * self.itemViewSize.width + CGFloat(i) * self.spacing
                                            animations?(view)
                }) { [unowned self] _ in
                    completion?(view)
                    self.enable(view: view)
                }
            }
            opened = true
        }
    }
    
    public func closeRightAnimation(duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions, animations: ((UIView) -> Void)?, completion: ((UIView) -> Void)?) {
        if let v: Array<UIView> = views {
            for i in 1..<v.count {
                let view: UIView = v[i]
                
                let w: CGFloat = nil == baseViewSize ? itemViewSize.width : baseViewSize!.width
                UIView.animate(withDuration: Double(i) * duration,
                                           delay: delay,
                                           usingSpringWithDamping: usingSpringWithDamping,
                                           initialSpringVelocity: initialSpringVelocity,
                                           options: options,
                                           animations: { [unowned self] in
                                            view.alpha = 0
                                            view.frame.origin.x = self.origin.x + w
                                            animations?(view)
                }) { [unowned self] _ in
                    view.isHidden = true
                    completion?(view)
                    self.enable(view: view)
                }
            }
            opened = false
        }
    }
    
    private func openCircleAnimation(duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions, animations: ((UIView) -> Void)?, completion: ((UIView) -> Void)?) {
        
        if let v: Array<UIView> = views {
            
            v[0].layer.add(rotateButton(duration: 0.1, fromValue: 0.0, toValue: CGFloat(Double.pi/4)), forKey: nil)
            
            var base: UIView?
            for i in 1..<v.count {
                if nil == base {
                    base = v[0]
                }
                let view: UIView = v[i]
                view.isHidden = false
                
                let angle = Double.pi + Double.pi / Double(v.count) * Double(i)
                
                UIView.animate(withDuration: Double(i) * duration,
                                           delay: delay,
                                           usingSpringWithDamping: usingSpringWithDamping,
                                           initialSpringVelocity: initialSpringVelocity,
                                           options: options,
                                           animations: {
                                            view.alpha = 1
                                            view.frame.origin.x = base!.frame.origin.x + self.radius * (cos(CGFloat(angle)))
                                            view.frame.origin.y = base!.frame.origin.y + self.radius * (sin(CGFloat(angle)))
                                            
                                            animations?(view)
                }) { [unowned self] _ in
                    completion?(view)
                    self.enable(view: view)
                }
            }
            opened = true
        }
    }
    
    public func closeCircleAnimation(duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping: CGFloat, initialSpringVelocity: CGFloat, options: UIViewAnimationOptions, animations: ((UIView) -> Void)?, completion: ((UIView) -> Void)?) {
        if let v: Array<UIView> = views {
            
            v[0].layer.add(rotateButton(duration: 0.1, fromValue: CGFloat(Double.pi/4), toValue: 0.0), forKey: nil)
            
            for i in 1..<v.count {
                let view: UIView = v[i]
                
                UIView.animate(withDuration: Double(i) * duration,
                                           delay: delay,
                                           usingSpringWithDamping: usingSpringWithDamping,
                                           initialSpringVelocity: initialSpringVelocity,
                                           options: options,
                                           animations: { [unowned self] in
                                            view.alpha = 0
                                            view.frame.origin.x = self.origin.x
                                            view.frame.origin.y = self.origin.y
                                            animations?(view)
                }) { [unowned self] _ in
                    view.isHidden = true
                    completion?(view)
                    self.enable(view: view)
                }
            }
            opened = false
        }
    }
    
    private func rotateButton(duration: CFTimeInterval, fromValue: CGFloat, toValue: CGFloat) -> CABasicAnimation {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        rotateAnimation.duration = duration
        
        rotateAnimation.fromValue = fromValue
        
        rotateAnimation.toValue = toValue
        
        rotateAnimation.fillMode = kCAFillModeForwards
        
        rotateAnimation.isRemovedOnCompletion = false
        
        return rotateAnimation
    }
    
    private func layoutButtons() {
        if let v: Array<UIView> = views {
            let size: CGSize = nil == baseViewSize ? itemViewSize : baseViewSize!
            for i in 0..<v.count {
                let view: UIView = v[i]
                if 0 == i {
                    view.frame.size = size
                    view.frame.origin = origin
                    view.layer.zPosition = 10000
                } else {
                    view.alpha = 0
                    view.isHidden = true
                    view.frame.size = itemViewSize
                    view.frame.origin.x = origin.x + (size.width - itemViewSize.width) / 2
                    view.frame.origin.y = origin.y + (size.height - itemViewSize.height) / 2
                    view.layer.zPosition = CGFloat(10000 - v.count - i)
                }
            }
        }
    }
    
    private func disable() {
        if let v: Array<UIView> = views {
            if 0 < v.count {
                enabled = false
            }
        }
    }
    
    private func enable(view: UIView) {
        if let v: Array<UIView> = views {
            if view == v.last {
                enabled = true
            }
        }
    }
}
