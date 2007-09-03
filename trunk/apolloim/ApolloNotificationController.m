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
		[controller setDelegate:self];
		[controller setVibrationEnabled:YES];
		if([controller vibrationEnabled])
			NSLog(@"VIBRATION IS ENABLED");
		
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
		
		[q appendItem:signOn error:&err];
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
		}																					
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
	[UIApp vibrateForDuration:2];
	totalUnreadMessages++;
	[UIApp setApplicationBadge:[NSString stringWithFormat:@"%u",totalUnreadMessages]];
	NSLog(@"PLEASE START VIBRATING.");	
}

-(void)switchToConvoWithMsgs:(int)msgCount
{
	if(totalUnreadMessages - msgCount > 0)
	{
		totalUnreadMessages-=msgCount;
		[UIApp setApplicationBadge:[NSString stringWithFormat:@"%u",totalUnreadMessages]];	
	}
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
	NSError *err;
	AVItem*  current = [controller currentItem];
	resumetime = [controller currentTime];

	[controller pause];
	NSLog(@"KICK THIS PIG");

	[controller setCurrentItem:item];
	[controller setCurrentTime:(double)0.0];

	NSLog(@"Playing...");
	[controller play:&err];
	if(nil != err)
	{
		NSLog(@"err! = %@ [controller play:&err];", err);
		exit(1);
	}
	
//	[self performSelector:@selector(resume:) withObject:current afterDelay:2.0];
}

-(void)resume:(AVItem *)item
{
	NSError *err;
	[controller pause];
	NSLog(@"KICK THIS PIG");

	[controller setCurrentItem:item];
	if([controller resumePlayback:resumetime error:&err])
	{
		NSLog(@"Resuming old song...");
		if(nil != err)
		{
			NSLog(@"err! = %@ [controller play:&err];", err);
			exit(1);
		}		
	}
	
	[controller play:&err];
	if(nil != err)
	{
		NSLog(@"err! = %@ [controller play:&err];", err);
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