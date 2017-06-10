// Dock by nathanaccidenally.
// Thanks to help from Uroboro, Wizages, and AppleBetas.

// Setting up headers.

@interface SBDockView : UIView // Dock view. We create this later for the floating dock and also for frame and layer.
@end

// This is for hiding the icon labels.

@interface SBIconLegibilityLabelView : UIView
@end

// SBIcon stuff for floating dock.
// Thanks to Wizages for the help with icons.

@interface SBIcon : NSObject // Also for the floating dock.
@end

@interface SBIconView : UIView
@end

@interface SBIconViewMap : NSObject
- (SBIconView *)mappedIconViewForIcon:(SBIcon *)icon;
@end

// SBIconModel has incorrect headers. Looking into this.

@interface SBIconModel : NSObject
// - (SBIconViewMap *)homescreenIconViewMap;
+ (id)sharedInstance;
// - (SBIconModel *)model;
@end

// This is for the blur on our floating dock.

@interface _UIBackdropView : UIView
-(id)initWithPrivateStyle:(long long)arg1;
@end

// Great now we can setup our booleans for the settings.

static BOOL enabled = NO;
static BOOL floatDock = NO;
static BOOL hideLabels = NO;

// Now we will set other things like values for our frames (CGFloat) and an NSInteger which will also become a float for use with frame.

static NSInteger floatyValue = 470; // Is to be used when creating our floating UIWindow, is user configurable.
CGFloat setDockWidth; // Being used to store CGFloats of frame values from our final set dock.
CGFloat setDockHeight; // Being used to store CGFloats of frame values from our final set dock.

// Now we need to set defalut strings for our icon views.
// These are bundle id's taken from the settings app.

NSString *iconOneID = @""; // First icon on the left. Next ones are so on.
NSString *iconTwoID = @"";
NSString *iconThreeID = @"";
NSString *iconFourID = @"";

// Great! Let's set up a SBIconController reference.

SBIconController *iconController = [%c(SBIconController) sharedInstance]; // Call this when you wanna make an SBIconController instance.

// Now we can actually do stuff. Let's start by making our group with anything we want in it.

%group dock

// Now we are gonna hook our dock.

%hook SBDockView

- (void)didMoveToWindow {
	%orig;
	// In here we wanna do two things, set clipsToBounds, and the cornerRadius.
	NSLog(@"Dock: SBDockView was hooked and didMoveToWindow was called. We will now setClipsToBounds and cornerRadius.");

	[self setClipsToBounds:YES];
	[self.layer setCornerRadius:13];

	NSLog(@"Dock: cornerRadius and setClipsToBounds should be successfully set.");
}

// Now we're gonna set the frame, before the re-write this didn't work;

- (void)setFrame:(CGRect)frame {
	// Here we need to make the dock more slim both width and height wise, as well as move it up slightly.
	NSLog(@"Dock: setFrame was called on the dock, setting width, height, x, and y values.");

	frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	%orig(frame);

	// Now we need to store our frame values within our CGFloat variables.

	setDockWidth = self.frame.size.width;
	setDockHeight = self.frame.size.height;

	NSLog(@"Dock: setFrame has finished running on the dock.");
}

%end

// Great now we need to hide icon labels.

%hook SBIconLegibilityLabelView

- (void)layoutSubviews {
	// Here we will hide the labels.

	%orig;
	NSLog(@"Dock: layoutSubviews called on the SBIcon views.");

	if ([self.superview.superview isMemberOfClass:objc_getClass("SBDockIconListView")] && hideLabels) {
		[self setHidden:YES];
		NSLog(@"Dock: Icon labels should be hidden.");
	}
}

%end

// Now we're done so we need to end our group.
%end

// Now we need to build our floating dock from scratch. This is because as of right now you can't get a class and it's subviews and attach it to another UIWindow, so we've gotta go old school.
// Also, this uses SBDockView on the SpringBoard so most tweaks that affect the dock (color etc) should work.

// Here we get a notification callback for when the SpringBoard loads, this is to avoid respring loops and wait so we can get the values we need (thanks Uroboro <3).

static void viewLoadedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	// Great, we've gotta let me know this happened! Let's log it.
	NSLog(@"Dock: Notification callback for the SpringBoard was triggered.");

	// Now we can check our settings and do some stuff.
	if (enabled && floatDock) {
		// If we've made it here, we should probably create our view.
		NSLog(@"Dock: We have been cleared to create our own dock view. Creating.");

		// Here's our window we're making.
		UIWindow *dockWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, floatyValue, UIScreen.mainScreen.bounds.size.width, setDockHeight)];
		dockWindow.windowLevel = UIWindowLevelNormal; // Should behave normally on the SpringBoard at least.

		NSLog(@"Dock: Our UIWindow (dockWindow) was created. Now making our SBDockView.");

		SBDockView *floatingDock = [[NSClassFromString(@"SBDockView") alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, setDockHeight)];
		[floatingDock setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.20]];

		NSLog(@"Dock: Our floating dock instance of SBDockView has been created. Making blur view.");

		_UIBackdropView *blurView = [[_UIBackdropView alloc] initWithPrivateStyle:2];
		[floatingDock addSubview:blurView];

		NSLog(@"Dock: Created _UIBackdropView blur and attached it to the floatingDock as a subview. Creating our SpringBoard icons.");

		// SpringBoard icons commented out right now because of header issues.

		// SBIcon *iconOne = [[iconController model] expectedIconForDisplayIdentifier:iconOneID];
        // SBIconView *iconViewOne = [[iconController homescreenIconViewMap] mappedIconViewForIcon:iconOne];
        // [floatingDock addSubview:iconViewOne];

        NSLog(@"Dock: Should have created icons and attached them to the floatingDock.");
        NSLog(@"Dock: Attaching floatingDock to our window and displaying result.");

        [dockWindow addSubview:floatingDock];
        [dockWindow setHidden:NO];

        NSLog(@"Dock: Releasing floatingDock.");

        [floatingDock release];
	}
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, viewLoadedCallback, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorCoalesce); // Our callback.

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.nathanaccidentally.dockprefs.plist"];

	if (prefs) {
		NSLog(@"Dock: Prefs loaded.");
		if ([prefs objectForKey:@"isEnabled"]) {
			enabled = [[prefs objectForKey:@"isEnabled"] boolValue];

			if ([[prefs objectForKey:@"isEnabled"] boolValue] == YES) {
				%init(dock);
				NSLog(@"Dock: Prefs told me to init the tweak. oops.");
			}
		}

		if ([prefs objectForKey:@"floatDock"]) {
			floatDock = [[prefs objectForKey:@"floatDock"] boolValue];
		}

		if ([prefs objectForKey:@"hideLabels"]) {
			hideLabels = [[prefs objectForKey:@"hideLabels"] boolValue];
		}

		NSLog(@"Dock: Loading settings for floating dock.");

		if([prefs objectForKey:@"floatyvalue"]) {
			floatyValue = [[prefs objectForKey:@"floatyvalue"] intValue];
		}

		if([prefs objectForKey:@"iconOneId"]) {
			iconOneID = [[prefs objectForKey:@"iconOneId"] stringValue];
		}
	}
}

// Phew. Why wasn't I warned a rewrite would be hard?