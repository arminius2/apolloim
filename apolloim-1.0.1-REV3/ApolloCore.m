//
//  ApolloCore.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 9/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//  THE NAME OF THIS CLASS IS BECAUSE OF THE MOVIE "THE CORE" WHICH WAS A GREAT MOVIE AND THIS IS THE SEQUEL

#import "ApolloCore.h"
#import "Event.h"
#include "ApolloIM-Callbacks.m"
#import "NetworkController.h"
#import "PurpleInterface.h"
#import "ViewController.h"

#define USER_ID(purp_user) 		[NSString stringWithFormat:@"%@/%@", [[NSString stringWithCString:(purp_user->username)]lowercaseString], [ProtocolConvert apolloProto:[NSString stringWithCString:((purp_user->protocol_id)?(purp_user->protocol_id):"")]]]
#define BUDDY_ID(buddy, purp_user)	[NSString stringWithFormat:@"%@/%@/%@", [buddy lowercaseString], [[NSString stringWithCString:(purp_user->username)]lowercaseString], [ProtocolConvert apolloProto:[NSString stringWithCString:(purp_user->protocol_id)]]]

static id sharedInst;
static NSRecursiveLock *lock;
extern UIApplication *UIApp;

// Private class just for handling account pairs
@interface UserPair : NSObject
{
@public
	User * ap_user;
	PurpleAccount * purp_user;
}
-(PurpleAccount*)purpleUser;
-(User*)apolloUser;
@end
@implementation UserPair

-(User*)apolloUser
{
	return ap_user;
}
-(PurpleAccount*)purpleUser
{
	return purp_user;
}
@end

//Private class just for converting "legible" conenction names to libpurple connection names
@interface ProtocolConvert : NSObject
{
}
+(NSString*)purpleProto:(NSString*)pass;
+(NSString*)apolloProto:(NSString*)pass;
@end
@implementation ProtocolConvert
+(NSString*)purpleProto:(NSString*)pass
{	
	if([pass isEqualToString:ICQ] || [pass isEqualToString:AIM] || [pass isEqualToString:DOTMAC])
		return [NSString stringWithString:@"prpl-aim"];		
	if([pass isEqualToString:MSN])
		return [NSString stringWithString:@"prpl-msn"];		
}

+(NSString*)apolloProto:(NSString*)pass
{
	if([pass isEqualToString:@"prpl-aim"] || [pass isEqualToString:@"prpl-icq"])
		return [NSString stringWithString:@"AIM"];
	if([pass isEqualToString:@"prpl-msn"])
		return [NSString stringWithString:@"MSN"];
}
/*
0 -- AIM
1 -- Gadu-Gadu
2 -- ICQ
3 -- IRC
4 -- MSN
5 -- QQ
6 -- XMPP
7 -- Zephyr
*/

+(int)numberProto:(NSString*)pass
{
	if([pass isEqualToString:AIM])
		return 0;
	if([pass isEqualToString:DOTMAC])
		return 0;
	if([pass isEqualToString:ICQ])
		return 2;
	if([pass isEqualToString:MSN])
		return 4;		
}
@end


@implementation ApolloCore

+ (void)initialize
{
	sharedInst = lock = nil;
}

+ (id)sharedInstance
{
    [lock lock];
	if (!sharedInst)
	{
		sharedInst = [[[self class] alloc] init];		
	}
	[lock unlock];
    
	return sharedInst;
}

+ (id)dump
{
	sharedInst = NO;
}


- (id)init
{
	int i;
	self = [super init];

	AlexLog(@" Initiating the ApolloCore.");

	//All accounts that are connected
	activeAccounts		=	[[NSMutableDictionary alloc]init];
	//All accounts that are not connected
	pendingAccounts		=	[[NSMutableDictionary alloc]init];
	//Where the conversations are stored.  
	activeConversations =	[[NSMutableDictionary alloc]init];	

	init_libpurple();
	names = NULL;
	AlexLog(@" libpurple initialized.");

	iter = purple_plugins_get_protocols();
	loop = g_main_loop_new(NULL, FALSE);	  //Do we need this?
	for (i = 0; iter; iter = iter->next) 
	{
		PurplePlugin *plugin = iter->data;
		PurplePluginInfo *info = plugin->info;
		if (info && info->name) 
		{
			AlexLog(@"%d -- %s", i++, info->name);
			names = g_list_append(names, info->id);
		}

	}	
	
	[NSThread detachNewThreadSelector:@selector(threadedGlib) toTarget:self withObject:nil];
    return self;
}

