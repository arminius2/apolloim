//
//  AccountsView.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AccountsView.h"
#import "Account.h"
#import <UIKit/UITextLabel.h>

@implementation AccountsView
- (id)initWithFrame:(struct CGRect)frame{
	if ((self == [super initWithFrame: frame]) != nil) {
		//NSLog(@"AccountsView>> Init AccountsView...");
		UITableColumn *col = [[UITableColumn alloc]
			initWithTitle: @"Account"
			identifier:@"account"
			width: frame.size.width
		];
		//NSLog(@"AccountsView>> init table...");
		_table = [[UITable alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[_table addTableColumn: col];
		[_table setSeparatorStyle: 1];
		[_table setDelegate: self];
		[_table setDataSource: self];

		//NSLog(@"AccountsView>> init _accounts");
		_accounts = [[NSMutableArray alloc] init];
		
		_rowCount = 0;
		_delegate = nil;
		//NSLog(@"AccountsView>> Reloading data...");
		[self reloadData];		
		//NSLog(@"AccountsView>> Adding table view...");
		[self addSubview: _table];
	}
	return self;
}

- (void)dealloc {
	[_accounts release];
	[_table release];
	_delegate = nil;
	[super dealloc];
}

- (void)updateAccount:(Account*)aAccount withAccount:(Account*)thisAccount
{
	[_accounts replaceObjectAtIndex:[_accounts indexOfObject:aAccount] withObject:thisAccount];
	[_table reloadData];
}

- (void)addAccount:(Account*)aAccount
{
	[_accounts addObject:aAccount];
	_rowCount++;
	[_table reloadData];	
}

- (void)reloadData 
{
	//Readd all accounts, for now add in dummy account
	/*foreach(account in _accounts)
	{
		
	}*/
	//NSLog(@"AccountsView>> Reloading table data...");
			
	_rowCount = [_accounts count];
	[_table reloadData];
}

- (void)setDelegate:(id)delegate {
	_delegate = delegate;
}

- (int)numberOfRowsInTable:(UITable *)table {
	return _rowCount;
}

- (UIImageAndTextTableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col {
	CGColorSpaceRef const colorSpace = CGColorSpaceCreateDeviceRGB();
	float transparentComponents[4] = {0, 0, 0, 0};
	float grayComponents[4] = {0.55, 0.55, 0.55, 1};
	float blueComponents[4] = {0.208, 0.482, 0.859, 1};

	UIImageAndTextTableCell *cell = [[UIImageAndTextTableCell alloc] init];

//	if([[_accounts objectAtIndex: row]enabled])
//		[cell setSelected:YES withFade:YES];

	[cell setTitle: [[_accounts objectAtIndex: row]username]];
	[cell setImage:[UIImage applicationImageNamed: @"aim.png"]];			
	
	//Create description label------------------------------------------------      X      Y       length  height
	UITextLabel *activeLabel	=	[[UITextLabel alloc] initWithFrame:CGRectMake(220.0f, 0.0f, 210.0f, 20.0f)];
	if([[_accounts objectAtIndex: row]enabled])
		[activeLabel setText:@"Active."];
		else
		[activeLabel setText:@""];		

	[activeLabel setWrapsText:YES];
	[activeLabel setBackgroundColor:CGColorCreate(colorSpace, transparentComponents)];

	UITextLabel *connLabel	=	[[UITextLabel alloc] initWithFrame:CGRectMake(220.0f, 20.0f, 210.0f, 20.0f)];
	[connLabel setText: @"AIM"];
	[connLabel setWrapsText:YES];
	[connLabel setBackgroundColor:CGColorCreate(colorSpace, transparentComponents)];
	
	[cell addSubview: activeLabel];
	[cell addSubview: connLabel];
	
	return cell;
}

- (void)tableRowSelected:(NSNotification *)notification {
//	if( [_delegate respondsToSelector:@selector( accountsView:accountSelected: )] )
		[_delegate accountsView:self accountSelected:[self selectedAccount]];	
}

- (Account *)selectedAccount {
	if ([_table selectedRow] == -1)
		return nil;
	//NSLog(@"AccountsView>> ACCOUNT SELECTED: %@",  [[_accounts objectAtIndex:[_table selectedRow]]username]);
	return [_accounts objectAtIndex:[_table selectedRow]];
}

- (void)setAccounts:(NSMutableArray*)accounts
{
	_accounts = [[NSMutableArray alloc]initWithArray:accounts];
	[self reloadData];
}

- (void)singleActive:(Account*)ActiveAccount
{
	//NSLog(@"Finding other actives...");
	int i=0, max=_rowCount;
	for(i=0; i<max; i++)
	{
		if(![[[_accounts objectAtIndex:i] username]isEqualToString:[ActiveAccount username]])
		{
			//NSLog(@"Settin inactive %@", [[_accounts objectAtIndex:i] username]);
			[[_accounts objectAtIndex:i] setEnabledString:@"NO"];
		}
	}
}

- (Account *)getActive
{
	int i=0, max=_rowCount;
	for(i=0; i<max; i++)
	{
		if([[_accounts objectAtIndex:i] enabled])
		{
			return [_accounts objectAtIndex:i];
		}
	}
	return nil;
}

- (NSArray*)accounts
{
	return [_accounts copy];
}
@end
