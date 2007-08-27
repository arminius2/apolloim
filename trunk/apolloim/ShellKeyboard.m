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

@implementation ShellKeyboard

- (void) show:(UITextView*)sendView withCell:(UIImageAndTextTableCell*) cell
{
	[sendView setBottomBufferHeight:(5.0f)];
	
	kbFrame = [self frame];
	cellFrame = [cell frame];

	[cell setFrame:CGRectMake(-10.0f, 185.0f, 320.0f, 20.0f)];

	[self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
	[self setFrame:CGRectMake(0.0f, 480.0, 320.0f, 480.0f)];

	struct CGAffineTransform trans = CGAffineTransformMakeTranslation(0, -270);
//	struct CGAffineTransform trans = CGAffineTransformMakeTranslation(0, -240);
	UITransformAnimation *translate =
	[[UITransformAnimation alloc] initWithTarget: self];
	[translate setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
	[translate setEndTransform: trans];
	[[[UIAnimator alloc] init] addAnimation:translate withDuration:.2 start:YES];

	_hidden = NO;
	NSLog(@"SHELKEYBOARD SHOW COMPLETE");
}

- (void) hide:(UITextView*)sendView withCell:(UIImageAndTextTableCell*) cell
{
  [cell setFrame:CGRectMake(0.0f,450.0f, 320.0f, 30.0f)];

  [sendView setBottomBufferHeight:(70.0f)];  
  struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
  rect.origin.x = rect.origin.y = 0.0f;
//  [sendView setFrame:CGRectMake(15.0f, -6.0f, 320.0f - 70.0f, 10.0f)];
  [self setTransform:CGAffineTransformMake(1,0,0,1,0,0)];
  [self setFrame:CGRectMake(0.0f, 240.0, 320.0f, 480.0f)];

  struct CGAffineTransform trans = CGAffineTransformMakeTranslation(0, 270);
  UITransformAnimation *translate =
    [[UITransformAnimation alloc] initWithTarget: self];
  [translate setStartTransform: CGAffineTransformMake(1,0,0,1,0,0)];
  [translate setEndTransform: trans];
  [[[UIAnimator alloc] init] addAnimation:translate withDuration:.2 start:YES];
  _hidden = YES;
}

- (void) toggle:(UITextView*)sendView withCell:(UIImageAndTextTableCell*) cell
{
  if (_hidden) {
    [self show:sendView withCell:cell];
  } else{
    [self hide:sendView withCell:cell];
  }
}

@end
