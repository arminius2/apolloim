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
#import <UIKit/UIPreferencesTextTableCell.h>

#import "PurpleInterface.h"
#import "EventListener.h"
#import "ApolloCore.h"
#import "UserManager.h"
#import "ViewController.h"

static id sharedInstancePurple;

@implementation PurpleInterface

-(id) init
{
	if ((self == [super init]) != nil) 
	{
		user_list = [[NSMutableArray alloc] init];
		listeners = [[NSMutableArray alloc] init];

		protocol = [NSString init];
		new_user_editing = NO;

		account_view = [[UIView alloc] initWithFrame: CGRectMake(0, 200, 320, 415)];

		username_cell = [[UIPreferencesTextTableCell alloc] init];
		[username_cell setTitle:@"Username"];
		[username_cell setPlaceHolderValue:@"Your username"];
		[username_cell setEnabled:YES];
		username_field = [username_cell textField];
		
		password_cell = [[UIPreferencesTextTableCell alloc] init];
		[password_cell setTitle:@"Password"];
		[[password_cell textField]setText:@""];
		[password_cell setEnabled:YES];
		[password_cell setPlaceHolderValue:@"Your password"];
		[[password_cell textField]setSecure:YES];
		password_field = [password_cell textField];

		server_cell = [[UIPreferencesTextTableCell alloc] init];
		[server_cell setTitle:@"Server"];
		[server_cell setPlaceHolderValue:@"Custom Server"];
		[server_cell setEnabled:YES];
		server_field = [server_cell textField];
		
		port_cell = [[UIPreferencesTextTableCell alloc] init];
		[port_cell setTitle:@"Port"];
		[[port_cell textField]setText:@""];
		[port_cell setEnabled:YES];
		[port_cell setPlaceHolderValue:@"Custom Port"];
		port_field = [port_cell textField];

		delete_button = [[UIPreferencesTableCell alloc] init];
		[delete_button setTitle:@"Delete User"];
		[delete_button setTarget:self];

		pref_table = [[UIPreferencesTable alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 415.0f)];
		[pref_table setDataSource:self];
		[pref_table setDelegate:self];
		[pref_table reloadData];

		[account_view addSubview:pref_table];

		NSLog(@"PurpleInterface created.");
	}

	return self;
}

-(void) logIn:(User *) auser
{
	if([auser isActive])
	{
		if([[auser getProtocol] isEqualToString:DOTMAC])
		{
			[auser setName: [[NSString alloc] initWithFormat:@"%@@mac.com", [auser getStartingName]]];
		}
		[user_list addObject: auser];
		[[ApolloCore sharedInstance] connect:auser];
	}
}

-(void) logOut:(User *) auser
{
	if([auser isActive])
	{
		[user_list removeObject: auser];
		[[ApolloCore sharedInstance] disconnect:auser];
		[auser removeAllFromBuddyList];
	}
}

-(BOOL) addEventListener:(id) el
{
	BOOL ret = true;
	[listeners addObject: el];
	//NSLog(@"Adding Event Listener, Total: %i",[listeners count]);
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
	NSLog(@"Updating User: %@ Is Away: %i Message:%@", [auser getName], [auser isAway], [auser getStatusMessage]);
	if([auser isAway])
		[[ApolloCore sharedInstance]away:auser];
	else
		[[ApolloCore sharedInstance]back:auser];
}

-(BOOL) supportsService:(NSString *) service
{
	return ([service isEqualToString:AIM] ||
		[service isEqualToString:ICQ] ||
		[service isEqualToString:DOTMAC] ||
		[service isEqualToString:MSN]);
}

-(void) fireEvent:(Event *) event
{
	//NSLog(@"Firing Message to %i listeners", [listeners count]);
	int i = 0;
	for(i; i<[listeners count]; i++)
	{
		id<EventListener> listener = [listeners objectAtIndex:i];
		[listener respondToEvent:event];
	}
}

+(id) sharedInstance
{
	if(sharedInstancePurple == nil)
		sharedInstancePurple = [[PurpleInterface alloc] init];
	return sharedInstancePurple;
}

