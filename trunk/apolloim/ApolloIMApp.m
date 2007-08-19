#import "ApolloIMApp.h"
#import "StartView.h"

@implementation ApolloIMApp

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSLog(@"ApolloIMApp.m>> Loading..");
	struct CGRect rect	=	[UIHardware fullScreenApplicationContentRect];
	rect.origin.x		=	rect.origin.y = 0.0f;

	NSLog(@"ApolloIMApp.m>> Initing _window...");
	_window = [[UIWindow alloc] initWithContentRect:rect];	

	NSLog(@"ApolloIMApp.m>> Initing startView...");
	startView			=	[[StartView alloc] initWithFrame: rect];
		
	NSLog(@"ApolloIMApp.m>> Setting content...");
	[_window	setContentView:	startView]; 
	[_window	orderFront:		self];
	[_window	makeKey:		self];
	[_window	_setHidden:		NO];
}

- (void)applicationWillTerminate {
	[_window release];
}

@end
