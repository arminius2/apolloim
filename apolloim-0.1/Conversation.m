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
#import "ApolloTOC.h"
#import "ApolloIM-PrivateAccess.h"
#import "ShellKeyboard.h"
#import "Buddy.h"
#import "ConversationView.h"

@implementation Conversation

	-(id)initWithFrame:(struct CGRect)frame withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate
	{
		float send_view_height = 30.0f;
		float send_text_width = 0.8f * frame.size.width;
		float left_buf = 0.03 * frame.size.width;
		float send_button_width = frame.size.width - (left_buf+send_text_width+left_buf);
		float kb_height = 215.0f;
		
		NSLog(@"Creating Conversation with dimensions(%f, %f, %f, %f)", frame.origin.x, frame.origin.y,
				frame.size.width, frame.size.height);
		if ((self == [super initWithFrame: frame]) != nil) 
		{	
			float lovelyShadeOfGreen[4] = {.1, .9, .1, 1};
			float lovelyShadeOfTransparent[4] = {0, 0, 0, 0};
			float black[4] = {0.0, 0.0, 0.0, 1.0};
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();				
			buddy = aBuddy;
			_rect = frame;
			_delegate = delegate;
			
			// Set up the conversation box first
			conv_rect_orig = CGRectMake(_rect.origin.x,_rect.origin.y, 
									_rect.size.width, _rect.size.height-send_view_height);
			conv_rect_keyboard = CGRectMake(_rect.origin.x,_rect.origin.y, 
									_rect.size.width, _rect.size.height-(send_view_height+kb_height));
			convoView = [[ConversationView alloc]
					initWithFrame: conv_rect_orig
					withBuddy: aBuddy
					andDelegate: self];
					
			// Set up the keyboard
			keyboard = [[ShellKeyboard alloc]initWithFrame:CGRectMake(_rect.origin.x,450.0f, _rect.size.width, 300.0f)];
			[keyboard setTapDelegate: self];

			// Set up the send box
			CGRect line_rect = CGRectMake(0,0, _rect.size.width, 1);
			UIBox * bg_line = [[UIBox alloc] initWithFrame:line_rect];
			[bg_line setBackgroundColor: CGColorCreate(colorSpace, black)];

			CGRect bg_rect = CGRectMake(0, 0, _rect.size.width, send_view_height);
			UIBox * send_bg = [[UIBox alloc] initWithFrame:bg_rect];
			[send_bg addSubview:bg_line];
			
			sendField = [[SendBox alloc] initWithFrame:CGRectMake(left_buf, 0.0f, 
										send_text_width, send_view_height)];			
			[sendField setBackgroundColor: CGColorCreate(colorSpace, lovelyShadeOfTransparent)];	
			[sendField setDelegate: self];
			[sendField becomeFirstResponder];

			sendBtn = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
			[sendBtn setFrame:CGRectMake(left_buf+send_text_width+left_buf, 0.0f, 
									send_button_width, send_view_height)];			
			[sendBtn setDrawsShadow: YES];
			[sendBtn setEnabled:YES];
			[sendBtn setTitle:@"Send"];
			[sendBtn setStretchBackground:YES];
			[sendBtn setTitleColor: CGColorCreate(colorSpace, black)];
			[sendBtn addTarget:self action:@selector(sendMessage) forEvents:1];

			send_rect_orig = CGRectMake(0.0, 
									_rect.size.height - send_view_height, 
									_rect.size.width, 
									send_view_height);
			send_rect_keyboard = CGRectMake(0.0, 
									_rect.size.height - (send_view_height+kb_height), 
									_rect.size.width, 
									send_view_height);
			cell = [[UIImageAndTextTableCell alloc] init];
			[cell setFrame:send_rect_orig];
			[cell addSubview:send_bg];
			[cell addSubview:sendBtn];
			[cell addSubview:sendField];
										
			//_msgBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(_rect.origin.x, 380.0f, _rect.size.width, 30.0f)];
			//[_msgBar setDelegate: self];
			//[_msgBar showButtonsWithLeftTitle:@"Buddy Info" rightTitle:nil leftBack: NO];
			//[_msgBar enableAnimation];							
			//[_msgBar setBarStyle:2];					

			[self addSubview: convoView];
			[self addSubview: cell];
			[self addSubview: keyboard];		
			_hidden = true;

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
//	  NSLog(@"CONVERSATION>> Request for selector: %@", NSStringFromSelector(aSelector));
	  return [super respondsToSelector:aSelector];
	}
	
	-(void)recvMessage:(NSString*)msg isStatusMessage:(BOOL)statusMessage
	{
		[convoView appendToConversation:msg fromUser:buddy  isStatusMessage:statusMessage];
		/*
		//I am awesome
		[convoView setHTML:
		[[convoView HTML]stringByAppendingString:[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div>",[buddy name],msg]]];
		
		[convoView scrollToEnd];
		[convoView insertText:@""];		
		//[self play:receiveMessage];			
		*/
	}	
	
	- (void)sendMessage
	{
		//Fix for crash if empty
		if(![[sendField text]isEqualToString:@""])
		{
			[convoView appendToConversation:[sendField text] fromUser:nil isStatusMessage:NO];
			[[ApolloTOC sharedInstance]sendIM:[sendField text] toUser:[buddy name]];
			[sendField setText:@""];
			[[ApolloNotificationController sharedInstance]playSendIm];			
		}
	}
	
	- (void)recvInfo:(NSString*)info
	{
		[convoView appendToConversation:sendField fromUser:nil];	
	}
	
	- (Buddy*)buddy
	{
		return buddy;
	}
	- (SendBox*)sendField;
	{
		return sendField;
	}	
	
	- (void)navigationBar:(UINavigationBar *)navbar buttonClicked:(int)button 
	{
//		NSLog(@"Buddy Info.");
//		[[ApolloTOC sharedInstance]getInfo:buddy];
	}	
	
	-(void)dealloc
	{
		[super dealloc];
	}

@end
