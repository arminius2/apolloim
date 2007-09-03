#import "ApolloNotificationController.h"
#import <UIKit/UIKit.h>
#import <Celestial/AVController.h>
#import <Celestial/AVQueue.h>
#import <Celestial/AVItem.h>
#import <Celestial/AVController-AVController_Celeste.h>

//From Aaron hillegass
#define LogMethod() NSLog(@"-[%@ %s]", self, _cmd)

static id sharedInst;
static NSRecursiveLock *lock;

extern UIApplication *UIApp;

@interface ApolloNotificationController (PrivateAPI)
-(void)play:(AVItem *)item;
@end

@implementation ApolloNotificationController

+ (void)initialize
{
    sharedInst = lock = nil;
}

+ (id)sharedInstance
{
    [lock lock];
    if (!sharedInst)
    {
        sharedInst = [[[self class] alloc] init];
    }
    [lock unlock];    
    return sharedInst;
}

- (id)init
{
	self = [super init];
	if (nil!= self)
	{
		NSError *err;				
		
		[UIApp removeApplicationBadge];
		totalUnreadMessages = 0;
		
		//Sound declarations
//		NSString *path = [[NSBundle mainBundle] pathForResource:@"ApolloRecv" ofType:@"wav" inDirectory:@"/"];
		NSString *path = [[NSBundle mainBundle] pathForResource:@"ApolloRecv" ofType:@"aiff" inDirectory:@"/"];
		recvIm = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}

//		path = [[NSBundle mainBundle] pathForResource:@"ApolloSend" ofType:@"wav" inDirectory:@"/"];
		path = [[NSBundle mainBundle] pathForResource:@"ApolloSend" ofType:@"aiff" inDirectory:@"/"];		
		sendIm = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}

		path = [[NSBundle mainBundle] pathForResource:@"ApolloSignOn" ofType:@"wav" inDirectory:@"/"];
		signOn = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}
		
		path = [[NSBundle mainBundle] pathForResource:@"ApolloSignOff" ofType:@"wav" inDirectory:@"/"];
		signOff = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}

		path = [[NSBundle mainBundle] pathForResource:@"ApolloGoAway" ofType:@"wav" inDirectory:@"/"];
		goAway = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}
		
		path = [[NSBundle mainBundle] pathForResource:@"ApolloComeBack" ofType:@"wav" inDirectory:@"/"];
		comeBack = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}		

		controller = [[AVController alloc] init];
//		controller = [AVController avController];
		[controller setDelegate:self];
		[controller setVibrationEnabled:YES];		
		
		q = [[AVQueue alloc] init];
		
		[q appendItem:recvIm error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}

		[q appendItem:sendIm error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
/*		[q appendItem:signOn error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
		[q appendItem:signOff error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
		[q appendItem:goAway error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
		[q appendItem:comeBack error:&err];
		if (nil != err)
		{
			NSLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}					*/																
	}
	return self;
}


- (void)dealloc
{
/*recvIm
sendIm
signOn
signOff
goAway
comeBack*/
	[recvIm release]; recvIm = nil;
	[sendIm release]; sendIm = nil;
	[signOn release]; signOn = nil;
	[signOff release]; signOff = nil;
	[goAway release]; goAway = nil;
	[comeBack release]; comeBack = nil;
	[q release]; q = nil;
	[controller release]; controller = nil;
	[super dealloc];
}

-(void)playSignOff
{
	[self play:signOff];
}

-(void)playSignon
{
	[self play:signOn];
}

-(void)playRecvIm
{
	[self play:recvIm];
	totalUnreadMessages++;
	[UIApp setApplicationBadge:[NSString stringWithFormat:@"%u",totalUnreadMessages]];
}

-(void)receiveUnreadMessages:(int)msgCount  //should just do playRecvIm
{
	totalUnreadMessages+=msgCount;
	[UIApp setApplicationBadge:[NSString stringWithFormat:@"%u",totalUnreadMessages]];
	NSLog(@"Set count to %d",msgCount);	
}

-(void)switchToConvoWithMsgs:(int)msgCount
{
	totalUnreadMessages-=msgCount;
	[UIApp setApplicationBadge:[NSString stringWithFormat:@"%u",totalUnreadMessages]];
	NSLog(@"Decrementing badge...");
	if(totalUnreadMessages == 0)
	{
		[UIApp removeApplicationBadge];
		NSLog(@"Clearing badge...");
	}
}

-(void)clearBadges
{	
	totalUnreadMessages = 0;
	[UIApp removeApplicationBadge];
}

-(void)playSendIm
{
	[self play:sendIm];
}

-(void)playGoAway
{
	[self play:goAway];
}

-(void)playComeBack
{
	[self play:comeBack];
}

-(void)play:(AVItem *)item
{
	[controller setCurrentItem:item];
	//play NOW
	[controller setCurrentTime:(double)0.0];
	//should probably check this eventually, too.
	//- (BOOL)isCurrentItemReady;
	NSError *err;
	[controller play:&err];
	if(nil != err)
	{
		NSLog(@"err! = %@    [controller play:&err];", err); 
		exit(1);
	}
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  NSLog(@"NOTIFICATION>> Request for selector: %@", NSStringFromSelector(aSelector));
  return [super respondsToSelector:aSelector];
}

-(void)stop;
{
	[controller pause];
}


- (void)queueItemWasAdded:(id)fp8
{
LogMethod();
}
@end