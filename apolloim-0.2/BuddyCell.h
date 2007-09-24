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
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIImage.h>
#import <UIKit/UITextLabel.h>
#import <UIKit/UISwitchControl.h>

#import "Buddy.h"

@interface BuddyCell : UIImageAndTextTableCell 
{
	CGRect frame;
	Buddy * buddy;
	BOOL is_editing;
	id deligate;

	int count;

	CGPoint status_onscreen;
	CGPoint status_offscreen;

	CGPoint user_no_message;
	CGPoint user_with_message;

	UITextLabel * buddy_label;
	UITextLabel * protocol_label;
	UITextLabel * away_message_label;
	UITextLabel * message_count;

	UIImageView * away_image;
	UIImageView * idle_image;
	UIImageView * active_image;
	UIImageView * away_image_conv;
	UIImageView * idle_image_conv;
	UIImageView * active_image_conv;
	UIImageView * buddy_icon;
}

-(id)initWithBuddy:(Buddy *) abuddy;

-(void)setDeligate:(id) adeligate;

-(void) reloadData;

@end
