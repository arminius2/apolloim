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
#import <UIKit/UIView-Rendering.h>
#import <UIKit/UIWindow.h>
#import <UIKit/CDStructures.h>
//#import <UIKit/UIWebView.h>
#import "Buddy.h"
#import "ConvoBox.h"

@implementation Conversation

	-(id)initWithFrame:(struct CGRect)frame withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate
	{
		if ((self == [super initWithFrame: frame]) != nil) 
		{
			buddy = aBuddy;
			_rect = frame;
			_delegate = delegate;
			convoView = [[ConvoBox alloc]initWithFrame:CGRectMake(_rect.origin.x,_rect.origin.y, _rect.size.width, 360.0f)];
			[convoView setEditable:NO];
			[convoView setAllowsRubberBanding:YES];
			[convoView setOpaque:NO];
			[convoView setTextSize:14];

			float backcomponents[4] = {10, 10, 10, 10};	  
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			
			[self addSubview:convoView];
			_msgBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(_rect.origin.x, 360.0f, _rect.size.width, 70.0f)];			
			
			sendField = [[UITextField alloc] initWithFrame:CGRectMake(_rect.origin.x, 360.0f, _rect.size.width, 40.0f)];			
		
			keyboard = [[ShellKeyboard alloc] initWithFrame: CGRectMake(0.0f, 240.0, 320.0f, 480.0f)];
			[keyboard setTapDelegate:sendField];
			//[sendField setKeyboard:keyboard];
			//[self addSubView:keyboard];
			[self addSubview:sendField];
			//[self addSubview:_msgBar];
		}
		return self;
	}
	
	-(void)recvMessage:(NSString*)msg;
	{
		//I am awesome
	

		
	/*	[convoView setHTML:
		[
		[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div><hr>",[buddy name],msg]
		stringByAppendingString:[convoView HTML]
		]

		];*/

		[convoView setHTML:
		[[convoView HTML]stringByAppendingString:[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div>",[buddy name],msg]]];
		//[convoView repositionCaretToVisibleRect];
		[convoView scrollToEnd];	
	//	[UIApplication vibrateForDuration:2];
		//[convoView insertText:[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div>",[buddy name],msg]];
		[convoView insertText:@"\n"];
		//[convoView scrollToMakeCaretVisible:YES];	

	}	
	
	- (Buddy*)buddy
	{
		return buddy;
	}
	
	-(void)dealloc
	{
		[super dealloc];
	}

@end
