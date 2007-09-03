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
-(void)switchToConvoWithMsgs:(int)msgCount;
-(void)playGoAway;
-(void)playComeBack;
-(void)playSendIm;
-(void)playRecvIm;
-(void)playSignOff;
-(void)playSignon;

-(BOOL)respondsToSelector:(SEL)aSelector;
-(void)stop;
-(void)resume:(AVItem *)item;
-(void)queueItemWasAdded:(id)fp8;

@end