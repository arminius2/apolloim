/*
 ApolloTOC.m: Objective-C firetalk interface.
 By Alex C. Schaefer
 Modification of BoomBot's objc/firetalk wrapper

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
#import "Buddy.h"

typedef enum {ApolloTOC_DISCONNECTED, ApolloTOC_CONNECTING, ApolloTOC_CONNECTED} ApolloTOCConnectionStatus;

@interface ApolloTOC : NSObject
{
	NSTimer* bastard;
	
    BOOL willSendMarkup;
	BOOL status;
    ApolloTOCConnectionStatus connected;
    void *ft_aim_connection;

	Buddy *you;
	
    NSString *infoMessage;
	
	id _delegate;
}

+ (void)initialize;
+ (id)sharedInstance;


- (id)init;
- (void)dealloc;
- (void)setDelegate:(id)delegate;
- (NSString*)infoMessage;
- (void)setInfoMessage:(NSString*)newMessage;

- (BOOL)connectUsingUsername:(NSString*)username password:(NSString*)password;
- (void)listBuddies;
- (BOOL)connected;
- (void)disconnect;

- (BOOL)willSendMarkup;
- (void)setWillSendMarkup:(BOOL)newSetting;

- (void)sendIM:(NSString*)body toUser:(NSString*)user;
- (void)buddyUpdate:(Buddy*)buddy withCode:(int)code;

- (NSString*) userName;
- (void)getInfo:(Buddy*)aBuddy;
- (void)keepAlive;

@end
