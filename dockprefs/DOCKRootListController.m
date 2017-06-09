#include "DOCKRootListController.h"

@implementation DOCKRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)respring {
	system("killall SpringBoard");
}

-(void)donate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/nathanaccidentally"]];
}

-(void)tweetMe {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/clichewow"]];
}

@end
