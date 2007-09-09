//
//  ApolloIM-Connection.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 9/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
//
//
//
//
//#import "ApolloIM-Connection.h"
//These should be in ApolloIM-Common.h - but we don't have that yet
///*enum {
//	AIM_RECV_MESG		=	1,
//	AIM_BUDDY_ONLINE	=	2, 
//	AIM_BUDDY_OFFLINE	=	3, 
//	AIM_BUDDY_AWAY		=	4, 
//	AIM_BUDDY_UNAWAY	=	5,
//	AIM_BUDDY_IDLE		=	6,	
//	AIM_BUDDY_MSG_RECV	=   7,
//	AIM_CONNECTED		=   8,
//	AIM_DISCONNECTED	=	9,
//	AIM_READ_MSGS		=   10,
//	AIM_BUDDY_INFO		=	11	
//};
//
//@implementation ApolloIM_Connection
//PurpleCoreUiOps core_uiops = 
//{
//	NULL,
//	NULL,
//	null_ui_init,
//	NULL,
//
//	/* padding */
//	NULL,
//	NULL,
//	NULL,
//	NULL
//};
//
//PurpleConversationUiOps conv_uiops = 
//{
//	NULL,                      /* create_conversation  */
//	NULL,                      /* destroy_conversation */
//	NULL,                      /* write_chat           */
//	NULL,                      /* write_im             */
//	null_write_conv,           /* write_conv           */
//	NULL,                      /* chat_add_users       */
//	NULL,                      /* chat_rename_user     */
//	NULL,                      /* chat_remove_users    */
//	NULL,                      /* chat_update_user     */
//	NULL,                      /* present              */
//	NULL,                      /* has_focus            */
//	NULL,                      /* custom_smiley_add    */
//	NULL,                      /* custom_smiley_write  */
//	NULL,                      /* custom_smiley_close  */
//	NULL,                      /* send_confirm         */
//	NULL,
//	NULL,
//	NULL,
//	NULL
//};
//
//typedef struct _PurpleGLibIOClosure {
//	PurpleInputFunction function;
//	guint result;
//	gpointer data;
//} PurpleGLibIOClosure;
//
//gboolean purple_glib_io_invoke(GIOChannel *source, GIOCondition condition, gpointer data)
//{
//	PurpleGLibIOClosure *closure = data;
//	PurpleInputCondition purple_cond = 0;
//
//	if (condition & PURPLE_GLIB_READ_COND)
//		purple_cond |= PURPLE_INPUT_READ;
//	if (condition & PURPLE_GLIB_WRITE_COND)
//		purple_cond |= PURPLE_INPUT_WRITE;
//
//	closure->function(closure->data, g_io_channel_unix_get_fd(source),
//			  purple_cond);
//
//	return TRUE;
//}
//
//guint glib_input_add(gint fd, PurpleInputCondition condition, PurpleInputFunction function,
//							   gpointer data)
//{
//	PurpleGLibIOClosure *closure = g_new0(PurpleGLibIOClosure, 1);
//	GIOChannel *channel;
//	GIOCondition cond = 0;
//
//	closure->function = function;
//	closure->data = data;
//
//	if (condition & PURPLE_INPUT_READ)
//		cond |= PURPLE_GLIB_READ_COND;
//	if (condition & PURPLE_INPUT_WRITE)
//		cond |= PURPLE_GLIB_WRITE_COND;
//
//	channel = g_io_channel_unix_new(fd);
//	closure->result = g_io_add_watch_full(channel, G_PRIORITY_DEFAULT, cond,
//						  purple_glib_io_invoke, closure, purple_glib_io_destroy);
//
//	g_io_channel_unref(channel);
//	return closure->result;
//}
//
//void signed_on(PurpleConnection *gc, gpointer null)
//{
//	PurpleAccount *account = purple_connection_get_account(gc);
//	NSLog(@"Account connected: %s %s\n", account->username, account->protocol_id);
//}
//
//
//- (id)initWithAccount:(Acct*)newAccount withDelegate:(id)delegate
//{
//	self = [super init];
//
//	_delegate = delegate;
//	thisAccount = newAccount;
//	
//	NSLog(@"Initing new ApolloIM-Connection...");
//
//	connected = ApolloCORE_DISCONNECTED;
//	
//	init_libpurple();
//	
//		NSLog(@"libpurple initialized.");
//
//
//	// If we need all the protocols they should probably be in ApolloCore
//	iter = purple_plugins_get_protocols();
//    loop = g_main_loop_new(NULL, FALSE);	
//	
//	for (i = 0; iter; iter = iter->next) {/
//		PurplePlugin *plugin = iter->data;
//		PurplePluginInfo *info = plugin->info;
//		if (info && info->name) {
//			printf("\t%d: %s\n", i++, info->name);
//			NSLog(@"%d -- %s", i++, info->name);
//			names = g_list_append(names, info->id);
//		}
//
//	}
//
//	return self;
//}
//
//
//void init_libpurple()
//{
//		purple_util_set_user_dir([[NSString stringWithString:@"."]cString]);
//		purple_debug_set_enabled(FALSE);
//		purple_core_set_ui_ops(&null_core_uiops);
//		purple_eventloop_set_ui_ops(&glib_eventloops);
//		purple_plugins_add_search_path([[NSString stringWithString:@"./plugins/"]cString]);
//		purple_core_init(0);
//		purple_set_blist(purple_blist_new());
//		purple_blist_load();
//		purple_prefs_load();
//		purple_plugins_load_saved(PLUGIN_SAVE_PREF);
//		purple_pounces_load();
//}
//
///* 
// 
//What we need to do to "init" a purple:
//
// init_libpurple()
//  
//  Set the core-uiops, which is used to
//	 - initialize the ui specific preferences.
//	 - initialize the debug ui.
//	 - initialize the ui components for all the modules.
//	 - uninitialize the ui components for all the modules when the core terminates.
//
//		purple_util_set_user_dir([[NSString stringWithString:@"."]cString]);
//		purple_debug_set_enabled(FALSE);
//		purple_core_set_ui_ops(&null_core_uiops);
//		purple_eventloop_set_ui_ops(&glib_eventloops);
//		purple_plugins_add_search_path([[NSString stringWithString:@"./plugins/"]cString]);
//		purple_core_init(0);
//		purple_set_blist(purple_blist_new());
//		purple_blist_load();
//		purple_prefs_load();
//		purple_plugins_load_saved(PLUGIN_SAVE_PREF);
//		purple_pounces_load();
//
//*/
//
//- (BOOL)connectUsingAccount:(Acct*)account
//{
//	int success;
//
//	if ([self connected])
//		return YES;
//
//	NSLog(@"In connectUsingAccount");
//	
//   [lock lock];
//   
//	/* Create the account */
//	purple_account = purple_account_new([thisAccount username], [thisAccount connection]);    // libpurple call
//
//	/* Get the password for the account */
//	purple_account_set_password(purple_account, [thisAccount password]);                     // libpurple call
//
//	/* It's necessary to enable the account first. */
//	purple_account_set_enabled(purple_account, UI_ID, TRUE);                                  // libpurple call
//
//	/* Now, to connect the account(s), create a status and activate it. */
//	status = purple_savedstatus_new(NULL, PURPLE_STATUS_AVAILABLE);                           // libpurple call
//	
//	purple_savedstatus_activate(status);                                                      // libpurple call
//	
//	connect_to_signals();
//
//	g_main_loop_run(loop);
//   
//	return YES; //Please, just work  //if connectUsingAccount return's no, it means it failed to login.  
//								   //for purple, this may have to be a void function with callbacks declared stating the login 
//	
//    ft_callback_storepass("");
//    ft_callback_storepass([password UTF8String]);
//	NSLog(@"ApolloTOC> Password Stored... Connecting.. %@",username);
//   /* success = firetalk_signon(ft_aim_connection, TOC_SERVER, TOC_PORT, [username cString]);
//	NSLog(@"ApolloTOC> Sign on request sent...");	
//	[lock unlock];		
//	
//	if (success != FE_SUCCESS)
//	{
//		NSLog(@"ApolloTOC> Payload prep...");
//		NSMutableArray* payload = 
//		[[NSMutableArray alloc]init];	
//		[payload addObject:		@"9"];	
//		switch (success)
//		{
//			case FE_CONNECT: [payload addObject:@"Apollo Unable to connect."]; break;
//			case FE_BADUSERPASS: [payload addObject:@"ApolloTOC: Bad user name or password."]; break;
//			case FE_SERVER: [payload addObject:@"ApolloTOC: Can't find specfied server."]; break;            
//			case FE_SOCKET: [payload addObject:@"ApolloTOC: Your internet connection is not ready."]; break;            
//			case FE_RESOLV: [payload addObject:@"ApolloTOC: Can't resolve specified server."]; break;            
//			case FE_BADCONNECTION: [payload addObject:@"ApolloTOC: Bad Connection."]; break;
//			case FE_VERSION: [payload addObject:@"ApolloTOC: Wrong Version."]; break;
//			case FE_BLOCKED: [payload addObject:@"ApolloTOC: You have been blocked. Signing on too often/too fast?"]; break;
//			case FE_USERDISCONNECT: [payload addObject:@"ApolloTOC: You're disconnected."]; break;
//			case FE_DISCONNECT: [payload addObject:@"ApolloTOC: Server disconnected you."]; break;
//			case FE_UNKNOWN: [payload addObject:@"ApolloTOC: Unknown error. Generally caused by a slow or unreachable toc network at AOL."]; break;
//			case FE_BADUSER: [payload addObject:@"ApolloTOC: Bad user name or password."]; break;
//			default:
//				[payload addObject:[NSString stringWithFormat:@"ApolloTOC: Unable to login to aim/toc, generic error %d\n", success]]; break;
//		}
//		[_delegate imEvent:		payload];		
//		return NO;
//	}
//
//	connected = ApolloCORE_CONNECTING; 
//	while (connected == ApolloCORE_CONNECTING)
//	{
//		[self runloopCheck:nil]; 
//		status = NO;
//		usleep(100); // wait for connection to either fail or succeed
//	}
//	if ([self connected])
//	{
//		//firetalk_im_list_buddies(ft_aim_connection);		
//		return YES;
//	}
//	else
//		return NO;*/
//}
//
//- (BOOL)connected
//{
//	if (connected == ApolloCORE_CONNECTED)
//		return YES;
//	else
//		return NO;
//}
//
//- (void)buddyUpdate:(Buddy*)buddy withCode:(int)code
//{
//	NSLog(@"Buddy Update: %@ -- %d",[buddy name], code);
//	NSMutableArray* payload = [[NSMutableArray alloc]init];		
//	[payload addObject:	[[NSString alloc]initWithFormat:@"%d",code] ]; 
//	[payload addObject:		buddy]; 	
//	[_delegate imEvent:		payload];
//}
//
//- (void)error:(int)code
//{
//}
//
//- (void)registerCallbacks
//{
//
//	[lock lock];
//			
//	[lock unlock];
//	NSLog(@"ApolloTOC: firetalk callbacks registered.");
//}
//- (void)getInfo:(Buddy*)aBuddy
//{
//	[lock lock];
//	firetalk_im_get_info(ft_aim_connection, [[[aBuddy name]lowercaseString]cString]);
//	[lock unlock];
//}
//
//- (void)connectionSucessful:(void *)ftConnection
//{
//	[lock lock];
//	//firetalk_im_upload_buddies(ftConnection); // kick to allow-all-but-denied mode
//
//	//firetalk_set_away(ftConnection, "");
//
//    if (infoMessage)
//        firetalk_set_info(ftConnection, [infoMessage cString]);
//	
//	connected = ApolloCORE_CONNECTED;
//	
//	NSLog(@"ApolloTOC: Connection sucessful.");
//	[lock unlock];
//	NSMutableArray* payload = 
//	[[NSMutableArray alloc]init];
//	
//	[payload addObject:		@"8"];
//	[_delegate imEvent:		payload];
//	NSLog(@"ApolloTOC>  here's to the good ol' days...");
//	keepAlive = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(keepAlive) userInfo:nil repeats:YES] ;	
//
//
//	[lock unlock];	
//}
//
//- (void)sendIM:(NSString*)body     toBuddy:(Buddy*)buddy
//{
//	NSLog(@"ApolloTOC: Recieved message from %@, is auto: %i.\n%@", [buddy properName], automessage, message); //properName strips spaces and capitalizes every character of their username.  Useful for comparing buddy names.
//	[[ApolloNotificationController sharedInstance]playRecvIm];	
//	
//	NSMutableArray* payload = 
//	[[NSMutableArray alloc]init];
//	
//	[payload addObject:		@"1"];
//	[payload addObject:		buddy];
//	[payload addObject:		message];
//	[_delegate imEvent:		payload];
//}
//
//
//- (void)setDelegate:(id)delegate 
//{
//	_delegate = delegate;
//}
///*- (void)disconnect
//{    
//	if (connected == ApolloCORE_DISCONNECTED)
//	{
//		NSLog(@"Can't disconnect if disconnected.");
//		return;
//	}
//	
//	[lock lock];
//	if (connected == ApolloCORE_CONNECTING)
//	{
//		NSLog(@"Connecting Clause");
//		connected = ApolloCORE_DISCONNECTED;
//	}
//	else
//	{
//		NSLog(@"Setting to disconnect.");	
//        connected = ApolloCORE_DISCONNECTED;
//        firetalk_disconnect(ft_aim_connection);
//	}
//	[lock unlock];
//}
//
//
//- (void)disconnected
//{
//	if (connected != ApolloCORE_DISCONNECTED) // if we think we're connected and we get here, there's a problem
//	{
//		[lock lock];
//*//*        NSLog(@"ApolloTOC: Error: Disconnected by remote host! Trying to cleanly disconnect; other error messages may follow.");
//		connected = ApolloCORE_DISCONNECTED;
//		NSMutableArray* payload = 
//		[[NSMutableArray alloc]init];	
//		[payload addObject:		@"9"];
//		[payload addObject:		@"THERE IS NO REASON RIGHT NOW"];
//		[_delegate imEvent:		payload];*//*
//		[lock unlock];
//	}
//	else
//		NSLog(@"This is pretty much impossible.  WTF M8");
//}
//
//- (void)buddyUpdate:(Buddy*)buddy withCode:(int)code
//{
//	NSLog(@"Called buddyUpdate");
//	
//	/*
//	This is the enum that's in startview as well, so any buddy update will be called with one of these codes
//	AIM_RECV_MESG		=	1,
//	AIM_BUDDY_ONLINE	=	2, 
//	AIM_BUDDY_OFFLINE	=	3, 
//	AIM_BUDDY_AWAY		=	4, 
//	AIM_BUDDY_UNAWAY	=	5,
//	AIM_BUDDY_IDLE		=	6,	
//	AIM_BUDDY_MSG_RECV	=   7,
//	AIM_CONNECTED		=   8,
//	AIM_DISCONNECTED	=	9,
//	AIM_READ_MSGS		=   10,
//	AIM_BUDDY_INFO		=	11	
//	
//	*//*
//}
//
//
//
//- (Acct*)thisAccount
//{
//	return thisAccount;
//}
//
//- (NSString*) username
//{
//	return [thisAccount username];
//}
//
//@end*/
