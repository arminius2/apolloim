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
	AIM_DISCONNECTED	=	9,
	AIM_READ_MSGS		=   10
};

@implementation BuddyView

- (id)initWithFrame:(CGRect)frame
{
	if ((self == [super initWithFrame: frame]) != nil) 
	{
		//NSLog(@"BuddyView>> Init BuddyView...");
		UITableColumn *col = [[UITableColumn alloc]
			initWithTitle: @"Buddies"
			identifier:@"buddies"
			width: frame.size.width
		];
		//NSLog(@"BuddyView>> init table...");
		_table = [[UITable alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, 410.0f)]; //this should prolly be frame.size.height
		[_table addTableColumn: col];
		[_table setSeparatorStyle: 1];
		[_table setDelegate: self];
		[_table setDataSource: self];

		//NSLog(@"BuddyView>> init _accounts");
		_buddies = [[NSMutableArray alloc] init];
		buddyList = [[NSMutableArray alloc]init];
		
		_rowCount = 0;
		_delegate = nil;
		//NSLog(@"BuddyView>> Adding table view...");
		[_table setAllowsRubberBanding:NO];
		[self addSubview: _table];
		//NSLog(@"BuddyView>> Reloading data...");
		[self reloadData];				
	}
	return self;
}

-(void)reloadData
{
	//LETS SORT THIS BITCHCCCHCHCHC
	_buddies = [[_buddies sortedArrayUsingSelector:@selector(compareNames:)]mutableCopy];
	[_table reloadData];
}

- (void)updateBuddy:(Buddy*)aBuddy withCode:(int)Code
{
	int i=0,max=[self numberOfRowsInTable:_table];
	bool recvd = NO;	
	//Search for buddy
	//if username matches, replace new buddy object with it
	//else add the buddy
	//NSLog(@"--------");
//	NSLog(@"BuddyView.m> Buddy is %@", [aBuddy properName]);

	switch(Code)
	{
		case AIM_BUDDY_ONLINE:
			for(i=0; i<max; i++)
			{	
				if([[[_buddies objectAtIndex:i]properName]isEqualToString:[aBuddy properName]])
				{
					//NSLog(@"BuddyView.m> %@ exists.  No add.", [aBuddy properName]);
					return;
				}
			}
			if([aBuddy online])
			{
				//NSLog(@"BuddyView.m> %@ is online.",[aBuddy properName]);
				[_buddies addObject:aBuddy];
			}
			else
				//NSLog(@"BuddyView.m> %@ is not online.",[aBuddy properName]);
			break;
		case AIM_BUDDY_OFFLINE:
			for(i=0; i<max; i++)
			{
				if([[[_buddies objectAtIndex:i]properName]isEqualToString:[aBuddy properName]])
				{
					[_buddies removeObjectAtIndex:i];
					//NSLog(@"BuddyView.m> %@ is offline --  was at index %d",[aBuddy properName], i);
					[self reloadData];
					return;
				}			
			}
			break;
		case AIM_BUDDY_AWAY:
			for(i=0; i<max; i++)
			{
				if([[[_buddies objectAtIndex:i]properName]isEqualToString:[aBuddy properName]])
				{
					[[_buddies objectAtIndex:i]setOnline:NO];
					//NSLog(@"BuddyView.m> %@ is away",[aBuddy properName]);
					[self reloadData];
					return;
				}			
			}
		case AIM_BUDDY_UNAWAY:
			for(i=0; i<max; i++)
			{
				if([[[_buddies objectAtIndex:i]properName]isEqualToString:[aBuddy properName]])
				{
					[[_buddies objectAtIndex:i]setOnline:YES];
					//NSLog(@"BuddyView.m> %@ is back",[aBuddy properName]);
					[self reloadData];
					return;
				}			
			}
			break;
		case AIM_READ_MSGS:	
			for(i=0; i<max; i++)
			{
				if([[[_buddies objectAtIndex:i]properName]isEqualToString:[aBuddy properName]])
				{
					[[_buddies objectAtIndex:i]setUnreadMsgs:0];
					[[_buddies objectAtIndex:i]setInAConversation:YES];					
					NSLog(@"BuddyView.m> You have read %@'s messages ",[aBuddy properName]);
					[self reloadData];
					return;
				}			
			}
			break;
		case AIM_RECV_MESG:		
			for(i=0; i<max; i++)
			{
				if([[[_buddies objectAtIndex:i]properName]isEqualToString:[aBuddy properName]])
				{
					recvd = YES;
					[[_buddies objectAtIndex:i]incrementMessages];
					NSLog(@"BuddyView.m> %@ has given you new messages",[aBuddy properName]);
					[self reloadData];
				}		
			}
			if(!recvd)
			{
				//NSLog(@"BuddyView.m> ---------");
				//NSLog(@"BuddyView.m> We don't have this buddy in our fucking list.  Bastard.");
				//NSLog(@"BuddyView.m> He might be our buddy, he might not be - point being, I want this to just work and not have to work properly.");
				//NSLog(@"BuddyView.m> For now, we're going to add him to the list.  Delete him if you want to.");
				//NSLog(@"BuddyView.m> In the future, we should get a buddy_list on sign on, and then do a check against who's online, and the rest are offline.");				
				//NSLog(@"BuddyView.m> That's for Beta 2. STAY TUNED.  PS This src is in yer buddylist warnin' yer dudes.");				
				//NSLog(@"BuddyView.m> ---------");
				[aBuddy incrementMessages];
				[_buddies addObject:aBuddy];		
			}						
			break;
//		case AIM_RECV_INFO:
//		break;
			
	}		
//	NSLog(@"--------");	
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
	CGColorSpaceRef const colorSpace = CGColorSpaceCreateDeviceRGB();
	float transparentComponents[4] = {0, 0, 0, 0};
	
	UIImageAndTextTableCell *cell = [[UIImageAndTextTableCell alloc] init];
	[cell setTitle: [[_buddies objectAtIndex: row]name]];
	if([[_buddies objectAtIndex:row]online])
		[cell setImage:[UIImage applicationImageNamed: @"aim_online.png"]];	
		else
		[cell setImage:[UIImage applicationImageNamed: @"aim_away.png"]];	

	if([[_buddies objectAtIndex: row]unreadMsgs] > 0)
	{
		UITextLabel *unreadmsgs	=	[[UITextLabel alloc] initWithFrame:CGRectMake(220.0f, 20.0f, 210.0f, 20.0f)];
		[unreadmsgs setText: [NSString stringWithFormat:@"%d msgs",[[_buddies objectAtIndex: row]unreadMsgs]]];
		[unreadmsgs setWrapsText:YES];
		[unreadmsgs setBackgroundColor:CGColorCreate(colorSpace, transparentComponents)];			
		[cell addSubview:unreadmsgs];
	}	
	return cell;
}

- (void)tableRowSelected:(NSNotification *)notification 
{
	//NSLog(@"BuddyView.m>--------");	
	//NSLog(@"BuddyView.m> %@ Selected",[[self selectedBuddy]name]);
	//NSLog(@"BuddyView.m> Moving to window from delegate...");
	[_delegate switchToConvo:[self selectedBuddy]];
	//NSLog(@"BuddyView.m>--------");	
}

- (Buddy *)selectedBuddy 
{
	if ([_table selectedRow] == -1)
		return nil;

	return [_buddies objectAtIndex: [_table selectedRow]];
}
- (void) dealloc 
{
	[_buddies	release];
	[_table		release];
	[super		dealloc];
}

@end
