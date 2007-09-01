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


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UINavigationItem.h>
#import <UIKit/UITransitionView.h>
#import "UIKIt/UITextLabel.h"
#import "Account.h"
//#import "AboutView.h"
#import "AccountsView.h"
#import "AccountEditorView.h"
#import "Buddy.h"
#import "BuddyView.h"
#import "ApolloTOC.h"

@interface StartView : UIView 
{
	UINavigationBar		*_navBar;
	UITransitionView	*_transitionView;
	UINavigationItem 	*navtitle;
	CGRect				_rect;	
	ApolloTOC			*conn;
	bool				EXIT;
	
//	AboutView			*_aboutView;
	AccountsView		*_accountsView;
	Account				*CurrentAccount;
	AccountEditorView	*accountEditor;
	BuddyView			*_buddyView;
	Account				*active;
	
	NSMutableArray		*_conversations;
	Buddy				*currentConversationBuddy;
	Conversation		*currentConversation;
		
	NSString			*prefFile;

	bool				_accountsViewBrowser;
	bool				_accountsEditorViewBrowser;	
	bool				_buddyViewBrowser;
	bool				_conversationView;
	bool				_about;			
}

- (void)navigationBar:(UINavigationBar *)navbar buttonClicked:(int)button;
- (id)initWithFrame:(CGRect)frame;
- (void)imEvent:(NSMutableArray*)payload;
- (void)populatePreferences;
- (void)receiveMessage:(NSString*)msg fromBuddy:(Buddy*)aBuddy isInfo:(BOOL)info;
- (void)accountsView:(AccountsView *)acctView accountSelected:(Account *)selectedAccount;
- (void)makeACoolMoveTo:(int)target;
-(void)checkForUpdates:(id)anObject;
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
	AIM_READ_MSGS		=   10,
	AIM_BUDDY_INFO		=	11	
};

