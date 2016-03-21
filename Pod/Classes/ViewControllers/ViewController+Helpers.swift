//
//  ViewController+Helpers.swift
//  themixxapp
//
//  Created by Andre Barrett on 16/02/2016.
//  Copyright © 2016 MixxLabs. All rights reserved.
//

import Foundation
import UIKit

protocol MOContainerViewDelegate {

    func headerOffset() -> CGFloat

    func footerOffset() -> CGFloat

    func didScrollToOffset(offset: CGFloat)

}