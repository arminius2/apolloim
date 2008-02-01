/*
 Apollo: Libpurple based Objective-C IM Client
 By Alex C. Schaefer & Adam Bellmore

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
 
 Portions of this code are referenced from "Libpurple", courtesy of www.pidgin.im
 as well as AdiumX (www.adiumx.com).  This code is full GPLv2, and a GPLv2.txt 
 is contained in the source and program root for you to read.  If not, please
 refer to the above address to obtain your own copy.
 
 Any questions or comments should be posted at http://apolloim.googlecode.com
*/

//Special thanks to Jonathan Saggau for releasing his pong audio code
#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "AddressBook.h"
#import "common.h"

@class AVItem;
@class AVController;
@class AVQueue;

@interface ApolloNotificationController : NSObject
{
    AddressBook *addressBook;
	AVItem *recvIm;
	AVItem *sendIm;
	AVItem *signOn;
	AVItem *signOff;
	AVItem *goAway;
	AVItem *comeBack;
	AVQueue *q;
	AVController *controller;
	
	BOOL soundEnabled;
	BOOL vibrateEnabled;
	
	int totalUnreadMessages;
	double resumetime;
}

+ (void)initialize;
+ (id)sharedInstance;

-(id)init;

-(void)receiveUnreadMessages:(int)msgCount;  //increment total unread messages
-(void)switchToConvoWithMsgs:(int)msgCount;  //decrement total unread messages
-(void)updateUnreadMessages;				 //updates the badge
-(void)clearBadges;

-(NSString*)getDisplayNameOfIMUser:(NSString*)cleanName forProtocol:(NSString*)proto;

-(void)playGoAway;
-(void)playComeBack;
-(void)playSendIm;
-(void)playRecvIm;							//increment total unread messages
-(void)playSignOff;
-(void)playSignon;
-(void)vibrateThread;			//These two functions go out to all the lonely ladies out there
-(void)vibrateForDuration;
-(void)soundThread:(AVItem *)item;

-(BOOL)respondsToSelector:(SEL)aSelector;
-(void)stop;
-(void)queueItemWasAdded:(id)fp8;

int callback(void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data);

@end