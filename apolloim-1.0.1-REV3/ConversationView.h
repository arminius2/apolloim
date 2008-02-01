/*
 ConversationView.m: the view for the conversation.
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
#import <UIKit/UITransitionView.h>
#import "Buddy.h"
#import "User.h"
#import "common.h"

@interface ConversationView : UIScroller {
	UITransitionView *_transitionView;
	CGRect _rect;	
	NSMutableArray *_conversation;
	float current_y;
	Buddy * _buddy;
	User * user;
	NSDate * last_stamp;
	struct __GSFont * event_font;
	struct __GSFont * chat_font;
}
- (id)initWithFrame:(struct CGRect)frame withOwner:(User *) aowner withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate;
- (void)dealloc;
- (BOOL)appendToConversation:(NSString *)text fromUser:(Buddy *)user isStatusMessage:(BOOL)status;
- (void)scrollToEnd;

@end
