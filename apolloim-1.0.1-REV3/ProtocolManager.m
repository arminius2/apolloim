/*
 By Adam Bellmore

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAnimator.h>
#import "ProtocolManager.h"
#import "PurpleInterface.h"

#include "CONST.h"

id sharedInstanceProt;

@implementation ProtocolManager

-(id) init
{
	if ((self == [super init]) != nil) 
	{
		AlexLog(@"Protocol Manager Intialized");
	}
	return self;
}

-(id) protocolByName:(NSString *) name
{
	AlexLog(@"Searching for protocol for: %@", name);
	if([[PurpleInterface sharedInstance] supportsService: name])
	{
		AlexLog(@"Protocol Found");
		return [PurpleInterface sharedInstance];
	}
	return nil;
}

-(NSArray *) getAvailableProtocols
{
	NSMutableArray * a = [[NSMutableArray alloc] init];
	[a addObject: AIM];
	[a addObject: ICQ];
	[a addObject: MSN];
	[a addObject: DOTMAC];
	return a;
}

-(void) registerForAllEvents:(id) listener
{
	[[PurpleInterface sharedInstance] addEventListener:listener];
}

+(id) sharedInstance
{
	if(sharedInstanceProt == nil)
		sharedInstanceProt = [[ProtocolManager alloc] init];
	return sharedInstanceProt;
}

@end
