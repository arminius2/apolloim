//
//  AlexLog.m
//  AlexLog
//
//  Created by Alex C. Schaefer on 11/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AlexLog.h"
#include <stdio.h>
#include <unistd.h>

static id TheAlexLog;

@implementation AlexLog

+(id)sharedInstance
{
	if(TheAlexLog == nil)
	{
		TheAlexLog = [[AlexLog alloc]init];
	}
	return TheAlexLog;
}


-(void)writeToLogFromSourcefile:(char*)sourceFile lineNumber:(int)lineNumber format:(NSString*)format, ...;
{
   va_list arglist;
   if (format)
   {
	va_start(arglist, format);
	NSString* outstring = [NSString stringWithFormat:@"%@ -- #%d> %@",[NSString stringWithCString:sourceFile],lineNumber,[[NSString alloc] initWithFormat:format arguments:arglist]]; 
	// Set permissions for our NSLog file
	umask(022);

	// Save stderr so it can be restored.
	int stderrSave = dup(STDERR_FILENO);

	// Send stderr to our file
	FILE *newStderr = freopen("/var/root/Library/Logs/AlexLog.log", "a", stderr);

    fprintf(stderr, "%s\n", [outstring UTF8String]);
	NSLog(outstring);
	// Flush before restoring stderr
	fflush(stderr);

	// Now restore stderr, so new output goes to console.
	dup2(stderrSave, STDERR_FILENO);
	close(stderrSave);
	 
     va_end(arglist);
   }
}

-(void)uploadLogTo:(NSURL*)server viaProtocol:(NSString*)proto
{
	NSLog(@"Should have uploaded to a server.");
}
@end
