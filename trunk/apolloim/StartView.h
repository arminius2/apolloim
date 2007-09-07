/*
 StartView.h: Objective-C firetalk interface.
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
#import <Message/NetworkController.h>
#import <UIKIt/UITextLabel.h>
#import "Acct.h"
#import "AccountsView.h"
#import "AccountEditorView.h"
#import "Buddy.h"
#import "BuddyView.h"
#import "ApolloCore.h"
#import "Shimmer.h"
#import "ApolloNotificationController.h"
#import "BuddyInfoView.h"
#import "PreferencesView.h"

@interface StartView : UIView 
{
	UINavigationBar		*_navBar;
	UITransitionView	*_transitionView;
	UINavigationItem 	*navtitle;
	CGRect				_rect;	
	CGRect				sub_views_rect;
	ApolloTOC			*conn;
	bool				EDGE;
	bool				okayToConnect;
	bool				connected;
	
//	AboutView			*_aboutView;
	AccountsView		*_accountsView;
	Acct				*CurrentAccount;
	AccountEditorView	*accountEditor;
	BuddyView			*_buddyView;
	Acct				*active;
	
	NSMutableArray		*_conversations;
	NSMutableArray		* buddyinfos;
	Buddy				*currentConversationBuddy;
	Conversation		*currentConversation;
	BuddyInfoView		*currentBuddyInfo;
	PreferencesView		*preferences;
		
	NSString			*prefFile;

	bool				_accountsViewBrowser;
	bool				_accountsEditorViewBrowser;	
	bool				_buddyViewBrowser;
	bool				_conversationView;
	bool				_about;			
	bool 				_buddyInfoView;
	bool				_prefView;
}

- (void)navigationBar:(UINavigationBar *)navbar buttonClicked:(int)button;
- (id)initWithFrame:(CGRect)frame;
- (void)imEvent:(NSMutableArray*)payload;
- (void)populatePreferences;

- (void)receiveMessage:(NSString*)msg fromBuddy:(Buddy*)aBuddy isInfo:(BOOL)info;
- (void)receiveInfo:(NSString*)msg fromBuddy:(Buddy*)aBuddy isInfo:(BOOL)info;
- (void)accountsView:(AccountsView *)acctView accountSelected:(Acct *)selectedAccount;
- (void)makeACoolMoveTo:(int)target;
- (void)checkForUpdates:(id)anObject;
- (void)closeActiveKeyboard;
- (void)dealloc;
-(void) resume;

@end

