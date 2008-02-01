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

#import "User.h"
#import "Buddy.h"

#include "CONST.h"
#import "common.h"

@interface Event : NSObject
{
	MessageType type;
	id content;
	User * owner;
	Buddy * buddy;
}

// Constructor
-(id) initWithUser:(User *) user type:(MessageType) atype content:(id) thecontent;
-(id) initWithUser:(User *) user buddy:(Buddy *) abuddy type:(MessageType) atype content:(id) thecontent;

-(id) getContent;
-(MessageType) getType;
-(User *) getOwner;
-(Buddy *) getBuddy;

@end
