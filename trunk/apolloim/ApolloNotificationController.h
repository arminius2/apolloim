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
	
	int totalUnreadMessages;
	double resumetime;
}

+ (void)initialize;
+ (id)sharedInstance;

-(id)init;

-(void)receiveUnreadMessages:(int)msgCount;  //increment total unread messages
-(void)switchToConvoWithMsgs:(int)msgCount;  //decrement total unread messages

-(void)playGoAway;
-(void)playComeBack;
-(void)playSendIm;
-(void)playRecvIm;
-(void)playSignOff;
-(void)playSignon;

-(BOOL)respondsToSelector:(SEL)aSelector;
-(void)stop;
-(void)queueItemWasAdded:(id)fp8;

@end