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
#import <UIKit/UISwitchControl.h>
#import <UIKit/UISectionList.h>
#import <UIKit/UITable.h>

#import "User.h"
#import "common.h"

@interface BuddyListView : UIView 
{
	UIImageView * top_bar;
	UIPushButton * logout_button;
	UIPushButton * status_button;
	UIPushButton * add_button;

	UITable * buddy_table;
	UISectionList * buddy_list;

	NSMutableArray * buddies;
	NSMutableDictionary * cells;
	CGRect frame;
	NSMutableArray * user_names;
	NSMutableArray * user_rows;

	BOOL is_away;
	int user_count;

	BOOL needs_refreshing;
}

-(id) initWithFrame:(CGRect) frame;

- (void)tableRowSelected:(NSNotification *)notification;
- (UIImageAndTextTableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col;
- (int)numberOfRowsInTable:(UITable *)table;
- (void)reloadData;
- (void)refreshTable;
@end
