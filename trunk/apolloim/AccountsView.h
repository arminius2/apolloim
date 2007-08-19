//
//  AccountsView.h
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITransitionView.h>
#import "Account.h"


@interface AccountsView : UIView {
	UINavigationBar *_navBar;
	UITransitionView *_transitionView;
    CGRect _rect;	

	NSMutableArray *_accounts;
	UITable *_table;
	int _rowCount;
	id _delegate;
}
- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;
- (void)reloadData;
- (void)setDelegate:(id)delegate;
- (int)numberOfRowsInTable:(UITable *)table;
- (UIImageAndTextTableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col;
- (Account *)selectedAccount;
- (void)updateAccount:(Account*)aAccount withAccount:(Account*)thisAccount;
- (void)addAccount:(Account*)aAccount;
- (void)tableRowSelected:(NSNotification *)notification;
- (NSArray*)accounts;
- (void)setAccounts:(NSMutableArray*)accounts;
- (void)singleActive:(Account*)ActiveAccount;					
- (Account *)getActive;
@end
