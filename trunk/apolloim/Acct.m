/*
 ApolloTOC.m: Objective-C firetalk interface.
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


@implementation Acct

- (id)init {
	self = [super init];
	if (self != nil) {
		username	= [[NSString alloc]init]	;
		password	= [[NSString alloc]init]	;
		status		= [[NSString alloc]initWithString:@"Disconnected."];
//		connection  = [[NSString alloc]init]	;
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

-(void)setDebug
{
	[self setUsername:		@"BLANKMAN"]		;
	[self setPassword:		@"BLANKPASS"]		;
//	[self setConnection:	@"AIM"]				;
	[self setStatus:		@"Disconnected."]	;
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
/*-(void)setConnection:(NSString*)pass
{
	connection	=	[pass copy];
}
-(void)setExtServer:(NSString*)pass
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
/*-(NSString*)connection
{
	return connection;
}
-(NSString*)extServer
{
	return extServer;
}*/
-(bool)enabled
{
	return enabled;
}

@end