- (void)threadedGlib
{
	NSAutoreleasePool *glibAutoreleasePool =  [[NSAutoreleasePool alloc] init];
        
	//This is dirty and terrible, but hey, it works.  I really ought to ask the adium guys.	
	//I'd love to connect to signals just about anywhere else, but bitches it seems.
	connect_to_signals();
	g_main_loop_run(loop);  //switch to adium runloop method
		
	[glibAutoreleasePool release];
}

- (int)connectionCount
{
	return connections;
}

- (void)registerConnection:(User*)theAccount  //ALL ACTIVE ACCOUNTS MUST BE REGISTERED.  PERIOD.
{
	UserPair * up = [[UserPair alloc] init];

//	if([theAccount getStatus] != OFFLINE)

	AlexLog(@"ProtoConvert: %@",[theAccount getProtocol]);
	AlexLog(@"ProtoConvert: %d",[ProtocolConvert numberProto:[theAccount getProtocol]]);
	prpl = g_list_nth_data(names, [ProtocolConvert numberProto:[theAccount getProtocol]]);

	PurpleAccount* account = purple_account_new([[theAccount getName] cString], prpl);
	purple_account_set_password(account, [[theAccount getSettingForKey:@"password"] cString]);
	purple_account_set_enabled(account, UI_ID, TRUE);

	up->ap_user = theAccount;
	up->purp_user = account;

//	AlexLog(@"ID: %@", [theAccount getID]);
//	AlexLog(@"PROTO: %@", [theAccount getProtocol]);
	if(	[activeAccounts objectForKey:[theAccount getID]]!=nil || 
		[theAccount getStatus] !=OFFLINE)
	{
		AlexLog(@" Why would we try to connect an already connected account?");
		return;
	}
	else
	{	[theAccount setStatus:LOGGING_IN];
		AlexLog(@"ApolloCore: Loggin In Account: %@", [theAccount getID]);
		if([pendingAccounts objectForKey:[theAccount getID]]==nil)
			[pendingAccounts setObject:up forKey:[theAccount getID]];
	}
	
/*	if([USER_ID(account)isEqualToString:[theAccount getID]])
		AlexLog(@"!!!!!!!!!!EQUAL");
		else
		AlexLog(@" %@ -- %@ -- %s", USER_ID(account), [theAccount getID], account->protocol_id);*/
	
	if(!([[NetworkController sharedInstance]isNetworkUp]))
	{
		if(![[NetworkController sharedInstance]isEdgeUp])
		{
			[[NetworkController sharedInstance]keepEdgeUp];									
			[[NetworkController sharedInstance]bringUpEdge];
			[[ViewController sharedInstance]connectStep:0 forAccount:[theAccount getName] withMessage:@"Bringing Edge up..." connected:NO];						
			sleep(5);
			[[PurpleInterface sharedInstance]fireEvent:[[Event alloc] initWithUser:theAccount type:NETWORK_EDGE content:@""]];		
		}
		else
		{
			//No working internet connections.
			//Send alert that connecting isn't possible.
			[[ViewController sharedInstance] connectionFailureFor:[theAccount getName] withMessage:@"No network available." isDisconnect:NO];
			[self disconnect:theAccount];
		}
	}

	[[PurpleInterface sharedInstance]fireEvent:[[Event alloc] initWithUser:theAccount type:NETWORK_WIFI content:@""]];			
}

- (void)destroyConnection:(User*)theAccount 
{
	AlexLog(@"ApolloCore::destroyConnection| Should do something - but I don't know what yet!  My spidey senses told me to have it, but they haven't told me what to do with it. ");
	AlexLog(@"ApolloCore::destroyConnection| My spidey senses should be more specific.");
	
	//PurpleAccount* account = [self getPurpleAccount:theAccount];	
}

