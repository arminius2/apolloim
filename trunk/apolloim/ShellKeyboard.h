// ShellKeyboard.h
#import <UIKit/UIKit.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIPreferencesTable.h>
#import "ConvoBox.h"

@interface ShellKeyboard : UIKeyboard
{
  bool _hidden;
  CGRect cellFrame;
  CGRect kbFrame;
}

- (void)show:(UITextView*)sendView    withCell:(UIImageAndTextTableCell*) cell;
- (void)hide:(UITextView*)sendView    withCell:(UIImageAndTextTableCell*) cell;
- (void)toggle:(UITextView*)sendView  withCell:(UIImageAndTextTableCell*) cell;

@end
