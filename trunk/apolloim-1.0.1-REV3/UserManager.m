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

#import "UserManager.h"
#import "Preferences.h"
#import "ProtocolManager.h"
#import "ProtocolInterface.h"

id sharedInstanceUserManager = nil;
NSString * account_key = @"account_list";

@implementation UserManager

// Constructor
-(id) init
{
	if ((self == [super init]) != nil) 
	{
		user_list = [[NSMutableArray alloc] init];

		[self reloadData];
	}
	return self;
}

-(void) reloadData
{
	NSString * account_string = [[Preferences sharedInstance] getGlobalPrefWithKey:account_key];
	NSArray * ind_acc = [account_string componentsSeparatedByString:@";"];

	[user_list removeAllObjects];
	
	if([ind_acc count] > 1)
	{	
		int i = 0;
		for(i; i< [ind_acc count]; i++)
		{
			NSString * account = [[NSString alloc]initWithString:[ind_acc objectAtIndex:i]];
			AlexLog(@"Found Account: %@",account);
			NSArray * acc_info = [account componentsSeparatedByString:@"/"];
			if([acc_info count]>1)
			{
				User * u = [[User alloc]
									initWithName:[acc_info objectAtIndex:0]
									andProtocol:[acc_info objectAtIndex:1]];
				if([u getProtocolInterface] != nil)
					[user_list addObject: u];
			}			
		}
	}
}

-(NSArray *) getUsers
{
	return user_list;
}

-(User *) getUserByName:(NSString *) name andProtocol:(NSString *) protocol
{
	User * ret = nil;
	int i = 0;
	for(i; i<[user_list count]; i++)
	{
		User * t = [user_list objectAtIndex:i];
		if([[t getName] isEqualToString: name] &&
			[[t getProtocol] isEqualToString: protocol])
			ret = t;
	}
	return ret;
}

-(void) addUser:(User *) user
{
	NSString *	p_out = [[NSString alloc]initWithFormat: @"%@/%@;", [user getName], [user getProtocol]];
	int i = 0;

	for(i; i<[user_list count]; i++)
	{
		User * u = [user_list objectAtIndex:i];		
		if(![p_out isEqualToString:[[NSString alloc]initWithFormat:@"%@/%@;",[u getName], [u getProtocol]]])
			p_out = [[NSString alloc]initWithFormat: @"%@;%@/%@", p_out, [u getName], [u getProtocol]];
	}
	
	NSMutableString * doubleColon = [[NSMutableString alloc]initWithString:[p_out copy]];
	[doubleColon replaceOccurrencesOfString:@";;" withString:@";" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [doubleColon length])];
	
	[p_out release];
	p_out = [doubleColon copy];
	
	[user_list addObject:user];	
	[[Preferences sharedInstance] setGlobalPrefWithKey: account_key andValue: p_out];
	
/*	AlexLog(@"Adding User: %@", [user getName]);
	NSString * account_string = [[Preferences sharedInstance] getGlobalPrefWithKey:account_key];
	AlexLog(@"Current Users: %@", account_string);

	NSString * p_out;
//	if(account_string)
	if([account_string rangeOfString:[NSString stringWithFormat: @"%@/%@;", [user getName], [user getProtocol]]].)
		p_out = [NSString stringWithFormat: @"%@;%@/%@", account_string, [user getName], [user getProtocol]];
	else
		p_out = [NSString stringWithFormat: @"%@/%@;", [user getName], [user getProtocol]];
		
	[[Preferences sharedInstance] setGlobalPrefWithKey: account_key andValue: p_out];
	[user_list addObject:user];*/
}

-(void) removeUser:(User *) user
{
	NSString *	p_out = [[NSString alloc]initWithFormat: @"%@/%@", [[user_list objectAtIndex:0] getName], [[user_list objectAtIndex:0] getProtocol]];
	int i = 1;
	
	[user_list removeObject:user];

	for(i; i<[user_list count]; i++)
	{
		User * u = [user_list objectAtIndex:i];
		p_out = [[NSString alloc]initWithFormat: @"%@;%@/%@", p_out, [u getName], [u getProtocol]];
	}
	AlexLog(@"POUT: %@", p_out);
	[[Preferences sharedInstance] setGlobalPrefWithKey: account_key andValue: p_out];
}

-(BOOL) loginAll
{
	BOOL ret = YES;
	BOOL one_active = NO;
	NSArray * users = [self getUsers];
	int i = 0;
	for(i; i<[users count]; i++)
	{
		User * u = [users objectAtIndex: i];
		if([u isActive])
		{
			AlexLog(@"%@ is active", [u getName]);
			one_active = YES;
			ProtocolManager * pm = [ProtocolManager sharedInstance];
			id<ProtocolInterface> pif = [pm protocolByName: [u getProtocol]];
			if(pif != nil)
			{
				[pif logIn:u];
			}
			else
			{
				ret = NO;
			}
		}
	}
	return (one_active && ret);
}

-(BOOL) logoutAll
{
	BOOL ret = YES;
	NSArray * users = [self getUsers];
	int i = 0;
	for(i; i<[users count]; i++)
	{
		User * u = [users objectAtIndex: i];
		ProtocolManager * pm = [ProtocolManager sharedInstance];
		id<ProtocolInterface> pif = [pm protocolByName: [u getProtocol]];
		if(pif != nil)
		{
			[pif logOut:u];
		}
		else
		{
			ret = NO;
		}
	}
}

+(id) sharedInstance
{
	if(sharedInstanceUserManager == nil)
		sharedInstanceUserManager = [[UserManager alloc] init];
	return sharedInstanceUserManager;
}

@end
