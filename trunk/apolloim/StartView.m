//
//  StartView.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import "StartView.h"
#import "ApolloTOC.h"
#import "ApolloIM-PrivateAccess.h"
#include <stdlib.h>
#include <stdio.h>
#include <objc/objc.h>
#include <objc/objc-runtime.h>

double objc_msgSend_fpret(id self, SEL op, ...) {
        Method method = class_getInstanceMethod(self->isa, op);
        int numArgs = method_getNumberOfArguments(method);

        if(numArgs == 2) {
                double (*imp)(id, SEL);
            imp = (double (*)(id, SEL))method->method_imp;
            return imp(self, op);
        } else if(numArgs == 3) {
                // FIXME: this code assumes the 3rd arg is 4 bytes
                va_list ap;
                va_start(ap, op);
                double (*imp)(id, SEL, void *);
            imp = (double (*)(id, SEL, void *))method->method_imp;
            return imp(self, op, va_arg(ap, void *));
        }

        // FIXME: need to work with multiple arguments/types
        fprintf(stderr, "ERROR: objc_msgSend_fpret, called on <%s %p> with selector %s, had to return 0.0\n", object_getClassName(self), self, sel_getName(op));
        return 0.0;
}

enum { 
	ACCOUNT_VIEW		=	1,
	ACCOUNT_EDITOR_VIEW	=	2,
	BUDDY_VIEW			=	3,
	CONVERSATION		=   4
};

static NSRecursiveLock *lock;

@implementation StartView
- (id)initWithFrame:(struct CGRect)rect 
{	
	CGColorSpaceRef const colorSpace = CGColorSpaceCreateDeviceRGB();
	float transparentComponents[4] = {0, 0, 0, 0};
	float grayComponents[4] = {0.55, 0.55, 0.55, 1};
	float blueComponents[4] = {0.208, 0.482, 0.859, 1};
	
	if ((self == [super initWithFrame: rect]) != nil) 
	{
		NSLog(@"StartView.m>>  Init startview...");
		float offset = 50.0;
		_navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 50.0f)];
//		NSLog(@"StartView.m>> Nav Bar...");
		[_navBar setDelegate: self];
		[_navBar showButtonsWithLeftTitle:@"Sign On" rightTitle:@"Add Account" leftBack: YES];
		[_navBar enableAnimation];
		
		navtitle = [[UITextLabel alloc]initWithFrame:CGRectMake(10, 10, rect.size.width, 15.0f)];
		[navtitle setText:@"ApolloIM"];
		[navtitle setCentersHorizontally:YES];
		[self addSubview:navtitle];

		NSLog(@"StartView.m>>  Initting base classes...");
		_accountsView	= [[AccountsView alloc]initWithFrame:rect];
		[_accountsView setDelegate:self];
		_buddyView		= [[BuddyView alloc]initWithFrame:rect];
		[_buddyView		setDelegate:self];
		_conversations	= [[NSMutableArray alloc]init];		
		
//		NSLog(@"StartView.m>>  Transition view...");
		_transitionView = [[UITransitionView alloc] initWithFrame: 
			CGRectMake(rect.origin.x, offset, rect.size.width, rect.size.height - offset)
		];
	
//		NSLog(@"StartView.m>>  Starting navbar...");
        [self addSubview: _navBar];

		[self addSubview: _transitionView];
		
//		NSLog(@"StartView.m>>  Transitioning...");

		[self makeACoolMoveTo:ACCOUNT_VIEW];
		prefFile = [[NSString alloc]initWithString:@"/var/root/Library/ApolloIM"];	
		[self populatePreferences];	
		EXIT=NO;
		_rect = rect;
	}
	return self;
}

- (void)populatePreferences
{
//	NSLog(@"StartView>> Populating Accounts...");
	if ([[NSFileManager defaultManager] fileExistsAtPath:prefFile]) 
		[_accountsView setAccounts:[NSKeyedUnarchiver unarchiveObjectWithFile:prefFile]];
}


/*	UIAlertSheet *sheet = [[UIAlertSheet alloc] initWithFrame: CGRectMake(0, 240, 320, 240)];
	[sheet setTitle:[selectedAccount username]];
	[sheet setBodyText:[NSString stringWithFormat:@"%@", [selectedAccount connection]]];
	[sheet addButtonWithTitle:@"OK"];
	[sheet setDelegate: self];
	[sheet presentSheetFromAboveView: self];*/


