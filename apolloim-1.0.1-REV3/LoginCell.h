/*
 Apollo: Libpurple based Objective-C IM Client
 By Alex C. Schaefer & Adam Bellmore

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
 
 Portions of this code are referenced from "Libpurple", courtesy of www.pidgin.im
 as well as AdiumX (www.adiumx.com).  This code is full GPLv2, and a GPLv2.txt 
 is contained in the source and program root for you to read.  If not, please
 refer to the above address to obtain your own copy.
 
 Any questions or comments should be posted at http://apolloim.googlecode.com
*/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIImage.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITextLabel.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UIPushButton.h>

#import "User.h"
#import "common.h"

@interface LoginCell : UIImageAndTextTableCell {
	CGRect frame;
	User * user;
	BOOL is_editing;
	BOOL is_deleting;
	id deligate;

	// Images
	UIImageView * background_img;
	UIImageView * delete_img;
	UIImageView * edit_img;

	UIPushButton * delete_spiral;
	UIPushButton * delete_button;

	UITextLabel * user_label;
	UITextLabel * protocol_label;

	UISwitchControl * enable_switch;

	id enclosing_view;
	
}

-(id)initWithUser:(User *) auser forLoginView:(id) view;
-(void)setEditing:(BOOL) editing;
-(void)setDeligate:(id) adeligate;
@end
