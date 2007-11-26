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
#import "User.h"
#import "ProtocolInterface.h"
#import "Buddy.h"
#import "Event.h"

@interface TestInterface : NSObject <ProtocolInterface>
{
	User * user;
	NSMutableArray * buddylist;
	BOOL online;

	NSMutableArray * listeners;
}

-(id) init;
-(void) logIn:(User *) auser;
-(void) logOut:(User *) auser;
-(BOOL) addEventListener:(id) el;
-(void) removeEventListener:(id) el;
-(void) performBuddyUpdate:(NSString *) buddy_name;
-(void) performUserUpdate:(User *) user;
-(BOOL) supportsService:(NSString *) service;
-(void) fireEventWithType:(MessageType) type content:(id) thecontent;
+(id) sharedInstance;
-(UIView *) getNewPreferencesViewWithFrame:(CGRect) frame;
-(UIView *) getPreferencesViewWithFrame:(CGRect) frame forUser:(User *) auser;

@end
