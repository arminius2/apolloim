/*
 ApolloCore.m: Objective-C firetalk interface.
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


@interface PreferenceController : NSObject 
{
	bool	vibrate;
	bool	sound;	
	bool	notify;
}
+ (void)initialize;
+ (id)sharedInstance;
+ (NSString*) removeHTML:(NSMutableString *) from;

-(id)init;
-(void)setSound:(bool)enable;
-(BOOL)sound;
-(void)setVibrate:(bool)enable;
-(BOOL)vibrate;
-(void)setNotify:(bool)enable;
-(bool)notify;
-(void)write;
-(void)read;

@end
