#import "../Common.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

BOOL override = NO;
BOOL override2 = NO;
BOOL override3 = NO;
BOOL override4 = NO;

BOOL plus = YES;
BOOL newFluid = YES;

//Force-add the "add tab" button to the toolbar
@interface UIBarButtonItem (Extend)
- (BOOL)isSystemItem;
- (UIBarButtonSystemItem)systemItem;
@end

@interface TabController : NSObject
@end

@interface BrowserController : NSObject
@end

@interface BrowserToolbar : NSObject
@end

%hook NSUserDefaults

- (BOOL)boolForKey:(NSString *)key
{
	return [key isEqualToString:@"ShowTabBar"] ? YES : %orig;
}

%end

%hook UIDevice

- (UIUserInterfaceIdiom)userInterfaceIdiom
{
	return override2 ? UIUserInterfaceIdiomPad : %orig;
}

%end

%hook UITraitCollection

- (UIUserInterfaceSizeClass)horizontalSizeClass
{
	return override ? UIUserInterfaceSizeClassRegular : %orig;
}

%end

%hook UIViewController

- (BOOL)safari_isHorizontallyConstrained
{
	return YES;
}

%end

%hook TabController

- (BOOL)canAddNewTab
{
	return YES;
}

- (BOOL)usesTabBar
{
	return YES;
}

- (void)setUsesTabBar:(BOOL)arg
{
	%orig(YES);
}

%end

%hook BrowserController

- (BOOL)_shouldUseNarrowLayout
{
	return override4 && newFluid ? NO : %orig;
}

- (CGFloat)_navigationBarOverlapHeight
{
	override2 = YES;
	CGFloat orig = %orig;
	override2 = NO;
	return orig;
}

- (void)dynamicBarAnimatorOutputsDidChange:(id)arg1
{
	override4 = YES;
	%orig;
	override4 = NO;
}

- (BOOL)usesNarrowLayout
{
	return override3 && newFluid ? NO : %orig;
}

- (void)_updateUsesNarrowLayout
{
	override3 = newFluid;
	override2 = newFluid;
	%orig;
	override3 = NO;
	override2 = NO;
}

- (void)updateUsesTabBar
{
	override = YES;
	%orig;
	override = NO;
}

- (void)updateShowingTabBarAnimated:(BOOL)arg1
{
	override = YES;
	%orig;
	override = NO;
}

- (BOOL)_shouldShowTabBar
{
	return YES;
}

%end

%hook BrowserToolbar

- (void)setItems:(NSArray *)items animated:(BOOL)arg2
{
	if (plus) {
		UIBarButtonItem *addTabItem;
		object_getInstanceVariable(self, "_addTabItem", (void **)&addTabItem);
		if (![items containsObject:addTabItem]) {
			NSMutableArray *newItems = [items mutableCopy];

			// Replace fixed spacers with flexible ones
			for (UIBarButtonItem *item in [newItems.copy autorelease]) {
				if ([item isSystemItem] && [item systemItem] == UIBarButtonSystemItemFixedSpace && [item width] > 0.1) {
					[newItems replaceObjectAtIndex:[items indexOfObject:item] withObject:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease]];
				}
			}
		
			UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			[newItems addObject:spacer];
			[newItems addObject:addTabItem];

			items = [newItems copy];
			[newItems release];
			[spacer release];
		}
	}
	%orig(items, arg2);
}

%end

%ctor
{
	runIn(@"Safari");
}