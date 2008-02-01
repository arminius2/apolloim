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
#import "ApolloNotificationController.h"
#import "Buddy.h"

@implementation Buddy
/*
{
	NSString * name;
	NSString * status_message;
	NSString * profile_content;
	NSString * group;
	NSString * safe_name;
	BOOL is_away;
	BOOL is_online;
	float idle_time;
}
*/

// Constructor
-(id) initWithName:(NSString *) aname andGroup:(NSString *) agroup andOwner:(id) anowner
{
	if ((self == [super init]) != nil) 
	{
		owner = anowner;
		name = aname;
		agroup = agroup;

		conversation = [[NSMutableArray alloc] init];

		status_message = nil;
		profile_content = nil;
		is_away = false;
		is_online = false;
		idle_time = 0.0f;
		is_conv_shown = NO;
		unread_msg_count = 0;

		NSMutableString* buddyname = [[NSMutableString alloc]initWithString:[[name copy] uppercaseString]];
		[buddyname replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [buddyname length])];
//		[buddyname release];
		
		lookupName = [[ApolloNotificationController sharedInstance]getDisplayNameOfIMUser:aname forProtocol:[owner getProtocol]];
		safe_name = [[NSString alloc]initWithString:buddyname];
		alias = @" ";
	}

	return self;
}

// Getters
-(NSString *) getName
{
//	return name;
	return safe_name;
}

-(NSString *) getRawName
{
	return name;
}

-(NSString *) getProtocol
{
	return [owner getProtocol];
}

-(NSString *) getDisplayName
{
	//AlexLog(@"Alias: '%@'", alias);
	if(lookupName != nil)
		return lookupName;
	else
		if([alias isEqualToString:@" "])
			return [name copy];
		else
			return [alias copy];
}

-(NSString *) getSafeName
{
	return [safe_name copy];
}

-(NSString *) getStatusMessage
{
	return [status_message copy];
}

-(NSString *) getProfile
{
	return [profile_content copy];
}

-(NSString *) getGroup
{
	return [group copy];
}

-(int) getIdleTimeMinutes
{
	return (int)idle_time;
}

-(BOOL) isAway
{
	return is_away;
}

-(BOOL) isIdle
{
	return (idle_time > 0.0f);
}

// Setters
-(void) setStatusMessage:(NSString *) status
{
	status_message = [status copy];
}

-(void) setProfile:(NSString *) profile
{
	profile_content = [profile copy];
}

-(void) setIdleTimeMinutes:(float) time
{
	idle_time = time;
}

-(void) setAlias:(NSString*) PassedAlias
{
	alias = [PassedAlias copy];
}

-(void) setAway:(BOOL) isaway
{
	is_away = isaway;
}

-(id) getOwner
{
	return owner;
}

-(id) copyWithZone:(NSZone *) zone
{
	Buddy * u = [[Buddy alloc] initWithName:name andGroup:group andOwner:owner];
	return u;
}

-(BOOL) isEqual:(id)anObject
{
	//AlexLog(@"Is Equal Called (%@==%@)", name, [anObject getName]);

	BOOL name_eq = [name isEqualToString:[anObject getName]];
	BOOL same_owner = (owner == [anObject getOwner]);

	//AlexLog(@"Results %i, %i", name_eq, same_owner);

	return (name_eq && same_owner);
}

-(BOOL) isConversationVisible
{
	return is_conv_shown;
}

-(void) setConversationVisible:(BOOL) is_visible
{
	is_conv_shown = is_visible;

	if(is_conv_shown)
		unread_msg_count = 0;
}

-(void) setOnline:(BOOL) online
{
	is_online = online;
}

-(BOOL) isOnline
{
	return is_online;
}

-(void) messageCountIncrease
{
	if(!is_conv_shown)
		unread_msg_count++;
}

-(void) clearMessageCount
{
	unread_msg_count = 0;
}

-(int) getMessageCount
{
	return unread_msg_count;
}

-(NSString *) getID
{
	return [NSString stringWithFormat:@"%@/%@/%@", [[self getName]lowercaseString], [[owner getName]lowercaseString], [owner getProtocol]];
}

@end
