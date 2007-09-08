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

