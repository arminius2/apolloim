/*
 ApolloTOC.m: Objective-C firetalk interface.
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

#import "BuddyInfoView.h"
#import <UIKit/UIBox.h>

@implementation BuddyInfoView

- (id)initWithFrame:(struct CGRect)frame withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate
{
	NSLog(@"Creating BuddynfoView with dimensions(%f, %f, %f, %f)", frame.origin.x, frame.origin.y,
				frame.size.width, frame.size.height);
	if ((self == [super initWithFrame: frame]) != nil) 
	{
		buddy = aBuddy;
		_rect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	
		[self setAdjustForContentSizeChange:YES];
		[self setContentSize: CGSizeMake(frame.size.width, frame.size.height)];
		[self setOpaque:YES];

		_delegate = delegate;
		
		UIBox * box = [[UIBox alloc] initWithFrame:frame];
		[self addSubview: box];
		[self setContentSize: frame.size];

		//Initialize the view
		buddy_name_label = [[UITextLabel alloc] initWithFrame: CGRectMake(frame.origin.x + 5, 
									frame.origin.y+5,
									200, 20)];
		[buddy_name_label setText: @"Buddy Name"];

		idle_time_label = [[UITextLabel alloc] initWithFrame: CGRectMake(frame.origin.x + 5, 
									frame.origin.y+35,
									200, 20)];
		[idle_time_label setText: @"Idle Time: 00:00:00"];

		info_label = [[UITextLabel alloc] initWithFrame: CGRectMake(frame.origin.x + 5,
                                                                        frame.origin.y+65,
                                                                        200, 20)];
		[info_label setText: @"Buddy Info:"];

		info_text = [[UITextView alloc] initWithFrame: CGRectMake(frame.origin.x + 15,
                                                                        frame.origin.y+85,
                                                                        frame.size.width-15, 200)];
		[info_text setTextSize: 12];
		[info_text setEditable: NO];
		[info_text setText: @"Sample Buddy Text"];

		//[self addSubview: box];
		[self addSubview: buddy_name_label];
		[self addSubview: idle_time_label];
		[self addSubview: info_label];
		[self addSubview: info_text];
	}
	return self;
	
}

- (void)dealloc
{
	[super dealloc];
}

- (Buddy *) buddy
{
	return buddy;
}

- (void) reloadData
{
	[buddy_name_label setText: [buddy name]];
	[idle_time_label setText: [NSString stringWithFormat:@"Idle Time: %i", [buddy idletime] / 60]];
	[info_text setHTML: [buddy info]];
	NSLog(@"InfoView data reladed");
}

@end
