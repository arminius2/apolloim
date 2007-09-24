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
#import "Event.h"

@implementation Event
/*
{
	Buddy * buddy;
	MessageType type;
	id content;
}
*/

// Constructor
-(id) initWithUser:(User *) user type:(MessageType) atype content:(id) thecontent;
{
	if ((self == [super init]) != nil) 
	{
		content = thecontent;
		type = atype;
		owner = user;
		buddy = nil;
	}

	return self;
}

-(id) initWithUser:(User *) user buddy:(Buddy *) abuddy type:(MessageType) atype content:(id) thecontent
{
	if ((self == [super init]) != nil) 
	{
		content = thecontent;
		type = atype;
		owner = user;
		buddy = abuddy;
	}

	return self;
}

-(id) getContent
{
	return content;
}

-(MessageType) getType
{
	return type;
}

-(User *) getOwner
{
	return owner;
}

-(Buddy *) getBuddy
{
	return buddy;
}

@end
