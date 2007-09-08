/*
 ApolloCore.m: Objective-C firetalk interface.
 By Alex C. Schaefer
 Modification of BoomBot's objc/firetalk wrapper

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

#import	"StartView.h"
#import "ApolloCore.h"
#import "ApolloIM-PrivateAccess.h"

#include "ApolloIM-Callbacks.m"

static id sharedInst;
static NSRecursiveLock *lock;

@implementation ApolloTOC

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
    self = [super init];

	NSLog(@"Initing new ApolloTOC...");

    connected = ApolloCORE_DISCONNECTED;
//    [self registerFiretalkCallbacks];

	connectionHandles = [[NSMutableArray alloc]init];

	int i;
    init_libpurple();
	names = NULL;
	NSLog(@"libpurple initialized.");

	iter = purple_plugins_get_protocols();
       loop = g_main_loop_new(NULL, FALSE);	
	for (i = 0; iter; iter = iter->next) {
		PurplePlugin *plugin = iter->data;
		PurplePluginInfo *info = plugin->info;
		if (info && info->name) {
//			printf("\t%d: %s\n", i++, info->name);
			NSLog(@"%d -- %s", i++, info->name);
			names = g_list_append(names, info->id);
		}

	}

    return self;
}

- (void)dealloc
{
    if (connected != ApolloCORE_DISCONNECTED)
        [self disconnect];
    if (infoMessage)
        [infoMessage release];

    [super dealloc];
}

- (NSString*)infoMessage
{
    return infoMessage;
}

- (void)setInfoMessage:(NSString*)newMessage
{
    [lock lock];
    [infoMessage autorelease];
    infoMessage = [newMessage retain];

    if ([self connected])
//        firetalk_set_info(ft_aim_connection, [infoMessage cString]);
    [lock unlock];
}

- (BOOL)connectUsingUsername:(NSString*)username password:(NSString*)password
{
    int success;
	you = [[Buddy alloc]init];
	[you setName:[username copy]];

    if ([self connected])
        return YES;

	NSLog(@"ApolloTOC> Preconnect...");
   [lock lock];
//   	printf("Select the protocol [0-%d]: ", i-1);
//  	fgets(name, sizeof(name), stdin);
//	sscanf(name, "%d", &num);
	prpl = g_list_nth_data(names, 0);

//	printf("Username: ");
//	fgets(name, sizeof(name), stdin);
//	name[strlen(name) - 1] = 0;  /* strip the \n at the end */

	/* Create the account */
	account = purple_account_new([username cString], prpl);

	/* Get the password for the account */
//	password = getpass("Password: ");
	purple_account_set_password(account, [password cString]);

	/* It's necessary to enable the account first. */
	purple_account_set_enabled(account, UI_ID, TRUE);

	/* Now, to connect the account(s), create a status and activate it. */
	status = purple_savedstatus_new(NULL, PURPLE_STATUS_AVAILABLE);
	purple_savedstatus_activate(status);
	
	connect_to_signals_for_demonstration_purposes_only();

	g_main_loop_run(loop);
   
	return YES; //Please, just work
	
//    ft_callback_storepass("");
//    ft_callback_storepass([password UTF8String]);
//	NSLog(@"ApolloTOC> Password Stored... Connecting.. %@",username);
   /* success = firetalk_signon(ft_aim_connection, TOC_SERVER, TOC_PORT, [username cString]);
	NSLog(@"ApolloTOC> Sign on request sent...");	
	[lock unlock];		
    
    if (success != FE_SUCCESS)
    {
		NSLog(@"ApolloTOC> Payload prep...");
		NSMutableArray* payload = 
		[[NSMutableArray alloc]init];	
		[payload addObject:		@"9"];	
        switch (success)
        {
			case FE_CONNECT: [payload addObject:@"Apollo Unable to connect."]; break;
            case FE_BADUSERPASS: [payload addObject:@"ApolloTOC: Bad user name or password."]; break;
            case FE_SERVER: [payload addObject:@"ApolloTOC: Can't find specfied server."]; break;            
			case FE_SOCKET: [payload addObject:@"ApolloTOC: Your internet connection is not ready."]; break;            
            case FE_RESOLV: [payload addObject:@"ApolloTOC: Can't resolve specified server."]; break;            
			case FE_BADCONNECTION: [payload addObject:@"ApolloTOC: Bad Connection."]; break;
			case FE_VERSION: [payload addObject:@"ApolloTOC: Wrong Version."]; break;
            case FE_BLOCKED: [payload addObject:@"ApolloTOC: You have been blocked. Signing on too often/too fast?"]; break;
            case FE_USERDISCONNECT: [payload addObject:@"ApolloTOC: You're disconnected."]; break;
            case FE_DISCONNECT: [payload addObject:@"ApolloTOC: Server disconnected you."]; break;
            case FE_UNKNOWN: [payload addObject:@"ApolloTOC: Unknown error. Generally caused by a slow or unreachable toc network at AOL."]; break;
            case FE_BADUSER: [payload addObject:@"ApolloTOC: Bad user name or password."]; break;
            default:
                [payload addObject:[NSString stringWithFormat:@"ApolloTOC: Unable to login to aim/toc, generic error %d\n", success]]; break;
        }
		[_delegate imEvent:		payload];		
        return NO;
    }

    connected = ApolloCORE_CONNECTING; 
    while (connected == ApolloCORE_CONNECTING)
    {
        [self runloopCheck:nil]; 
		status = NO;
        usleep(100); // wait for connection to either fail or succeed
    }
    if ([self connected])
	{
		//firetalk_im_list_buddies(ft_aim_connection);		
        return YES;
	}
    else
        return NO;*/
}

