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
#import <UIKit/UIView.h>
#import "User.h"
#import "common.h"

@protocol ProtocolInterface

/*
Logs the given user in.
*/
-(void) logIn:(User *) auser;

/*
Logs the given user out.
*/
-(void) logOut:(User *) auser;

/*
Adds the given EventListener to the list of event listeners.
All events genereated from this interface should go
to all event listeners.
*/
-(void) addEventListener:(id) el;

/*
Removes the EventListener from the list of event listeners.
This stops all events generated from being passed to the
listener.
*/
-(void) removeEventListener:(id) el;

/*
Performs any non-passive buddy updates.  Such as get profile on AIM.
*/
-(void) performBuddyUpdate:(NSString *) buddy_name;

/*
Adds a buddy to the buddy list.
*/
-(void) addBuddy:(NSString *) buddy_name;

/*
Removes a buddy to the buddy list.
*/
-(void) removeBuddy:(Buddy *) buddy;

/*
Performs updates to the server, such as status/away/prifiles.  
*/
-(void) performUserUpdate:(User *) user;

/*
Returns true if this interface supports the given service.
Examples:  @"AIM", @"MSN", @"GTalk"
*/
-(BOOL) supportsService:(NSString *) service;

/*
Creates a grpahical object with no set preferences to display this protocols preferences.
This is used when creating a new user.
*/
-(UIView *) getNewPreferencesViewWithFrame:(CGRect) frame andProtocol:(NSString *) protocol;

/*
Creates a grpahical object with set preferences to display this protocols preferences.
This is used when editing a user's preferences.
*/
-(UIView *) getPreferencesViewWithFrame:(CGRect) frame forUser:(User *) auser andProtocol:(NSString *) protocol;

/*
Save the data from the last made preference view.
*/
-(BOOL) performSave;

/*
Sends a message to the buddy
*/
-(void) sendMessage:(NSString *) msg fromUser:(User *) user toBuddy:(Buddy *) buddy;

/*
All interfaces must be singletons.  Returns the singleton instance.
*/
+(id) sharedInstance;

@end
