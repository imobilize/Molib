import Foundation
import UIKit

public typealias VoidCompletion = () -> Void
public typealias BoolCompletion = (_ success: Bool) -> Void
public typealias ErrorCompletion = (_ errorOptional: Error?) -> Void
public typealias VoidOptionalCompletion = (() -> Void)?
public typealias DataResponseCompletion = (_ dataOptional: Data?, _ errorOptional: Error?) -> Void

