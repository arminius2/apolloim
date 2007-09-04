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
#import <UIKit/UITransitionView.h>
#import "UIKit/UITextView.h"
#import "UIKit/UISegmentedControl.h"
#import "UIKit/UIPreferencesTable.h"
#import "UIKit/UISwitchControl.h"
#import "UIKit/UIPreferencesTableCell.h"
#import "UIKit/UIPreferencesTextTableCell.h"
#import <UIKit/UIPushButton.h>
#import "Acct.h"
#import "UIKit/UIKeyboard.h"

@interface PreferencesView : UIView 
{
	UIPreferencesTable	*_table;

	UISwitchControl		*soundSwitch;	
	UISwitchControl		*vibrateSwitch;	
		
    	CGRect _rect;	
	
	id _delegate;
}

- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;

- (void)setDelegate:(id)delegate;

- (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group;
- (float)preferencesTable:(UIPreferencesTable *)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed ;
- (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable ;
- (UIPreferencesTextTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForRow:(int)row inGroup:(int)group ;
- (void)savePreferences;
@end