//- (void)listBuddies
//{
//	[lock lock];
//	firetalk_im_list_buddies(ft_aim_connection);
//	[lock unlock];
//}

- (BOOL)connected
{
    if (connected == ApolloCORE_CONNECTED)
        return YES;
    else
        return NO;
}

- (void)killHandle
{
	[lock lock];
//	firetalk_destroy_handle(ft_aim_connection);
	[lock unlock];	
}

- (void)sendIM:(NSString*)body toUser:(NSString*)user
{
    NSLog(@"Sending IM %@ to user %@...", body, user);
    
    [lock lock];
//    firetalk_im_send_message(ft_aim_connection, [user cString], [body cString], 0);
    [lock unlock];
	
	[[ApolloNotificationController sharedInstance]playSendIm];
}

- (void)buddyUpdate:(Buddy*)buddy withCode:(int)code
{
	NSLog(@"Buddy Update: %@ -- %d",[buddy name], code);
	NSMutableArray* payload = [[NSMutableArray alloc]init];		
	[payload addObject:	[[NSString alloc]initWithFormat:@"%d",code] ]; 
	[payload addObject:		buddy]; 	
	[_delegate imEvent:		payload];
}

- (void)error:(int)code
{
}

- (void)registerCallbacks
{

    [lock lock];
			
    [lock unlock];
    NSLog(@"ApolloTOC: firetalk callbacks registered.");
}
- (void)getInfo:(Buddy*)aBuddy
{
	[lock lock];
//	firetalk_im_get_info(ft_aim_connection, [[[aBuddy name]lowercaseString]cString]);
	[lock unlock];
}

- (void)connectionSucessful:(void *)ftConnection
{
    [lock lock];
    //firetalk_im_upload_buddies(ftConnection); // kick to allow-all-but-denied mode

    //firetalk_set_away(ftConnection, "");

//    if (infoMessage)
//        firetalk_set_info(ftConnection, [infoMessage cString]);
    
    connected = ApolloCORE_CONNECTED;
	
    NSLog(@"ApolloTOC: Connection sucessful.");
    [lock unlock];
	NSMutableArray* payload = 
	[[NSMutableArray alloc]init];
	
	[payload addObject:		@"8"];
	[_delegate imEvent:		payload];
	NSLog(@"ApolloTOC>  here's to the good ol' days...");
	keepAlive = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(keepAlive) userInfo:nil repeats:YES] ;	


	[lock unlock];	
}

- (void)receivedMessage:(NSString*)message fromUser:(NSString*)user isAutomessage:(BOOL)automessage
{
	NSLog(@"ApolloTOC: Recieved message from %@, is auto: %i.\n%@", user, automessage, message);
	[[ApolloNotificationController sharedInstance]playRecvIm];	
	Buddy* yourBuddy = [[Buddy alloc]init];
	[yourBuddy setName:user];
	
	NSMutableArray* payload = 
	[[NSMutableArray alloc]init];
	
	[payload addObject:		@"1"];
	[payload addObject:		yourBuddy];
	[payload addObject:		message];
	[_delegate imEvent:		payload];
}


- (void)setDelegate:(id)delegate 
{
	_delegate = delegate;
}
- (void)disconnect
{    
    if (connected == ApolloCORE_DISCONNECTED)
	{
		NSLog(@"Can't disconnect if disconnected.");
        return;
	}
    
    [lock lock];
    if (connected == ApolloCORE_CONNECTING)
	{
		NSLog(@"Connecting Clause");
		connected = ApolloCORE_DISCONNECTED;
	}
    else
    {
		NSLog(@"Setting to disconnect.");	
//        connected = ApolloCORE_DISCONNECTED;
//        firetalk_disconnect(ft_aim_connection);
	}
    [lock unlock];
}


- (void)disconnected
{
    if (connected != ApolloCORE_DISCONNECTED) // if we think we're connected and we get here, there's a problem
    {
		[lock lock];
        NSLog(@"ApolloTOC: Error: Disconnected by remote host! Trying to cleanly disconnect; other error messages may follow.");
		connected = ApolloCORE_DISCONNECTED;
		NSMutableArray* payload = 
		[[NSMutableArray alloc]init];	
		[payload addObject:		@"9"];
		[payload addObject:		@"THERE IS NO REASON RIGHT NOW"];
		[_delegate imEvent:		payload];
		[lock unlock];
    }
	else
		NSLog(@"This is pretty much impossible.  WTF M8");
}

- (Buddy*)you
{
	return you;
}

- (NSString*) userName
{
	return [you name];
}

@end