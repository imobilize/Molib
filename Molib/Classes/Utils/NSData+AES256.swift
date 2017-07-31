//
//  NSData+AES256.swift
//  Bigger
//
//  Created by Andre Barrett on 23/08/2015.
//  Copyright (c) 2015 BiggerEventsLtd. All rights reserved.
//

import Foundation
//import CommonCrypto

extension NSData {
    
    
    func encryptWithKey(key: String) -> NSData? {
        
//        let keyData: NSData! = key.dataUsingEncoding(NSUTF8StringEncoding)
//        
//        
//        let keyMutableData = NSMutableData(bytes: keyData.bytes, length: keyData.length)
//        keyMutableData.increaseLengthBy(Int(kCCKeySizeAES256) - keyData.length)
//       
//        let keyBytes         = UnsafeMutablePointer<Void>(keyMutableData.bytes)
//        
//        let data: NSData! = self
//        let dataLength    = size_t(data.length)
//        let dataBytes     = UnsafeMutablePointer<Void>(data.bytes)
//        
//        let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
//        let cryptPointer = UnsafeMutablePointer<Void>(cryptData!.mutableBytes)
//        let cryptLength  = size_t(cryptData!.length)
//        
//        let keyLength              = size_t(kCCKeySizeAES256)
//        let operation: CCOperation = UInt32(kCCEncrypt)
//        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
//        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding + kCCOptionECBMode)
//        
//        var numBytesEncrypted :size_t = 0
//        
//        let cryptStatus = CCCrypt(operation,
//            algoritm,
//            options,
//            keyBytes, keyLength,
//            nil,
//            dataBytes, dataLength,
//            cryptPointer, cryptLength,
//            &numBytesEncrypted)
//        
//        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
//            //  let x: UInt = numBytesEncrypted
//            cryptData!.length = Int(numBytesEncrypted)
//    
//        } else {
//            print("Error: \(cryptStatus)", terminator: "")
//        }
//        
//        return cryptData
        return self.AES256EncryptWithKey(key)
    }
    
    func decryptWithKey(key: String) -> NSData? {
//
//        let data = self
//        
//        let keyData: NSData! = key.dataUsingEncoding(NSUTF8StringEncoding)
//        
//        let keyMutableData = NSMutableData(bytes: keyData.bytes, length: keyData.length)
//        keyMutableData.increaseLengthBy(Int(kCCKeySizeAES256) - keyData.length)
//        
//        let keyBytes         = UnsafeMutablePointer<Void>(keyMutableData.bytes)
//        
//        print("keyLength   = \(keyData.length), keyData   = \(keyData)", terminator: "")
//        
//        //let message       = "Don´t try to read this text. Top Secret Stuff"
//        // let data: NSData! = (message as NSString).dataUsingEncoding(NSUTF8StringEncoding) as NSData!
//        let dataLength    = size_t(data.length)
//        let dataBytes     = UnsafeMutablePointer<Void>(data.bytes)
//        print("dataLength  = \(dataLength), data      = \(data)", terminator: "")
//        
//        let cryptData    = NSMutableData(length: Int(dataLength) + kCCBlockSizeAES128)
//        let cryptPointer = UnsafeMutablePointer<Void>(cryptData!.mutableBytes)
//        let cryptLength  = size_t(cryptData!.length)
//        
//        let keyLength              = size_t(kCCKeySizeAES256)
//        let operation: CCOperation = UInt32(kCCDecrypt)
//        let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
//        let options:   CCOptions   = UInt32(kCCOptionPKCS7Padding + kCCOptionECBMode)
//        
//        var numBytesEncrypted :size_t = 0
//        
//        let cryptStatus = CCCrypt(operation,
//            algoritm,
//            options,
//            keyBytes, keyLength,
//            nil,
//            dataBytes, dataLength,
//            cryptPointer, cryptLength,
//            &numBytesEncrypted)
//        
//        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
//            //  let x: UInt = numBytesEncrypted
//            cryptData!.length = Int(numBytesEncrypted)
//        } else {
//            print("Error: \(cryptStatus)", terminator: "")
//        }
        
//        return cryptData
        return AES256DecryptWithKey(key)
    }
}