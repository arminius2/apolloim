//
//  NSLog.h
//  Apollo
//
//  Created by Alex C. Schaefer on 11/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define AlexLog(s,...) \
[[AlexLog sharedInstance] writeToLogFromSourcefile:__FILE__ lineNumber:__LINE__ \
format:(s),##__VA_ARGS__]

@interface AlexLog : NSObject 
{
    NSString*       logLocation;
	FILE*			stderror;
	int				real_stderror;
    int             logWrites;
}

+(id)sharedInstance;
-(void)writeToLogFromSourcefile:(char*)sourceFile lineNumber:(int)lineNumber format:(NSString*)format, ...;

@end