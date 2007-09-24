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
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIImage.h>
#import <UIKit/UISwitchControl.h>
#import "common.h"

#import "BuddyCell.h"
#import "Event.h"
#import "ViewController.h"
#import "Conversation.h"

@implementation BuddyCell

-(id)initWithBuddy:(Buddy *) abuddy
{
	if ((self == [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, 39.0)]) != nil) 
	{
//		NSLog(@"BuddyCell: initializing cell");
	
		struct __GSFont * large_font = [NSClassFromString(@"WebFontCache") 
					createFontWithFamily:@"Helvetica" traits:2 size:16];
		struct __GSFont * small_font = [NSClassFromString(@"WebFontCache") 
					createFontWithFamily:@"Helvetica" traits:2 size:11];

		float white[4] = {1.0, 1.0, 1.0, 1.0};
		float transparent[4] = {0.0, 0.0, 0.0, 0.0};
		float grey[4] = {0.71, 0.71, 0.71, 1.0};
		float red[4] = {0.96, 0.35, 0.30, 1.0};
		float black[4] = {0.35, 0.35, 0.35, 1.0};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		[self setBackgroundColor:CGColorCreate(colorSpace, white)];

		buddy = abuddy;
		count = 0;

		status_onscreen = CGPointMake(10.0, 12.0);
		status_offscreen = CGPointMake(17.0+320, 12.0);

		user_with_message = CGPointMake(35.0, -7.0);
		user_no_message = CGPointMake(35.0, 1.0);

		// Conversation Images
		away_image_conv = [[UIImageView alloc] initWithFrame: CGRectMake(status_offscreen.x,
								status_offscreen.y, 13, 13)];
		[away_image_conv setImage:[UIImage applicationImageNamed: @"buddy_status_chat_away.png"]];
		
		idle_image_conv = [[UIImageView alloc] initWithFrame: CGRectMake(status_offscreen.x,
								status_offscreen.y, 13, 13)];
		[idle_image_conv setImage:[UIImage applicationImageNamed: @"buddy_status_chat_idle.png"]];
		
		active_image_conv = [[UIImageView alloc] initWithFrame: CGRectMake(status_onscreen.x,
								status_offscreen.y, 13, 13)];
		[active_image_conv setImage:[UIImage applicationImageNamed: @"buddy_status_chat_online.png"]];
		
		// No conversastion Images
		away_image = [[UIImageView alloc] initWithFrame: CGRectMake(status_offscreen.x,
								status_offscreen.y, 13, 13)];
		[away_image setImage:[UIImage applicationImageNamed: @"buddy_status_away.png"]];
		
		idle_image = [[UIImageView alloc] initWithFrame: CGRectMake(status_offscreen.x,
								status_offscreen.y, 13, 13)];
		[idle_image setImage:[UIImage applicationImageNamed: @"buddy_status_idle.png"]];
		
		active_image = [[UIImageView alloc] initWithFrame: CGRectMake(status_onscreen.x,
								status_offscreen.y, 13, 13)];
		[active_image setImage:[UIImage applicationImageNamed: @"buddy_status_online.png"]];
		
		buddy_label = [[UITextLabel alloc] initWithFrame: CGRectMake(35.0f, 80.0f, 180.f, 35.0f)];
//		[buddy_label setText: [buddy getName]];
		[buddy_label setText: [buddy getDisplayName]];
		[buddy_label setFont: large_font];
		[buddy_label setColor: CGColorCreate(colorSpace, black)];
		[buddy_label setBackgroundColor: CGColorCreate(colorSpace, transparent)];

//		NSLog(@"BuddyCell label initialized");

		away_message_label = [[UITextLabel alloc] initWithFrame: CGRectMake(35.0f, 13.0f, 220.f, 30.0f)];
		[away_message_label setText: @""];
		[away_message_label setFont: small_font];
		[away_message_label setBackgroundColor: CGColorCreate(colorSpace, transparent)];
		[away_message_label setColor: CGColorCreate(colorSpace, grey)];

		message_count = [[UITextLabel alloc] initWithFrame:CGRectMake([buddy_label textSize].width+35.0+15, 
						0, 70, 20)];
		[message_count setText:@""];
		[message_count setFont:small_font];
		[message_count setBackgroundColor: CGColorCreate(colorSpace, transparent)];
		[message_count setColor: CGColorCreate(colorSpace, red)];

		[self addSubview:buddy_label];
		[self addSubview:away_message_label];
		[self addSubview:active_image];
		[self addSubview:idle_image];
		[self addSubview:away_image];
		[self addSubview:active_image_conv];
		[self addSubview:idle_image_conv];
		[self addSubview:away_image_conv];
		[self addSubview:message_count];

//		NSLog(@"BuddyCell: Data Going to be Loaded");

		[self reloadData];

//		NSLog(@"BuddyCell: Data Reloaded");

		[[[buddy getOwner] getProtocolInterface] addEventListener:self];

//		NSLog(@"BuddyCell: initializing complete");
	}
	return self;
	
}

