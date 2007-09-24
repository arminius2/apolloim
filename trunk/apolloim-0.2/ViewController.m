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
#import <UIKit/UITransitionView.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView.h>
#import <UIKit/UIAlertSheet.h>

#import "ViewController.h"
#import "LoginView.h"
#import "BuddyListView.h"
#import "Conversation.h"
#import "User.h"
#import "ApolloCore.h"

extern UIApplication *UIApp;

static id sharedInstanceViewControl;

@implementation ViewController 

-(id) initWithFrame:(CGRect) aframe
{
	if ((self == [super initWithFrame: aframe]) != nil) 
	{
		frame = CGRectMake(aframe.origin.x, aframe.origin.y,
					aframe.size.width, aframe.size.height);
		login_view = [[LoginView alloc] initWithFrame:aframe];
		buddy_list_view = [[BuddyListView alloc] initWithFrame:aframe];

		buddy_conversations = [[NSMutableDictionary alloc] init];

		transition = [[UITransitionView alloc] initWithFrame:aframe];

		blank = [[UIBox alloc] initWithFrame:frame];

		connectSheet = [[UIAlertSheet alloc]initWithTitle:@"Connecting..." buttons:nil defaultButtonIndex:1 delegate:self context:nil];
		[connectSheet setDimsBackground:YES];

		[self addSubview: transition];
		[self transitionToLoginView];
	}
	return self;
}

-(void) transitionTo:(UIView *) view slideDirection:(int) style
{
	[current_view resignFirstResponder];
	prev_view = current_view;
	current_view = view;
	[transition transition:style toView:view];
	[view becomeFirstResponder];
}

-(void) transitionToLoginView
{
	[self transitionToLoginViewWithEditActive:NO];
}

-(void) transitionToLoginViewWithEditActive:(BOOL) is_active
{
	int trans = 0;

	if(current_view == account_edit_view)
		trans = 2;
	if(current_view == buddy_list_view)
		trans = 2;

	[login_view reloadData];
	[login_view setIsEditing:!is_active];

	[self transitionTo:login_view slideDirection:trans];
}

-(void) transitionToBlankView
{
	[self transitionTo:blank slideDirection:0];
}

-(void) reverseView
{
	[self transitionTo:prev_view slideDirection:0];
}

-(void) transitionToBuddyListView
{
	int trans = 2;

	if(current_view == login_view)
		trans = 1;

	[buddy_list_view reloadData];
	[self transitionTo:buddy_list_view slideDirection:trans];
}

-(void) forceBuddyListRefresh
{
	[buddy_list_view reloadData];
}

-(void) transitionToAccountEditView
{
	if(account_edit_view)
		[account_edit_view release];

	account_edit_view = [[AccountEditView alloc] initWithFrame:frame];
	[self transitionTo:account_edit_view slideDirection:1];
}

-(void) transitionToAccountEditViewWithUser:(User *) user
{
	if(account_edit_view)
		[account_edit_view release];

	account_edit_view = [[AccountEditView alloc] initWithFrame:frame];
	[account_edit_view loadUser:user];
	[self transitionTo:account_edit_view slideDirection:1];
}

-(void) transitionToConversationWith:(Buddy *) buddy
{
	Conversation * conv = [buddy_conversations objectForKey:[buddy getID]];
	if(conv==nil)
	{
		conv = [[Conversation alloc] initWithFrame: frame 
					withOwner:[buddy getOwner] withBuddy: buddy andDelegate:self];
		[buddy_conversations setObject:conv forKey:[buddy getID]];
	}

	[self transitionTo: conv slideDirection:1];
	[conv addTimeStamp];
}

-(Conversation *) createConversationWith:(Buddy *) buddy
{
	Conversation * conv = [buddy_conversations objectForKey:[buddy getID]];
	if(conv==nil)
	{
		conv = [[Conversation alloc] initWithFrame: frame 
					withOwner:[buddy getOwner] withBuddy: buddy andDelegate:self];
		[buddy_conversations setObject:conv forKey:[buddy getID]];

		NSLog(@"Creating Conversation For: %@", [buddy getName]);
	}

	[conv addTimeStamp];	
	return conv;
}

-(void) closeConversationWith:(Buddy *) buddy
{
	[buddy clearMessageCount];
	[buddy_conversations removeObjectForKey:[buddy getID]];
}

-(BOOL) conversationWithBuddyExists:(Buddy *) buddy
{
	BOOL found = NO;
	Conversation * conv = [buddy_conversations objectForKey:[buddy getID]];

	return (conv?YES:NO);
}

