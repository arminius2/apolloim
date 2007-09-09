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
#import <UIKit/UIBox.h>
#import "Common.m"

@implementation ApolloIMApp

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {


	NSLog(@"ApolloIMApp.m>> Loading..");
	struct CGRect rect	=	[UIHardware fullScreenApplicationContentRect];
	rect.origin.x		=	rect.origin.y = 0.0f;
	rect.size.width = 320.0;
	rect.size.height = 465.0;

	NSLog(@"ApolloIMApp.m>> Initing _window...");
	_window = [[UIWindow alloc] initWithContentRect:rect];	

	NSLog(@"ApolloIMApp.m>> Initing startView...");
	startView			=	[[StartView alloc] initWithFrame: rect];
		
	NSLog(@"ApolloIMApp.m>> Setting content...");
	[_window	setContentView:	startView]; 
	[_window	orderFront:		self];
	[_window	makeKey:		self];
	[_window	_setHidden:		NO];
	
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(resetIdles) userInfo:nil repeats:YES];
	/*
	float x = 0.0f;
	float y = 50.0f;
	int i;
	for(i=0; i<10; i++)
	{
		float lovelyShadeOfGreen[4] = {.1, .9, .1, 1};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();	
		CGRect frame = CGRectMake(x, 0, 4, y);
		UIBox * b = [[UIBox alloc] initWithFrame: frame];
		[b setBackgroundColor: CGColorCreate( colorSpace, lovelyShadeOfGreen)];
		[startView addSubview:b];
		x+=8.0f;
		y+=1.0f;
	}
	*/
}

-(void)resetIdles
{
	[self resetIdleTimer];
	[self resetIdleDuration:0.0f];
	if([UIApp isLocked])
	{
		NSLog(@"LOCKING");
		[[NSString stringWithString:@"NINJA"]writeToFile:@"/tmp/SummerBoard.DisablePowerManagement" atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
}

- (void)applicationSuspend:(struct __GSEvent *)fp8
{
	NSLog(@"Suspending...");
	[[NSString stringWithString:@"NINJA"]writeToFile:@"/tmp/SummerBoard.DisablePowerManagement" atomically:YES encoding:NSUTF8StringEncoding error:nil];	
	if([startView connected])
	{
//		[startView closeActiveKeyboard];
//		[startView resume];
		[[ApolloNotificationController sharedInstance] clearBadges];
	}
	else
	{
		system("rm /tmp/SummerBoard.DisablePowerManagement");		
		exit(1);
	}
}

- (void)applicationResume:(struct __GSEvent *)fp8
{
	NSLog(@"Resuming...");
	NSLog(@"Removing Lock file...");
	system("rm /tmp/SummerBoard.DisablePowerManagement");
//	[[ApolloTOC sharedInstance]resumeApollo];
	[startView resume];
	[[ApolloNotificationController sharedInstance] clearBadges];
}

- (BOOL)applicationIsReadyToSuspend
{
	NSLog(@"APPLICATION IS READY");
	//Please?  Please work?
	return NO;
}

- (BOOL)isSuspendingUnderLock
{
	NSLog(@"SUSPENDING UNDER LOCK");
	return YES;
}

- (void)applicationDidResumeFromUnderLock
{
	[startView resume];
	NSLog(@"Resuming from under lock...");
		system("rm /tmp/SummerBoard.DisablePowerManagement");	
}

- (void)applicationWillSuspendUnderLock
{
	if(![UIApp isLocked])
	{
		NSLog(@"Locking...");
		[[NSString stringWithString:@"NINJA"]writeToFile:@"/tmp/SummerBoard.DisablePowerManagement" atomically:YES encoding:NSUTF8StringEncoding error:nil];	
	}
}

- (void)applicationWillTerminate
{	
	[[ApolloNotificationController sharedInstance] clearBadges];
	[self removeApplicationBadge];
	system("rm /tmp/SummerBoard.DisablePowerManagement");	
	[_window release];
}

- (BOOL) suspendRemainInMemory
{
	NSLog(@"SUSPEND REMAIN IN MEMORY");
	return YES;
}

- (void)menuButtonDown:(struct __GSEvent *)fp8
{
//	[startView makeACoolMoveTo:BUDDY_VIEW];
	
}

- (void)ringerChanged:(int)fp8
{
	NSLog(@"RINGER CHANGED %d", fp8);
}

@end