-(void)increaseUnreadCount
{
	[buddy messageCountIncrease];

	NSLog(@"Count: %i", [buddy getMessageCount]);

	[message_count needsDisplay];
	
	if(![buddy isConversationVisible])
		[message_count setText:[[NSString alloc]initWithFormat:@"(%d)",[buddy getMessageCount]]];
	
	[self needsDisplay];
}

-(void)setDeligate:(id) adeligate
{
}

- (BOOL) removeHTML:(NSMutableString *) from
{
	int del = 0;
	int i = 0;
	for(i; i< ([from length]); i++)
	{
		BOOL deleted = NO;
		if([from characterAtIndex: i] == '<')
			del ++;
			
		if(del > 0)
		{
			deleted = YES;
		}
		
		if([from characterAtIndex: i] == '>')
		{
			if(del > 0)
				del --;
		}
		
		if(deleted)
		{
			NSRange r = NSMakeRange(i, 1);
			[from deleteCharactersInRange: r];
			i--;
		}
	}
}


-(void) reloadData
{
	float black[4] = {0.0, 0.0, 0.0, 1.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

	[buddy_label setText: [buddy getDisplayName]];

	[away_image_conv setFrame: CGRectMake(status_offscreen.x,
				status_offscreen.y, 13, 13)];
	[idle_image_conv setFrame: CGRectMake(status_offscreen.x,
				status_offscreen.y, 13, 13)];
	[active_image_conv setFrame: CGRectMake(status_offscreen.x,
				status_offscreen.y, 13, 13)];
	[away_image setFrame: CGRectMake(status_offscreen.x,
				status_offscreen.y, 13, 13)];
	[idle_image setFrame: CGRectMake(status_offscreen.x,
				status_offscreen.y, 13, 13)];
	[active_image setFrame: CGRectMake(status_offscreen.x,
				status_offscreen.y, 13, 13)];
		
	
	if([[ViewController sharedInstance] conversationWithBuddyExists:buddy])
	{
		if([buddy isAway])
		{
			[away_image_conv setFrame: CGRectMake(status_onscreen.x,
					status_onscreen.y, 13, 13)];
		}
		else if([buddy isIdle])
		{
			[idle_image_conv setFrame: CGRectMake(status_onscreen.x,
					status_onscreen.y, 13, 13)];
		}
		else
		{
			[active_image_conv setFrame: CGRectMake(status_onscreen.x,
					status_onscreen.y, 13, 13)];
		}
	}
	else
	{
		if([buddy isAway])
		{
			[away_image setFrame: CGRectMake(status_onscreen.x,
					status_onscreen.y, 13, 13)];
		}
		else if([buddy isIdle])
		{
			[idle_image setFrame: CGRectMake(status_onscreen.x,
					status_onscreen.y, 13, 13)];
		}
		else
		{
			[active_image setFrame: CGRectMake(status_onscreen.x,
					status_onscreen.y, 13, 13)];
		}
	}

//	NSLog(@"Cell Updating Status Message: '%@'", [buddy getStatusMessage]);

	if(!([[buddy getStatusMessage] isEqualToString:@" "] || [[buddy getStatusMessage] isEqualToString:@"  "]))
	{
		[buddy_label setFrame: CGRectMake(user_with_message.x,
						user_with_message.y, 
						180.0f, 35.0f)];
		[message_count setFrame:CGRectMake(user_with_message.x+[buddy_label textSize].width+5,
						user_with_message.y+10,
						100.0f, 15.0f)];
		if([buddy isIdle])
		{
			NSMutableString * msg = [NSString 
					stringWithFormat:@"Idle %i minutes : %@", 
					[buddy getIdleTimeMinutes], [buddy getStatusMessage]];
			[away_message_label setText:msg];
		}
		else
		{
			int threshold = 25;
			NSMutableString * msg = [NSMutableString stringWithString:[buddy getStatusMessage]];
			[self removeHTML:msg];
			[away_message_label setText:msg];
		}
	}
	else
	{
		[buddy_label setFrame: CGRectMake(user_no_message.x,
						user_no_message.y, 
						180.f, 35.0f)];
		[message_count setFrame:CGRectMake(user_no_message.x+[buddy_label textSize].width+5,
						user_no_message.y+10,
						100.0f, 15.0f)];
		[away_message_label setText:@""];
	}
	
	if([buddy isConversationVisible])
		[message_count setText:@""];

	[away_message_label needsDisplay];
	[buddy_label needsDisplay];
	[self needsDisplay];
}

-(void) respondToEvent:(Event *) event
{
	int i;
	if(([event getType] == DISCONNECT) && ([[[event getOwner]getName]isEqualToString:[[buddy getOwner]getName]]))
	//if(([event getType] == DISCONNECT) && ([event getOwner] == [buddy getOwner]))
	{
		[buddy clearMessageCount];
		[message_count setText:@""];
		[[[buddy getOwner] getProtocolInterface] removeEventListener:self];
		//WE NEED TO DEALLOC BUT WE HAVENT
		NSLog(@"RECEIVED DISCONNECT");
	}
	
	if(([event getType] == BUDDY_MESSAGE) 
	&& ([[[event getBuddy]getSafeName]isEqualToString:[buddy getSafeName]])
	&& ([[[event getOwner]getName]isEqualToString:[[buddy getOwner]getName]]))
	{
		// Craete a conversation if one does not exist
						
		id * conv = [[ViewController sharedInstance] createConversationWith:buddy];
					
		// A new one was created, the event must be relayed to it
		if(conv)
		{
			//[conv respondToEvent:event];
		}
		
		NSLog(@"INCREASING UNREADCOUNT");
		if(![buddy isConversationVisible])
			[self increaseUnreadCount];
			
		[self reloadData];
	}
	if(([event getType] == BUDDY_STATUS) && ([[[event getBuddy]getSafeName]isEqualToString:[buddy getSafeName]]))
	{
///		NSLog(@"NEW STATUS MESSAGE FOR %@ THAT IS '%@'",[[event getBuddy] getName], [[event getBuddy] getStatusMessage]);

		if(![[[event getBuddy]getStatusMessage]isEqualToString:[buddy getStatusMessage]])
			[buddy setStatusMessage:[[event getBuddy]getStatusMessage]];

//		if([buddy isAway]!=[[event getBuddy]isAway])
		NSLog(@"STATUS CHANGE FOR %@: WAS %d COULD BE %d now",[[event getBuddy] getName],[buddy isAway],[[event getBuddy] isAway]);
		[buddy setAway:[[event getBuddy]isAway]];
		[self reloadData];
	}
}

@end