- (void)connected:(PurpleAccount*)theAccount
{
	AlexLog(@" CONNECTED -- %@ -- %@", USER_ID(theAccount), self);
	UserPair * connectedAccount = [pendingAccounts objectForKey:USER_ID(theAccount)];
	AlexLog(@" Got connected account...");
	
	if(connectedAccount == nil)
	{
		AlexLog(@" This account was never registered.  Abort.");
		[connectedAccount->ap_user setStatus:OFFLINE];		
		return;
	}
	else
	{
		AlexLog(@"Connection Successful.... setting active, removing pending status -- %@", [NSString stringWithCString:theAccount->username]);
		[[ViewController sharedInstance]connectStep:6  forAccount:[NSString stringWithCString:theAccount->username] withMessage:@"Connected." connected:YES];			
		[activeAccounts setObject:connectedAccount forKey:USER_ID(theAccount)];
		[pendingAccounts removeObjectForKey:USER_ID(theAccount)];
		[connectedAccount->ap_user setStatus:ONLINE];
		[[PurpleInterface sharedInstance]fireEvent:[[Event alloc] initWithUser:[self getApolloUser:theAccount] type:ONLINE content:@""]];		
		connections++;			
	}		
	//Alert UI with notification
	//TODO

//	[connectedAccount retain];
}

- (void)disconnected:(PurpleAccount*)theAccount
{
	AlexLog(@"DISCONNECTED.");
	UserPair* disconnectedAccount = [activeAccounts objectForKey:USER_ID(theAccount)];		
	AlexLog(@"ACCOUNT FOUND.");
	if(disconnectedAccount == nil)
	{
		//If a lookup from activeaccounts fails, it means it's in pending, meaning it was never active.
		//A connecitonDisconnection will be called soon and this will send information to connectionStatus for use in a UI notification
		AlexLog(@"ApolloCore--%@> Failed Signon.", self);
	}
	else
	{	
		connections--;	
		[pendingAccounts setObject:disconnectedAccount forKey:USER_ID(theAccount)];  //This might not be needed.  Ensure the account is removed from actives.		
		[activeAccounts removeObjectForKey:USER_ID(theAccount)];
		[pendingAccounts removeObjectForKey:USER_ID(theAccount)];		
//		[disconnectedAccount->ap_user setStatus:OFFLINE];	
		AlexLog(@" Fully disconnected.");
		if(!(connections <= 0))
		{
			[[PurpleInterface sharedInstance]fireEvent:[[Event alloc] initWithUser:[self getApolloUser:theAccount] type:DISCONNECT content:@""]];//One account down, more are still working.
		}
		else
		{
			[[PurpleInterface sharedInstance]fireEvent:[[Event alloc] initWithUser:[self getApolloUser:theAccount] type:DISCONNECTED content:@""]];//All accounts down, take me back to account screen
		}
			
		[[ViewController sharedInstance]fullDisconnect];		
		//[theAccount removeAllBuddies];		
	}	
	
	//Alert UI with notification -- note this needs hookup w/ the correct UI ops so you can get a reason why 
	//we were disconnected.  This isn't so bad though, look throw ApolloIM-Callbacks.m.  
	// TODO
}
- (void)buddyUpdate:(Buddy*)buddy withCode:(int)code
{
	AlexLog(@" Buddy Update %@ -- %d",[buddy getDisplayName],code);
	[lock lock];
	Buddy * real_buddy = [[buddy getOwner] getBuddyByName:[buddy getName]];
	
	if(real_buddy != nil)
	{	
		[real_buddy setAway: [buddy isAway]];
		[real_buddy setOnline: [buddy isOnline]];
		[real_buddy setIdleTimeMinutes: [buddy getIdleTimeMinutes]];
		[real_buddy setStatusMessage:[buddy getStatusMessage]];
	}
		
	switch(code)
	{
		case BUDDY_LOGIN:
			[buddy setOnline:YES];
			[[buddy getOwner] addBuddyToBuddyList:buddy];
		break;
		case BUDDY_LOGOUT:	
			[real_buddy setOnline:NO];
			//[[[buddy getOwner]getBuddyList] removeObject:real_buddy];			
		break;
		case BUDDY_STATUS:
			AlexLog(@" BUDDY STATUS CHANGED FOR %@", [real_buddy getName]);
		break;
		case BUDDY_AWAY:
			AlexLog(@" BUDDY AWAY %@", [buddy getName]);
		break;
		case BUDDY_BACK:
			AlexLog(@" BUDDY UNAWAY %@", [buddy getName]);
		break;		
	}
	
	Event* e = [[Event alloc]initWithUser:[real_buddy getOwner] buddy:real_buddy type:code content:nil];
	[lock unlock];

	[[PurpleInterface sharedInstance] fireEvent:e];
	
	[[ViewController sharedInstance] forceBuddyListRefresh];
}

