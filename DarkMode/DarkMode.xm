#import "../Common.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface UITableConstants_iOS : NSObject
+ (UITableConstants_iOS *)sharedConstants;
@end

@interface UITableConstants_TV : NSObject
+ (UITableConstants_TV *)sharedConstants;
@end

@interface UITableConstants_Phone : NSObject
+ (UITableConstants_Phone *)sharedConstants;
@end

%hook UITableConstants_Phone

- (BOOL)supportsUserInterfaceStyles
{
	return YES;
}

+ (UITableConstants_Phone *)sharedConstants
{
	return (UITableConstants_Phone *)[NSClassFromString(@"UITableConstants_TV") sharedConstants];
}

%end

%hook UIScreen

- (NSInteger)_effectiveUserInterfaceStyle
{
	return 2;
}

%end

%hook NSUserDefaults

- (BOOL)boolForKey:(NSString *)key
{
	return [key isEqualToString:@"UISystemwideUserInterfaceStyle"] ? YES : %orig;
}

%end

%hook UITraitCollection

+ (UITraitCollection *)traitCollectionWithUserInterfaceStyle:(NSInteger)style
{
	return %orig(2);
}

- (NSInteger)userInterfaceStyle
{
	return 2;
}

%end

%ctor
{
	runIn(@"UIKit");
}