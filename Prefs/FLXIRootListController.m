#include "FLXIRootListController.h"

@implementation FLXIRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

- (void)github {
	NSURL *url = [NSURL URLWithString:@"https://github.com/Flipboard/FLEX/commit/b64cd37ec6d920ac18d5cbe18b4667cbe85a9f3a"];
	[[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)respring:(id)sender {
	pid_t pid;
	const char* args[] = {"killall", "backboardd", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}

@end
