//
//  SendBox.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.

#import "SendBox.h"
#import "common.h"

@implementation SendBox
- (id)initWithFrame:(struct CGRect)fp8 withConversation:(id) conv
{
	if((self = [super initWithFrame:fp8]) != nil)
	{
		[self setText:@""];
		[self setTextSize:14];
		[self setEditable:YES];
		[self setAllowsRubberBanding:NO];
		[self setOpaque:YES];

		AlexLog(@"0x%8x", conv); 

		conv_view = conv;
	}

	return self;
}

- (BOOL)canBecomeFirstResponder
{
	return true;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
//  AlexLog(@"SENDBOX>> Request for selector: %@", NSStringFromSelector(aSelector));
  return [super respondsToSelector:aSelector];
}

- (BOOL)webView:(id)fp8 shouldInsertText:(id)character replacingDOMRange:(id)fp16 givenAction:(int)fp20
{
	CGRect doc_box = [self visibleTextRect];

	if([character characterAtIndex:0] == '\n')
	{
		[_delegate sendMessage];
		return NO;
	}

	AlexLog(@"POP %x", conv_view);

	[conv_view resizeInputArea];

	return [super webView:fp8 shouldInsertText:character replacingDOMRange:fp16 givenAction:fp20];
}

- (BOOL)webView:(id)fp8 shouldBeginEditingInDOMRange:(id)fp12
{
	[_delegate rollKeyboard];
//	return [[self _webView] webView:fp8 shouldBeginEditingInDOMRange:fp12];
	return YES;
}

@end
