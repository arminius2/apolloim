//
//  Buddy.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/18/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Buddy.h"

@implementation Buddy
- (id)init {
	self = [super init];
	if (self != nil) {
		name		= [[NSString alloc]init];
		group		= [[NSString alloc]init];
		status		= [[NSString alloc]init];
		online		= false;
		conversation= [[NSMutableArray alloc]init];
	}
	return self;
}

- (id) initWithBuddyName:(NSString*)aName group:(NSString*)aGroup status:(NSString*)aStatus isOnline:(bool)_online message:(NSString*)msg
{
	self = [super init];
	if (self != nil) 
	{
		[self setName:aName];
		[self setGroup:aGroup];
		[self setStatus:aStatus];
		[self addMessage:msg];
		[self setOnline:_online];
	}
	return self;
}

-(id)initWithCoder: (NSCoder *)coder
{
	if(self = [super init])
	{
		//Someday I, too, will have logging support.
	}
	return self;
}

-(void)encodeWithCoder: (NSCoder *)coder
{
	//Someday I, too, will have logging support.
/*	[coder encodeObject: username forKey:@"username"];
	[coder encodeObject: password forKey:@"password"];
	if(enabled)
		[coder encodeObject: @"YES" forKey:@"enabled"];
		else
		[coder encodeObject: @"NO" forKey:@"enabled"];		*/
}

-(void)setName:(NSString*)pass
{
	name = [pass copy];
}
-(void)setStatus :(NSString*)pass
{
	status = [pass copy];
}
-(void)setGroup :(NSString*)pass
{
	group = [pass copy];
}

-(void)setIdletime :(long)pass
{
	idletime = pass;
}

-(void)setInfo:(NSString*)pass
{
	info = [pass copy];
}

-(void)addMessage:(NSString*)pass
{
	[conversation addObject:pass];
}

-(void)setOnline:(bool)pass
{
	online = pass;
}

-(NSString*)name
{
	return [name copy];
}
-(NSString*)status
{
	return [status copy];
}
-(NSString*)group
{
	return [group copy];
}
-(NSString*)info
{
	return [info copy];
}
-(NSArray*)conversation
{
	return [conversation copy];
}
-(long)idletime
{
	return idletime;
}
-(bool)online
{
	return online;
}
@end
