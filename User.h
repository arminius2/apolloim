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

#import "Buddy.h"

#include "CONST.h"

//typedef enum {DISCONNECTED, CONNECTING, CONNECTED} ConnectionStatus;

@interface User : NSObject
{
	NSString * name;
	NSString * protocol;
	id protocol_interface;
	NSString * status_message;
	NSString * profile;
	BOOL away;
	BOOL active;
	
//	ConnectionStatus status;
	
	UserStatus status;

	NSMutableArray * buddy_list;
	BOOL new_user_editing;

	NSMutableDictionary * buddy_dict;
}

// Constructor
-(id) initWithName:(NSString *) aname andProtocol:(NSString *) aprotocol;

// Getters
-(NSString *) getName;
-(NSString *) getStatusMessage;
-(NSString *) getProfile;
-(NSString *) getProtocol;
-(id) getProtocolInterface;
-(BOOL) isAway;
-(Buddy *) getBuddyByName:(NSString *)name;

// Setters
-(void) setName:(NSString *) aname;
-(void) setStatusMessage:(NSString *) status;
-(void) setProfile:(NSString *) profile;
-(void) setAway:(BOOL) is_away;

// User Preferences
-(NSString *) getSettingForKey:(NSString *) key;
-(void)setSettingForKey: (NSString *) key andValue:(NSString *) value;

// Server Stuff
-(void) connect;
-(void) disconnect;

//buddies
-(NSMutableArray *) getBuddyList;
-(void) addBuddy:(NSString *) buddy_name;
-(void) removeBuddy:(Buddy *) abuddy;
-(void) removeAllBuddies;

-(UserStatus) getStatus;
-(void) setStatus:(UserStatus) astatus;
-(BOOL) isActive;
-(void) setActive:(BOOL) isactive;
-(void) sendMessage:(NSString *) msg toBuddy:(Buddy *) buddy;

-(NSString *) getID;

@end
