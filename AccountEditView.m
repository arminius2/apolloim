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

#import "AccountEditView.h"
#import "ViewController.h"
#import "ProtocolManager.h"
#import "ProtocolInterface.h"

@implementation AccountEditView

-(id) initWithFrame:(CGRect) aframe
{
	if ((self == [super initWithFrame: aframe]) != nil) 
	{
		bg_box = [[UIBox alloc] initWithFrame:aframe];

		top_bar = [[UIImageView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 59.0f)];
                [top_bar setImage:[UIImage applicationImageNamed: @"login_topnav_background.png"]];

		cancel_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
                [cancel_button setFrame:CGRectMake(5, 7.0, 59.0, 32.0)];
                [cancel_button setImage: [UIImage applicationImageNamed: @"login_addcancelbutton_up.png"]
                                        forState: 0];
                [cancel_button setImage: [UIImage applicationImageNamed: @"login_addcancelbutton_down.png"]
                                        forState: 1];
		[cancel_button addTarget:self action:@selector(buttonEvent:) forEvents:255];

		save_button = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
                [save_button setFrame:CGRectMake(aframe.size.width-(47.0+5.0), 7.0, 47.0, 32.0)];
                [save_button setImage: [UIImage applicationImageNamed: @"login_addsavebutton_up.png"]
                                        forState: 0];
                [save_button setImage: [UIImage applicationImageNamed: @"login_addsavebutton_down.png"]
                                        forState: 1];
		[save_button addTarget:self action:@selector(buttonEvent:) forEvents:255];
		[save_button setEnabled:NO];

		ats = [[AccountTypeSelector alloc] initWithFrame:CGRectMake(0, 46.0, 320.0, 480.0-46)];
		[ats setDelegate: self];

		[self addSubview:bg_box];
		[self addSubview:top_bar];
		[self addSubview:cancel_button];
		[self addSubview:save_button];
		[self addSubview:ats];
	}
	return self;
}

-(void) loadUser:(User *) user
{
	[ats setEnabled:NO];
	[ats selectProtocol:[user getProtocol]];
	[ats setFrame:CGRectMake(0, 46.0, 320.0, 30.0)];

	NSString * type = [user getProtocol];
	
	id<ProtocolInterface> pro = [[ProtocolManager sharedInstance] protocolByName:type];
	UIView * v = [pro getPreferencesViewWithFrame: CGRectMake(0.0f, 46.0f+30.0f, 320.0f, 480.0f-(46.0+30.0)) forUser:user andProtocol:type];
	[self addSubview:v];
}

- (void) buttonEvent:(UIPushButton *)button 
{
	NSLog(@"BUTTON");
	if (![button isPressed] && [button isHighlighted])
        {
		if(button == cancel_button)
		{
			[[ViewController sharedInstance] transitionToLoginViewWithEditActive:YES];
		}
		else
		{
			NSLog(@"TYPE");
			NSString * type = [[[ProtocolManager sharedInstance] getAvailableProtocols]objectAtIndex: [ats selectedRow]];
			NSLog(@"PROTO INSTANCE");
			id<ProtocolInterface> pro = [[ProtocolManager sharedInstance] protocolByName:type];
			NSLog(@"PERFORM SAVE.");
			if([pro performSave])
			{
				NSLog(@"PRE TRANSITION");
				[[ViewController sharedInstance] transitionToLoginViewWithEditActive:NO];
			}
		}
	}
}

-(void) tableRowSelected:(NSNotification *)notification
{
	NSString * type = [[[ProtocolManager sharedInstance] getAvailableProtocols]objectAtIndex: [ats selectedRow]];
	id<ProtocolInterface> pro = [[ProtocolManager sharedInstance] protocolByName:type];
	if(pro != nil)
	{
		[ats setEnabled:NO];
		[ats setFrame:CGRectMake(0, 46.0, 320.0, 45.0)];
		[ats scrollRowToVisible:[ats selectedRow]];
		[save_button setEnabled:YES];
		UIView * v = [pro getNewPreferencesViewWithFrame: CGRectMake(0.0f, 46.0f+45.0f, 320.0f, 465.0f-(46.0+45.0)) andProtocol:type];
		[self addSubview:v];
	}
	else
	{
		NSLog(@"ERROR! Protocol Not Found!");
	}
}


@end
