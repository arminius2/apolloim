//
//  StartView.h
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITransitionView.h>
#import "UIKIt/UITextLabel.h"
#import "Account.h"
#import "AccountsView.h"
#import "AccountEditorView.h"
#import "Buddy.h"
#import "BuddyView.h"
#import "ApolloTOC.h"

@interface StartView : UIView 
{
	UINavigationBar		*_navBar;
	UITransitionView	*_transitionView;
	UITextLabel			*navtitle;
	CGRect				_rect;	
	ApolloTOC			*conn;
	bool				EXIT;
	
	AccountsView		*_accountsView;
	Account				*CurrentAccount;
	AccountEditorView	*accountEditor;
	BuddyView			*_buddyView;
	Account*			active;

	NSMutableArray		*_conversations;
	Buddy				*currentConversationBuddy;
	Conversation		*currentConversation;
		
	NSString			*prefFile;

	bool				_accountsViewBrowser;
	bool				_accountsEditorViewBrowser;	
	bool				_buddyViewBrowser;
	bool				_conversationView;
//	bool				_currentBuddyInfo;			
}

- (void)navigationBar:(UINavigationBar *)navbar buttonClicked:(int)button;
- (id)initWithFrame:(CGRect)frame;
- (void)imEvent:(NSMutableArray*)payload;
- (void)populatePreferences;
- (void)receiveMessage:(NSString*)msg fromBuddy:(Buddy*)aBuddy;
- (void)accountsView:(AccountsView *)acctView accountSelected:(Account *)selectedAccount;
- (void)makeACoolMoveTo:(int)target;
- (void)dealloc;

@end

enum {
	AIM_RECV_MESG		=	1,
	AIM_BUDDY_ONLINE	=	2, 
	AIM_BUDDY_OFFLINE	=	3, 
	AIM_BUDDY_AWAY		=	4, 
	AIM_BUDDY_UNAWAY	=	5,
	AIM_BUDDY_IDLE		=	6,	
	AIM_BUDDY_MSG_RECV	=   7,
	AIM_CONNECTED		=   8,
	AIM_DISCONNECTED	=	9,
	AIM_READ_MSGS		=   10
};
