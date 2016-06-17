#import "../Common.h"
#import "../ZKSwizzle.h"
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
	NSArray *paths = [names componentsSeparatedByString:@","];
	NSMutableString *dylibs = [NSMutableString string];
	for (NSString *name in paths)
		[dylibs appendString:[NSString stringWithFormat:@"%@:", SH_PATH(name)]];
	[dylibs appendString:SH_PATH(@"FLEXDylib")];
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
	NSLog(@"%@ for bundleIdentifier: %@", env, bundleIdentifier);
	return env;
}

hook(SBApplicationInfo)

- (NSDictionary *)environmentVariables
{
	return overridedEnv(ZKOrig(NSDictionary *), (SBApplicationInfo *)self);
}

endhook

// testing
@interface SBAppSwitcherDefaults : NSObject
@end

hook(SBAppSwitcherDefaults)

- (_Bool)isSpringBoardKillable
{
	return YES;
}

endhook

__attribute__((constructor)) static void init()
{
	runIn(@"SpringBoard");
}