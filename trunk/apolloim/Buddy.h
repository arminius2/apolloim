//
//  Account.h
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Buddy : NSObject 
{
	NSString*			name;
	NSString*			group;
	NSString*			status;
	NSString*			info;
	NSString*			properName;
	bool				online;
	long				idletime;
	NSMutableArray*		conversation;
	
	float				result;
}
-(id) init;
-(id) initWithBuddyName:(NSString*)aName group:(NSString*)aGroup status:(NSString*)aStatus isOnline:(bool)_online message:(NSString*)msg;
-(void)setName:(NSString*)pass;
-(void)setStatus :(NSString*)pass;
-(void)setGroup :(NSString*)pass;
-(void)setIdletime :(long)pass;
-(void)setInfo:(NSString*)pass;
-(void)setOnline:(bool)pass;
-(void)addMessage:(NSString*)pass;

-(NSString*)name;
-(NSString*)properName;
-(NSString*)status;
-(bool)online;
-(NSString*)group;
-(NSString*)info;
-(NSArray*)conversation;
-(long)idletime;
-(float)result;

-(NSComparisonResult)compareNames:(Buddy *)anotherBuddy;
-(NSComparisonResult)compareResults:(Buddy *)anotherBuddy;

@end
