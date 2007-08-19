//
//  Account.h
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Account : NSObject 
{
	NSString*	username;
	NSString*	password;
	NSString*	status;
//	NSString*	connection;	
//	NSString*	extServer;		//For jabber	
	bool		enabled;
}

-(void)setUsername:(NSString*)pass;
-(void)setPassword:(NSString*)pass;
-(void)setStatus:(NSString*)pass;
//-(void)setConnection:(NSString*)pass;
-(void)setEnabled:(bool)pass;
-(void)setEnabledString:(NSString*)pass;
//-(void)setExtServer:(NSString*)pass;
-(NSString*)username;
-(NSString*)password;
-(NSString*)status;
//-(NSString*)connection;
//-(NSString*)extServer;
-(bool)enabled;

- (void) encodeWithCoder: (NSCoder *)coder;
- (id) initWithCoder: (NSCoder *)coder;

-(void)setDebug;

@end
