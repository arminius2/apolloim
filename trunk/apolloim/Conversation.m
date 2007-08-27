//
//  Conversation.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

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
			sendField = [[UITextView alloc] initWithFrame:CGRectMake(15.0f, -6.0f, 320.0f - 70.0f, 10.0f)];			
			[sendField setBackgroundColor: CGColorCreate( colorSpace, lovelyShadeOfTransparent)];
			[sendField setEditable:YES];		
			[sendField setTextSize:14];			
			[sendField setAlpha:50];			
			
			convoView = [[ConvoBox alloc]initWithFrame:CGRectMake(_rect.origin.x,_rect.origin.y, _rect.size.width,  _rect.size.height - 30.0f)];
			//[convoView setDelegate: self];  //This might not work, and I'm expecting it as such

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
			[cell setImage:[UIImage applicationImageNamed: @"Default.png"]];
			[cell addSubview:sendField];
			[cell addSubview:send];
			[cell setFrame:CGRectMake(0.0f,450.0f, _rect.size.width, 30.0f)];
										
			_msgBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(_rect.origin.x, 380.0f, _rect.size.width, 30.0f)];
			[_msgBar setDelegate: self];
			//[_msgBar showButtonsWithLeftTitle:@"Buddy Info" rightTitle:nil leftBack: NO];
			[_msgBar enableAnimation];							
			[_msgBar setBarStyle:2];					
																				
			[self addSubview: convoView];
		//	[self addSubview: _msgBar];
			[self addSubview: cell];					
			[self addSubview: keyboard];
	//		[self addSubview: sendField];
	//		[self addSubview: send];
			[self foldKeyboard];			
		}
		return self;
	}
	
	-(void)rollKeyboard
	{	
		[keyboard show:sendField withCell:cell];
		[convoView setFrame:CGRectMake(_rect.origin.x,_rect.origin.y, _rect.size.width,  (((_rect.size.height / 2) - 20.0f)/* + 30.0f*/))];
		_hidden = false;
		NSLog(@"Showing...");
		[convoView setEditable:NO];				
	}
	
	-(void)foldKeyboard
	{
		[keyboard hide:sendField withCell:cell];
		[convoView setFrame:CGRectMake(_rect.origin.x,_rect.origin.y, _rect.size.width,  (((_rect.size.height * 2) + 20.0f)/* - 30.0f*/ ))];
		NSLog(@"Hiding...");
		_hidden = true;
		
	}
	
	-(void)toggle
	{
		if(_hidden)
			[self rollKeyboard];
			else
			[self foldKeyboard];	
	}
	
/*	- (BOOL)respondsToSelector:(SEL)aSelector
	{
	  NSLog(@"Request for selector: %@", NSStringFromSelector(aSelector));
	  return [super respondsToSelector:aSelector];
	}*/
	
	-(void)recvMessage:(NSString*)msg;
	{
		//I am awesome
		[convoView setHTML:
		[[convoView HTML]stringByAppendingString:[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div>",[buddy name],msg]]];
		[convoView scrollToEnd];	
		[convoView insertText:@""];
		[convoView setEditable:NO];				
	}	
	
	- (void)sendMessage
	{
		[convoView setHTML:
		[[convoView HTML]stringByAppendingString:[NSString stringWithFormat:@"<div><font color=\"red\">%@</font>: %@</div>",[[ApolloTOC sharedInstance]userName],[sendField text]]]];
		[[ApolloTOC sharedInstance]sendIM:[sendField text] toUser:[buddy name]];
		[convoView scrollToEnd];
		[convoView insertText:@""];		
		[convoView setEditable:NO];
		[sendField setText:@""];
	}
	
	- (Buddy*)buddy
	{
		return buddy;
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
