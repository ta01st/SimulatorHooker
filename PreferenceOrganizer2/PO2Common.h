#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#define DPKG_PATH "/var/lib/dpkg/info/net.angelxwind.preferenceorganizer2.list"

#define NSLog(LogContents, ...) NSLog((@"PreferenceOrganizer 2: %s:%d " LogContents), __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define PO2PreferencePath @"/User/Library/Preferences/net.angelxwind.preferenceorganizer2.plist"

#define STRINGIFY_(x) #x
#define STRINGIFY(x) STRINGIFY_(x)


#define PO2BoolPref(var, key, default) do {\
	NSNumber *key = PO2Settings[@STRINGIFY(key)];\
	var = key ? [key boolValue] : default;\
} while (0)

#define PO2IntPref(var, key, default) do {\
	NSNumber *key = PO2Settings[@STRINGIFY(key)];\
	var = key ? [key intValue] : default;\
} while (0)

#define PO2FloatPref(var, key, default) do {\
	NSNumber *key = PO2Settings[@STRINGIFY(key)];\
	var = key ? [key floatValue] : default;\
} while (0)

#define PO2StringPref(var, key, default) do {\
	NSString *key = PO2Settings[@STRINGIFY(key)];\
	var = ([key length] > 0) ? key : default;\
} while (0)

#define PO2Observer(funcToCall, listener) CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)funcToCall, CFSTR(listener), NULL, CFNotificationSuspensionBehaviorCoalesce);
#define PO2SyncPrefs()\
	NSDictionary *PO2Settings = [NSDictionary dictionaryWithContentsOfFile:PO2PreferencePath];
#define isJonyIve() (kCFCoreFoundationVersionNumber > 793.00)
