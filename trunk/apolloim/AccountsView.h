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
