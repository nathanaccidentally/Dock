// Dock by nathanaccidentally. Make your dock like iOS 11.
// Big thanks to Uroboro, AppleBetas, and Andywiik for guidance during this project. It wouldn't be possible without you guys.

@interface SBDockView : UIView
@end

@interface SBIcon : NSObject
@end

@interface SBIconView : UIView
@end

@interface  SBIconViewMap
- (SBIconView *)mappedIconViewForIcon:(SBIcon *)icon;
@end

@interface SBIconModel : NSObject
-(id)expectedIconForDisplayIdentifier:(id)arg1; // NOT THIS!
@end

@interface SBIconController : NSObject
-(SBIconViewMap *)homescreenIconViewMap;
// +(id)sharedInstance;
// -(SBIconModel *)model;
@end

@interface SBIconLegibilityLabelView : UIView
@end

@interface _UIBackdropView : UIView
-(id)initWithPrivateStyle:(long long)arg1;
@end

static BOOL enabled = NO;
static BOOL floatDock = NO;
static BOOL hideLabels = YES;
static NSInteger floatyvalue = 470;

// Bundle id's for the dock
NSString *iconOneId = @"com.apple.Maps";

CGFloat dockWidth;
CGFloat dockHeight;

// We need to set this up for our icons. 

// SBIconController *iconController = [%c(SBIconController) sharedInstance];

%group dock
%hook SBDockView

- (void)didMoveToWindow {
	%orig;
	[self setClipsToBounds:YES];
	[self.layer setCornerRadius:13];
}

- (void)setFrame:(CGRect)frame {
	frame = CGRectMake(5, frame.origin.y - 2, frame.size.width - 10, frame.size.height - 10);
	%orig(frame);

	dockWidth = frame.size.width;
	dockHeight = frame.size.height + 10;
}

%end

%hook SBIconLegibilityLabelView

- (void)layoutSubviews {
	if ([self.superview.superview isMemberOfClass:objc_getClass("SBDockIconListView")] && hideLabels) { // Sorry Urobueno for bad code. :(
		[self setHidden:YES];
	}
}

%end
%end

// Below is for the floating dock.

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (enabled && floatDock) {

		// This is called if we're told to float the dock.
		UIWindow *dockView = [[UIWindow alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.origin.x, floatyvalue, UIScreen.mainScreen.bounds.size.width, dockHeight)];
		dockView.windowLevel = UIWindowLevelNormal;
		dockView.hidden = NO;

		SBDockView *dock = [[NSClassFromString(@"SBDockView") alloc]initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, dockHeight)];
		[dock setBackgroundColor:[[UIColor whiteColor]colorWithAlphaComponent:0.50]];

		_UIBackdropView *blurView = [[_UIBackdropView alloc] initWithPrivateStyle:2]; // Should make for some nice blur.
		[dock addSubview:blurView];

		// SBIcon *iconOne = [[iconController model] expectedIconForDisplayIdentifier:iconOneID];
        // SBIconView *iconViewOne = [[iconController homescreenIconViewMap] mappedIconViewForIcon:iconOne];

		// [iconViewOne setBackgroundColor:[UIColor blackColor]];
		// [iconViewOne.layer setCornerRadius:13];

		// [dock addSubview:iconViewOne];

		// Let's post our dock to our UIWindow
		[dockView addSubview:dock];
		[dock release];
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, notificationCallback, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.nathanaccidentally.dockprefs.plist"];
	
	if (prefs) {
		if([prefs objectForKey:@"isEnabled"]) {
			enabled = [[prefs objectForKey:@"isEnabled"] boolValue];
			if ([[prefs objectForKey:@"isEnabled"] boolValue] == YES) {
				%init(dock)
			}
		}

		if([prefs objectForKey:@"floatDock"]) {
			floatDock = [[prefs objectForKey:@"floatDock"] boolValue];
		}

		if([prefs objectForKey:@"hideLabels"]) {
			hideLabels = [[prefs objectForKey:@"hideLabels"] boolValue];
		}

		// Settings for floating dock.

		if([prefs objectForKey:@"floatyvalue"]) {
			floatyvalue = [[prefs objectForKey:@"floatyvalue"] intValue];
		}

		if([prefs objectForKey:@"iconOneId"]) {
			iconOneId = [[prefs objectForKey:@"iconOneId"] stringValue];
		}
	}
}