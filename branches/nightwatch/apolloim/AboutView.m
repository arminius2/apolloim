/*
 ApolloTOC.m: Objective-C firetalk interface.
 By Alex C. Schaefer

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
#import "AboutView.h"


@implementation AboutView
	-(id)initWithFrame:(struct CGRect)frame
	{
		if ((self == [super initWithFrame: frame]) != nil) 
		{
			aboutField =[[ConvoBox alloc]initWithFrame:CGRectMake(_rect.origin.x,_rect.origin.y, _rect.size.width,  _rect.size.height)];
			[aboutField setHTML:@"<b>Special Thanks to Doc, natetrue, wheat, Erica, Extremis (who got me a dev box - thank god), Ste, darkten, and Nervegas.  </b>"];
			[self addSubview:aboutField];
		}
		return self;
	}
	-(void)dealloc
	{
		[super dealloc];
	}
	
@end
