//
//  PreferenceController.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 9/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"


@implementation PreferenceController

static id sharedInst;
static NSRecursiveLock *lock;

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


-(id)init
{
	self = [super init];
	if (nil!= self)
	{
	}
	return self;		
}

-(void)setSound:(bool)enable
{
	sound = enable;
	NSLog(@"SOUND %d", enable);	
	[self write];
}
-(BOOL)sound
{
	return sound;
}
-(void)setVibrate:(bool)enable
{
	vibrate = enable;
	NSLog(@"VIBRATE %d", enable);
	[self write];
}
-(BOOL)vibrate
{
	return vibrate;
}

-(void)write
{
	NSLog(@"Writing...");
	[[NSString stringWithFormat:@"%d|%d", sound, vibrate]
	writeToFile:@"/Applications/ApolloIM.app/prefs" atomically:NO encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"Written.");
}

-(void)read
{
	NSLog(@"Reading...");
	NSArray* prefs = [[NSString stringWithContentsOfFile:@"/Applications/ApolloIM.app/prefs"]componentsSeparatedByString:@"|"];
	
	if([prefs count] == 2)
	{
		NSLog(@"Setting...");
		vibrate = [[prefs objectAtIndex:0]intValue];	
		sound = [[prefs objectAtIndex:1]intValue];
	}
	else
	{
		NSLog(@"First Run!");
		vibrate = 1;
		sound = 0;
		[self write];
	}
	NSLog(@"Green means go.");
}
@end
