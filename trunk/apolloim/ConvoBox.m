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

#import "ConvoBox.h"

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#import <UIKit/UIView-Rendering.h>
//Dear mobile terminal programmers,
//you are 5x the hacker I am.
//Thank you for open sourcing your code.
//--alex

// Forward declarations

@interface UITextLoupe : UIView

- (void)drawRect:(struct CGRect)fp8;

@end

@implementation UITextLoupe (Black)

- (void)drawRect:(struct CGRect)fp8 { }

@end

// ShellView

@implementation ConvoBox : UITextView

- (id)initWithFrame:(struct CGRect)fp8
{
  //debug(@"Created ShellView");
  id parent = [super initWithFrame:fp8];

  [self setText:@""];
  [self setTextSize:14];
  [self setEditable:NO];
  [self setAllowsRubberBanding:YES];
  [self displayScrollerIndicators];
  [self setOpaque:NO];

  return parent;
}

/*- (void)mouseUp:(struct __GSEvent *)fp8
{
  if (![self isScrolling]) 
  {
	[_delegate toggle];
  }
  
  [super mouseUp:fp8];
}	*/

- (void)scrollToEnd
{
  NSLog(@"Scrolling to end...");
  NSRange aRange;
  aRange.location = 9999999; 
  aRange.length = 1;
  [self setSelectionRange:aRange];
  [self scrollToMakeCaretVisible:YES];
}

- (void)insertText:(NSString*)text
{
  // Insert at the end of the WebKit WebView
  [[[self _webView] webView] moveToEndOfDocument:self];
  _ignoreInsertText = YES;
  [[self _webView] insertText:text];
  _ignoreInsertText = NO;
  [self scrollToEnd];
}
- (BOOL)respondsToSelector:(SEL)aSelector
	{
	  NSLog(@"CONVOBOX>> Request for selector: %@", NSStringFromSelector(aSelector));
	  return [super respondsToSelector:aSelector];
	}

- (BOOL)webView:(id)fp8 shouldInsertText:(id)fp12 replacingDOMRange:(id)fp16 givenAction:(int)fp20
{
	return NO;
}

- (BOOL)webView:(id)fp8 shouldDeleteDOMRange:(id)fp12
{
	return NO;
}

@end
