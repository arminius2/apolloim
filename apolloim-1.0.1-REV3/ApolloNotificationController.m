#import "ApolloNotificationController.h"
#import <UIKit/UIKit.h>
#import <Celestial/AVController.h>
#import <Celestial/AVQueue.h>
#import <Celestial/AVItem.h>
#import <Celestial/AVController-AVController_Celeste.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>
#include <time.h>
//Special thankyou to Jonathan Saggau, nice code mate.

//From Aaron hillegass
#define LogMethod() AlexLog(@"-[%@ %s]", self, _cmd)

static id sharedInst;
static NSRecursiveLock *lock;

extern UIApplication *UIApp;

extern void * _CTServerConnectionCreate(CFAllocatorRef, int (*)(void *, CFStringRef, CFDictionaryRef, void *), int *);
extern int _CTServerConnectionSetVibratorState(int *, void *, int, int, int, int, int);

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
//		addressBook = [[AddressBook alloc] init];	
	
		NSError *err;				
		AlexLog(@"RINGER STATE %d", [UIHardware ringerState]);
		[UIApp removeApplicationBadge];
		totalUnreadMessages = 0;
		
		//Sound declarations
//		NSString *path = [[NSBundle mainBundle] pathForResource:@"ApolloRecv" ofType:@"wav" inDirectory:@"/"];
		NSString *path = [[NSBundle mainBundle] pathForResource:@"ApolloRecv" ofType:@"aiff" inDirectory:@"/"];
		recvIm = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}

//		path = [[NSBundle mainBundle] pathForResource:@"ApolloSend" ofType:@"wav" inDirectory:@"/"];
		path = [[NSBundle mainBundle] pathForResource:@"ApolloSend" ofType:@"aiff" inDirectory:@"/"];		
		sendIm = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}

/*		path = [[NSBundle mainBundle] pathForResource:@"ApolloSignOn" ofType:@"wav" inDirectory:@"/"];
		signOn = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}
		
		path = [[NSBundle mainBundle] pathForResource:@"ApolloSignOff" ofType:@"wav" inDirectory:@"/"];
		signOff = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}

		path = [[NSBundle mainBundle] pathForResource:@"ApolloGoAway" ofType:@"wav" inDirectory:@"/"];
		goAway = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}
		
		path = [[NSBundle mainBundle] pathForResource:@"ApolloComeBack" ofType:@"wav" inDirectory:@"/"];
		comeBack = [[AVItem alloc] initWithPath:path error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n item = [[AVItem alloc] initWithPath:path error:&err];", err);
			exit(1);
		}		*/

		controller = [[AVController alloc] init];
//		controller = [AVController avController];
		[controller setDelegate:self];
		[controller setVibrationEnabled:YES];		
		
		q = [[AVQueue alloc] init];
		
		[q appendItem:recvIm error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}

/*		[q appendItem:sendIm error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}*/
		
/*		[q appendItem:signOn error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
		[q appendItem:signOff error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
		[q appendItem:goAway error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}
		
		[q appendItem:comeBack error:&err];
		if (nil != err)
		{
			AlexLog(@"err! = %@ \n [q appendItem:item error:&err];", err);
			exit(1);
		}					*/
	}
	return self;
}

-(NSString*)getDisplayNameOfIMUser:(NSString*)cleanName forProtocol:(NSString*)proto
{
//       return [addressBook getDisplayNameOfIMUser:cleanName  protocol:proto];
	return nil;
}

-(void)vibrateForDuration
{
	
	[NSThread detachNewThreadSelector:@selector(vibrateThread) toTarget:self withObject:nil];

}

-(void)vibrateThread
{
	//This all should work.  But it doesn't.  So fuck that noise. We'll do this the old fashion way.
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];	
	system("/Applications/Apollo.app/vibrator");
	[pool release];	
	
/*	int x = 0;    
	AlexLog(@"Connecting to telephony...");
	int connection = _CTServerConnectionCreate(kCFAllocatorDefault, callback, &x);    
	AlexLog(@"Setting vibrator state...");
	int ret = _CTServerConnectionSetVibratorState(&x, connection, 3, 10, 10, 10, 10);    
	AlexLog(@"Timing it...");
	time_t now = time(NULL);    	
	while (time(NULL) - now < 10)
	{
	}	
	AlexLog(@"Killing vibrator...");	
	_CTServerConnectionSetVibratorState(&x, connection, 0, 10, 10, 10, 10);*/
	
	
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

int callback(void *connection, CFStringRef string, CFDictionaryRef dictionary, void *data) 
{
    return 1;
}

-(void)setVibrateEnabled:(bool)enable
{
	vibrateEnabled = enable;	
}

-(BOOL) vibrateEnabled
{
	return vibrateEnabled;
}

-(BOOL)soundEnabled
{
	return soundEnabled;
}

-(void)playSignOff
{
	[self play:signOff];
}

-(void)playSignon
{
	[self play:signOn];
}

-(void)playSendIm
{
	[self play:sendIm];	
}

-(void)playRecvIm
{
	[self play:recvIm];
}

-(void)receiveUnreadMessages:(int)msgCount  //should just do playRecvIm
{
	totalUnreadMessages+=msgCount;
	[self updateUnreadMessages];
	AlexLog(@"Set count to %d",msgCount);	
}

-(void)updateUnreadMessages
{
//	if([UIApp isSuspended] || [UIApp isLocked])
	{
		[lock lock];
		if(totalUnreadMessages <= 20)
			[UIApp setApplicationBadge:[NSString stringWithFormat:@"%u",totalUnreadMessages]];
		else
			[UIApp setApplicationBadge:@"20+"];
		[lock unlock];
	}
	if(totalUnreadMessages == 0)
	{
		[UIApp removeApplicationBadge];
		AlexLog(@"Clearing badge...");
	}	
}

-(void)switchToConvoWithMsgs:(int)msgCount
{
	totalUnreadMessages-=msgCount;
	[self updateUnreadMessages];
	AlexLog(@"Decrementing badge...");
}

-(void)clearBadges
{	
//	totalUnreadMessages = 0;
//	[UIApp removeApplicationBadge];
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
	[NSThread detachNewThreadSelector:@selector(soundThread:) toTarget:self withObject:item];
/*	if([UIHardware ringerState])  //this will be moved to individual options to allow customized which sounds on/off.  I am lazy right now.
	{
		AlexLog(@"Playing.");
		[controller setCurrentItem:item];
		[controller setCurrentTime:(double)0.0];
		NSError *err;
		[controller play:&err];
		//if(nil != err)
		//{
			//AlexLog(@"err! = %@    [controller play:&err];", err); 
			//exit(1);
		//}
	}
	[self vibrateForDuration];*/
}

-(void)soundThread:(AVItem *)item
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if([UIHardware ringerState])  //this will be moved to individual options to allow customized which sounds on/off.  I am lazy right now.
	{
		[lock lock];
		AlexLog(@"Playing.");
		[controller setCurrentItem:item];
		[controller setCurrentTime:(double)0.0];
		NSError *err;
		[controller play:&err];
		//if(nil != err)
		//{
		//	AlexLog(@"err! = %@    [controller play:&err];", err); 
		//	exit(1);
		//}
		[lock unlock];
	}	
	[self vibrateForDuration];
	[pool release];	
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  AlexLog(@"NOTIFICATION>> Request for selector: %@", NSStringFromSelector(aSelector));
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
