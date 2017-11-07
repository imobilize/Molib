
#import <Foundation/Foundation.h>

extern NSString *kApiVersionKey;
extern NSString *kClientVersionKey;
extern NSString *kDeviceUniqueIdentifierKey;
extern NSString *kClientLanguageKey;
extern NSString *kDeviceModelKey;
extern NSString *kSystemNameKey;
extern NSString *kOperatingSystemKey;
extern NSString *kScreenResolutionKey;
extern NSString *kAPIFormatKey;


@interface MODeviceUtils : NSObject

+ (void)initializeForAppStart;

+ (void)finalizeForAppShutdown;

+ (NSDictionary*)deviceInfoHeaderFields;



+ (void)loadCookies;

+ (void)saveCookies;

- (void)clearCookies;

@end
