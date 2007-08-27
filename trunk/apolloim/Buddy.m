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
		properName	= [[NSString alloc]init];
		group		= [[NSString alloc]init];
		status		= [[NSString alloc]init];
		online		= false;
		unreadMsgs = 0;		
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
		unreadMsgs = 0;		
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

-(bool)inAConversation
{
	return inAConversation;
}

-(void)setInAConversation:(bool)pass;
{
	inAConversation = pass;
}

-(void)setUnreadMsgs:(int)pass
{
	unreadMsgs = pass;
}
-(int)unreadMsgs
{
	return unreadMsgs;
}
-(void)incrementMessages
{
	NSLog(@"INCREMENTING");
	unreadMsgs++;
}

-(void)setName:(NSString*)pass
{
	NSArray* split = [pass componentsSeparatedByString:@":"];
	name = [[split objectAtIndex:0]copy];
//	NSLog(@"|-----SETNAME---START");
//	if([split count]>1)
//		NSLog(@"|  Name: %@   Other: %@  Count: %d", name,[split objectAtIndex:1], [split count]);
//		else
//		NSLog(@"|  Name: %@  Count: %d", name,[split count]);		
//	NSLog(@"|-----SETNAME---END");	
	
	NSMutableString* buddyname = [[NSMutableString alloc]initWithString:[[split objectAtIndex:0] uppercaseString]];
	[buddyname replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [buddyname length])];	
	properName = [NSString stringWithString:buddyname];
}

-(NSComparisonResult)compareNames:(Buddy *)anotherBuddy
{
	return [properName caseInsensitiveCompare:[anotherBuddy properName]];
}

-(NSComparisonResult)compareResults:(Buddy *)anotherBuddy
{
	if(result < [anotherBuddy result])
		return NSOrderedAscending;
	else if ( result > [anotherBuddy result])
		return NSOrderedDescending;
	else
		return NSOrderedSame;
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
-(NSString*)properName
{
	return [properName copy];
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

-(float)result
{
	return result;
}
@end

