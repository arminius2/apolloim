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
#import <UIKit/UIAnimator.h>

@interface Buddy : NSObject
{
	NSString * name;
	NSString * lookupName;
	NSString * alias;
	NSString * status_message;
	NSString * profile_content;
	NSString * group;
	NSString * safe_name;
	BOOL is_away;
	BOOL is_online;
	float idle_time;
	NSMutableArray * conversation;
	id * owner;
	BOOL is_conv_shown;
	int unread_msg_count;
}

// Constructor
-(id) initWithName:(NSString *) aname andGroup:(NSString *) group andOwner:(id) user;

// Getters
-(NSString *) getRawName;
-(NSString *) getName;
-(NSString *) getDisplayName;
-(NSString *) getSafeName;
-(NSString *) getStatusMessage;
-(NSString *) getProfile;
-(NSString *) getGroup;
-(id) getOwner;
-(int) getIdleTimeMinutes;
-(BOOL) isAway;
-(BOOL) isIdle;
-(BOOL) isConversationVisible;
-(BOOL) isOnline;
-(int) getMessageCount;
-(NSString *) getID;
-(void) clearMessageCount;

// Setters
-(void) setStatusMessage:(NSString *) status;
-(void) setProfile:(NSString *) profile;
-(void) setIdleTimeMinutes:(float) time;
-(void) setAway:(BOOL) isaway;
-(void) setAlias:(NSString*) PassedAlias;
-(void) setConversationVisible:(BOOL) is_visible;
-(void) messageCountIncrease;
-(void) setOnline:(BOOL) online;

@end
