//
//  Conversation.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Conversation.h"
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Rendering.h>
#import <UIKit/UIWindow.h>
#import <UIKit/CDStructures.h>
//#import <UIKit/UIWebView.h>


#import "Buddy.h"

@implementation Conversation

	-(id)initWithFrame:(struct CGRect)frame withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate
	{
		if ((self == [super initWithFrame: frame]) != nil) 
		{
			buddy = aBuddy;
			_rect = frame;
			_delegate = delegate;
			convoView = [[UITextView alloc]initWithFrame:frame];
			[convoView setEditable:NO];
			[convoView setAllowsRubberBanding:YES];
			[convoView setOpaque:NO];
			[convoView setTextSize:14];
			
			[self addSubview:convoView];			
			_msgBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(_rect.origin.x, 390.0f, _rect.size.width, 50.0f)];			
			sendField = [[UITextField alloc] initWithFrame:CGRectMake(0,0,_rect.size.width,30.0f)];			
			[_msgBar addSubview:sendField];
			[self addSubview:_msgBar];			
		}
		return self;
	}
	
	-(void)recvMessage:(NSString*)msg;
	{
		//I am awesome
		[convoView setHTML:
		[[convoView HTML]stringByAppendingString:[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div>",[buddy name],msg]]];
		CGSize fullSize = [convoView contentSize];
		[convoView scrollRectToVisible:CGRectMake(0.0f, fullSize.height - 20.0f,320.0f, fullSize.height) animated: YES];

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
