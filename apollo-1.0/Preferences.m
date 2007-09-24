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
#import "Preferences.h"

#include "CONST.h"

static id sharedInstancePref;

@implementation Preferences
/*
{
	NSMutableDictionary * global_pref;
	NSMutableDictionary * user_prefs;
}
*/

// Constructor
-(id) init
{
	if ((self == [super init]) != nil) 
	{	
		global_prefs = [[NSMutableDictionary alloc]initWithContentsOfFile: GLOBAL_PREF_PATH];
		if(global_prefs == nil)
		{
			NSLog(@"Global Preference File Not Found");
			global_prefs = [[NSMutableDictionary alloc] init];
			[global_prefs setObject:@"" forKey:@"account_list"];
			[global_prefs writeToFile:GLOBAL_PREF_PATH atomically: TRUE];
		}
		else
		{
			NSLog(@"Global Preference File Loaded");
		}
		user_prefs = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(NSString *) getGlobalPrefWithKey:(NSString *) a_key
{
	//global_prefs = [NSMutableDictionary dictionaryWithContentsOfFile: GLOBAL_PREF_PATH];
	return (NSString *) [[NSString alloc] initWithString:([global_prefs objectForKey:a_key]?[global_prefs objectForKey:a_key]:@" ")];
}

-(void) setGlobalPrefWithKey:(NSString *) a_key andValue:(NSString *) value
{
	//global_prefs = [NSMutableDictionary dictionaryWithContentsOfFile: GLOBAL_PREF_PATH];
	[global_prefs setObject:value forKey:a_key];
	[global_prefs writeToFile:GLOBAL_PREF_PATH atomically: TRUE];
}

-(NSString *) getUserPrefForUser:(User *) a_user withKey:(NSString *) a_key
{
	NSString * ret = nil;
	NSMutableDictionary * user_dict = [[NSMutableDictionary alloc] initWithDictionary:[user_prefs objectForKey:[a_user getID]]];
	
//	NSLog(@"COUNT %d", [user_dict count]);
	if([user_dict count] == 0)
	{
//		NSLog(@"Nil... initing with file...");
		user_dict = [[NSMutableDictionary alloc] initWithContentsOfFile: USER_PREF_PATH(a_user)];
		if([user_dict count] == 0)
		{
			user_dict = [[NSMutableDictionary alloc] init];
		}
		
//		NSLog(@"Setting... %@", user_prefs);
		[user_prefs setObject: user_dict forKey: [a_user getID]];
//		NSLog(@"Setg... %@", user_prefs);		
	}
//	NSLog(@"COUNT %d", [user_dict count]);	
//	NSLog(@"INITING....");
	ret = [user_dict objectForKey: a_key];
	NSLog(@"Reading Pref For User: %@ (%@->%@)", [a_user getName], a_key, ret);
	return ret;
}

-(void) setUserPrefForUser:(User *) a_user withKey:(NSString *) a_key andValue:(NSString *) value
{
	NSLog(@"Setting Pref For User: %@ (%@->%@)", [a_user getName], a_key, value);
	NSMutableDictionary * user_dict = [user_prefs objectForKey: [a_user getID]];
	if(user_dict == nil)
	{
		user_dict = [NSMutableDictionary dictionaryWithContentsOfFile: USER_PREF_PATH(a_user)];
		if(user_dict == nil)
		{
			user_dict = [[NSMutableDictionary alloc] init];
			[user_dict setObject:[a_user getName] forKey:@"username"];
			[user_dict setObject:[a_user getProtocol] forKey:@"protocol"];
		}
		[user_prefs setObject: user_dict forKey: [a_user getID]];
	}
	[user_dict setObject: value forKey: a_key];
	[user_dict writeToFile: USER_PREF_PATH(a_user) atomically: TRUE];
}

+(id) sharedInstance
{
	if(sharedInstancePref == nil)
		sharedInstancePref = [[Preferences alloc] init];
	return sharedInstancePref;
}

@end