-(void)saveAccounts
{
//	NSLog(@"StartView>> Save Accounts");
	[NSKeyedArchiver archiveRootObject:[_accountsView accounts] toFile:prefFile];
}

- (void)accountsView:(AccountsView *)acctView accountSelected:(Account *)selectedAccount 
{
	accountEditor = [[AccountEditorView alloc]initWithFrame:_rect];
	[accountEditor setAccount:selectedAccount];
	CurrentAccount = selectedAccount;
	NSLog(@"StartView>> Editing %@", [CurrentAccount username]);
	[accountEditor setMode:true];
	[self makeACoolMoveTo:ACCOUNT_EDITOR_VIEW];
}

- (void)imEvent:(NSMutableArray*)payload
{
//	NSLog(@"EVENT RECEIVED");
	[lock lock];
	if([payload count] > 0)
	{
//		NSLog(@"PAYLOAD IS SET");
		switch([[NSString stringWithString:[payload objectAtIndex:0]]intValue])
		{		
			case AIM_BUDDY_ONLINE:
//				NSLog(@"New Buddy.");											
				[_buddyView updateBuddy:[payload objectAtIndex:1] withCode:AIM_BUDDY_ONLINE];
				break;
			case AIM_BUDDY_OFFLINE:
//				NSLog(@"Buddy offline.");
				[_buddyView updateBuddy:[payload objectAtIndex:1] withCode:AIM_BUDDY_OFFLINE];
				break;
			case AIM_BUDDY_AWAY:
//				NSLog(@"Buddy offline.");
				[_buddyView updateBuddy:[payload objectAtIndex:1] withCode:AIM_BUDDY_AWAY];
				break;
			case AIM_BUDDY_UNAWAY:
//				NSLog(@"Buddy offline.");
				[_buddyView updateBuddy:[payload objectAtIndex:1] withCode:AIM_BUDDY_UNAWAY];
				break;
			case AIM_DISCONNECTED:
				NSLog(@"You have been disconnected.");
				EXIT = YES;				
				UIAlertSheet *sheet = [[UIAlertSheet alloc] initWithFrame: CGRectMake(0, 220, 320, 220)];
				[sheet setTitle:[active username]];
				if([payload count]>1)
					[sheet setBodyText:[payload objectAtIndex:1]];
					else
					[sheet setBodyText:@"You have been disconnected."];
				[sheet addButtonWithTitle:@"OK"];
				[sheet setDelegate: self];
				[sheet presentSheetFromAboveView: self];		
				break;
			case AIM_RECV_MESG:
				NSLog(@"Received Message from %@ that says '%@'",[[payload objectAtIndex:1]name],[payload objectAtIndex:2]);
				[self receiveMessage:(NSString*)[payload objectAtIndex:2] fromBuddy:(Buddy*)[payload objectAtIndex:1]];
				break;
			case AIM_CONNECTED:
				NSLog(@"Connected.");
				[[ApolloTOC sharedInstance]listBuddies];
				[self makeACoolMoveTo:BUDDY_VIEW];				
				break;			
			default:
				NSLog(@"StartView> No case statement for Event. Event is...");
		}
	}
	[lock unlock];
	NSLog(@"StartView>> Event -- %d", [[NSString stringWithString:[payload objectAtIndex:0]]intValue]);
}

- (void)alertSheet:(UIAlertSheet *)sheet buttonClicked:(int)button 
{
	[sheet dismiss];
	if(EXIT)
	{
		sleep(3);
		exit(1);
	}
}

