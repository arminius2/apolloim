#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UITextView.h>

@class ShellKeyboard;

@interface ConvoBox : UITextView {
  ShellKeyboard* _keyboard;
}

- (id)initWithFrame:(struct CGRect)fp8;
- (void)setKeyboard:(ShellKeyboard*) keyboard;
- (void)scrollToEnd;
- (void)insertText:(NSString*)text;

@end
