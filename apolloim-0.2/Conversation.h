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
#import <UIKit/UITextView.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import "ConversationView.h"
#import "SendBox.h"
#import "Buddy.h"
#import "User.h"
#import "Event.h"

@class ShellKeyboard;

@interface Conversation : UIView 
{
	UIImageAndTextTableCell* cell;
	UIImageView * top_bar;
	ConversationView* convoView;
	UINavigationBar *_msgBar;
	UIPushButton	*sendBtn;
	SendBox			*sendField;	
	ShellKeyboard	*keyboard;
	CGRect _rect;	
	Buddy* buddy;
	bool _hidden;	
	id _delegate;
	
	CGRect conv_rect_orig, conv_rect_keyboard;
	CGRect send_rect_orig, send_rect_keyboard;

	User * owner;

	UIPushButton * back_button;
	UIPushButton * close_button;
	UIPushButton * multi_button;
	
	bool introShown;

	Event * last_event;
}
- (id)initWithFrame:(struct CGRect)frame withOwner:(User *)aowner withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate;
- (void)rollKeyboard;	
- (void)foldKeyboard;
- (void)toggle;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (void)recvMessage:(NSString*)msg isStatusMessage:(BOOL)statusMessage;
- (void)sendMessage;
- (void)recvInfo:(NSString*)info;
- (Buddy*)buddy;
- (void)switchToMe;
- (SendBox*)sendField;
- (void)navigationBar:(UINavigationBar *)navbar buttonClicked:(int)button;
- (void)dealloc;
- (void)addTimeStamp;
@end
