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
			convoView = [[ConvoBox alloc]initWithFrame:CGRectMake(_rect.origin.x,_rect.origin.y, _rect.size.width, 380.0f)];
			[convoView setEditable:NO];
			[convoView setAllowsRubberBanding:YES];
			[convoView setOpaque:NO];
			[convoView setTextSize:14];
			
			[self addSubview:convoView];
			_msgBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(_rect.origin.x, 380.0f, _rect.size.width, 50.0f)];			
			sendField = [[UITextField alloc] initWithFrame:CGRectMake(0,0,_rect.size.width,30.0f)];			
			[_msgBar addSubview:sendField];
			[self addSubview:_msgBar];			
		}
		return self;
	}
	
	-(void)recvMessage:(NSString*)msg;
	{
		//I am awesome
		[convoView scrollToMakeCaretVisible:YES];		
		[convoView repositionCaretToVisibleRect];
		
	/*	[convoView setHTML:
		[
		[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div><hr>",[buddy name],msg]
		stringByAppendingString:[convoView HTML]
		]

		];*/
//		[UIApplication vibrateForDuration:2];
//		[convoView setHTML:
//		[[convoView HTML]stringByAppendingString:[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div>",[buddy name],msg]]];
	
		[convoBox insertText:[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div>",[buddy name],msg]];
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