+(id) initSharedInstanceWithFrame:(CGRect) win
{
	sharedInstanceViewControl = [[ViewController alloc] initWithFrame:win];
	return sharedInstanceViewControl;
}

-(CGRect) getFrame
{
	return frame;
}

+(id) sharedInstance
{
	return sharedInstanceViewControl;
}

- (void)mouseDown:(struct __GSEvent *)fp8
{
	NSLog(@"BING");
}

-(void) showNewMessageFrom:(NSString*)dude withMessage:(NSString*)groovy
{
		UIAlertSheet* sheet = [[UIAlertSheet alloc]initWithTitle:dude buttons:nil defaultButtonIndex:1 delegate:self context:nil];
        [sheet setBodyText:[self removeHTML:[[NSMutableString alloc]initWithString:groovy]]];
        [sheet addButtonWithTitle:@"OK"];
		[sheet setAlertSheetStyle:0];
		[sheet setShowsOverSpringBoardAlerts:YES];
		[sheet popupAlertAnimated:NO];
}

-(void) showError:(NSString *) error
{
	//UIAlertSheet *sheet = [[UIAlertSheet alloc] initWithFrame: CGRectMake(0, 240, 320, 240)];
	UIAlertSheet* sheet = [[UIAlertSheet alloc] initWithTitle:[[NSString alloc]initWithString:@"Error:"] buttons:nil defaultButtonIndex:1 delegate:self context:nil];	
        [sheet setBodyText:error];
        [sheet addButtonWithTitle:@"OK"];
	[sheet setAlertSheetStyle:0];		
	[sheet popupAlertAnimated: YES];
        //[sheet presentSheetFromAboveView: self];
}

-(void) connectionFailureFor:(NSString*)account withMessage:(NSString*)message isDisconnect:(bool)maybe
{
		[connectSheet dismiss];
		UIAlertSheet* sheet = [[UIAlertSheet alloc]initWithTitle:[[NSString alloc]initWithFormat:@"%@",account] buttons:nil defaultButtonIndex:1 delegate:self context:nil];	
		[sheet setBodyText:[NSString stringWithString:message]];
		[sheet addButtonWithTitle:@"OK"];
		[sheet setAlertSheetStyle:0];		
//		[sheet performSelector:@selector(popupAlertAnimated:) withObject:YES afterDelay:0.4];		
		[sheet popupAlertAnimated: YES];
//		[account setActive:NO];
		[[ApolloCore sharedInstance] reset];
		
		//TODO
		//We pass the account in case we need to reconnect. 
		//Not implemented yet.		
		//That shouldn't even be here probably.  So maybe not
		//TODO
		//Figure out the best way to do that
}

-(void) connectStep:(int)step forAccount:(NSString*)account withMessage:(NSString*)message connected:(bool)status
{
//	if(![UIAlertSheet atLeastOneAlertVisible] && step == 0)
//	if(![UIAlertSheet atLeastOneAlertVisible])
	if(step==0)
	{
		[connectSheet presentSheetInView:self];		
	}			
	
		[connectSheet setTitle:[NSString stringWithFormat:@"Connecting %@", account]];			
		[connectSheet setBodyText:[[NSString alloc]initWithString:[NSString stringWithString:message]]];			
		
		if(status)  //Let's get rid of this sheet after we're done with it.
			[connectSheet performSelector:@selector(dismiss) withObject:nil afterDelay:0.8];
}

- (void)alertSheet:(UIAlertSheet *)sheet buttonClicked:(int)button
{
        [sheet dismiss];
}

- (void) transitionOnResume
{
	[self transitionToBlankView];
	[self reverseView];
}

- (NSString*) removeHTML:(NSMutableString *) from
{
	int del = 0;
	int i = 0;
	for(i; i< ([from length]); i++)
	{
		BOOL deleted = NO;	
		if([from characterAtIndex: i] == '<')
			del ++;
			
		if(del > 0)
		{
			deleted = YES;
		}
		
		if([from characterAtIndex: i] == '>')
		{
			if(del > 0)
				del --;
		}
		
		if(deleted)
		{
			NSRange r = NSMakeRange(i, 1);
			[from deleteCharactersInRange: r];
			i--;
		}
	}
	return [NSString stringWithString:[from copy]];
}

-(void)fullDisconnect
{
	buddy_conversations = [[NSMutableDictionary alloc] init];
}


@end
