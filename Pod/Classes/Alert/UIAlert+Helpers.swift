//
//  UIAlert+Helpers.swift
//  Bigger
//
//  Created by Andre Barrett on 14/08/2015.
//  Copyright (c) 2015 BiggerEventsLtd. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertView {
    
    class func showErrorWithMessage(message: String) {
    
        showError("Error", message: message)
    }
    
    class func showError(title: String, message: String) {
        
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        
        alert.show()
    }
}