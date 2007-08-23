// ShellView.h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UITextView.h>

@class ShellKeyboard;

@interface ConvoBox : UITextView {
  NSMutableString* _nextCommand;
  bool _ignoreInsertText;
  bool _controlKeyMode;
  ShellKeyboard* _keyboard;
  UIView *_mainView;
  int _fd;
  id _heartbeatDelegate;
  SEL _heartbeatSelector;
}

- (id)initWithFrame:(struct CGRect)fp8;
- (void)setKeyboard:(ShellKeyboard*) keyboard;
- (void)scrollToEnd;
- (void)insertText:(NSString*)text;

@end
