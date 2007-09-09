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
//  NSLog(@"SENDBOX>> Request for selector: %@", NSStringFromSelector(aSelector));
  return [super respondsToSelector:aSelector];
}

- (BOOL)webView:(id)fp8 shouldInsertText:(id)character replacingDOMRange:(id)fp16 givenAction:(int)fp20
{
	if([character characterAtIndex:0] == '\n')
	{
		[_delegate sendMessage];
		return NO;
	}

	return [super webView:fp8 shouldInsertText:character replacingDOMRange:fp16 givenAction:fp20];
}

- (BOOL)webView:(id)fp8 shouldBeginEditingInDOMRange:(id)fp12
{
	[_delegate rollKeyboard];
//	return [[self _webView] webView:fp8 shouldBeginEditingInDOMRange:fp12];
	return YES;
}

@end
