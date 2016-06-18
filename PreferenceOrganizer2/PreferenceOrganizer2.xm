#import "PreferenceOrganizer2.h"
#import "PO2Common.h"
#import "../Common.h"
#import <objc/runtime.h>
#import <KarenLocalizer/KarenLocalizer.h>

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_8_0 1140.10
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_9_0
#define kCFCoreFoundationVersionNumber_iOS_9_0 1240.10
#endif


static NSMutableArray *AppleAppSpecifiers, *SocialAppSpecifiers, *TweakSpecifiers, *AppStoreAppSpecifiers;


@implementation AppleAppSpecifiersController
-(NSArray *) specifiers {
	if (!_specifiers) {
		self.specifiers = AppleAppSpecifiers;
	}
	return _specifiers;
}
@end
@implementation SocialAppSpecifiersController
-(NSArray *) specifiers {
	if (!_specifiers) {
		self.specifiers = SocialAppSpecifiers; 
	}
	return _specifiers;
}
@end
@implementation TweakSpecifiersController
-(NSArray *) specifiers {
	if (!_specifiers) {
		self.specifiers = TweakSpecifiers;
	}
	return _specifiers;
}
@end
@implementation AppStoreAppSpecifiersController
-(NSArray *) specifiers {
	if (!_specifiers) {
		self.specifiers = AppStoreAppSpecifiers;
	}
	return _specifiers;
}
@end

static BOOL shouldShowAppleApps=YES;
static BOOL shouldShowTweaks=YES;
static BOOL shouldShowAppStoreApps=YES;
static BOOL shouldShowSocialApps=YES;

static BOOL ddiIsMounted;
static NSString *appleAppsLabel;
static NSString *socialAppsLabel;
static NSString *tweaksLabel;
static NSString *appStoreAppsLabel;

KarenLocalizer *karenLocalizer;

static void PO2InitPrefs() {
	PO2SyncPrefs();
	PO2BoolPref(shouldShowAppleApps, ShowAppleApps, 1);
	PO2BoolPref(shouldShowTweaks, ShowTweaks, 1);
	PO2BoolPref(shouldShowAppStoreApps, ShowAppStoreApps, 1);
	PO2BoolPref(shouldShowSocialApps, ShowSocialApps, 1);
	karenLocalizer = [[KarenLocalizer alloc] initWithKarenLocalizerBundle:@"PreferenceOrganizer2"];
	PO2StringPref(appleAppsLabel, AppleAppsName, [karenLocalizer karenLocalizeString:@"APPLE_APPS"]);
	PO2StringPref(socialAppsLabel, SocialAppsName, [karenLocalizer karenLocalizeString:@"SOCIAL_APPS"]);
	PO2StringPref(tweaksLabel, TweaksName, [karenLocalizer karenLocalizeString:@"TWEAKS"]);
	PO2StringPref(appStoreAppsLabel, AppStoreAppsName, [karenLocalizer karenLocalizeString:@"APP_STORE_APPS"]);
}

static NSMutableArray *unorganisedSpecifiers = nil;

%hook PSUIPrefsListController

- (void)_setupiCloudSpecifier:(PSSpecifier *)specifier
{
	if (specifier == nil)
		return;
	%orig(specifier);
}

- (void)_setupiCloudSpecifier:(PSSpecifier *)specifier withPrimaryAccount:(id)arg2
{
	if (specifier == nil)
		return;
	%orig(specifier, arg2);
}

