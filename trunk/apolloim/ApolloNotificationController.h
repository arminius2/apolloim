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