- (void)receiveMessage:(NSString*)msg fromBuddy:(Buddy*)aBuddy
{
	//Go through conversations, looking for one
	//If one matches this buddy, add to that
	//Else - create new conversation, add it to the conversations array.
	int i=0,max=[_conversations count];
	bool exist=NO;
	NSLog(@"StartView> Mother fucking %@ wants to talk to me.h", [aBuddy properName]);	
	for(i=0; i<max; i++)
	{
		if([[[[_conversations objectAtIndex:i]buddy]properName]isEqualToString:[aBuddy properName]])
		{
			NSLog(@"StartView> (recv) Adding to Existing Convo with... %@", [aBuddy name]);		
			if(msg != nil)			
			{
				NSLog(@"StartView> (recv) totally adding...");
				[[_conversations objectAtIndex:i] recvMessage:msg];
				return;
			}
		}	
 	}
 	
 	[_buddyView updateBuddy:aBuddy withCode:AIM_RECV_MESG];
	
	NSLog(@"StartView> (recv) Starting New Convo with... %@", [aBuddy name]);
	Conversation* convo = [[Conversation alloc]initWithFrame:_rect withBuddy:aBuddy andDelegate:self];
	[convo recvMessage:msg];
	[_conversations addObject:convo];	
}

- (void)switchToConvo:(Buddy*)aBuddy
{
	[lock lock];
	[_navBar showButtonsWithLeftTitle:@"Buddy List" rightTitle:@"Buddy Info" leftBack: YES];				
	_accountsEditorViewBrowser	=	false;
	_buddyViewBrowser			=	false;
	_accountsViewBrowser		=	false;	
	_conversationView			=	true;
	int i=0,max=[_conversations count];
	
 	[_buddyView updateBuddy:aBuddy withCode:AIM_READ_MSGS];	
	
	NSLog(@"StartView> (Switch) Switching to ", [aBuddy name]);
	for(i=0; i<max; i++)
	{
		if([[[[_conversations objectAtIndex:i]buddy]properName]isEqualToString:[aBuddy properName]])
		{
			NSLog(@"StartView> Going to existing Convo with... %@", [aBuddy name]);		
			[lock unlock];
			[_transitionView transition:1 toView:[_conversations objectAtIndex:i]];				
			return;
		}
 	}

	NSLog(@"StartView> (Switch) Starting New Convo with... %@", [aBuddy name]);
	Conversation* convo = [[Conversation alloc]initWithFrame:_rect withBuddy:aBuddy andDelegate:self];
	[_conversations addObject:convo];	
	[lock unlock];
	[_transitionView transition:1 toView:[_conversations objectAtIndex:i]];			
}

- (void)makeACoolMoveTo:(int)target
{
	switch(target)
	{	
		case ACCOUNT_VIEW:
			[_navBar showButtonsWithLeftTitle:@"Sign On" rightTitle:@"Add Account" leftBack: YES];
			[_transitionView transition:3 toView:_accountsView];	
			_accountsEditorViewBrowser	=	false;
			_buddyViewBrowser			=	false;
			_conversationView			=	false;
			
			_accountsViewBrowser		=	true;
			[navtitle setText:@"Accounts"];	
			break;
		case ACCOUNT_EDITOR_VIEW:			
			[_transitionView transition:3 toView:accountEditor];
			_accountsViewBrowser		=	false;			
			_buddyViewBrowser			=	false;
			_conversationView			=	false;			

			_accountsEditorViewBrowser	=	true;			
			[navtitle setText:@"Account Editor"];			
			[_navBar showButtonsWithLeftTitle:@"Save" rightTitle:@"Cancel" leftBack: YES];		
			break;
		case BUDDY_VIEW:
			[_transitionView transition:3 toView:_buddyView];
			_accountsViewBrowser		=	false;
			_accountsEditorViewBrowser	=	false;
			_conversationView			=	false;			

			_buddyViewBrowser			=	true;
			[_navBar showButtonsWithLeftTitle:@"Disconnect" rightTitle:@"Options" leftBack: YES];				
			break;		
	}
}

