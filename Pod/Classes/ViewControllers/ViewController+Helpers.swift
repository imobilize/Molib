
import Foundation
import UIKit

public protocol MOContainerViewDelegate {

    func headerOffset() -> CGFloat

    func footerOffset() -> CGFloat

    func didScrollToOffset(offset: CGFloat)

}