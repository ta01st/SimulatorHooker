#import "../ZKSwizzle.h"
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

hook(NSUserDefaults)

- (BOOL)boolForKey:(NSString *)key
{
	return [key isEqualToString:@"ShowTabBar"] ? YES : ZKOrig(BOOL, key);
}

endhook

hook(UIDevice)

- (UIUserInterfaceIdiom)userInterfaceIdiom
{
	return override2 ? UIUserInterfaceIdiomPad : ZKOrig(UIUserInterfaceIdiom);
}

endhook

hook(UITraitCollection)

- (UIUserInterfaceSizeClass)horizontalSizeClass
{
	return override ? UIUserInterfaceSizeClassRegular : ZKOrig(UIUserInterfaceSizeClass);
}

endhook

hook(UIViewController)

- (BOOL)safari_isHorizontallyConstrained
{
	return YES;
}

endhook

hook(TabController)

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
	ZKOrig(void, YES);
}

endhook

hook(BrowserController)

- (BOOL)_shouldUseNarrowLayout
{
	return override4 && newFluid ? NO : ZKOrig(BOOL);
}

- (CGFloat)_navigationBarOverlapHeight
{
	override2 = YES;
	CGFloat orig = ZKOrig(CGFloat);
	override2 = NO;
	return orig;
}

- (void)dynamicBarAnimatorOutputsDidChange:(id)arg1
{
	override4 = YES;
	ZKOrig(void, arg1);
	override4 = NO;
}

- (BOOL)usesNarrowLayout
{
	return override3 && newFluid ? NO : ZKOrig(BOOL);
}

- (void)_updateUsesNarrowLayout
{
	override3 = newFluid;
	override2 = newFluid;
	ZKOrig(void);
	override3 = NO;
	override2 = NO;
}

- (void)updateUsesTabBar
{
	override = YES;
	ZKOrig(void);
	override = NO;
}

- (void)updateShowingTabBarAnimated:(BOOL)arg1
{
	override = YES;
	ZKOrig(void);
	override = NO;
}

- (BOOL)_shouldShowTabBar
{
	return YES;
}

endhook

hook(BrowserToolbar)

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
	ZKOrig(void, items, arg2);
}

endhook

__attribute__((constructor)) static void init()
{
	runIn(@"Safari");
}