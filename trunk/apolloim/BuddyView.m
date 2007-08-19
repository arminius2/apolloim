//
//  BuddyView.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BuddyView.h"


@implementation BuddyView

- (id)initWithFrame:(CGRect)frame
{
	if ((self == [super initWithFrame: frame]) != nil) 
	{
		NSLog(@"BuddyView>> Init BuddyView...");
		UITableColumn *col = [[UITableColumn alloc]
			initWithTitle: @"Buddies"
			identifier:@"buddies"
			width: frame.size.width
		];
		NSLog(@"BuddyView>> init table...");
		_table = [[UITable alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[_table addTableColumn: col];
		[_table setSeparatorStyle: 1];
		[_table setDelegate: self];
		[_table setDataSource: self];

		NSLog(@"BuddyView>> init _accounts");
		_buddies = [[NSMutableArray alloc] init];
		
		_rowCount = 0;
		_delegate = nil;
		NSLog(@"BuddyView>> Reloading data...");
		[self reloadData];		
		NSLog(@"BuddyView>> Adding table view...");
		[self addSubview: _table];
	}
	return self;
}

-(void)reloadData
{
	[_table reloadData];
}

- (void)updateBuddy:(Buddy*)aBuddy
{
	/*int i=0,max=[self numberOfRowsInTable:_table];
	
	//Search for buddy
	//if username matches, replace new buddy object with it
	//else add the buddy
	
	for(i=0; i<max;i++)
	{
		Buddy* comparisonBuddy = [_buddies objectAtIndex:i];

		if([[[_buddies objectAtIndex:i]name] isEqualToString:[aBuddy name]] && [[_buddies objectAtIndex:i]online])
		{
			NSLog(@"REPLACE");
			[_buddies replaceObjectAtIndex:i withObject:aBuddy];
			return;
		}	
		else
		if([[[_buddies objectAtIndex:i]name] isEqualToString:[aBuddy name]] && ![[_buddies objectAtIndex:i]online])
		{
			NSLog(@"OFFLINE");
			[_buddies removeObject:[_buddies objectAtIndex:i]];
			return;
		}
	}
	
	NSLog(@"ADD BUDDY");
	[_buddies addObject:aBuddy];
	[self reloadData];*/
}

- (void)setDelegate:(id)delegate
{
	_delegate = delegate;
}

- (int) numberOfRowsInTable: (UITable *)table
{
    return [_buddies count];	
}

- (UITableCell *)table:(UITable *)table cellForRow:(int)row column:(UITableColumn *)col
{
	UIImageAndTextTableCell *cell = [[UIImageAndTextTableCell alloc] init];
	[cell setTitle: [[_buddies objectAtIndex: row]name]];
	[cell setImage:[UIImage applicationImageNamed: @"smiley.gif"]];	
	return cell;
}

- (void)tableRowSelected:(NSNotification *)notification 
{
	NSLog(@"BUDDY: %@",[[self selectedBuddy]name]);
}

- (Buddy *)selectedBuddy 
{
	if ([_table selectedRow] == -1)
		return nil;

	return [_buddies objectAtIndex: [_table selectedRow]];
}
- (void) dealloc {
	[_buddies	release];
	[_table		release];
	[super		dealloc];
}

@end
