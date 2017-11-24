
import Foundation
import UIKit

public protocol ContainerViewDelegate {

    func headerOffset() -> CGFloat

    func footerOffset() -> CGFloat

    func didScrollToOffset(offset: CGFloat)

}

public protocol ContainerEmbeddableViewController {

    func heightOfView() -> CGFloat

    func widthOfView() -> CGFloat
}
