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
#import "common.h"

@interface Preferences : NSObject
{
	NSMutableDictionary * global_prefs;
	NSMutableDictionary * user_prefs;
}

// Constructor
-(id) init;

-(NSString *) getGlobalPrefWithKey:(NSString *) a_key;
-(void) setGlobalPrefWithKey:(NSString *) a_key andValue:(NSString *) value;

-(NSString *) getUserPrefForUser:(User *) a_user withKey:(NSString *) a_key;
-(void) setUserPrefForUser:(User *) a_user withKey:(NSString *) a_key andValue:(NSString *) value;

+(id) sharedInstance;

@end
