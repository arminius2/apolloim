//
//  Account.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Account.h"


@implementation Account

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
