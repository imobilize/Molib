//
//  NSData+AES256.h
//  SkyStore
//
//  Created by Barrett, Andre (Technology) on 19/03/2014.
//  Copyright (c) 2014 BSkyB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
