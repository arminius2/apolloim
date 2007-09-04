/*
 ApolloTOC.m: Objective-C firetalk interface.
 By Adam Bellmore

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


//Special thanks to Jonathan Saggau for releasing his pong audio code
#import <Foundation/Foundation.h>
@class AVItem;
@class AVController;
@class AVQueue;

@interface ApolloNotificationController : NSObject
{
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
-(void)clearBadges;

-(void)playGoAway;
-(void)playComeBack;
-(void)playSendIm;
-(void)playRecvIm;							//increment total unread messages
-(void)playSignOff;
-(void)playSignon;
-(void)vibrateThread;			//These two functions go out to all the lonely ladies out there
-(void)vibrateForDuration;

-(void)setSoundEnabled:(bool)enable;
-(BOOL)soundEnabled;
-(void)setVibrateEnabled:(bool)enable;
-(BOOL) vibrateEnabled;

-(BOOL)respondsToSelector:(SEL)aSelector;
-(void)stop;
-(void)queueItemWasAdded:(id)fp8;

int callback(void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data);

@end