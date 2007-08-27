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

#import <Cocoa/Cocoa.h>


@interface Buddy : NSObject 
{
	NSString*			name;
	NSString*			group;
	NSString*			status;
	NSString*			info;
	NSString*			properName;
	bool				online;
	bool				inAConversation;
	int					unreadMsgs;
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
-(void)setInAConversation:(bool)pass;
-(void)setUnreadMsgs:(int)pass;
-(void)incrementMessages;

-(NSString*)name;
-(NSString*)properName;
-(NSString*)status;
-(bool)online;
-(NSString*)group;
-(NSString*)info;
-(NSArray*)conversation;
-(long)idletime;
-(bool)inAConversation;
-(int)unreadMsgs;

-(float)result;
-(NSComparisonResult)compareNames:(Buddy *)anotherBuddy;
-(NSComparisonResult)compareResults:(Buddy *)anotherBuddy;

@end
