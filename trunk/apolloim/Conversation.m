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

#import "Conversation.h"
#import <UIKit/UIApplication.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/CDStructures.h>
#import "ApolloTOC.h"
#import "ApolloIM-PrivateAccess.h"
#import "ShellKeyboard.h"
#import "Buddy.h"
#import "ConvoBox.h"

@implementation Conversation

	-(id)initWithFrame:(struct CGRect)frame withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate
	{
		if ((self == [super initWithFrame: frame]) != nil) 
		{	
			float lovelyShadeOfGreen[4] = {.1, .9, .1, 1};
			float lovelyShadeOfTransparent[4] = {0, 0, 0, 0};
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();				
			buddy = aBuddy;
			_rect = frame;
			_delegate = delegate;
			

			//sendField = [[UITextView alloc] initWithFrame:CGRectMake(_rect.origin.x, 450.0f, _rect.size.width - 50.0f, 30.0f)];	
			//sendField = [[UITextView alloc] initWithFrame:CGRectMake(_rect.origin.x + 15.0f, -6.0f, _rect.size.width - 70.0f, 10.0f)];
			sendField = [[SendBox alloc] initWithFrame:CGRectMake(15.0f, -6.0f, 320.0f - 70.0f,30.0f)];			
			[sendField setBackgroundColor: CGColorCreate( colorSpace, lovelyShadeOfTransparent)];	
			[sendField setDelegate: self];		
			
			convoView = [[ConvoBox alloc]initWithFrame:CGRectMake(_rect.origin.x,_rect.origin.y, _rect.size.width, 376.0f)];
			[convoView setDelegate: self];		

			keyboard = [[ShellKeyboard alloc]initWithFrame:CGRectMake(_rect.origin.x,450.0f, _rect.size.width, 300.0f)];
			[keyboard setTapDelegate: self];
			send = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
			//[send setFrame:CGRectMake(_rect.size.width-50.0f, 450.0f, 50.0f, 30.0f)];
			[send setFrame:CGRectMake(_rect.size.width - 76.0f + 15.0f, -3.0f, 64.0f, 30.0f)];			
			[send setDrawsShadow: YES];
			[send setEnabled:YES];
			[send setTitle:@"Send"];
			[send setStretchBackground:YES];
			[send setBackground:[UIImage applicationImageNamed:@"SendButton.png"] forState:0];
			[send setBackground:[UIImage applicationImageNamed:@"SendButtonPressed.png"] forState:1];
			[send addTarget:self action:@selector(sendMessage) forEvents:1];

			cell = [[UIImageAndTextTableCell alloc] init];
			[cell setImage:[UIImage applicationImageNamed: @"SendField.png"]];
			[cell addSubview:sendField];
			[cell addSubview:send];
			[cell setFrame:CGRectMake(-10.0f,380.0f, _rect.size.width, 30.0f)];
										
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
			[convoView setFrame:CGRectMake(_rect.origin.x,_rect.origin.y, _rect.size.width,  186.0f)];
			NSLog(@"Showing...");	
			_hidden = false;	
		}
		//[convoView scrollToEnd];
	}
	
	-(void)foldKeyboard
	{
		if(!_hidden)
		{
			[keyboard hide:sendField withCell:cell forConvoBox:convoView];
			[convoView setFrame:CGRectMake(_rect.origin.x,_rect.origin.y, _rect.size.width, 376.0f)];
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
	  NSLog(@"CONVERSATION>> Request for selector: %@", NSStringFromSelector(aSelector));
	  return [super respondsToSelector:aSelector];
	}
	
	-(void)recvMessage:(NSString*)msg;
	{
		//I am awesome
		[convoView setHTML:
		[[convoView HTML]stringByAppendingString:[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div>",[buddy name],msg]]];
		
		[convoView scrollToEnd];
		[convoView insertText:@""];		
		//[self play:receiveMessage];			
	}	
	
	- (void)sendMessage
	{
		[convoView setHTML:
		[[convoView HTML]stringByAppendingString:[NSString stringWithFormat:@"<div><font color=\"red\">%@</font>: %@</div>",[[ApolloTOC sharedInstance]userName],[sendField text]]]];
		[[ApolloTOC sharedInstance]sendIM:[sendField text] toUser:[buddy name]];
		[sendField setText:@""];
		
		[convoView scrollToEnd];
		[convoView insertText:@""];
	}
	
	- (void)recvInfo:(NSString*)info
	{
		[convoView setHTML:
		[[convoView HTML]stringByAppendingString:[NSString stringWithFormat:@"<div><font color=\"gray\">%@'s info:<div>%@</div></font></div>",[buddy name],info]]];
		[convoView scrollToEnd];
		[convoView insertText:@""];		
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
		NSLog(@"Buddy Info.");
		[[ApolloTOC sharedInstance]getInfo:buddy];
	}	
	
	-(void)dealloc
	{
		[super dealloc];
	}

@end