-(UIView *) getNewPreferencesViewWithFrame:(CGRect) frame andProtocol:(NSString *) aprotocol;
{
	last_user_editing = nil;
	new_user_editing = YES;
	protocol = aprotocol;

	[username_field setText:@""];
	[username_cell setEnabled:YES];
	[password_field setText:@""];
	[server_field setText:@""];
	[port_field setText:@""];

	if([aprotocol isEqualToString:JABBER])
	{
		[server_cell setEnabled:YES];
		[port_cell setEnabled:YES];
	}
	else
	{
		[server_cell setEnabled:NO];
		[port_cell setEnabled:NO];
	}

	[delete_button setEnabled:NO];
	[account_view setFrame:frame];
	return account_view;
}

-(UIView *) getPreferencesViewWithFrame:(CGRect) frame forUser:(User *) auser andProtocol:(NSString *) aprotocol
{
	last_user_editing = auser;
	new_user_editing = NO;
	protocol = aprotocol;

	[username_field setText:[auser getStartingName]];
	[username_cell setEnabled:NO];
	[password_field setText:[auser getSettingForKey:@"password"]];
	
	if([aprotocol isEqualToString:JABBER])
	{
		[server_field setText:[auser getSettingForKey:@"server"]];
		[server_cell setEnabled:YES];
		[port_field setText:[auser getSettingForKey:@"port"]];
		[port_cell setEnabled:YES];
	}
	else
	{
		[server_field setText:@""];
		[server_cell setEnabled:NO];
		[port_field setText:@""];
		[port_cell setEnabled:NO];
	}

	[delete_button setEnabled:YES];

	[account_view setFrame:frame];
	return account_view;
}

-(BOOL) performSave
{
	NSString * username = [username_field text];
	NSString * password = [password_field text];
	NSString * server = [server_field text];
	NSString * port = [port_field text];

	if([protocol isEqualToString:MSN])
	{
		if([username rangeOfString:@"@"].location == NSNotFound)
			username = [[NSString alloc] initWithFormat:@"%@@%@", username, @"hotmail.com"];
	}

	if([@"" isEqualToString:username])
	{
		NSLog(@"EQUAL EMPTY");
		return NO;
	}

	UserManager * um = [UserManager sharedInstance];
	NSLog(@"USER MANAGE SET");
	if(!new_user_editing)
	{
		NSLog(@"NOT NEW USER");
		[um removeUser:last_user_editing];
		NSLog(@"REMOVE USER");
		[last_user_editing setName:username];
	}
	else
	{
		NSLog(@"EXISTING USER EDIT");
		last_user_editing = [[User alloc] initWithName:username andProtocol:protocol];
	}
	NSLog(@"ADDING USER");
	[um addUser:last_user_editing];
	[last_user_editing setSettingForKey:@"password" andValue:password];
	NSLog(@"PASS");
	[last_user_editing setSettingForKey:@"server" andValue:server];
	NSLog(@"SERVER");
	[last_user_editing setSettingForKey:@"port" andValue:port];
	NSLog(@"PORT");

	return YES;
}

-(void) sendMessage:(NSString *) msg fromUser:(User *) user toBuddy:(Buddy *) buddy
{
	[[ApolloCore sharedInstance] sendIM:msg toBuddyName:[buddy getRawName] fromAcct:user]; 
}

// Table methods
-(int) numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable
{
	return 3;
}

-(int) preferencesTable:(UIPreferencesTable *)aTable numberOfRowsInGroup:(int)group
{
	if(group == 2)
		return 1;
	return 2;
}

-(UIPreferencesTableCell *) preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group
{
	UIPreferencesTableCell * cell = [[UIPreferencesTableCell alloc] init];
	return [cell autorelease];
}

-(float) preferencesTable:(UIPreferencesTable *)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed
{
	return proposed;
}

-(BOOL) preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group
{
	return;
}

-(UIPreferencesTextTableCell *) preferencesTable:(UIPreferencesTable *)aTable cellForRow:(int)row inGroup:(int)group
{
	if(group == 0)
	{
		if(row == 0)
		{
			return username_cell;
		}
		else
		{
			return password_cell;
		}
	}
	else if(group == 1)
	{
		if(row == 0)
		{
			return server_cell;
		}
		else
		{
			return port_cell;
		}
	}
	else if(group == 2)
	{
		return delete_button;
	}
	return nil; 
 }

- (void)tableRowSelected:(NSNotification *)notification
{
	if([pref_table selectedRow] == 7)
	{
		// delete the user
		[[UserManager sharedInstance] removeUser:last_user_editing];
		
		[[ViewController sharedInstance] transitionToLoginViewWithEditActive:YES];
	}
}
@end
