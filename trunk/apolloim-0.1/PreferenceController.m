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

-(void)setNotify:(bool)enable
{
	notify = enable;
		[self write];
}

-(bool)notify
{
	return notify;
}

-(void)write
{
/*	NSLog(@"Writing...");
	[[NSString stringWithFormat:@"%d|%d|%d", sound, vibrate, notify]
	writeToFile:@"/Applications/ApolloIM.app/prefs" atomically:YES encoding:NSUTF8StringEncoding error:nil];
	NSLog(@"Written.");*/
}

-(void)read
{
/*	NSLog(@"Reading...");
	NSArray* prefs = [[NSString stringWithContentsOfFile:@"/Applications/ApolloIM.app/prefs"]componentsSeparatedByString:@"|"];
	
	if([prefs count] == 3)
	{
		NSLog(@"Setting...");
		vibrate = [[prefs objectAtIndex:0]intValue];	
		sound	= [[prefs objectAtIndex:1]intValue];
		notify	= [[prefs objectAtIndex:2]intValue];
	}
	else
	{
		NSLog(@"First Run!");
		vibrate =	1;
		sound =		0;
		notify =	1;
		[self write];
	}
	NSLog(@"Green means go.");
	NSLog(@"SOUND %d VIBRATE %d NOTIFY %d", sound, vibrate, notify);*/
}

+ (NSString*) removeHTML:(NSMutableString *) from
{
	NSMutableString* htmlObject = [[NSMutableString alloc]initWithString:from];
	int del = 0;
	int i = 0;
	for(i; i< ([htmlObject length]); i++)
	{
		BOOL deleted = NO;
		if([htmlObject characterAtIndex: i] == '<')
			del ++;
			
		if(del > 0)
		{
			deleted = YES;
		}
		
		if([htmlObject characterAtIndex: i] == '>')
		{
			if(del > 0)
				del --;
		}
		
		if(deleted)
		{
			NSRange r = NSMakeRange(i, 1);
			[htmlObject deleteCharactersInRange: r];
			i--;
		}
		
	}
	return htmlObject;
}
@end
