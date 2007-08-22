//
//  Conversation.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Conversation.h"
#import "UIKit/UIPreferencesTable.h"
#import "UIKit/UIPreferencesTableCell.h"
#import "UIKit/UIPreferencesTextTableCell.h"
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Rendering.h>
#import "UIKit/UISwitchControl.h"
#import <UIKit/UIWindow.h>
#import <UIKit/CDStructures.h>
#import "Buddy.h"

@implementation Conversation

	-(id)initWithFrame:(struct CGRect)frame withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate
	{
		if ((self == [super initWithFrame: frame]) != nil) 
		{
			buddy = aBuddy;
//			rect = frame;
			_delegate = delegate;
			convoView = [[UITextView alloc]initWithFrame:frame];
			[convoView setEditable:NO];
			[convoView setAllowsRubberBanding:YES];
			[convoView displayScrollerIndicators];
			[convoView setOpaque:NO];
			[self addSubview:convoView];			
		}
		return self;
	}
	
	-(void)recvMessage:(NSString*)msg;
	{
		//I am awesome
//		[[convoView _webView] insertText: @"THIS IS TEXT"];
		[convoView setHTML:
		[[convoView HTML]stringByAppendingString:[NSString stringWithFormat:@"<div><font color=\"blue\">%@</font>: %@</div>",[buddy name],msg]]];
		
//		NSLog(@"%@ >> %@", [buddy name], msg);
//		NSLog(@"%@ Convo Dump> %@", [buddy name], [convoView text]);
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
