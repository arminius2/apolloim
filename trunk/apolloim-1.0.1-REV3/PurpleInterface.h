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
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesTableCell.h>
#import "User.h"
#import "ProtocolInterface.h"
#import "Buddy.h"
#import "Event.h"
#import "common.h"

@interface PurpleInterface : NSObject <ProtocolInterface>
{
	NSMutableArray * user_list;
	NSMutableArray * listeners;

	// View for editing
	UIView * account_view;
	UIPreferencesTable * pref_table;
	UITextField * password_field;
	UITextField * username_field;
	UITextField * server_field;
	UITextField * port_field;

	UIPreferencesTextTableCell * username_cell;
	UIPreferencesTextTableCell * password_cell;
	UIPreferencesTextTableCell * server_cell;
	UIPreferencesTextTableCell * port_cell;

	UIPreferencesTableCell * delete_button;

	NSString * protocol;

	BOOL new_user_editing;
	User * last_user_editing;
}

-(id) init;
-(void) logIn:(User *) auser;
-(void) logOut:(User *) auser;
-(BOOL) addEventListener:(id) el;
-(void) removeEventListener:(id) el;
-(void) performBuddyUpdate:(NSString *) buddy_name;
-(void) performUserUpdate:(User *) user;
-(BOOL) supportsService:(NSString *) service;
+(id) sharedInstance;
-(UIView *) getNewPreferencesViewWithFrame:(CGRect) frame andProtocol:(NSString *) protocol;
-(UIView *) getPreferencesViewWithFrame:(CGRect) frame forUser:(User *) auser andProtocol:(NSString *) protocol;
-(BOOL) performSave;
-(void) fireEvent:(Event *) event;

@end
