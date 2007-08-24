#import "ConvoBox.h"

#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#import <UIKit/UIView-Rendering.h>
#import "ShellKeyboard.h"

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
  [self setEditable:NO]; // don't mess up my pretty output
  [self setAllowsRubberBanding:YES];
  [self displayScrollerIndicators];
  [self setOpaque:NO];

  return parent;
}

- (void)setKeyboard:(ShellKeyboard*) keyboard
{
  _keyboard=keyboard;
}

- (void)mouseUp:(struct __GSEvent *)fp8
{
  if ([self isScrolling]) {
    // Ignore mouse events that cause scrolling
  } else{
    // NSLog(@"MouseUp: not scrolling\n");
    [_keyboard toggle:self];
  }
  [super mouseUp:fp8];
}

- (void)scrollToEnd
{
  NSRange aRange;
  aRange.location = 9999999; // horray for magic number
  aRange.length = 1;
  [self setSelectionRange:aRange];
  [self scrollToMakeCaretVisible:YES];
}

- (void)insertText:(NSString*)text
{
  // Insert at the end of the WebKit WebView
  [[[self _webView] webView] moveToEndOfDocument:self];
  [[self _webView] insertText:text];
  [self scrollToEnd];
}

@end
