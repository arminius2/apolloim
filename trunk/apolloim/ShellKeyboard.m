// ShellKeyboard.m
//
// TODO: Should be able to cancel animations that have already started so they
// transition smoothly in the other direction
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
