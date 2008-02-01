/*
 By Adam Bellmore

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
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIImage.h>
#import <UIKit/UITextView.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView.h>

#import "User.h"
#import "Conversation.h"
#import "BuddyListView.h"
#import "AccountEditView.h"
#import "LoginView.h"
#import "common.h"

@interface ViewController : UIView
{
	UIWindow * window;
	UITransitionView * transition;
	CGRect frame;

	UIAlertSheet *connectSheet;

	LoginView * login_view;
	BuddyListView * buddy_list_view;
	AccountEditView * account_edit_view;

	UIView * current_view;
	UIView * prev_view;
//	NSMutableArray * buddy_conversations;
	NSMutableDictionary*	buddy_conversations;
	
	bool connecting;

	UIBox * blank;
}

-(id) initWithFrame:(CGRect) frame;
-(void) transitionTo:(UIView *) view slideDirection:(int) style;
-(CGRect) getFrame;
-(void) transitionToLoginView;
-(void) transitionToAccountEditView;
-(void) transitionToAccountEditViewWithUser:(User *) user;
-(void) transitionToBuddyListView;
-(void) transitionToConversationWith:(Buddy *) buddy;
-(Conversation *) createConversationWith:(Buddy *) buddy;
-(void) closeConversationWith:(Buddy *) buddy;
-(void) showError:(NSString *) error;
-(void) transitionOnResume;

-(void) showNewMessageFrom:(NSString*)dude withMessage:(NSString*)groovy;
-(void) connectionFailureFor:(NSString*)account withMessage:(NSString*)message isDisconnect:(bool)maybe;
-(void) connectStep:(int)step forAccount:(NSString*)account withMessage:(NSString*)message connected:(bool)status;
-(BOOL) isAtLoginView;

+(id) initSharedInstanceWithFrame:(CGRect) win;
+(id) sharedInstance;
-(void)fullDisconnect;
- (NSString*) removeHTML:(NSMutableString *) from;
@end