- (void)connectionStatus:(int)statusLevel withMessage:(NSString*)message forAccount:(PurpleAccount*)account
{
	AlexLog(@" STATUS LEVEL %d", statusLevel);		

	switch(statusLevel)
	{
		case -1: 
			AlexLog(@" <%@> Connection Error: %@",			USER_ID(account), message); 
			if(message == nil)
			{
				message = [[NSString alloc]initWithString:@" "];
			}
			[[ViewController sharedInstance] connectionFailureFor:[NSString stringWithFormat:@"%s",account->username] withMessage:message isDisconnect:NO];
//			[[PurpleInterface sharedInstance]fireEvent:[[Event alloc] initWithUser:[self getApolloUser:account] type:CONNECT_FAILURE content:message]];		
			
			break;
		default: 
//			[[PurpleInterface sharedInstance]fireEvent:[[Event alloc] initWithUser:[self getApolloUser:account] type:CONNECT_MSG content:message]];		
			AlexLog(@" Step %d for %@> %@", statusLevel,	USER_ID(account), message);	
			[[ViewController sharedInstance]connectStep:statusLevel forAccount:[NSString stringWithCString:account->username] withMessage:message connected:NO];
			break;
	}

//	[[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectionStatusNotification" object:nil userInfo:
//	[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:statusLevel] forKey:@"statusLevel"]];
}

- (void)connect:(User*) theAccount  
{
	[self registerConnection:theAccount];
}

- (void)disconnect:(User*) theAccount
{
	//Alert UI with notification of pending disconnect?
	AlexLog(@" <Disconnect> Disconnecting %@", [theAccount getName]);	
	if([theAccount getStatus]!=OFFLINE)  //can't disconnect if you're offline
	{
		AlexLog(@"Checking account...");
		PurpleAccount*			account			= [self getPurpleAccount:theAccount];
		AlexLog(@"Account traced...");
		if(account!=nil)  //Double check.
		{
			AlexLog(@" <Disconnect> Purple account retrieved %s -- %d", account->username,[theAccount getStatus]);
			
			purple_status_type_get_id(purple_account_get_status_type_with_primitive(account, PURPLE_STATUS_OFFLINE));
			purple_account_set_enabled(account, UI_ID, NO);	
			[theAccount setStatus:OFFLINE];
			AlexLog(@" Disconnecting...");
	
			[theAccount removeAllBuddies];
		}
	}
}

- (void)away:(User*) theAccount
{
//	if([theAccount getStatus]==ONLINE)
	{
		PurpleAccount*			account			= ((UserPair *)[activeAccounts objectForKey:[theAccount getID]])->purp_user;
		PurpleStatus*			status			= purple_account_get_active_status(account);
		PurpleStatusType*		statusType		= purple_status_get_type(status);
		PurplePresence*			presence		= purple_status_get_presence(status);
	
		purple_presence_set_status_active(presence, "away", true);
	}
}

- (void)back:(User*) theAccount
{	
//	if([theAccount getStatus]==ONLINE)	
	{
		PurpleAccount*			account			= ((UserPair *)[activeAccounts objectForKey:[theAccount getID]])->purp_user;
		PurpleStatus*			status			= purple_account_get_active_status(account);
		PurpleStatusType*		statusType		= purple_status_get_type(status);
		PurplePresence*			presence		= purple_status_get_presence(status);
		

		purple_presence_set_status_active(presence, "available", true);
	}
}

- (void)sendIM:(NSString *)body toBuddyName:(NSString *)buddy fromAcct:(User *)account   
{
	//Should work.
	AlexLog(@"  Sending Message %@ to %@> %@", [account getName], buddy, body);
    [lock lock];
	purple_conv_im_send(purple_conversation_get_im_data([self conversationWith:buddy fromAcct:account]),[body cString]);
	[lock unlock];
}

