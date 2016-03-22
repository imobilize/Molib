//
//  NSUserDefaults+SecureProtocol.swift
//  Bigger
//
//  Created by Andre Barrett on 23/08/2015.
//  Copyright (c) 2015 BiggerEventsLtd. All rights reserved.
//

import Foundation


public protocol UserDefaults {
    
    func stringForKey(key: String) -> String?
    
    func secureStringForKey(key: String) -> String?
    
    func dictionaryForKey(key: String) -> Dictionary<String, AnyObject>?
    
    func dataForKey(key: String) -> NSData?
    
    func boolForKey(key: String) -> Bool?
    
    //MARK: Setting methods
    
    func setString(value: String?, forKey key: String)
    
    func setSecureString(value: String?, forKey key: String)
    
    func setDictionary(value: Dictionary<String, AnyObject>, forKey key: String)
    
    func setData(value: NSData?, forKey key: String)
    
    func setBool(value: Bool, forKey key: String)
    
    func synchronize() -> Bool
}
