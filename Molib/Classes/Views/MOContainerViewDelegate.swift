import Foundation
import UIKit

public protocol MOContainerViewDelegate: class {
    
    func didScrollToOffset(contentOffset: CGFloat)
    func footerOffset() -> CGFloat
}