- (NSMutableArray *)specifiers {
	NSMutableArray *specifiers = %orig();
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (unorganisedSpecifiers == nil)
			unorganisedSpecifiers = [specifiers.copy retain];

		int groupID = 0;
		NSMutableDictionary *organizableSpecifiers = [[NSMutableDictionary alloc] init];
		NSString *currentOrganizableGroup = nil;

		for (int i = 0; i < specifiers.count; i++) { 
			PSSpecifier *s = (PSSpecifier *) specifiers[i];
			NSString *identifier = s.identifier ?: @"";

			if (s->cellType != 0) {

				if ([identifier isEqualToString:@"DEVELOPER_SETTINGS"]) {
					NSMutableArray *lastSavedGroup = organizableSpecifiers[currentOrganizableGroup];
					[lastSavedGroup removeObjectAtIndex:lastSavedGroup.count - 1];
					
					ddiIsMounted = 1;
				}

				else if ([identifier isEqualToString:@"CASTLE"] ) {
					currentOrganizableGroup = identifier;
					
					NSMutableArray *newSavedGroup = [[NSMutableArray alloc] init];
					[newSavedGroup addObject:specifiers[i - 1]];
					[newSavedGroup addObject:s];

					[organizableSpecifiers setObject:newSavedGroup forKey:currentOrganizableGroup];
				}

				else if ([identifier isEqualToString:@"STORE"]) {
					currentOrganizableGroup = identifier;
					
					NSMutableArray *newSavedGroup = [[NSMutableArray alloc] init];
					
					
					[newSavedGroup addObject:s];

					[organizableSpecifiers setObject:newSavedGroup forKey:currentOrganizableGroup];
				}

				else if (currentOrganizableGroup) {
					[organizableSpecifiers[currentOrganizableGroup] addObject:s];
				}

				
			}

			
			
			else if ([identifier isEqualToString:@"SOCIAL_ACCOUNTS"]) {
				currentOrganizableGroup = identifier;

				NSMutableArray *newSavedGroup = [[NSMutableArray alloc] init];
				[newSavedGroup addObject:s];

				[organizableSpecifiers setObject:newSavedGroup forKey:currentOrganizableGroup];
			}

			else if (currentOrganizableGroup) {
				if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_8_0) {
					
					if (groupID < 2 + ddiIsMounted) {
						groupID++;
						currentOrganizableGroup = @"STORE";
					} else if (groupID == 2 + ddiIsMounted) {
						groupID++;
						currentOrganizableGroup = @"TWEAKS";
					} else {
						groupID++;
						currentOrganizableGroup = @"APPS";
					}
				} else {
					NSMutableArray *tweaksGroup = organizableSpecifiers[@"TWEAKS"];
					if (tweaksGroup && tweaksGroup.count > 1) { 
						currentOrganizableGroup = @"APPS";
					} else {
						currentOrganizableGroup = @"TWEAKS";
					}
				}

				NSMutableArray *newSavedGroup = organizableSpecifiers[currentOrganizableGroup];
				if (!newSavedGroup) {
					newSavedGroup = [[NSMutableArray alloc] init];
				}

				[newSavedGroup addObject:s];
				[organizableSpecifiers setObject:newSavedGroup forKey:currentOrganizableGroup];
			}
			if (i == specifiers.count - 1 && groupID != 4 + ddiIsMounted) {
				groupID++;
				currentOrganizableGroup = @"APPS";
				NSMutableArray *newSavedGroup = organizableSpecifiers[currentOrganizableGroup];
				if (!newSavedGroup) {
					newSavedGroup = [[NSMutableArray alloc] init];
				}
				[organizableSpecifiers setObject:newSavedGroup forKey:currentOrganizableGroup];
			}
		}

		AppleAppSpecifiers = [organizableSpecifiers[@"CASTLE"] retain];
		[AppleAppSpecifiers addObjectsFromArray:organizableSpecifiers[@"STORE"]];

		SocialAppSpecifiers = [organizableSpecifiers[@"SOCIAL_ACCOUNTS"] retain];

		NSMutableArray *tweaksGroup = organizableSpecifiers[@"TWEAKS"];
		if ([tweaksGroup count] != 0 && ((PSSpecifier *)tweaksGroup[0])->cellType == 0 && ((PSSpecifier *)tweaksGroup[1])->cellType == 0) {
			[tweaksGroup removeObjectAtIndex:0];
		}
		TweakSpecifiers = [tweaksGroup retain];

		AppStoreAppSpecifiers = [organizableSpecifiers[@"APPS"] retain];

		
		
		[specifiers addObject:[PSSpecifier groupSpecifierWithName:nil]];
		
		if (shouldShowAppleApps && AppleAppSpecifiers) {
			[specifiers removeObjectsInArray:AppleAppSpecifiers];
			PSSpecifier *appleSpecifier = [PSSpecifier preferenceSpecifierNamed:appleAppsLabel target:self set:NULL get:NULL detail:[AppleAppSpecifiersController class] cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:Nil];
			[appleSpecifier setProperty:[UIImage _applicationIconImageForBundleIdentifier:@"com.apple.mobilesafari" format:0 scale:[UIScreen mainScreen].scale] forKey:@"iconImage"];
			[specifiers addObject:appleSpecifier];
		}

		if (shouldShowSocialApps && SocialAppSpecifiers) {
			[specifiers removeObjectsInArray:SocialAppSpecifiers];
			PSSpecifier *socialSpecifier = [PSSpecifier preferenceSpecifierNamed:socialAppsLabel target:self set:NULL get:NULL  detail:[SocialAppSpecifiersController class] cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:Nil];
			[socialSpecifier setProperty:[UIImage imageWithContentsOfFile:(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_9_0) ? @"/System/Library/PrivateFrameworks/Preferences.framework/FacebookSettings.png" : @"/Applications/Preferences.app/FacebookSettings.png"] forKey:@"iconImage"];
			[specifiers addObject:socialSpecifier];
		}

		if (shouldShowTweaks && TweakSpecifiers) {
			[specifiers removeObjectsInArray:TweakSpecifiers];
			PSSpecifier *cydiaSpecifier = [PSSpecifier preferenceSpecifierNamed:tweaksLabel target:self set:NULL get:NULL detail:[TweakSpecifiersController class] cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:Nil];
			[cydiaSpecifier setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/POPreferences.bundle/Tweaks.png"] forKey:@"iconImage"];
			[specifiers addObject:cydiaSpecifier];
		}

		if (shouldShowAppStoreApps && AppStoreAppSpecifiers) {
			[specifiers removeObjectsInArray:AppStoreAppSpecifiers];
			PSSpecifier *appstoreSpecifier = [PSSpecifier preferenceSpecifierNamed:appStoreAppsLabel target:self set:NULL get:NULL detail:[AppStoreAppSpecifiersController class] cell:[PSTableCell cellTypeFromString:@"PSLinkCell"] edit:Nil];
			[appstoreSpecifier setProperty:[UIImage _applicationIconImageForBundleIdentifier:@"com.apple.AppStore" format:0 scale:[UIScreen mainScreen].scale] forKey:@"iconImage"];
			[specifiers addObject:appstoreSpecifier];
		}

		
	});

	return specifiers;
}

