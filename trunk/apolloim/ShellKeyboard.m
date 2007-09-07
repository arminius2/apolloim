/*
 ApolloCore.m: Objective-C firetalk interface.
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
#import "ShellKeyboard.h"
#import <UIKit/UITextView.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAnimator.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIScroller.h>
#import <UIKit/UITransformAnimation.h>
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIPreferencesTable.h>

@interface UITextLoupe : UIView

- (void)drawRect:(struct CGRect)fp8;

@end

@implementation ShellKeyboard

- (void) show:(UITextView*)sendView withCell:(UIImageAndTextTableCell*) cell forConvoBox:(ConversationView*)box
{
	[sendView setBottomBufferHeight:(5.0f)];
	
	kbFrame = [self frame];
	cellFrame = [cell frame];

	[self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
	[self setFrame:CGRectMake(0.0f, 480.0, 320.0f, 480.0f)];

    struct CGAffineTransform transKb = CGAffineTransformMakeTranslation(0, -280);
    struct CGAffineTransform transCell = CGAffineTransformMakeTranslation(0, -210);	
	
	UITransformAnimation *translateKb =
	[[UITransformAnimation alloc] initWithTarget: self];
	[translateKb setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
	[translateKb setEndTransform: transKb];
	
	UITransformAnimation *translateCell =
	[[UITransformAnimation alloc] initWithTarget: cell];
	[translateCell setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
	[translateCell setEndTransform: transCell];	
	
	[[[UIAnimator alloc] init] addAnimation:translateKb withDuration:.1 start:YES];
//	[[[UIAnimator alloc] init] addAnimation:translateCell withDuration:.5 start:YES];	
//	[cell setFrame:CGRectMake(-10.0f, 175.0f, 320.0f, 20.0f)];
	_hidden = NO;
}

- (void) hide:(UITextView*)sendView withCell:(UIImageAndTextTableCell*) cell forConvoBox:(ConversationView*)box
{


  [sendView setBottomBufferHeight:(5.0f)];  
  struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
  rect.origin.x = rect.origin.y = 0.0f;
//  [sendView setFrame:CGRectMake(15.0f, -6.0f, 320.0f - 70.0f, 10.0f)];
  [self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
  [self setFrame:CGRectMake(0.0f, 240.0, 320.0f, 480.0f)];

    struct CGAffineTransform transKb = CGAffineTransformMakeTranslation(0, 280);
    struct CGAffineTransform transCell = CGAffineTransformMakeTranslation(0, 200);
	
	UITransformAnimation *translateKb =
	[[UITransformAnimation alloc] initWithTarget: self];
	[translateKb setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
	[translateKb setEndTransform: transKb];
	
	UITransformAnimation *translateCell =
	[[UITransformAnimation alloc] initWithTarget: cell];
	[translateCell setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
	[translateCell setEndTransform: transCell];	
	
	[[[UIAnimator alloc] init] addAnimation:translateKb withDuration:.5 start:YES];
//	[[[UIAnimator alloc] init] addAnimation:translateCell withDuration:.5 start:YES];
//	[cell setFrame:CGRectMake(-10.0f,380.0f, 320.0f, 20.0f)];
  _hidden = YES;
}

- (void) toggle:(UITextView*)sendView withCell:(UIImageAndTextTableCell*) cell forConvoBox:(ConversationView*)box
{
  if (_hidden) {
    [self show:sendView withCell:cell forConvoBox:box];
  } else{
    [self hide:sendView withCell:cell forConvoBox:box];
  }
}

@end
