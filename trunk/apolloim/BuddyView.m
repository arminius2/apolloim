//
//  BuddyView.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BuddyView.h"

enum { 
	AIM_RECV_MESG		=	1,
	AIM_BUDDY_ONLINE	=	2, 
	AIM_BUDDY_OFFLINE	=	3, 
	AIM_BUDDY_AWAY		=	4, 
	AIM_BUDDY_UNAWAY	=	5,
	AIM_BUDDY_IDLE		=	6,	
	AIM_BUDDY_MSG_RECV	=   7,
	AIM_CONNECTED		=   8,
	AIM_DISCONNECTED	=	9
};

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

- (void)updateBuddy:(Buddy*)aBuddy withCode:(int)Code
{
	int i=0,max=[self numberOfRowsInTable:_table];
	
	//Search for buddy
	//if username matches, replace new buddy object with it
	//else add the buddy
	NSLog(@"BUDDY IS %@", [aBuddy properName]);

	switch(Code)
	{
		case AIM_BUDDY_ONLINE:
			for(i=0; i<max; i++)
			{	
				if([[[_buddies objectAtIndex:i]properName]isEqualToString:[aBuddy properName]])
				{
					NSLog(@"%@ exists.  No add.", [aBuddy properName]);
					return;			
				}
			}
			if([aBuddy online])
			{
				NSLog(@"%@ is online.",[aBuddy properName]);
				[_buddies addObject:aBuddy];
			}
			else
				NSLog(@"%@ is not online.",[aBuddy properName]);
			break;
		case AIM_BUDDY_OFFLINE:
			for(i=0; i<max; i++)
			{
				if([[[_buddies objectAtIndex:i]properName]isEqualToString:[aBuddy properName]])
				{
					[_buddies removeObjectAtIndex:i];
					NSLog(@"Buddy is offline.");
					return;			
				}			
			}
			break;
	}		
	[self reloadData];
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
	[cell setImage:[UIImage applicationImageNamed: @"aim.png"]];	
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