- (void)receivedMessage:(NSString*)message withBuddyName:(NSString*)buddy fromAcct:(PurpleAccount*)account 
{
	//Alert UI with notification
	AlexLog(@" Receiving message on %s from %@> %@",account->username, buddy, message);
	User	* user			=	[self getApolloUser:account]; 
	Buddy	* theBuddy		=	[user getBuddyByName:buddy];
		
	if(theBuddy == nil)
	{
		AlexLog(@" CREATING TEMP BUDDY: %@", buddy);
		theBuddy = [[Buddy alloc] initWithName:buddy andGroup:@"" andOwner:user];
		[theBuddy setStatusMessage:@" "];
		[theBuddy setOnline:NO];

		[user addBuddyToBuddyList: theBuddy];
		[[ViewController sharedInstance] createConversationWith: theBuddy];
		
		AlexLog(@" Buddy Logged In");
	}
	
	Event * event = [[Event alloc] initWithUser:user buddy:theBuddy type:BUDDY_MESSAGE content: message];
	
	AlexLog(@" Firing Message Event to: %@", [theBuddy getName]);
	[[PurpleInterface sharedInstance] fireEvent:event];

}

- (void)errorBecauseOfMessageWith:(NSString*)buddyName fromAccount:(User *)account withError:(NSString*)error isCritical:(bool)maybe
{
	[[PurpleInterface sharedInstance]
	fireEvent:[[Event alloc] initWithUser:account 
	buddy:[account getBuddyByName:buddyName] 
	type:MESSAGE_ERROR content:error]];
	
	//Incase of a message had a problem sending, a callback is called to here, and we should do UI notification of this case.
/*	[[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorSendingMessageNotification" object:nil userInfo:
	[NSDictionary dictionaryWithObjectsAndKeys:
	   buddyName,    @"buddyName",
	   account,      @"fromAccount",
	   error,        @"error",
	   maybe,        @"isCritical",
	   NULL]
	];
	[buddyName retain];
	[account retain];
	[error retain];*/
}

- (PurpleConversation*)conversationWith:(NSString *)buddy fromAcct:(User *)account
{
	//Keep in mind "purple_conversation_get_account(PurpleConversation)"
	//I don't know why yet either.  But it could come in handy.

//	ConvWrapper* convo = [activeConversations objectForKey:BUDDY_ID(buddy,[self getPurpleAccount:account])];
	ConvWrapper* convo = nil;
	if(convo==nil)
	{
		PurpleAccount * pa = [self getPurpleAccount:account];
		PurpleConversation * pc = purple_conversation_new(PURPLE_CONV_TYPE_IM, pa, [buddy UTF8String]);
		AlexLog(@" Creating a new conversation - %s", pa->username);		
		convo = [[ConvWrapper alloc]initWithConvo:pc];
		[activeConversations setObject:convo forKey:BUDDY_ID(buddy,[self getPurpleAccount:account])];		
	}

	return [convo conv];
}

- (void)createdConversation:(ConvWrapper*)conv withBuddyName:(NSString*)buddy fromAcct:(PurpleAccount*)account
{
	[activeConversations setObject:conv forKey:BUDDY_ID(buddy, account)];
	//When receiving a message, a new conv is created.  
	//No reason to create another new one, so the "new convo" callback calls function and we use that convo
	//since creating a new one would be stupid.
}

- (void)dealloc
{
	[activeAccounts release];
	[pendingAccounts release];
	[activeConversations release];
	
	//TODO: shutdown libpurple	
	//TODO: Hey - how does one do that anyway?
	//TODO: tra la la la la	
	
	[super dealloc];
}

- (User *) getApolloUser:(PurpleAccount *) pa
{
	return [((UserPair *)[activeAccounts objectForKey:USER_ID(pa)]) apolloUser];
}

- (PurpleAccount *) getPurpleAccount:(User *) user
{
	return [((UserPair *)[activeAccounts objectForKey:[user getID]]) purpleUser];
}

- (void) reset
{
	AlexLog(@"RESET CALLED");
	[self performSelector:@selector(goTeamCancer) withObject:nil afterDelay:5];
}

- (void) goTeamCancer
{
	if(connections <= 0)
		[[ViewController sharedInstance]transitionToLoginView];
		else
		AlexLog(@"TOO MANy CONNECTIONS TO RESET: %d", connections);
	
}

@end
