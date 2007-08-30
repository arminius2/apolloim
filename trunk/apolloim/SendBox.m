//
//  SendBox.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.


#import <UIKit/UIView-Rendering.h>
#import "SendBox.h"

@implementation SendBox
- (id)initWithFrame:(struct CGRect)fp8
{
  id parent = [super initWithFrame:fp8];

  [self setText:@""];
  [self setTextSize:14];
  [self setEditable:YES];
  [self setAllowsRubberBanding:NO];
  [self setOpaque:YES];

  return parent;
}

- (BOOL)canBecomeFirstResponder
{
	return true;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
  NSLog(@"SENDBOX>> Request for selector: %@", NSStringFromSelector(aSelector));
  return [super respondsToSelector:aSelector];
}

- (BOOL)webView:(id)fp8 shouldBeginEditingInDOMRange:(id)fp12
{
	[_delegate rollKeyboard];
//	return [[self _webView] webView:fp8 shouldBeginEditingInDOMRange:fp12];
	return YES;
}

@end
