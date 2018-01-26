#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MODeviceUtils.h"

NSString *kApiVersionKey = @"x-api-version";
NSString *kClientVersionKey = @"x-app-version";
NSString *kDeviceUniqueIdentifierKey = @"x-unique-identifier";
NSString *kClientLanguageKey = @"x-client-language";
NSString *kDeviceModelKey = @"x-device-model";
NSString *kSystemNameKey = @"x-system-name";
NSString *kOperatingSystemKey = @"x-system-version";
NSString *kScreenResolutionKey = @"x-screen-resolution";
NSString *kAPIFormatKey = @"x-format";


NSString *kFormatType = @"json";

NSString *kSessionCookiesKey = @"SessionCookies";


@implementation MODeviceUtils

+ (void)initializeForAppStart {
    
//    [MagicalRecord setupCoreDataStack];
    
    srand((unsigned)time(0));
    
    [self setDeviceIdentifier];
    
    [self loadCookies];
}

+ (void)finalizeForAppShutdown {
    
    [self saveCookies];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    [[NSManagedObjectContext rootSavingContext] saveToPersistentStoreAndWait];
//    
//    [MagicalRecord cleanUp];
}


#pragma mark - Cookie Storage

+ (void)saveCookies {
    
//    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject: cookiesData forKey: kSessionCookiesKey];
}

+ (void)loadCookies {
    
//    NSData *cookiesData = [[NSUserDefaults standardUserDefaults] objectForKey: kSessionCookiesKey];
//    
//    if(cookiesData != nil) {
//        
//        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: cookiesData];
//        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//        
//        for (NSHTTPCookie *cookie in cookies){
//            [cookieStorage setCookie: cookie];
//        }
//    }
}

- (void)clearCookies {
    
//    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData: [[NSUserDefaults standardUserDefaults] objectForKey: kSessionCookiesKey]];
//    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    
//    for (NSHTTPCookie *cookie in cookies){
//        [cookieStorage deleteCookie: cookie];
//    }
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults removeObjectForKey: kSessionCookiesKey];
}


+ (NSDictionary*)deviceInfoHeaderFields {
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:7];
    
    UIDevice *device = [UIDevice currentDevice];
    
    headers[kSystemNameKey] = device.systemName;
    
    headers[kOperatingSystemKey] = device.systemVersion;
    
    headers[kDeviceModelKey] = device.model;
    
    headers[kDeviceUniqueIdentifierKey] = [[self class] deviceIndentifier];
    
    headers[kAPIFormatKey] = kFormatType;
    
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    headers[kClientVersionKey] = appVersion;
    
    
    NSString *apiVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"API_Version"];
    
    headers[kApiVersionKey] = apiVersion;
    
    headers[kClientLanguageKey] = [self deviceLanguage];
    
    
    return headers;
}


+ (NSString*)deviceIndentifier {
    
    NSString *deviceIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceUniqueIdentifierKey];
    
    if (deviceIdentifier == nil) {
        
        [[self class] setDeviceIdentifier];
        
        deviceIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceUniqueIdentifierKey];
    }
    
    return deviceIdentifier;
}

+ (void)setDeviceIdentifier {
    
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kDeviceUniqueIdentifierKey];
	
    if (testValue == nil) {
        
		NSString *uniqueIdentifier = [[NSUUID UUID] UUIDString];
        
		[[NSUserDefaults standardUserDefaults] setValue:uniqueIdentifier forKey:kDeviceUniqueIdentifierKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
	}
}


+ (NSString*)deviceLanguage {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *preferredLanguages = [defaults objectForKey:@"AppleLanguages"];
    
    NSString *preferredLanguageCode = [preferredLanguages objectAtIndex:0];
    
    return preferredLanguageCode;
}



@end
