import Foundation
import UIKit

public protocol MODownloadModelDelegate {
    
    func downloadRequestDidUpdateProgress(progressFraction: Float)
    
    func downloadStatusDidUpdate(status: String)
    
}
