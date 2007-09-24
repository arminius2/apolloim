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

#import <UIKit/UIBox.h>
#import <UIKit/UIImageView.h>
#import "common.h"

#import "LoginCell.h"

@implementation LoginCell

-(id)initWithUser:(User *) auser forLoginView:(id) view
{
	
	if ((self == [super initWithFrame:CGRectMake(0, 0, 320, 59)]) != nil) 
	{
		struct __GSFont * large_font = [NSClassFromString(@"WebFontCache") 
					createFontWithFamily:@"Helvetica" traits:0 size:18];
		struct __GSFont * small_font = [NSClassFromString(@"WebFontCache") 
					createFontWithFamily:@"Helvetica" traits:0 size:13];
		
		enclosing_view = view;

		is_deleting = NO;
		user = auser;
		float transparent[4] = {0.0, 0.0, 0.0, 0.0};
		float grey[4] = {0.47, 0.47, 0.47, 1.0};
		float dark_grey[4] = {0.34, 0.34, 0.34, 1.0};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

		background_img = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 320, 59)];
		[background_img setImage:[UIImage applicationImageNamed: @"login_userpanel_background.png"]];
		
		edit_img = [[UIImageView alloc] initWithFrame: CGRectMake(296, 20, 9, 18)];
		[edit_img setImage:[UIImage applicationImageNamed: @"login_editarrow.png"]];
		[edit_img setBackgroundColor: CGColorCreate(colorSpace, transparent)];

		NSLog(@"Creating Cell For: %@", [user getName]);
		user_label = [[UITextLabel alloc] initWithFrame: CGRectMake(25.0f, 5.0f, 170.f, 35.0f)];
		[user_label setText: [user getName]];
		[user_label setFont:large_font];
		[user_label setBackgroundColor: CGColorCreate(colorSpace, transparent)];
		[user_label setColor: CGColorCreate(colorSpace, dark_grey)];

		protocol_label = [[UITextLabel alloc] initWithFrame: CGRectMake(25, 25, 180, 30)];
		[protocol_label setText: [user getProtocol]];
		[protocol_label setFont: small_font];
		[protocol_label setBackgroundColor: CGColorCreate(colorSpace, transparent)];
		[protocol_label setColor: CGColorCreate(colorSpace, grey)];

		enable_switch = [[UISwitchControl alloc]
					initWithFrame:CGRectMake(215.0f, 10.0f, 50.0f, 58.0f)];
		[enable_switch setBackgroundColor: CGColorCreate(colorSpace, transparent)];
		[enable_switch addTarget:self action:@selector(switchClick:) forEvents:255];
		
		delete_spiral = [[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
		[delete_spiral setFrame:CGRectMake(0.0 , 400.0, 58.0, 58.0)];
		[delete_spiral setImage: [UIImage applicationImageNamed: @"deletebutton1_up.png"]
					forState: 0];
		[delete_spiral setImage: [UIImage applicationImageNamed: @"deletebutton1_down.png"]
					forState: 1];
		[delete_spiral addTarget:self action:@selector(buttonEvent:) forEvents:255];
		[delete_spiral setAutosizesToFit:YES];

		[self addSubview:background_img];
		[self addSubview:edit_img];
		[self addSubview:enable_switch];
		[self addSubview:user_label];
		[self addSubview:protocol_label];
		[self addSubview:delete_spiral];

		[self setEditing:false];
		NSLog(@"Cell init complete");
	}

	return self;
}

-(void)setEditing:(BOOL) editing
{
	float offset = 320.0f;
	if(editing)
	{
		// We are editing, get rid of the slider
		// and add the delete and edit images
		
		// Get rid of it by moving it off screen
		[enable_switch setFrame:CGRectMake(220.0f+offset, 0.0f, 91.0f, 58.0f)];
		//[user_label setFrame:CGRectMake(45.0f, 5.0f, 170.f, 35.0f)];
		//[protocol_label setFrame: CGRectMake(45.0, 25.0, 180.0, 30.0)];
		//[delete_spiral setFrame:CGRectMake(11.0 , 16.0, 26.0, 26.0)];
		[enable_switch setValue: YES];
		[enable_switch needsDisplay];
		[enable_switch setValue: NO];
		[enable_switch needsDisplay];
		[enable_switch setValue: [user isActive]];

		// Move the edit/delete images back
		[edit_img setFrame:CGRectMake(296, 20, 9, 19)];
	}
	else
	{
		[enable_switch setFrame:CGRectMake(220.0f, 0.0f, 91.0f, 58.0f)];
		[user_label setFrame:CGRectMake(25.0f, 5.0f, 170.f, 35.0f)];
		[protocol_label setFrame: CGRectMake(25.0, 25.0, 180.0, 30.0)];
		//[delete_spiral setFrame:CGRectMake(11.0+offset , 16.0, 26.0, 26.0)];
		[enable_switch setValue: YES];
		[enable_switch needsDisplay];
		[enable_switch setValue: NO];
		[enable_switch needsDisplay];
		[enable_switch setValue: [user isActive]];

		[edit_img setFrame:CGRectMake(300+offset, 20, 10, 20)];
	}
	[enable_switch needsDisplay];
	[self needsDisplay];
}

-(void)setDeligate:(id) adeligate
{
}

-(void) switchClick:(UISwitchControl *) sw
{	
	[user setActive: [sw value]];
}

-(void) needsDisplay
{
	[super needsDisplay];
}

- (void) buttonEvent:(UIPushButton *)button 
{

	NSLog(@"Delete Button Clicked");
	
	if (![button isPressed] && [button isHighlighted])
	{
		if(button == delete_spiral)
		{
			if(!is_deleting)
			{
				[enclosing_view setDeleting:YES fromCell:self];
				[delete_spiral setImage: [UIImage applicationImageNamed: @"deletebutton1_down.png"]
							forState: 0];
			}
			else
			{
				[enclosing_view setDeleting:NO fromCell:self];
				[delete_spiral setImage: [UIImage applicationImageNamed: @"deletebutton1_up.png"]
							forState: 0];
			}
			is_deleting = !is_deleting;
		}
	}
}
@end
