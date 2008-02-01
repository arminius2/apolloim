/*
 By Adam Bellmore

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
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAnimator.h>
#import <UIKit/UIView.h>
#import <UIKit/UIPickerView.h>
#import <UIKit/UIPreferencesTableCell.h>
#import "TestInterface.h"
#import "EventListener.h"

static id sharedInstanceTest;

@implementation TestInterface

-(id) init
{
	if ((self == [super init]) != nil) 
	{
		user = nil;
		online = NO;
		buddylist = [[NSMutableArray alloc] init];
		listeners = [[NSMutableArray alloc] init];
		AlexLog(@"TestProtocol created.");
	}

	return self;
}

-(void) logIn:(User *) auser
{
	if(user == nil)
	{
		AlexLog(@"Attempting to log in user: %@", [auser getName]);
		user = auser;
		online = YES;

		int i = 0;
		for(i; i<10; i++)
		{
			Buddy * test1 = [[Buddy alloc] initWithName:[NSString stringWithFormat:@"TestBuddy1-%i", i] andGroup:@"Buddies" andOwner: auser];
			[test1 setStatusMessage:@"Chilling on my iphone"];
			Buddy * test2 = [[Buddy alloc] initWithName:[NSString stringWithFormat:@"TestBuddy2-%i", i] andGroup:@"Buddies" andOwner: auser];
			[test2 setAway: YES];
			Buddy * test3 = [[Buddy alloc] initWithName:[NSString stringWithFormat:@"TestBuddy3-%i", i] andGroup:@"Buddies" andOwner: auser];
			[test3 setIdleTimeMinutes: 35];
			[test3 setStatusMessage:@"Bing"];
			Buddy * test4 = [[Buddy alloc] initWithName:[NSString stringWithFormat:@"TestBuddy4-%i", i] andGroup:@"Buddies" andOwner: auser];
			[test4 setAway: YES];
			[test4 setIdleTimeMinutes: 13];
			[test4 setStatusMessage:@"Kicking at the mall."];
			[[user getBuddyList] addObject: test1];
			[[user getBuddyList] addObject: test2];
			[[user getBuddyList] addObject: test3];
			[[user getBuddyList] addObject: test4];
		}
		
		[self fireEventWithType:LOGIN_SUCCESS content:@"Login Success"];
		AlexLog(@"Login Successful");
	}
	else
	{
		[self fireEventWithType:LOGIN_FAIL content:@"Interface Alreaady In Use"];
	}
}

-(void) logOut:(User *) auser
{
	if(auser == user)
	{
		[[user getBuddyList] removeAllObjects];
		user = nil;
		online = NO;
		[self fireEventWithType:DISCONNECT content:@"Logout Successful"];
	}
}

-(BOOL) addEventListener:(id) el
{
	BOOL ret = true;
	[listeners addObject: el];
	AlexLog(@"Adding Event Listener, Total: %i",[listeners count]);
	return ret;
}

-(void) removeEventListener:(id) el
{
	[listeners removeObject: el];
}

-(void) performBuddyUpdate:(NSString *) buddy_name
{
	// do nothing for we have no server to update to
}

-(void) performUserUpdate:(User *) auser
{
	// do nothing for we have no server to update to
	AlexLog(@"Updating USer: %@ Is Away: %i Message:%@", [auser getName], [auser isAway], [auser getStatusMessage]);
}

-(BOOL) supportsService:(NSString *) service
{
	return [service isEqualToString:@"Test"];
}

-(void) fireEvent:(Event *) event
{
	AlexLog(@"Firing Message to %i listeners", [listeners count]);
	int i = 0;
	for(i; i<[listeners count]; i++)
	{
		AlexLog(@"Firing");
		id<EventListener> listener = [listeners objectAtIndex:i];
		[listener respondToEvent:event];
	}
}

-(void) fireEventWithType:(MessageType)type content:(id) thecontent
{
	Event * ev = [[Event alloc] initWithUser: user type:type content:thecontent];
	[self fireEvent:ev];
}

+(id) sharedInstance
{
	if(sharedInstanceTest == nil)
		sharedInstanceTest = [[TestInterface alloc] init];
	return sharedInstanceTest;
}

-(UIView *) getNewPreferencesViewWithFrame:(CGRect) frame
{
	UIView * view = [[UIView alloc] initWithFrame: frame];

	UIPreferencesTableCell * cell = [[UIPreferencesTableCell alloc] initWithFrame:
						CGRectMake(10.0, 10.0, 300.0, 40.0)];
	[cell setTitle:@"Username"];

	[view addSubview:cell];

	return view;
}

-(void) sendMessage:(NSString *) msg fromUser:(User *) user toBuddy:(Buddy *) buddy
{
	AlexLog(@"Looping Message");
	// Loop the message back
	Event * event = [[Event alloc] initWithUser:user buddy:buddy 
			type: BUDDY_MESSAGE
			content: [NSString stringWithFormat:@"LOOPED: %@", msg]];

	[self fireEvent:event];
}

-(UIView *) getPreferencesViewWithFrame: (CGRect) frame forUser:(User *) auser
{
}

-(void) performSave
{
}

@end
