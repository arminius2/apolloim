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
#import "Preferences.h"
#import "ProtocolManager.h"

int buddy_compare(id left, id right, void * context)
{
	return [[left getDisplayName] localizedCaseInsensitiveCompare:[right getDisplayName]];
}

@implementation User
/*
{
	NSString * name;
	NSString * protocol;
	id protocol_interface;
	NSString * status_message;
	NSString * profile;
}
*/

// Constructor
-(id) initWithName:(NSString *) aname andProtocol:(NSString *) aprotocol
{
	if ((self == [super init]) != nil) 
	{
		name = [aname copy];
		protocol = [aprotocol copy];
		away = NO;
		active = NO;
		buddy_list = [[NSMutableArray alloc] init];

		status = OFFLINE;

		protocol_interface = [[ProtocolManager sharedInstance] protocolByName: protocol];
	}
	return self;
}

// Getters
-(NSString *) getName
{
	return [name copy];
}

-(void) setName:(NSString *) aname
{
	name = aname;
}

-(NSString *) getStatusMessage
{
	return [status_message copy];
}

-(NSString *) getProfile
{
	return [profile copy];
}

-(NSString *) getProtocol
{
	return [protocol copy];
}

-(id) getProtocolInterface
{
	return protocol_interface;
}

-(BOOL) isAway
{
	return away;
}

-(void) setAway:(BOOL) is_away
{
	away = is_away;
	if([self isActive])
		[protocol_interface performUserUpdate:self];
}

// Setters
-(void) setStatusMessage:(NSString *) astatus
{
	status_message = astatus;
	[protocol_interface performUserUpdate:self];
}

-(void) setProfile:(NSString *) new_profile
{
	profile = new_profile;
	[protocol_interface performUserUpdate:self];
}

-(id) copyWithZone:(NSZone *) zone
{
	User * u = [[User alloc] initWithName: name andProtocol:protocol];
	return u;
}

// User Preferences
-(NSString *) getSettingForKey:(NSString *) key
{
	NSString * ret = [[Preferences sharedInstance] getUserPrefForUser:self withKey:key];
	if(ret == nil)
		ret = @"";
	return ret;
}

-(void)setSettingForKey: (NSString *) key andValue:(NSString *) value
{
	[[Preferences sharedInstance] setUserPrefForUser:self withKey:key andValue:value];
}

// Server Stuff
-(void) connect
{
	if(status==OFFLINE)
	{
		[NSThread detachNewThreadSelector:@selector(logIn:) toTarget:protocol_interface withObject:self];
//		[protocol_interface logIn:self];
	}
}

-(void) disconnect
{
	if(status==ONLINE)
	{
		[NSThread detachNewThreadSelector:@selector(logOut:) toTarget:protocol_interface withObject:self];
		[self setStatus:OFFLINE];
//		[protocol_interface logOut:self];
	}
}

-(NSMutableArray *) getBuddyList
{
	return buddy_list;
}

-(Buddy *) getBuddyByName:(NSString *) name
{
	//TODO: Why isn't this a dictionary?
	int i = 0;
	for(i; i<[buddy_list count]; i++)
	{		
		Buddy * b = [buddy_list objectAtIndex:i];

		NSMutableString* buddyname = [[NSMutableString alloc]initWithString:[[name copy] uppercaseString]];
		[buddyname replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [buddyname length])];
		
		if([[b getName]isEqualToString:[NSString stringWithString:[buddyname copy]]])
		{
//			NSLog(@"WE HAVE A WINNER FOLKS");
			return b;
		}
	}
	
	return nil;
}

-(Buddy *) getBuddyByID:(NSString *) ID
{
	NSLog(@"Finding: %@", ID);
	return [buddy_dict objectForKey:ID];
}

-(void) addBuddyToBuddyList:(Buddy *) abuddy
{
	[buddy_list addObject:abuddy];
	[buddy_dict setValue:abuddy forKey:[abuddy getID]];

	[buddy_list sortUsingFunction:buddy_compare context:nil];
}

-(void) removeBuddyFromBuddyList:(Buddy *) abuddy
{
	[buddy_list removeObject: abuddy];
	[buddy_dict removeObjectForKey:[abuddy getID]];
}

-(void) removeAllFromBuddyList
{
	[buddy_list removeAllObjects];
	buddy_dict =[[ NSMutableDictionary alloc] init];
}

-(void) addBuddy:(NSString *) buddy_name
{
	NSLog(@"%@> Adding buddy %@", name, buddy_name);
	[protocol_interface addBuddy:buddy_name];
	[protocol_interface performUserUpdate:self];
}

-(void) removeBuddy:(Buddy *) abuddy
{
	[protocol_interface removeBuddy:abuddy];
	[protocol_interface performUserUpdate:self];
}

-(void) removeAllBuddies
{
//	[buddy_list removeAllObjects];
	[buddy_list release];
	buddy_list = [[NSMutableArray alloc]init];
}

-(UserStatus) getStatus
{
	return status;
}

-(void) setStatus:(UserStatus) astatus
{
//	[protocol_interface performUserUpdate:self];
	status = astatus;
}

-(BOOL) isActive
{
//	return active;
	return [@"YES" isEqualToString:[self getSettingForKey:@"is_active" ]];
}

-(void) setActive:(BOOL) isactive
{
	active = isactive;
	
	if(isactive)
		[self setSettingForKey:@"is_active" andValue:@"YES"];
	else	
		[self setSettingForKey:@"is_active" andValue:@"NO"];
}

-(void) sendMessage:(NSString *) msg toBuddy:(Buddy *) buddy
{
	NSLog(@"Sending");
	[protocol_interface sendMessage:msg fromUser:self toBuddy: buddy];
}

-(NSString *) getID
{
	NSMutableString* mod_proto = [[NSMutableString alloc]initWithString:protocol];
	//Some protocols actually are the same as others.
	//These will make sure this is okay.
	[mod_proto replaceOccurrencesOfString:@"ICQ" withString:@"AIM" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mod_proto length])];	

	return [[NSString alloc] initWithFormat:@"%@/%@", [name lowercaseString], mod_proto];
}

@end
