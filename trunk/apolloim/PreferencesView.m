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

#import "PreferencesView.h"
#import "UIKit/UITextView.h"
#import "UIKit/UITransformAnimation.h"
#import "Acct.h"
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIView-Rendering.h>
#import "UIKit/UISwitchControl.h"
#import <UIKit/UIWindow.h>
#import <UIKit/CDStructures.h>
#import "UIKit/UIPreferencesTable.h"
#import "UIKit/UIPreferencesTableCell.h"
#import "UIKit/UIPreferencesTextTableCell.h"
#import "ApolloNotificationController.h"

@implementation PreferencesView

- (id)initWithFrame:(CGRect)frame
{
	if ((self == [super initWithFrame: frame]) != nil) 
	{
		_rect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);

		//Colors
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		float whiteComponents[4] = {1, 1, 1, 1};
		float transparentComponents[4] = {0, 0, 0, 0};
		float blackComponents[4] = {0.0, 0.0, 0.0, 1.0};
		
        	_table = [[UIPreferencesTable alloc] initWithFrame:frame];
        	[_table setDataSource:self];
		[_table setDelegate:self];
		[_table reloadData];		

		[self addSubview:	_table];
		_delegate = nil;

		soundSwitch = [[UISwitchControl alloc]initWithFrame:CGRectMake(200.0f, 10.0f, 320.0f, 480.0f)];
		[soundSwitch setValue:[[ApolloNotificationController sharedInstance]soundEnabled]];
		
		vibrateSwitch = [[UISwitchControl alloc]initWithFrame:CGRectMake(200.0f, 10.0f, 320.0f, 480.0f)];
		[vibrateSwitch setValue:[[ApolloNotificationController sharedInstance]vibrateEnabled]];
		
		
	}
	return self;
}

 - (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable 
 {
	return 2;
 }

 - (int)preferencesTable:(UIPreferencesTable *)aTable numberOfRowsInGroup:(int)group 
 {
	   return 1;
 }
 - (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group 
 {
         UIPreferencesTableCell * cell = [[UIPreferencesTableCell alloc] init];
         return [cell autorelease];
 } 
 
- (UIPreferencesTextTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForRow:(int)row inGroup:(int)group 
{
  	UIPreferencesTextTableCell * cell = [[UIPreferencesTextTableCell alloc] init];
	[cell setEnabled:NO];
        if(group == 0) 
	{
		if(row == 0)
		{
			[cell setTitle:			@"Enable Sound"];
			[cell setEnabled:		YES];	
			[[cell textField]setEnabled:	false];				
			[cell addSubview:		soundSwitch];
		}
	} 
	else 
	{
		if(row == 0)
		{
			[cell setTitle:			@"Enable Vibrate"];
			[cell setEnabled:		YES];	
			[[cell textField]setEnabled:	false];				
			[cell addSubview:		vibrateSwitch];
		}
	}
         return [cell autorelease];  
 }
 
 - (float)preferencesTable:(UIPreferencesTable *)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed 
 {
         return proposed;
 }
 - (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group
  {
         return;
}
		 
- (void)dealloc
{
	[super dealloc];
}

- (void)setDelegate:(id)delegate
{
	_delegate = delegate;
}

- (void)savePreferences
{
	[[ApolloNotificationController sharedInstance]setSoundEnabled:[soundSwitch value]];
	[[ApolloNotificationController sharedInstance]setVibrateEnabled:[vibrateSwitch value]];
	NSLog(@"Preferences Saved");
}

@end
