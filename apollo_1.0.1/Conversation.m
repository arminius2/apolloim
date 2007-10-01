/*
 ApolloTOC.m: Objective-C firetalk interface.
 By Alex C. Schaefer, Adam Bellmore

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

#import "Conversation.h"
#import <UIKit/UIApplication.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIBox.h>

#import "ShellKeyboard.h"
#import "Buddy.h"
#import "ConversationView.h"
#import "Event.h"
#import "ViewController.h"
#import "ApolloNotificationController.h"

@implementation Conversation

-(id)initWithFrame:(struct CGRect)frame withOwner:(User*)aowner withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate
{
	float send_view_height = 22.0+23.0;
	float send_text_width = frame.size.width;
	float left_buf = 0.03 * frame.size.width;
	float send_button_width = frame.size.width - (left_buf+send_text_width+left_buf);
	float kb_height = 215.0f;
		
	if ((self == [super initWithFrame: frame]) != nil) 
	{	
		float lovelyShadeOfGreen[4] = {.1, .9, .1, 1};
		float lovelyShadeOfTransparent[4] = {0, 0, 0, 0};
		float black[4] = {0.0, 0.0, 0.0, 1.0};
		float white[4] = {1.0, 1.0, 1.0, 1.0};
		float dark_grey[4] = {0.1, 0.1, 0.1, 1.0};
		float bg_color[4] = {1.0, 1.0, 1.0, 1.0};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

		UIBox * bg_box = [[UIBox alloc] initWithFrame:frame];			
		[bg_box setBackgroundColor:CGColorCreate(colorSpace, bg_color)];
		[self addSubview:bg_box];
			
		name_font = [NSClassFromString(@"WebFontCache") 
						createFontWithFamily:@"Helvetica" traits:0 size:14];
			
		buddy = aBuddy;
		_rect = frame;
		_delegate = delegate;
		owner = aowner;
		is_empty = YES;

		buddy_bar = [[UIImageView alloc] initWithFrame:CGRectMake(0,46,320, 22)];
		[buddy_bar setImage:[UIImage applicationImageNamed:@"chat_name_background.png"]];

		buddy_name = [[UITextLabel alloc] initWithFrame:CGRectMake(5,0,315, 22)];
		[buddy_name setFont:name_font];
		[buddy_name setText:[buddy getDisplayName]];
		[buddy_name setColor:CGColorCreate(colorSpace, dark_grey)];
		[buddy_name setBackgroundColor:CGColorCreate(colorSpace, lovelyShadeOfTransparent)];
		[buddy_name setShadowColor:CGColorCreate(colorSpace, white)];
		[buddy_name setShadowOffset:CGSizeMake(0,1)];

		[buddy_bar addSubview:buddy_name];
	
		[[owner getProtocolInterface] addEventListener:self];
		
		top_bar = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 64.0f)];
		[top_bar setImage:[UIImage applicationImageNamed: @"buddy_topnav_background.png"]];

		// Set up the conversation box first
		conv_rect_orig = CGRectMake(_rect.origin.x,_rect.origin.y+46, 
								_rect.size.width, _rect.size.height-(send_view_height+46));
		conv_rect_keyboard = CGRectMake(_rect.origin.x,_rect.origin.y+46, 
									_rect.size.width, _rect.size.height-(send_view_height+kb_height+46));
		convoView = [[ConversationView alloc]
				initWithFrame: conv_rect_orig
				withOwner: owner
				withBuddy: aBuddy
				andDelegate: self];
				
		// Set up the keyboard
		keyboard = [[ShellKeyboard alloc]initWithFrame:CGRectMake(_rect.origin.x,480.0f, _rect.size.width, 300.0f)];
		[keyboard setTapDelegate: self];

		// Set up the send box
		CGRect line_rect = CGRectMake(0,0, _rect.size.width, 1);
		UIBox * bg_line = [[UIBox alloc] initWithFrame:line_rect];
		[bg_line setBackgroundColor: CGColorCreate(colorSpace, black)];

		CGRect bg_rect = CGRectMake(0, 0, _rect.size.width, send_view_height);
		UIBox * send_bg = [[UIBox alloc] initWithFrame:bg_rect];
		[send_bg addSubview:bg_line];
		
		sendField = [[SendBox alloc] initWithFrame:CGRectMake(left_buf, 8.0f, 
					send_text_width - (2 * left_buf), 3 * 24)
					withConversation:self];			
		[sendField setBackgroundColor: CGColorCreate(colorSpace, lovelyShadeOfTransparent)];
		[sendField setDelegate: self];
		[sendField becomeFirstResponder];
		[sendField setTextSize: 13];

		send_rect_orig = CGRectMake(0.0, 
								_rect.size.height - send_view_height, 
								_rect.size.width, 
								send_view_height);
		send_rect_keyboard = CGRectMake(0.0, 
								_rect.size.height - (send_view_height+kb_height), 
								_rect.size.width, 
								send_view_height);
		cell = [[UIImageAndTextTableCell alloc] init];

		send_top= [[UIImageView alloc] initWithFrame:
					 CGRectMake(0.0f, 0.0, 320.0f, 23.0f)];
		[send_top setImage:[UIImage applicationImageNamed: @"chat_textentry_top.png"]];

		send_middle= [[UIPushButton alloc] init];
		[send_middle setImage:[UIImage applicationImageNamed: @"chat_textentry_middle.png"]];
		[send_middle setFrame:CGRectMake(0.0f, 0.0, 320.0f, 0.0f)];

		send_bot= [[UIImageView alloc] initWithFrame:
					 CGRectMake(0.0f, 23.0, 320.0f, 22.0f)];
		[send_bot setImage:[UIImage applicationImageNamed: @"chat_textentry_bottom.png"]];

		[cell setFrame:send_rect_orig];

		[cell addSubview:send_bg];
		[cell addSubview:send_middle];
		[cell addSubview:send_top];
		[cell addSubview:send_bot];
		[cell addSubview:sendBtn];
		[cell addSubview:sendField];

		back_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
		[back_button setFrame:CGRectMake(5.0, 7.0, 84.0, 32.0)];
		[back_button setImage: [UIImage applicationImageNamed: @"chat_buddybutton_up.png"]
					forState: 0];
		[back_button setImage: [UIImage applicationImageNamed: @"chat_buddybutton_down.png"]
					forState: 1];
		[back_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
									
		close_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
		[close_button setFrame:CGRectMake(320.0 - (32.0+5.0), 7.0, 34.0, 32.0)];
		[close_button setImage: [UIImage applicationImageNamed: @"chat_closebutton_up.png"]
					forState: 0];
		[close_button setImage: [UIImage applicationImageNamed: @"chat_closebutton_down.png"]
					forState: 1];
		[close_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
									
		[self addSubview: convoView];
		[self addSubview: cell];
		[self addSubview: keyboard];

		[self addSubview: top_bar];
		[self addSubview: back_button];
		[self addSubview: close_button];

		[self addSubview: buddy_bar];
		
		//[self addSubview: sendField];
		_hidden = true;
		introShown = NO;
			
	}
	return self;
}
	
	-(void)rollKeyboard
	{
		if(_hidden)
		{
			[keyboard show:sendField withCell:cell forConvoBox:convoView];
			[convoView setFrame:conv_rect_keyboard];
			[cell setFrame:send_rect_keyboard];
			NSLog(@"Showing...");	
			_hidden = false;	
		}
		[convoView scrollToEnd];
	}
	
	-(void)foldKeyboard
	{
		if(!_hidden)
		{
			[keyboard hide:sendField withCell:cell forConvoBox:convoView];
			[convoView setFrame:conv_rect_orig];
			[cell setFrame:send_rect_orig];
			NSLog(@"Hiding...");
			_hidden = true;
			[convoView scrollToEnd];		
		}
	}
	
	-(void)toggle
	{
		if(_hidden)
			[self rollKeyboard];
			else
			[self foldKeyboard];	
	}
	
	- (BOOL)respondsToSelector:(SEL)aSelector
	{
	  return [super respondsToSelector:aSelector];
	}
	
	-(void)recvMessage:(NSString*)msg isStatusMessage:(BOOL)statusMessage
	{
		if(![buddy isConversationVisible])
		{
			if(!introShown)
			{
				[[ViewController sharedInstance] showNewMessageFrom:[buddy getDisplayName] withMessage:msg];
				introShown=YES;
			}
			[[ApolloNotificationController sharedInstance]receiveUnreadMessages:1];		
			[[ApolloNotificationController sharedInstance]playRecvIm];
		}
			
		if(statusMessage)
		{
			[convoView addStatusMessage:msg fromUser:buddy];
		}
		else
		{
			is_empty = NO;
			[convoView appendToConversation:msg fromUser:buddy];
		}
	}	
	
	- (void)sendMessage
	{
		//Fix for crash if empty
		if(![[sendField text]isEqualToString:@""])
		{
			[convoView appendToConversation:[sendField text] fromUser:nil];
			[owner sendMessage:[sendField text] toBuddy:buddy];
			[sendField setText:@""];
			is_empty = NO;
		}
	}
	
	- (void)recvInfo:(NSString*)info
	{
		//[convoView appendToConversation:sendField fromUser:nil];	
	}
	
	- (Buddy*)buddy
	{
		return buddy;
	}
	- (SendBox*)sendField;
	{
		return sendField;
	}	
	
	- (void)switchToMe
	{
		[sendField becomeFirstResponder];
	}
	
	-(void)dealloc
	{
		[[owner getProtocolInterface] removeEventListener:self];
		[super dealloc];
	}

	-(void) respondToEvent:(Event *) event
	{
		// Make sure its not a double event
		// sometimes happens when they are initialized
		if(event == last_event)
			return;

		if([event getType] == BUDDY_MESSAGE)
		{
			if([event getContent]!=NULL 
				&& [[[event getBuddy]getSafeName]isEqualToString:[buddy getSafeName]]
				&& [[[event getOwner]getID]isEqualToString:[[buddy getOwner]getID]])
				[self recvMessage:[event getContent] isStatusMessage:NO];
		}

		if([event getType] == BUDDY_STATUS)
		{
			//if([event getBuddy] == buddy)
			//	[self recvMessage:[[event getOwner] getStatusMessage] isStatusMessage:YES];
		}

		event = last_event;
	}

- (void) buttonEvent:(UIPushButton *)button 
{
	if (![button isPressed] && [button isHighlighted])
	{
		if((button == close_button) || (button == back_button && is_empty))
		{
			[[ViewController sharedInstance] closeConversationWith: buddy];
			[[ViewController sharedInstance] transitionToBuddyListView];
		}
		else if(button == back_button)
		{
			[[ViewController sharedInstance] transitionToBuddyListView];
		}
	}
}

- (void)addTimeStamp
{
	[convoView addTimeStamp];
}

-(unsigned int) becomeFirstResponder
{
	NSLog(@"Conversation became forground: %@", [buddy getName]);
	[[ApolloNotificationController sharedInstance] switchToConvoWithMsgs:[buddy getMessageCount]];	
	
	[buddy setConversationVisible:YES];
	return [super becomeFirstResponder];
}

- (BOOL) resignFirstResponder
{
	NSLog(@"Conversation lost forground: %@", [buddy getName]);
	[buddy setConversationVisible:NO];
	return [super resignFirstResponder];
}

- (void)resizeInputArea
{
	CGRect doc_box = [sendField visibleTextRect];

	NSLog(@"Doc Rect: (%f, %f, %f, %f)", doc_box.origin.x, doc_box.origin.y, doc_box.size.width, doc_box.size.height);

}
@end
