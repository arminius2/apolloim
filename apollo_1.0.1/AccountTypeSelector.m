/*
 By Adam Bellmore

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
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIImage.h>
#import <UIKit/UITextView.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIPickerTableCell.h>

#import "AccountEditView.h"
#import "ProtocolManager.h"

@implementation AccountTypeSelector
/*
{
	UIImageView * top_bar;
	UIPushButton * cancel_button;
	UIPushButton * save_button;
}
*/
-(id) initWithFrame:(CGRect) aframe
{
	if ((self == [super initWithFrame: aframe]) != nil) 
	{
		UITableColumn *col = [[UITableColumn alloc]
                	initWithTitle: @"Account"
                	identifier:@"account"
                	width: 320.0
                ];
		[self setSeparatorStyle:1];
		[self addTableColumn: col];
		[self setDelegate: self];
		[self setDataSource: self];
		[self setRowHeight: 45.0];

		accounts = [[NSMutableArray alloc] init];
		[self reloadData];
	}
	return self;
}

-(void) selectProtocol:(NSString *) protocol
{
	NSArray * acc = [[ProtocolManager sharedInstance] getAvailableProtocols];
	
	int i = 0;
	for(i; i<[acc count]; i++)
	{
		if([[acc objectAtIndex:i] isEqualToString:protocol])
		{
			[self selectRow:i byExtendingSelection:NO];
			[self scrollRowToVisible:i];
		}
	}
}

- (void)reloadData
{
	NSArray * acc = [[ProtocolManager sharedInstance] getAvailableProtocols];
	
	int i = 0;
	for(i; i<[acc count]; i++)
	{
		UIImageAndTextTableCell * cell = [[UIImageAndTextTableCell alloc] init];
		[cell setTitle:[acc objectAtIndex:i]];
		NSString * image_name = [NSString stringWithFormat:@"icon-%@.png", [acc objectAtIndex:i]];
		NSLog(@"Loading Image: %@", image_name);
		[cell setImage:[UIImage applicationImageNamed: image_name]];

		[accounts addObject:cell];
	}

	[super reloadData];
}

- (int)numberOfRowsInTable:(id)fp8
{
	NSLog(@"Size: %i", [accounts count]);
	return [accounts count];
}

- (id)table:(id)fp8 cellForRow:(int)row column:(id)col
{
	return [accounts objectAtIndex: row];
}

- (int)numberOfColumns
{
	return 1;
}

@end
