//
//  BuddyView.h
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITransitionView.h>
#import "Account.h"
#import "Buddy.h"
#import "Conversation.h"

@interface BuddyView : UIView {
	UINavigationBar *_navBar;
	UITransitionView *_transitionView;
    CGRect _rect;	
	
	NSMutableArray *_buddies;
	
	UITable *_table;
	int _rowCount;
	id _delegate;
}
- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;
- (void)reloadData;
- (void)setDelegate:(id)delegate;
- (int)numberOfRowsInTable:(UITable *)table;
- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col;
- (Buddy *)selectedBuddy;
- (void)updateBuddy:(Buddy*)aBuddy withCode:(int)Code;
- (void)tableRowSelected:(NSNotification *)notification;
@end
