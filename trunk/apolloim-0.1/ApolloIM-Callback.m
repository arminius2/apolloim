/*
 ApolloTOC.m: Objective-C firetalk interface.
 By Alex C. Schaefer
 Modification of BoomBot's objc/firetalk wrapper

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

#import "ApolloIM-Callback.h"
#import "ApolloTOC.h"
#import "ApolloIM-PrivateAccess.h"
#import "Buddy.h"

#import "libfiretalk/firetalk.h"
enum {
	AIM_RECV_MESG		=	1,
	AIM_BUDDY_ONLINE	=	2, 
	AIM_BUDDY_OFFLINE	=	3, 
	AIM_BUDDY_AWAY		=	4, 
	AIM_BUDDY_UNAWAY	=	5,
	AIM_BUDDY_IDLE		=	6,	
	AIM_BUDDY_MSG_RECV	=   7,
	AIM_CONNECTED		=   8,
	AIM_DISCONNECTED	=	9,
	AIM_READ_MSGS		=   10,
	AIM_BUDDY_INFO		=	11	
};
char pass[1024];

void ft_callback_error(void *c, void *cs, const int error, const char * const roomoruser, const char * const description)
{
    NSLog(@"ft_callback_error");
    [[ApolloTOC sharedInstance] error:error ftConnection:c];
}

void ft_callback_connectfailed(void *c, void *cs, int error, char *reason)
{
//     NSLog(@"ft_callback_connectfailed");
    [[ApolloTOC sharedInstance] disconnected:c reason:error];
}

void ft_callback_doinit (void *c, void *cs, char *nickname)
{
     NSLog(@"ft_callback_doinit");
    [[ApolloTOC sharedInstance] connectionSucessful:c];
}

void ft_callback_getmessage(void *c, void *cs, const char * const who, const int automessage, const char * const message)
{
//     NSLog(@"ft_callback_getmessage");
    [[ApolloTOC sharedInstance] recievedMessage:[NSString stringWithCString:message]
                                   fromUser:[NSString stringWithCString:who]
									isAutomessage:automessage
									ftConnection:c];
}

void ft_callback_listbuddy(void *c, void *cs, const char * const nickname, const char * const group, char online, char away, const long idle)
{
	NSLog(@"ft_callback_listbuddy -- %@ -- ONLINE: %c   AWAY: %c   IDLE: %x", [NSString stringWithCString:nickname], online, away, idle);
	Buddy* buddy = [[Buddy alloc]initWithBuddyName:[NSString stringWithCString:nickname] group:[NSString stringWithCString:group] status:@"Unknown"	isOnline:(bool)away		   message:nil];
	[[ApolloTOC sharedInstance] buddyUpdate:buddy withCode:AIM_BUDDY_AWAY];
}

void ft_callback_im_user_nickchanged(void *c, void *cs, const char * const nickname)
{
	NSLog(@"ft_callback_im_user_nickchanged-- %@", [NSString stringWithCString:nickname]);
}
void ft_callback_buddyonline(void *c, void *cs, const char * const who)
{
//	NSLog(@"ft_callback_buddyonline--%@", [NSString stringWithCString:who]);
	Buddy* buddy = [[Buddy alloc]initWithBuddyName:
		[NSString stringWithCString:who] 
		group:@"Unknown" 
		status:@"Online"			
		isOnline:true
		message:nil];

	[[ApolloTOC sharedInstance] buddyUpdate:buddy withCode:AIM_BUDDY_ONLINE];	
}

void ft_callback_buddyoffline		(void *c, void *cs, const char * const who)
{
//	NSLog(@"ft_callback_buddyoffline--%@", [NSString stringWithCString:who]);
	Buddy* buddy = [[Buddy alloc]initWithBuddyName:
		[NSString stringWithCString:who] 
		group:@"Unknown"
		status:@"offline"			
		isOnline:false
		message:nil];
	[[ApolloTOC sharedInstance] buddyUpdate:buddy withCode:AIM_BUDDY_OFFLINE];		
}

void ft_callback_buddyunaway		(void *c, void *cs, const char * const who)
{
//	NSLog(@"ft_callback_buddyunaway--%@", [NSString stringWithCString:who]);
	Buddy* buddy = [[Buddy alloc]initWithBuddyName:
		[NSString stringWithCString:who] 
		group:@"Unknown" 
		status:@"Available"			
		isOnline:true
		message:nil];
	[[ApolloTOC sharedInstance] buddyUpdate:buddy withCode:AIM_BUDDY_UNAWAY];		
}

void ft_callback_buddyaway			(void *c, void *cs, const char * const who)
{
//	NSLog(@"ft_callback_buddyaway-- %@", [NSString stringWithCString:who]);
	Buddy* buddy = [[Buddy alloc]initWithBuddyName:
		[NSString stringWithCString:who] 
		group:@"Unknown" 
		status:@"Away"			
		isOnline:true
		message:nil];
	[[ApolloTOC sharedInstance] buddyUpdate:buddy withCode:AIM_BUDDY_AWAY];		
}

void ft_callback_getinfo(void *c, void *cs, const char * const who, const char * const info, const int warning, const int idle, const int flags)
{
	Buddy* buddy = [[Buddy alloc]initWithBuddyName:
		[NSString stringWithCString:who] 
		group:@"Unknown"
		status:@"UNKNOWN"
		isOnline:true
		message:nil];
	if(![[buddy properName]isEqualToString:@"WSJ"])
	{ 
		[buddy setInfo:[NSString stringWithCString:info]];
		[[ApolloTOC sharedInstance] buddyUpdate:buddy withCode:AIM_BUDDY_INFO];			
	}
	else
		[[ApolloTOC sharedInstance] keepAliveDecrement];
}

void ft_callback_buddytyping		(void *c, void *cs, const char * const who, const int typing)
{
    NSLog(@"ft_callback_buddytyping %@ - %d", [NSString stringWithCString:who], typing);
}
void ft_callback_buddyidle			(void *c, void *cs, const char * const who, const long idle)
{
    NSLog(@"ft_callback_buddyinfo %@ - %l", [NSString stringWithCString:who], idle);
}

void ft_callback_buddystatus		(void *c, void *cs, const char * const who, const char *message)
{
    NSLog(@"ft_callback_buddyStatus %@ - %s",[NSString stringWithCString:who],message);
}

void ft_callback_disconnect(void *c, void *cs, const int error)
{
    NSLog(@"ft_callback_disconnect");
    [[ApolloTOC sharedInstance] disconnected:c reason:error];
}

void ft_callback_needpass(void *c, void *cs, char *p, const int size)
{
    NSLog(@"ft_callback_needpass");
    strncpy(p, pass, size);
}

void ft_callback_storepass(char* newpass)
{
    NSLog(@"ft_callback_storepass");
    strncpy(pass, newpass, 1024);
}
