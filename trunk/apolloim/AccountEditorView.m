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

#import "AccountEditorView.h"
#import "UIKit/UITextView.h"
#import "UIKit/UITransformAnimation.h"
#import "Acct.h"
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Rendering.h>
#import "UIKit/UISwitchControl.h"
#import <UIKit/UIWindow.h>
#import <UIKit/CDStructures.h>
#import "UIKit/UIPreferencesTable.h"
#import "UIKit/UIPreferencesTableCell.h"
#import "UIKit/UIPreferencesTextTableCell.h"

@implementation AccountEditorView
- (id)initWithFrame:(CGRect)frame
{
if ((self == [super initWithFrame: frame]) != nil) {
		CGRect rect = frame;
		//NSLog(@"AccountsEditorView>> Init AccountsView...");
		rect.origin.x = rect.origin.y = 0.0f;		
		//Colors
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		float whiteComponents[4] = {1, 1, 1, 1};
		float transparentComponents[4] = {0, 0, 0, 0};
		
        _table = [[UIPreferencesTable alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 415.0f)];
        [_table setDataSource:self];
		[_table setDelegate:self];
		[_table reloadData];		

		enabledSwitch = [[UISwitchControl alloc]initWithFrame:CGRectMake(200.0f, 10.0f, 320.0f, 480.0f)];
		[enabledSwitch setEnabled:YES];

		//NSLog(@"AccountEditorView>> Keyboard implementation...");

		[self addSubview:	_table];		
		
//		[_table setKeyboardVisible:NO];
//		[[_table keyboard]setFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];

		[self setMode:		 false];
		_delegate = nil;
	}
	return self;
}
//*************************************

 - (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable 
 {
//	//NSLog(@"Number of groups");
	return 2;
 }

 - (int)preferencesTable:(UIPreferencesTable *)aTable numberOfRowsInGroup:(int)group 
 {
//         //NSLog(@"preferencesTable:numberOfRowsInGroup: %i", group);

      //   if(group == 0) return 2;
       //  else if(group == 1) return 2;
	   return 2;
 }
 - (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group 
 {
//         //NSLog(@"preferencesTable:cellForGroup: %i", group);
                                
         UIPreferencesTableCell * cell = [[UIPreferencesTableCell alloc] init];
         return [cell autorelease];
 } 
 
  - (UIPreferencesTextTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForRow:(int)row inGroup:(int)group 
  {
//         //NSLog(@"preferencesTable:cellForRow: %i", row);
         UIPreferencesTextTableCell * cell = [[UIPreferencesTextTableCell alloc] init];
         [cell setEnabled:NO];
         if(group == 0) 
		 {
                 if(row == 0) 
				{
					[cell setTitle:				@"Username"];
					[cell	setPlaceHolderValue:@"Your username"];					
					[[cell	textField]setText:	usernameEXIST];
					[cell	setEnabled:			YES];
					usernameField	=			[cell textField];		
					if(editOrnew)
						[usernameField setText:[account username]];	
				} 
				 else 
				if(row == 1) 
				{
					[cell setTitle:							@"Password"];
					[[cell textField]setText:				passwordEXIST];
					[cell	setEnabled:								YES];	
					[cell	setPlaceHolderValue:		@"Your password"];
					[[cell textField]setSecure:						YES];
					passwordField =						[cell textField];
					if(editOrnew)
						[passwordField setText:[account password]];					
				}
         } 
		 else 
		 {
			if(row == 0)
			{
				[cell setTitle:			@"Set Active"];
				[cell setEnabled:		          YES];	
				[[cell textField]setEnabled:	false];				
				if(editOrnew)
				{
					[enabledSwitch setValue:[[NSNumber numberWithFloat:[enabledSwitch value]]boolValue]];

					if([account enabled])
					{
						//NSLog(@"AccountEditorView>> Account Enabled...");	
						[enabledSwitch setValue:YES];
					}
					else
					{
						//NSLog(@"AccountEditorView>> Account Disabled...");		
						[enabledSwitch setValue:NO];
					}		
				}
				[cell addSubview:		enabledSwitch];						
			}
		 }					
         return [cell autorelease];  
 }
 
 - (float)preferencesTable:(UIPreferencesTable *)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed 
 {
//	//NSLog(@"heightForRow");
         return proposed;
 }
 - (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group
  {
//	//NSLog(@"isLabelGroup");
         return;
}
		 
//*************************************		 
 

- (void)setMode:(bool)_mode
{
	editOrnew = _mode;
}

- (bool)getMode
{
	return editOrnew;
}

-(void)setAccount:(Acct*)theAccount
{
	account = theAccount;

//	[theAccount setUsername:@"TESTALEX"];
	editOrnew = YES;
			
	//NSLog(@"AccountEditorView>> Account Set: %@", [theAccount username]);
}

-(Acct*)getAccount
{

	//NSLog(@"AccountEditorView>> Retreiving username...");
	Acct* getaccount = [[Acct alloc]init];
	[getaccount setUsername:[usernameField text]];
	//NSLog(@"AccountEditorView>> Retreiving password...");
	[getaccount setPassword:[passwordField text]];

	if([[NSNumber numberWithFloat:[enabledSwitch value]]boolValue])
	{
		//NSLog(@"AccountEditorView>> Account Enabled...");	
		[getaccount setEnabled:true];
	}
	else
	{
		//NSLog(@"AccountEditorView>> Account Disabled...");		
		[getaccount setEnabled:false];
	}		
	//NSLog(@"AccountEditorView>>  Returning Account: %@",[getaccount username]);	
	return getaccount;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)setDelegate:(id)delegate
{
	_delegate = delegate;
}
@end
