/*
 ApolloTOC.m: Objective-C firetalk interface.
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
#import "ApolloTOC.h"
#import "ApolloIM-PrivateAccess.h"
#import "ApolloIM-Callback.h"
//New Firetalk - thanks to NAIM crew for helping me out and letting me use their wonderful code
#import "libfiretalk/firetalk.h"

typedef void (*ptrtofnct)(firetalk_t, void *, ...);
const char* TOC_SERVER = "toc.oscar.aol.com";
const int TOC_PORT = 9898;

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

- (id)init
{
    self = [super init];

	NSLog(@"Initing new ApolloTOC...");

    connected = ApolloTOC_DISCONNECTED;
    willSendMarkup = YES;
    [self registerFiretalkCallbacks];

	connectionHandles = [[NSMutableArray alloc]init];

    [NSTimer scheduledTimerWithTimeInterval:0.20 target:self selector:@selector(runloopCheck:) userInfo:nil repeats:YES];

    return self;
}

- (void)dealloc
{
    if (connected != ApolloTOC_DISCONNECTED)
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
        firetalk_set_info(ft_aim_connection, [infoMessage cString]);
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
    ft_callback_storepass([password UTF8String]);
	NSLog(@"ApolloTOC> Password Stored... Connecting..");
    success = firetalk_signon(ft_aim_connection, TOC_SERVER, TOC_PORT, [[username lowercaseString] cString]);
	NSLog(@"ApolloTOC> Sign on request sent...");	
    [lock unlock];
	
    if (success != FE_SUCCESS && success != FE_CONNECT)
    {
		NSLog(@"ApolloTOC> Payload prep...");
		NSMutableArray* payload = 
		[[NSMutableArray alloc]init];	
		[payload addObject:		@"9"];	
        switch (success)
        {
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

    connected = ApolloTOC_CONNECTING; 
    while (connected == ApolloTOC_CONNECTING)
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
        return NO;
}

//- (void)listBuddies
//{
//	[lock lock];
//	firetalk_im_list_buddies(ft_aim_connection);
//	[lock unlock];
//}

- (BOOL)connected
{
    if (connected == ApolloTOC_CONNECTED)
        return YES;
    else
        return NO;
}

- (void)disconnect
{
    
    if (connected == ApolloTOC_DISCONNECTED)
        return;
    
    [lock lock];
    if (connected == ApolloTOC_CONNECTING)
        connected = ApolloTOC_DISCONNECTED;
    else
    {
        connected = ApolloTOC_DISCONNECTED;
        firetalk_disconnect(ft_aim_connection); 
		NSMutableArray* payload = 
		[[NSMutableArray alloc]init];		
		[payload addObject:		@"9"];
		[_delegate imEvent:		payload];		
    }
    [lock unlock];
}

- (void)killHandle
{
	[lock lock];
	firetalk_destroy_handle(ft_aim_connection);
	[lock unlock];	
}

- (void)sendIM:(NSString*)body toUser:(NSString*)user
{
    NSLog(@"Sending IM %@ to user %@...", body, user);
    
    [lock lock];
    firetalk_im_send_message(ft_aim_connection, [user cString], [body cString], 0);
    [lock unlock];
}

- (void)buddyUpdate:(Buddy*)buddy withCode:(int)code
{
	NSLog(@"Buddy Update: %@ -- %d",[buddy name], code);
	NSMutableArray* payload = [[NSMutableArray alloc]init];		
	[payload addObject:	[[NSString alloc]initWithFormat:@"%d",code] ]; 
	[payload addObject:		buddy]; 	
	[_delegate imEvent:		payload];
}

- (void)registerFiretalkCallbacks
{

    [lock lock];
	int proto = firetalk_find_protocol("TOC2");
	NSLog(@"ApolloTOC> Registering callbacks... %d", proto);
	NSLog(@"ApolloTOC> Creating Handle...");	
    ft_aim_connection = firetalk_create_handle(proto, NULL);
	NSLog(@"ApolloTOC> Come on callbacks... %p", ft_aim_connection);
		
	if(ft_aim_connection == nil)
	{
		NSLog(@"Shit is fucked. Let's go get some tacobell.");
		//[UIApp exit];
		exit(40);	
	}
		
    firetalk_register_callback(ft_aim_connection, FC_DOINIT, (ptrtofnct)ft_callback_doinit);
    firetalk_register_callback(ft_aim_connection, FC_ERROR, (ptrtofnct)ft_callback_error);
    firetalk_register_callback(ft_aim_connection, FC_CONNECTFAILED, (ptrtofnct)ft_callback_connectfailed);
    firetalk_register_callback(ft_aim_connection, FC_IM_GETMESSAGE, (ptrtofnct)ft_callback_getmessage);
    firetalk_register_callback(ft_aim_connection, FC_DISCONNECT, (ptrtofnct)ft_callback_disconnect);
	firetalk_register_callback(ft_aim_connection, FC_NEEDPASS, (ptrtofnct)ft_callback_needpass);
	firetalk_register_callback(ft_aim_connection, FC_IM_LISTBUDDY, (ptrtofnct)ft_callback_listbuddy);
	firetalk_register_callback(ft_aim_connection, FC_IM_USER_NICKCHANGED, (ptrtofnct)ft_callback_im_user_nickchanged);	
	firetalk_register_callback(ft_aim_connection, FC_IM_BUDDYONLINE, (ptrtofnct)ft_callback_buddyonline);
	firetalk_register_callback(ft_aim_connection, FC_IM_BUDDYOFFLINE, (ptrtofnct)ft_callback_buddyoffline);
	firetalk_register_callback(ft_aim_connection, FC_IM_BUDDYAWAY, (ptrtofnct)ft_callback_buddyaway);
	firetalk_register_callback(ft_aim_connection, FC_IM_BUDDYUNAWAY, (ptrtofnct)ft_callback_buddyunaway);		
	firetalk_register_callback(ft_aim_connection, FC_IM_GOTINFO, (ptrtofnct)ft_callback_getinfo);
    [lock unlock];
    NSLog(@"ApolloTOC: firetalk callbacks registered.");
}

- (void)error:(int)code ftConnection:(void *)ftConnection
{
    // error code 11 is "unknown packet", which happens about once a minute
    // firetalk doesn't like some change that happened to the server and generates these
    // it's harmless, so ignore it
    if (code == 11)
	{
		return;	
	}
     
    
    NSLog(@"ApolloTOC: Error code %i recieved: %s", code, firetalk_strerror(code));
}

- (void)getInfo:(Buddy*)aBuddy
{
	[lock lock];
	firetalk_im_get_info(ft_aim_connection, [[[aBuddy name]lowercaseString]cString]);
	[lock unlock];
}

- (void)connectionSucessful:(void *)ftConnection
{
    [lock lock];
    //firetalk_im_upload_buddies(ftConnection); // kick to allow-all-but-denied mode

    //firetalk_set_away(ftConnection, "");

//    if (infoMessage)
//        firetalk_set_info(ftConnection, [infoMessage cString]);
    
    connected = ApolloTOC_CONNECTED;
	
    NSLog(@"ApolloTOC: Connection sucessful.");
    [lock unlock];
	NSMutableArray* payload = 
	[[NSMutableArray alloc]init];
	
	[payload addObject:		@"8"];
	[_delegate imEvent:		payload];
	NSLog(@"ApolloTOC>  here's to the good ol' days...");
	[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(keepAlive) userInfo:nil repeats:YES] ;	

//	firetalk_im_list_buddies(ftConnection);  //Use this at start to get full buddy listing.  Will be necessary for groups.

	[lock unlock];	
}

- (void)recievedMessage:(NSString*)message fromUser:(NSString*)user isAutomessage:(BOOL)automessage ftConnection:(void *)ftConnection
{
	NSLog(@"ApolloTOC: Recieved message from %@, is auto: %i.\n%@", user, automessage, message);
	
	Buddy* yourBuddy = [[Buddy alloc]init];
	[yourBuddy setName:user];
	
	NSMutableArray* payload = 
	[[NSMutableArray alloc]init];
	
	[payload addObject:		@"1"];
	[payload addObject:		yourBuddy];
	[payload addObject:		message];
	[_delegate imEvent:		payload];
//	[payload release];	
}

- (void)runloopCheck:(NSTimer*)timer
{
    struct timeval timeout;

  //  NSLog(@"Timer fired.");
    
    timeout.tv_sec = 0;
    timeout.tv_usec = 50;

    if (connected != ApolloTOC_DISCONNECTED)
    {		
        if (firetalk_select_custom(0,NULL,NULL,NULL,&timeout) < 0) {
            NSLog(@"ApolloTOC: Error: firetalk_select failed.");
             [NSApp terminate:self];
        }
    }
}

- (void)setDelegate:(id)delegate 
{
	_delegate = delegate;
}

- (BOOL)willSendMarkup
{
    return willSendMarkup;
}

- (void)setWillSendMarkup:(BOOL)newSetting
{
    willSendMarkup = newSetting;
}

- (void)disconnected:(void *)ftConnection reason:(int)reason
{
    if (connected != ApolloTOC_DISCONNECTED) // if we think we're connected and we get here, there's a problem
    {
        NSLog(@"ApolloTOC: Error: Disconnected by remote host! Trying to cleanly disconnect; other error messages may follow.");
        NSLog(@"Reason: %s", firetalk_strerror(reason));
	
		NSMutableArray* payload = 
		[[NSMutableArray alloc]init];	
		[payload addObject:		@"9"];
		[payload addObject:		[NSString stringWithCString:firetalk_strerror(reason)]];
		[_delegate imEvent:		payload];			
        [self disconnect];
    }
}

- (void)keepAlive
{
	Buddy* aBuddy = [[Buddy alloc]init];
	[aBuddy setName:@"WSJ"];
	[self getInfo:aBuddy];
	NSLog(@"Keeping alive...");
}

- (NSString*) userName
{
	return [you name];
}

@end