/*-(void)loadView {
	NSMutableArray *originalSpecifiers = MSHookIvar<NSMutableArray *>(self, "_specifiers");
	MSHookIvar<NSMutableArray *>(self, "_specifiers") = unorganisedSpecifiers;
	%orig;
	MSHookIvar<NSMutableArray *>(self, "_specifiers") = originalSpecifiers;
}*/

/*-(void) _reallyLoadThirdPartySpecifiersForProxies:(id)arg1 withCompletion:(id)arg2 {
	%orig(arg1, arg2);
	if (shouldShowAppStoreApps) {
		int thirdPartyID = 0;
		NSMutableArray* specifiers = [[NSMutableArray alloc] initWithArray:((PSListController *)self).specifiers];
		for (int i = 0; i < [specifiers count]; i++) {
			PSSpecifier* item = [specifiers objectAtIndex:i];
			if ([item.identifier isEqualToString:@"THIRD_PARTY_GROUP"]) {
				thirdPartyID = i;
				break;
			}
		}
		for (int i = thirdPartyID + 1; i < [specifiers count]; i++) {
			[AppStoreAppSpecifiers addObject:specifiers[i]];
		}

		while ([specifiers count] > thirdPartyID + 1) {
			[specifiers removeLastObject];
		}
		((PSListController *)self).specifiers = specifiers;
	}
}*/

%end

%hook PreferencesAppController

-(void) preferenceOrganizerOpenTweakPane:(NSString *)name {
	
	
}

-(void) applicationOpenURL:(NSURL *)url {
	NSString *parsableURL = [url absoluteString];
	if (parsableURL.length >= 11 && [parsableURL rangeOfString:@"root=Tweaks"].location != NSNotFound) {
		NSString *truncatedPrefsURL = [@"prefs:root=" stringByAppendingString:tweaksLabel];
		url = [NSURL URLWithString:truncatedPrefsURL];
		%orig(url);
		NSRange tweakPathRange = [parsableURL rangeOfString:@"path="];
		if (tweakPathRange.location != NSNotFound) {
			NSInteger tweakPathOrigin = tweakPathRange.location + tweakPathRange.length;
			[self preferenceOrganizerOpenTweakPane:[parsableURL substringWithRange:NSMakeRange(tweakPathOrigin, parsableURL.length - tweakPathOrigin)]];
		}
	} else {
		%orig(url);
	}
}

%end

%ctor
{
	runIn(@"Preferences");
	%init();
	PO2InitPrefs();
}