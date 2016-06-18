#import "../Common.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface PURootSettings : NSObject
+ (void)presentSettingsController;
@end

@interface PUAlbumListViewController : UIViewController
- (UINavigationItem *)navigationItem;
@end

@interface PUAlbumListViewController (Addition)
- (UIBarButtonItem *)_internalButtonItem;
@end

UIBarButtonItem *_btn;

%hook PUAlbumListViewController

- (UIBarButtonItem *)_internalButtonItem
{
	if (objc_getAssociatedObject(self, &_btn) == nil) {
		UIButton *gear = [[UIButton alloc] initWithFrame:CGRectZero];
		[gear sizeToFit];
		UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonItemStylePlain target:self action:@selector(ip_handleInternalButton:)];
		[gear release];
		objc_setAssociatedObject(self, &_btn, btn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[btn release];
    }
    return objc_getAssociatedObject(self, &_btn);
}

- (void)ip_handleInternalButton:(id)sender
{
	[NSClassFromString(@"PURootSettings") presentSettingsController];
}

- (void)updateNavigationBarAnimated:(BOOL)animated
{
	%orig;
	UINavigationItem *navigationItem = [[self navigationItem] retain];
	NSArray *buttonItems = navigationItem.leftBarButtonItems;
	NSMutableArray *buttons = [[buttonItems retain] mutableCopy];
	if (buttons == nil)
		return;
	UIBarButtonItem *internalButton = [[self _internalButtonItem] retain];
	if ([buttons containsObject:internalButton])
		return;
	[buttons addObject:internalButton];
	[navigationItem setLeftBarButtonItems:buttons animated:animated];
	[navigationItem release];
	[buttons release];
	[internalButton release];
}

%end

%ctor
{
	runIn(@"Photos");
}