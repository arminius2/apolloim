//
//  Conversation.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/19/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Conversation.h"


@implementation Conversation
{
	- (id)initWithFrame:(struct CGRect)frame withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate
	{
		if ((self == [super initWithFrame: frame]) != nil) 
		{
			buddy = aBuddy;
			rect = frame;
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
	- (void)addMessage:(NSString*)msg;
	{
		[convoView insertText:[msg stringByAppendingString:@"<br/><br/>"]];
	}
}
@end
