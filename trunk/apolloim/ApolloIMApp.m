/*
 ApolloTOC.m: Objective-C firetalk interface.
 By Alex C. Schaefer

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/
#import "ApolloIMApp.h"
#import "StartView.h"
#import "ApolloTOC.h"
#import "ApolloIM-PrivateAccess.h"

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
- (void)applicationSuspend:(struct __GSEvent *)event 
{
	NSLog(@"Suspending...");
//	[[ApolloTOC sharedInstance]suspendApollo];
}

- (void)applicationResume:(struct __GSEvent *)event 
{
	NSLog(@"Resuming...");
//	[[ApolloTOC sharedInstance]resumeApollo];	
}

- (BOOL)applicationIsReadyToSuspend
{
	//Please?  Please work?
	return NO;
}

- (BOOL)isSuspendingUnderLock
{
	return NO;
}

- (void)applicationWillTerminate {
	[_window release];
}

@end
