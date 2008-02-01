/*
 ApolloTOC.m: Objective-C firetalk interface.
 By Alex C. Schaefer

	credit to mobile terminal

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
#import <UIKit/UIKit.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UITextView.h>
#import "ConversationView.h"
#import "common.h"

@interface ShellKeyboard : UIKeyboard
{
  bool _hidden;
  CGRect cellFrame;
  CGRect kbFrame;
}
- (id)initWithFrame:(struct CGRect)fp8;
- (void)show:(UITextView*)sendView    withCell:(UIImageAndTextTableCell*) cell	forConvoBox:(ConversationView*)box;
- (void)hide:(UITextView*)sendView    withCell:(UIImageAndTextTableCell*) cell  forConvoBox:(ConversationView*)box;
- (void)toggle:(UITextView*)sendView  withCell:(UIImageAndTextTableCell*) cell	forConvoBox:(ConversationView*)box;

@end
