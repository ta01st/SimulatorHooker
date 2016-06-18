#import "../Common.h"
#import <UIKit/UIKit.h>
#import <dlfcn.h>

@interface BSSettings : NSObject
@end

@interface SBActivationSettings : NSObject
@end

@interface SBApplication : NSObject
- (BOOL)isRunning;
@end

@interface SBWorkspaceEntity : NSObject
- (void)applyActivationSettings:(id)settings;
@end

@interface SBWorkspaceApplication : SBWorkspaceEntity
@property (nonatomic, retain) SBApplication *application;
@property (nonatomic, copy, readonly) NSString *bundleIdentifier; 
@end

@interface SBWorkspaceTransitionRequest : NSObject
@property (nonatomic, copy) NSString *eventLabel;
- (id)descriptionWithMultilinePrefix:(id)arg1;
- (id)succinctDescription;
- (id)succinctDescriptionBuilder;
- (id)descriptionBuilderWithMultilinePrefix:(id)arg1;
@end

@interface SBMainWorkspaceTransitionRequest : SBWorkspaceTransitionRequest
@end

@interface SBWorkspace : NSObject
- (id)createRequestForApplicationActivation:(id)arg1 options:(id)arg2;
@end

@interface SBMainWorkspace : SBWorkspace
- (BOOL)_setCurrentTransactionForRequest:(SBMainWorkspaceTransitionRequest *)request fallbackProvider:(/*^block*/id)provider;
- (void)transactionDidComplete:(SBMainWorkspaceTransitionRequest *)request;
@end

@interface SBWorkspaceTransaction : NSObject
- (SBWorkspaceTransitionRequest *)transitionRequest;
@end

@interface SBMainWorkspaceTransaction : SBWorkspaceTransaction
@end

@interface SBToAppsWorkspaceTransaction : SBMainWorkspaceTransaction
@end

@interface SBAppToAppWorkspaceTransaction : SBToAppsWorkspaceTransaction
@end

@interface FBApplicationInfo : NSObject
- (NSURL *)bundleContainerURL;
- (NSMutableDictionary *)_configureEnvironment:(NSDictionary *)environment;
@end

@interface SBApplicationInfo : FBApplicationInfo
- (NSString *)bundleIdentifier;
@end

NSString *dylibPaths(NSString *names)
{
	NSMutableString *dylibs = [NSMutableString string];
	if (names && names.length > 0) {
		NSArray *paths = [names componentsSeparatedByString:@","];
		for (NSString *name in paths) {
			if ([name hasSuffix:@"-MAIN"]) {
				name = [name stringByReplacingOccurrencesOfString:@"-MAIN" withString:@""];
				[dylibs appendString:SH_PATH_2(name)];
				[dylibs appendString:@":"];
			}
			else
				[dylibs appendString:[NSString stringWithFormat:@"%@:", SH_PATH(name)]];
		}
	}
	[dylibs appendString:SH_PATH_2(@"FLEXDylib")];
	/*[dylibs appendString:@":"];
	[dylibs appendString:SH_PATH(@"DarkMode")];*/
	return dylibs;
}

NSDictionary *overridedEnv(NSDictionary *orig, SBApplicationInfo *self)
{
	NSString *bundleIdentifier = self.bundleIdentifier;
	NSMutableDictionary *env = orig ? orig.mutableCopy : [NSMutableDictionary dictionary];
	if ([bundleIdentifier isEqualToString:@"com.apple.camera"])
		env[@"DYLD_INSERT_LIBRARIES"] = dylibPaths(@"Camera_test");
	else if ([bundleIdentifier isEqualToString:@"com.apple.mobileslideshow"])
		env[@"DYLD_INSERT_LIBRARIES"] = dylibPaths(@"InternalPhotos");
	else if ([bundleIdentifier isEqualToString:@"com.apple.mobilesafari"])
		env[@"DYLD_INSERT_LIBRARIES"] = dylibPaths(@"FullSafari");
	else if ([bundleIdentifier isEqualToString:@"com.apple.Preferences"])
		env[@"DYLD_INSERT_LIBRARIES"] = dylibPaths(@"PreferenceLoader-MAIN,PreferenceOrganizer2");
	else
		env[@"DYLD_INSERT_LIBRARIES"] = dylibPaths(@"");
	NSLog(@"%@ for bundleIdentifier: %@", env, bundleIdentifier);
	return env;
}

%hook SBApplicationInfo

- (NSDictionary *)environmentVariables
{
	return overridedEnv(%orig, self);
}

%end

// testing
@interface SBAppSwitcherDefaults : NSObject
@end

%hook SBAppSwitcherDefaults

- (_Bool)isSpringBoardKillable
{
	return YES;
}

%end

@interface CCUIButtonModule : NSObject
@end

%hook CCUIButtonModule

+ (BOOL)isSupported:(int)arg1
{
	return YES;
}

%end

@interface CCUIMagnifierModule : NSObject
@end

%hook CCUIMagnifierModule

+ (BOOL)isInternalButton
{
	return NO;
}

%end

@interface CCUITapToRadarShortcut : NSObject
@end

%hook CCUITapToRadarShortcut

+ (BOOL)isInternalButton
{
	return NO;
}

%end

@interface CCUIArtraceModule : NSObject
@end

%hook CCUIArtraceModule

+ (BOOL)isInternalButton
{
	return NO;
}

%end

@interface CCUILowPowerModeSetting : NSObject
@end

%hook CCUILowPowerModeSetting

+ (BOOL)isInternalButton
{
	return NO;
}

%end

@interface CCUIPersonalHotspotSetting : NSObject
@end

%hook CCUIPersonalHotspotSetting

+ (BOOL)isInternalButton
{
	return NO;
}

%end

@interface CCUICellularDataSetting : NSObject
@end

%hook CCUICellularDataSetting

+ (BOOL)isInternalButton
{
	return NO;
}

%end

@interface CCUINewLockscreenShortcut : NSObject
@end

%hook CCUINewLockscreenShortcut

+ (BOOL)isInternalButton
{
	return NO;
}

%end

__attribute__((constructor)) static void init()
{
	runIn(@"SpringBoard");
}