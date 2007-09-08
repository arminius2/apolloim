/*
 ApolloCore.m: Objective-C firetalk interface.
 By Alex C. Schaefer

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

#import "Acct.h"

/*

enum info for purple

2007-09-08 14:22:08.033 ApolloIM[5961:d03] libpurple initialized.
2007-09-08 14:22:08.035 ApolloIM[5961:d03] 0 -- AIM
2007-09-08 14:22:08.037 ApolloIM[5961:d03] 1 -- ICQ
2007-09-08 14:22:08.039 ApolloIM[5961:d03] 2 -- IRC
2007-09-08 14:22:08.041 ApolloIM[5961:d03] 3 -- XMPP


*/

@implementation Acct

- (id)init {
	self = [super init];
	if (self != nil) {
		username	= [[NSString alloc]init]	;
		password	= [[NSString alloc]init]	;
		status		= [[NSString alloc]initWithString:@"Disconnected."];
		connection  = 0;//We only support AIM for now, and it will be enum'd to 0... 
		enabled		= false;
	}
	return self;
}

-(id)initWithCoder: (NSCoder *)coder
{
	if(self = [super init])
	{
		[self setUsername:[coder decodeObjectForKey:@"username"]];
		[self setPassword:[coder decodeObjectForKey:@"password"]];
		[self setEnabledString:[coder decodeObjectForKey:@"enabled"]];
	}
	return self;
}

-(void)encodeWithCoder: (NSCoder *)coder
{
	[coder encodeObject: username forKey:@"username"];
	[coder encodeObject: password forKey:@"password"];
	if(enabled)
		[coder encodeObject: @"YES" forKey:@"enabled"];
		else
		[coder encodeObject: @"NO" forKey:@"enabled"];		
}

-(void)setUsername:(NSString*)pass
{
	username	=	[pass copy];
}
-(void)setPassword:(NSString*)pass
{
	password	=	[pass copy];
}

-(void)setStatus:(NSString*)pass
{
	status		=	[pass copy];
}

-(void)setConnection:(int)conn;
{
	connection	=	conn;
}

-(void)setConnected:(bool)pass
{
    connected = pass;
}

/*-(void)setExtServer:(NSString*)pass
{
	extServer	=	[pass copy];
}*/
-(void)setEnabledString:(NSString*)pass
{
	enabled		=	[pass isEqualToString:@"YES"];
}
-(void)setEnabled:(bool)pass
{
	enabled		=	pass;
}
-(NSString*)username
{
	return username;
}
-(NSString*)password
{
	return password;
}
-(NSString*)status
{
	return status;
}
-(int)connection
{
	return connection;
}
-(bool)connected
{
    return connected;
}

/*-(NSString*)extServer
{
	return extServer;
}*/
-(bool)enabled
{
	return enabled;
}

@end
