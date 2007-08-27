#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <UIKit/UITextField.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import "ConvoBox.h"
#import "Buddy.h"

@class ShellKeyboard;

@interface Conversation : UIView 
{
	UIImageAndTextTableCell* cell;

	ConvoBox* convoView;
	UINavigationBar *_msgBar;
	UITransitionView *_transitionView;
	UIPushButton	*send;
	UITextView		*sendField;	
	ShellKeyboard	*keyboard;
    CGRect _rect;	
	Buddy* buddy;
	bool _hidden;	
	id _delegate;	
}
- (id)initWithFrame:(struct CGRect)frame withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate;
- (void)rollKeyboard;	
- (void)foldKeyboard;
- (void)toggle;
//- (BOOL)respondsToSelector:(SEL)aSelector;
- (void)recvMessage:(NSString*)msg;
- (void)sendMessage;
- (Buddy*)buddy;
- (void)navigationBar:(UINavigationBar *)navbar buttonClicked:(int)button;
- (void)dealloc;
@end
