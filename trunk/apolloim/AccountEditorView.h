//
//  AccountEditor.h
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITransitionView.h>
#import "UIKit/UITextView.h"
#import "UIKit/UISegmentedControl.h"
#import "UIKit/UIPreferencesTable.h"
#import "UIKit/UISwitchControl.h"
#import "UIKit/UIPreferencesTableCell.h"
#import "UIKit/UIPreferencesTextTableCell.h"
#import "Account.h"
#import "UIKit/UIKeyboard.h"
#import "ShellKeyboard.h"

@interface AccountEditorView : UIView 
{
	UINavigationBar		*_navBar;
	UITransitionView	*_transitionView;
	UIPreferencesTable	*_table;
	UISegmentedControl	*typeSelection;
	UISwitchControl		*enabledSwitch;	
		
	UITextField			*usernameField;
	UITextField			*passwordField;

	ShellKeyboard*			_keyboard;
		
	//Passed
	NSString			*passwordEXIST;
	NSString			*usernameEXIST;
	NSString			*connectionEXIST;
	//int					serviceEXIST;	
	//bool				enabledEXIST;	
	bool				editOrnew; //true \ false
    CGRect _rect;	
	
	Account				*account;
	id _delegate;
}

- (id)initWithFrame:(CGRect)frame;
- (void)setMode:(bool)_mode;
- (bool)getMode;
- (void)dealloc;
- (Account*)getAccount;
- (void)setAccount:(Account*)theAccount;
- (void)setDelegate:(id)delegate;
- (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group;
- (float)preferencesTable:(UIPreferencesTable *)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed ;
- (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable ;
- (UIPreferencesTextTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForRow:(int)row inGroup:(int)group ;
@end