- (void)navigationBar:(UINavigationBar *)navbar buttonClicked:(int)button 
{
	switch (button) 
	{
		case 1:
			if (_buddyViewBrowser)
			{
//				NSLog(@"StartView>> LEFT -- BUDDY_VIEW -- DISCONNECTBUTTON");
				[[ApolloTOC sharedInstance]disconnect];
				exit(1);
			}
			if (_accountsViewBrowser) 
			{
//				NSLog(@"StartView>> LEFT -- ACCOUNT_VIEW -- SIGNON");
				active = [_accountsView getActive];
				if(active == nil)
				{
					UIAlertSheet *sheet = [[UIAlertSheet alloc] initWithFrame: CGRectMake(0, 240, 320, 240)];
					[sheet setTitle:@"No Active Account Set."];
					[sheet setBodyText:@"The 'active account' is the account you wish to sign on with.  Please set an active account and try again."];
					[sheet addButtonWithTitle:@"OK"];
					[sheet setDelegate: self];
					[sheet presentSheetFromAboveView: self];					
				}
				else
				{
					NSLog(@"StartView>> Initiating a connection...");
					[[ApolloTOC sharedInstance] setDelegate:self];
					[[ApolloTOC sharedInstance] connectUsingUsername:[active username] password:[active password]];
				}
				return;
			}        
			
			if(_accountsEditorViewBrowser)
			{
				if([[[accountEditor getAccount] username] isEqualToString:@""] || [[[accountEditor getAccount] password] isEqualToString:@""] )
				{
					UIAlertSheet *sheet = [[UIAlertSheet alloc] initWithFrame: CGRectMake(0, 240, 320, 240)];
					[sheet setTitle:@"Username/Password error"];
//					[sheet setBodyText:@"Your username or password was blank.  Your account will have one of each.  Give that form another shot, slugger."];
					[sheet addButtonWithTitle:@"OK"];
					[sheet setDelegate: self];
					[sheet presentSheetFromAboveView: accountEditor];
				}
				else
				{												
//					NSLog(@"LEFT -- ACCOUNT_VIEW_EDITOR -- SAVE");
					Account* EditedAccount = [accountEditor getAccount];		
					if(![accountEditor getMode])
					{
//						NSLog(@"ADD ACCOUNT");
						[_accountsView addAccount:EditedAccount];
					}
					else
					{
//						NSLog(@"UPDATE ACCOUNT");
						[_accountsView updateAccount:CurrentAccount withAccount:EditedAccount];
					}
					
					//TAKE THIS OUT FOR MULTIPLE SIGNONS
					if([EditedAccount enabled])
					{
//						NSLog(@"SETTING ONLY ACTIVE.");
						[_accountsView singleActive:EditedAccount];		
					}
									
					//TAKE THIS OUT FOR MULTIPLE SIGNONS					
					[self saveAccounts];
//					NSLog(@"Account Editor Release...");
					[self makeACoolMoveTo:ACCOUNT_VIEW];
//					NSLog(@"USERNAME: %@", [EditedAccount username]);
//					NSLog(@"PASSWORD: %@", [EditedAccount password]);
//					NSLog(@"ENABLED : %d", [EditedAccount enabled]);
//					NSLog(@"SERVER  : %@", [EditedAccount extServer]);
//					NSLog(@"STATUS  : %@", [EditedAccount status] );					
					[EditedAccount release];	
					[accountEditor release];							
//					NSLog(@"Released.");
				}
				return;
			}
			if(_conversationView)
			{
				NSLog(@"StartView>> LEFT -- CONVERSATION_VEW -- BACK_TO_BUDDYLIST");	
				[self makeACoolMoveTo:BUDDY_VIEW];
				return;
			}
			break;
		case 0:	
			if (_buddyViewBrowser)
			{
//				NSLog(@"StartView>> RIGHT -- BUDDY_VIEW -- OPTIONS");				
			}		
			if(_accountsViewBrowser)
			{
//				NSLog(@"RIGHT -- ACCOUNT_VIEW -- ADDNEW");	
				accountEditor = [[AccountEditorView alloc]initWithFrame:_rect];
				[accountEditor setMode:false];				
				[self makeACoolMoveTo:ACCOUNT_EDITOR_VIEW];
				return;
			}
			if(_accountsEditorViewBrowser)
			{		
				[self makeACoolMoveTo:ACCOUNT_VIEW];	
				Account *temp = [accountEditor getAccount];
/*				NSLog(@"USERNAME: %@",	[temp username]);
				NSLog(@"PASSWORD: %@",	[temp password]);
				NSLog(@"ENABLED:  %d",  [temp enabled]);*/
				return;
			}
			if(_conversationView)
			{
				NSLog(@"StartView>> RIGHT -- CONVERSATION_VEW -- BUDDYINFO");	
				return;
			}
			break;
	}
}



- (void)dealloc {
	[_navBar release];
	[super dealloc];
}
@end
