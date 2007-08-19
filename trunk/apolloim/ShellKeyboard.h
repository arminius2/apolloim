// ShellKeyboard.h
#import <UIKit/UIKit.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIPreferencesTable.h>



@interface ShellKeyboard : UIKeyboard
{
  bool _hidden;
}

// TODO: Init code that sets default values for _hidden

// TODO: Only show and toggle are called -- remove more dead code here
- (void)show:(UIPreferencesTable*)shellView;
- (void)hide:(UIPreferencesTable*)shellView;
- (void)toggle:(UIPreferencesTable*)shellView;

@end
