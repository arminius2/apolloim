//
//  AccountsView.h
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITransitionView.h>
#import "ShellKeyboard.h"
#import "Buddy.h"

@interface Conversation : UIView 
{
	UITextView* convoView;
	UITextField* sendField;
	UINavigationBar *_msgBar;
	UITransitionView *_transitionView;
    CGRect _rect;	
	Buddy* buddy;

	NSMutableArray *_accounts;
	id _delegate;
	
	
}
- (id)initWithFrame:(struct CGRect)frame withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate;
- (void)recvMessage:(NSString*)msg;
- (Buddy*)buddy;
- (void)dealloc;
@end
