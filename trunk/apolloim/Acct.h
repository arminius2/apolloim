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

#import <Foundation/Foundation.h>


@interface Acct : NSObject 
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
