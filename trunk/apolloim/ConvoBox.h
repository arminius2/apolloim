#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UITextView.h>

@interface ConvoBox : UITextView {
}

- (id)initWithFrame:(struct CGRect)fp8;
//- (void)setDelegate:(id)delegate;
- (void)scrollToEnd;
- (void)insertText:(NSString*)text;
//- (void)mouseUp:(struct __GSEvent *)fp8;
@end
