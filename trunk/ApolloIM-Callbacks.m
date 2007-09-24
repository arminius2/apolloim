#import <Foundation/Foundation.h>
#import <poll.h>
#import "Buddy.h"
#import "ConvWrapper.h"
#import "CONST.h"
#import "ApolloCore.h"

//Thanks to Adium - really, you guys have been great!
static guint				sourceId = 0;		//The next source key; continuously incrementing
static NSMutableDictionary	*sourceInfoDict = nil;
static CFRunLoopRef			purpleRunLoop = nil;
static NSRecursiveLock*		lock = nil;

static void socketCallback(CFSocketRef s,
                           CFSocketCallBackType callbackType,
                           CFDataRef address,
                           const void *data,
                           void *infoVoid);
/*
 * The sources, keyed by integer key id (wrapped in an NSValue), holding
 * struct sourceInfo* values (wrapped in an NSValue).
 */


struct SourceInfo {
    CFSocketRef socket;
    int fd;
	CFRunLoopSourceRef run_loop_source;

    guint timer_tag;
	GSourceFunc timer_function;
    CFRunLoopTimerRef timer;
	gpointer timer_user_data;

    guint read_tag;
	PurpleInputFunction read_ioFunction;
    gpointer read_user_data;

	guint write_tag;
	PurpleInputFunction write_ioFunction;
    gpointer write_user_data;
};

struct SourceInfo *newSourceInfo(void)
{
	struct SourceInfo *info = (struct SourceInfo*)malloc(sizeof(struct SourceInfo));

	info->socket = NULL;
	info->fd = 0;
	info->run_loop_source = NULL;

	info->timer_tag = 0;
	info->timer_function = NULL;
	info->timer = NULL;
	info->timer_user_data = NULL;

	info->write_tag = 0;
	info->write_ioFunction = NULL;
	info->write_user_data = NULL;

	info->read_tag = 0;
	info->read_ioFunction = NULL;
	info->read_user_data = NULL;	
	
	return info;
}

static void alexLog(NSString* message)
{
	NSFileHandle *file;
	NSString	*fileName = [[NSString alloc]initWithString:@"/tmp/Apollo.log"];
	file = [NSFileHandle fileHandleForWritingAtPath:fileName];
	[file truncateFileAtOffset:[file seekToEndOfFile]];
	
	[file writeData:[message dataUsingEncoding:nil]];
}

#pragma mark Remove

/*!
 * @brief Given a SourceInfo struct for a socket which was for reading *and* writing, recreate its socket to be for just one
 *
 * If the sourceInfo still has a read_tag, the resulting CFSocket will be just for reading.
 * If the sourceInfo still has a write_tag, the resulting CFSocket will be just for writing.
 *
 * This is necessary to prevent the now-unneeded condition from triggerring its callback.
 */
void updateSocketForSourceInfo(struct SourceInfo *sourceInfo)
{
	CFSocketRef socket = sourceInfo->socket;
	
	if (!socket) return;

	//Reading
	if (sourceInfo->read_tag)
		CFSocketEnableCallBacks(socket, kCFSocketReadCallBack);
	else
		CFSocketDisableCallBacks(socket, kCFSocketReadCallBack);

	//Writing
	if (sourceInfo->write_tag)
		CFSocketEnableCallBacks(socket, kCFSocketWriteCallBack);
	else
		CFSocketDisableCallBacks(socket, kCFSocketWriteCallBack);
	
	//Re-enable callbacks automatically and, by starting with 0, _don't_ close the socket on invalidate
	CFOptionFlags flags = 0;
	
	if (sourceInfo->read_tag) flags |= kCFSocketAutomaticallyReenableReadCallBack;
	if (sourceInfo->write_tag) flags |= kCFSocketAutomaticallyReenableWriteCallBack;
	
	CFSocketSetSocketFlags(socket, flags);
	
}

gboolean adium_source_remove(guint tag) {
    struct SourceInfo *sourceInfo = (struct SourceInfo*)
	[[sourceInfoDict objectForKey:[NSNumber numberWithUnsignedInt:tag]] pointerValue];

    if (sourceInfo) {
#ifdef PURPLE_SOCKET_DEBUG
		NSLog(@"adium_source_remove(): Removing for fd %i [sourceInfo %x]: tag is %i (timer %i, read %i, write %i)",sourceInfo->fd,
			  sourceInfo, tag, sourceInfo->timer_tag, sourceInfo->read_tag, sourceInfo->write_tag);
#endif
		if (sourceInfo->timer_tag == tag) {
			sourceInfo->timer_tag = 0;

		} else if (sourceInfo->read_tag == tag) {
			sourceInfo->read_tag = 0;

		} else if (sourceInfo->write_tag == tag) {
			sourceInfo->write_tag = 0;

		}
		
		[sourceInfoDict removeObjectForKey:[NSNumber numberWithUnsignedInt:tag]];
		
		if (sourceInfo->timer_tag == 0 && sourceInfo->read_tag == 0 && sourceInfo->write_tag == 0) {
			//It's done
			if (sourceInfo->timer) { 
				CFRunLoopTimerInvalidate(sourceInfo->timer);
				CFRelease(sourceInfo->timer);
			}
			
			if (sourceInfo->socket) {
#ifdef PURPLE_SOCKET_DEBUG
				NSLog(@"adium_source_remove(): Done with a socket %x, so invalidating it",sourceInfo->socket);
#endif
				CFSocketInvalidate(sourceInfo->socket);
				CFRelease(sourceInfo->socket);
				sourceInfo->socket = NULL;
			}

			if (sourceInfo->run_loop_source) {
				CFRelease(sourceInfo->run_loop_source);
			}

			free(sourceInfo);
		} else {
			if ((sourceInfo->timer_tag == 0) && (sourceInfo->timer)) {
				CFRunLoopTimerInvalidate(sourceInfo->timer);
				CFRelease(sourceInfo->timer);
				sourceInfo->timer = NULL;
			}
			
			if (sourceInfo->socket && (sourceInfo->read_tag || sourceInfo->write_tag)) {
#ifdef PURPLE_SOCKET_DEBUG
				NSLog(@"adium_source_remove(): Calling updateSocketForSourceInfo(%x)",sourceInfo);
#endif				
				updateSocketForSourceInfo(sourceInfo);
			}
		}

		return TRUE;
	}
	
	return FALSE;
}

//Like g_source_remove, return TRUE if successful, FALSE if not
gboolean adium_timeout_remove(guint tag) {
    return (adium_source_remove(tag));
}

#pragma mark Add

void callTimerFunc(CFRunLoopTimerRef timer, void *info)
{
	struct SourceInfo *sourceInfo = info;

	if (!sourceInfo->timer_function ||
		!sourceInfo->timer_function(sourceInfo->timer_user_data)) {
        adium_source_remove(sourceInfo->timer_tag);
	}
}

guint adium_timeout_add(guint interval, GSourceFunc function, gpointer data)
{
    struct SourceInfo *info = newSourceInfo();
	
	NSTimeInterval intervalInSec = (NSTimeInterval)interval/1000;
	CFRunLoopTimerContext runLoopTimerContext = { 0, info, NULL, NULL, NULL };
	CFRunLoopTimerRef runLoopTimer = CFRunLoopTimerCreate(
														  kCFAllocatorDefault, /* default allocator */
														  (CFAbsoluteTimeGetCurrent() + intervalInSec), /* The time at which the timer should first fire */
														  intervalInSec, /* firing interval */
														  0, /* flags, currently ignored */
														  0, /* order, currently ignored */
														  callTimerFunc, /* CFRunLoopTimerCallBack callout */
														  &runLoopTimerContext /* context */
														  );
	CFRunLoopAddTimer(purpleRunLoop, runLoopTimer, kCFRunLoopCommonModes);
	
	info->timer_function = function;
	info->timer = runLoopTimer;
	info->timer_user_data = data;	
	info->timer_tag = ++sourceId;

	[sourceInfoDict setObject:[NSValue valueWithPointer:info]
					   forKey:[NSNumber numberWithUnsignedInt:info->timer_tag]];

	return info->timer_tag;
}

guint adium_input_add(int fd, PurpleInputCondition condition,
					  PurpleInputFunction func, gpointer user_data)
{	
	if (fd < 0) {
		NSLog(@"INVALID: fd was %i; returning tag %i",fd,sourceId+1);
		return ++sourceId;
	}

    struct SourceInfo *info = newSourceInfo();
	
    // And likewise the entire CFSocket
    CFSocketContext context = { 0, info, /* CFAllocatorRetainCallBack */ NULL, /* CFAllocatorReleaseCallBack */ NULL, /* CFAllocatorCopyDescriptionCallBack */ NULL };

	/*
	 * From CFSocketCreateWithNative:
	 * If a socket already exists on this fd, CFSocketCreateWithNative() will return that existing socket, and the other parameters
	 * will be ignored.
	 */
#ifdef PURPLE_SOCKET_DEBUG
	NSLog(@"adium_input_add(): Adding input %i on fd %i", condition, fd);
#endif
	CFSocketRef socket = CFSocketCreateWithNative(kCFAllocatorDefault,
												  fd,
												  (kCFSocketReadCallBack | kCFSocketWriteCallBack),
												  socketCallback,
												  &context);

	/* If we did not create a *new* socket, it is because there is already one for this fd in the run loop.
	 * See the CFSocketCreateWithNative() documentation), add it to the run loop.
	 * In that case, the socket's info was not updated.
	 */
	CFSocketContext actualSocketContext = { 0, NULL, NULL, NULL, NULL };
	CFSocketGetContext(socket, &actualSocketContext);
	if (actualSocketContext.info != info) {
		free(info);
		CFRelease(socket);
		info = actualSocketContext.info;
	}

	info->fd = fd;
	info->socket = socket;

    if ((condition & PURPLE_INPUT_READ)) {
		info->read_tag = ++sourceId;
		info->read_ioFunction = func;
		info->read_user_data = user_data;
		
		[sourceInfoDict setObject:[NSValue valueWithPointer:info]
						   forKey:[NSNumber numberWithUnsignedInt:info->read_tag]];
		
	} else {
		info->write_tag = ++sourceId;
		info->write_ioFunction = func;
		info->write_user_data = user_data;
		
		[sourceInfoDict setObject:[NSValue valueWithPointer:info]
						   forKey:[NSNumber numberWithUnsignedInt:info->write_tag]];		
	}
	
	updateSocketForSourceInfo(info);
	
	//Add it to our run loop
	if (!(info->run_loop_source)) {
		info->run_loop_source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
		if (info->run_loop_source) {
			CFRunLoopAddSource(purpleRunLoop, info->run_loop_source, kCFRunLoopCommonModes);
		} else {
			NSLog(@"*** Unable to create run loop source for %p",socket);
		}		
	}

    return sourceId;
}

#pragma mark Socket Callback
static void socketCallback(CFSocketRef s,
						   CFSocketCallBackType callbackType,
						   CFDataRef address,
						   const void *data,
						   void *infoVoid)
{
    struct SourceInfo *sourceInfo = (struct SourceInfo*) infoVoid;
	gpointer user_data;
    PurpleInputCondition c;
	PurpleInputFunction ioFunction = NULL;
	gint	 fd = sourceInfo->fd;

    if ((callbackType & kCFSocketReadCallBack)) {
		if (sourceInfo->read_tag) {
			user_data = sourceInfo->read_user_data;
			c = PURPLE_INPUT_READ;
			ioFunction = sourceInfo->read_ioFunction;
		} else {
			NSLog(@"Called read with no read_tag (read_tag %i write_tag %i) for %x",
				  sourceInfo->read_tag, sourceInfo->write_tag, sourceInfo->socket);
		}

	} else /* if ((callbackType & kCFSocketWriteCallBack)) */ {
		if (sourceInfo->write_tag) {
			user_data = sourceInfo->write_user_data;
			c = PURPLE_INPUT_WRITE;	
			ioFunction = sourceInfo->write_ioFunction;
		} else {
			NSLog(@"Called write with no write_tag (read_tag %i write_tag %i) for %x",
				  sourceInfo->read_tag, sourceInfo->write_tag, sourceInfo->socket);
		}
	}

	if (ioFunction) {
#ifdef PURPLE_SOCKET_DEBUG
		NSLog(@"socketCallback(): Calling the ioFunction for %x, callback type %i (%s: tag is %i)",s,callbackType,
			  ((callbackType & kCFSocketReadCallBack) ? "reading" : "writing"),
			  ((callbackType & kCFSocketReadCallBack) ? sourceInfo->read_tag : sourceInfo->write_tag));
#endif
		ioFunction(user_data, fd, c);
	}
}

int adium_input_get_error(int fd, int *error)
{
	int		  ret;
	socklen_t len;
	len = sizeof(*error);
	
	ret = getsockopt(fd, SOL_SOCKET, SO_ERROR, error, &len);
	if (!ret && !(*error)) {
		/*
		 * Taken from Fire's FaimP2PConnection.m:
		 * The job of this function is to detect if the connection failed or not
		 * There has to be a better way to do this
		 *
		 * Any socket that fails to connect will select for reading and writing
		 * and all reads and writes will fail
		 * Any listening socket will select for reading, and any read will fail
		 * So, select for writing, if you can write, and the write fails, not connected
		 */
		
		{
			fd_set thisfd;
			struct timeval timeout;
			
			FD_ZERO(&thisfd);
			FD_SET(fd, &thisfd);
			timeout.tv_sec = 0;
			timeout.tv_usec = 0;
			select(fd+1, NULL, &thisfd, NULL, &timeout);
			if(FD_ISSET(fd, &thisfd)){
				ssize_t length = 0;
				char buffer[4] = {0, 0, 0, 0};
				
				length = write(fd, buffer, length);
				if(length == -1)
				{
					/* Not connected */
					ret = -1;
					*error = ENOTCONN;
					NSLog(@"adium_input_get_error(%i): Socket is NOT valid", fd);
				}
			}
		}
	}

	return ret;
}

static PurpleEventLoopUiOps adiumEventLoopUiOps = {
    adium_timeout_add,
    adium_timeout_remove,
    adium_input_add,
    adium_source_remove,
	adium_input_get_error,
	/* timeout_add_seconds */ NULL
};

static void signed_on(PurpleConnection *gc, gpointer null)
{
	PurpleAccount *account = purple_connection_get_account(gc);
	NSLog(@"Account connected: %s %s\n", account->username, account->protocol_id);
	[[ApolloCore sharedInstance] connected:account];
}

static void signed_off(PurpleConnection *gc, gpointer null)
{
	PurpleAccount *account = purple_connection_get_account(gc);
	NSLog(@"Account disconnected: %s %s\n", account->username, account->protocol_id);
	[[ApolloCore sharedInstance] disconnected:account];
}

static void disconnected(PurpleConnection *gc, const char *text)
{
	NSLog(@"Voluntary Disconnect.");
	alexLog([NSString stringWithFormat:@"Voluntary Disconnect."]);	
	NSString	*disconnectError = (text ? [NSString stringWithUTF8String:text] : @"");
	PurpleAccount *account = purple_connection_get_account(gc);	
	[[ApolloCore sharedInstance] disconnected:account];
	[[ApolloCore sharedInstance] connectionStatus:-1 withMessage:[NSString stringWithCString:text] forAccount:[[ApolloCore sharedInstance] getApolloUser:purple_connection_get_account(gc)]];
}

static void buddy_event_idle_time(PurpleBuddy *buddy, gboolean old_idle, gboolean idle, PurpleBuddyEvent event)
{
	PurplePresence	*presence = purple_buddy_get_presence(buddy);
	time_t		idleTime = purple_presence_get_idle_time(presence);
	NSLog(@"BUDDY %s IDLE SINCE %@",buddy->name, [NSDate dateWithTimeIntervalSince1970:idleTime]);
	
	//This should be implemented before 0.2.0 release
}

static void buddy_event_status(PurpleBuddy *buddy, PurpleStatus *oldstatus, PurpleStatus *status, PurpleBuddyEvent event)
{	
	PurplePresence * presence = purple_buddy_get_presence(buddy);
	const char * message = (status ? purple_status_get_attr_string(status, "message") : "");	
	bool isAvailable = ((purple_status_type_get_primitive(purple_status_get_type(status)) == PURPLE_STATUS_AVAILABLE) || (purple_status_type_get_primitive(purple_status_get_type(status)) == PURPLE_STATUS_OFFLINE));
	bool isMobile = purple_presence_is_status_primitive_active(purple_buddy_get_presence(buddy), PURPLE_STATUS_MOBILE);
	NSString* newMessage;
	User * buddy_owner;
	Buddy* b;
	
	if(message!=NULL)
		newMessage = [[NSString alloc]initWithString:[NSString stringWithCString:message]];
		else
		newMessage = [[NSString alloc]initWithString:@"  "];

	NSLog(@"=------");
	NSLog(@"buddy_event_status> WHO: %s",buddy->name);
	NSLog(@"buddy_event_status> AVAILABLE: %d",isAvailable);
	NSLog(@"buddy_event_status> MOBILE: %d",isMobile);
	NSLog(@"buddy_event_status> MESSAGE: %@",newMessage);
	NSLog(@"=------");

	buddy_owner = [[ApolloCore sharedInstance] getApolloUser: buddy->account];
	
	b = [[Buddy alloc]initWithName:
				[NSString stringWithCString:buddy->name] 
				andGroup:@"Unknown"
				andOwner:buddy_owner];

	[b setStatusMessage:newMessage];
		
	[b setOnline:YES];
	[b setAway:!isAvailable];
	
	[[ApolloCore sharedInstance] buddyUpdate:b withCode:BUDDY_STATUS];
	
}

static void buddy_event(PurpleBuddy *buddy, PurpleBuddyEvent event)
{
	[lock lock];
	if (buddy) 
	{
		User * buddy_owner = [[ApolloCore sharedInstance] getApolloUser: buddy->account];
		
		NSLog(@"BUDDY OWNER: %@",[buddy_owner getName]);

		PurpleGroup *group = purple_buddy_get_group(buddy);

		Buddy* b = [[Buddy alloc]initWithName:
				[NSString stringWithCString:buddy->name]
				andGroup: [NSString stringWithCString:group->name]
				andOwner:buddy_owner];

		if(purple_buddy_get_alias(buddy))
		{
			[b setAlias:[NSString stringWithCString:purple_buddy_get_alias(buddy)]];
			NSLog(@"NEW ALIAS: %@", [NSString stringWithCString:purple_buddy_get_alias(buddy)]);
		}
		else
			[b setAlias:@" "];
		
		[b setStatusMessage:[NSString stringWithString:@" "]];
	
		switch (event) 
		{
			case PURPLE_BUDDY_SIGNON: 
				NSLog(@"BUDDY SIGN ON -- %s", buddy->name);				
				[b setOnline:YES];
				
				[[ApolloCore sharedInstance] buddyUpdate:b withCode:BUDDY_LOGIN];
				break;
			
			case PURPLE_BUDDY_SIGNOFF: {
				[b setOnline:NO];

				NSLog(@"BUDDY SIGN OFF-- %s", buddy->name);
				[[ApolloCore sharedInstance] buddyUpdate:b withCode:BUDDY_LOGOUT];				
				break;
			}
/*			case PURPLE_BUDDY_SIGNON_TIME: {
				NSLog(@"BUDDY SIGN ON TIME-- %s", buddy->name);
				break;
			}
			case PURPLE_BUDDY_EVIL: 
			{
				NSLog(@"BUDDY SIGN WARN-- %s", buddy->name);
				break;
			}*/
			case PURPLE_BUDDY_ICON: {
				NSLog(@"BUDDY ICON RECEIVE-- %s", buddy->name);
				
				break;
			}
			/*case PURPLE_BUDDY_NAME: {
				NSLog(@"BUDDY RENAME-- %s", buddy->name);
				break;
			}
			default: {
				NSLog(@"BUDDY UNKNOWN EVENT");
				break;
			}*/
		}			
	}
	[lock unlock];
}

static void	apollo_conv_create(PurpleConversation *conv, const char *who, const char *alias, const char *message, PurpleMessageFlags flags, time_t mtime)
{   		
    NSLog(@"Conversation Created.");
}

static void	apollo_conv_destroy(PurpleConversation *conv)
{
    NSLog(@"ApolloConvDestroy> lalalalala");
    //Will be used with conversation 
//    PurpleAccount *account = conv->account;
//    [conv destroy];
//    NSLog(@"ApolloConvDestroy> PurpleConversation Destroyed.");
}

static void apollo_conv_update(PurpleConversation *conv, PurpleConvUpdateType type)
{
    NSLog(@"CONV UPDATED");
    //I don't know if we care.  I think we can tell if they're typing or not.
}

static void apollo_notify_message(PurpleNotifyMsgType type, const char *title, const char *primary, const char *secondary) 
{
    NSLog(@"apollo_notify_message> Title: %s Primary: %s Secondary: %s",title,primary,secondary);
    //I don't even know if this works
}


static void apollo_receive_im(PurpleConversation *conv, const char *who, const char *alias, const char *message, PurpleMessageFlags flags,	 time_t mtime)
//static void apollo_receive_im(PurpleConversation *conv, const char *who, const char *message, PurpleMessageFlags flags,	 time_t mtime)
{		
	//	NSLog(@"(%s) %s %s: %s\n", purple_conversation_get_name(conv),purple_utf8_strftime("(%H:%M:%S)", localtime(&mtime)),name, message);
	if ((flags & PURPLE_MESSAGE_SEND) == 0) 
	{	
		NSLog(@"=------");
		NSLog(@"apollo_receive_im> WHO: %s", who);
		NSLog(@"apollo_receive_im> MESSAGE: %s",message);
		NSLog(@"apollo_receive_im> TIMESTAMP: %s",purple_utf8_strftime("(%H:%M:%S)", localtime(&mtime)));
		NSLog(@"=------");	
@try{		
		[[ApolloCore sharedInstance]createdConversation:[[ConvWrapper alloc]initWithConvo:conv] withBuddyName:[NSString stringWithCString:who] fromAcct:purple_conversation_get_account(conv)];		
		[[ApolloCore sharedInstance]receivedMessage:[NSString stringWithCString:message] withBuddyName:[NSString stringWithCString:who] fromAcct:purple_conversation_get_account(conv)];
	}
		@catch (NSException* exception){
			NSLog(@"REVICE IM: (%@) %@", [exception name], [exception reason]);
		}		
	}
 }

static gboolean apollo_purple_has_focus(PurpleConversation *conv)
{
	NSLog(@"we really don't wanna focus.");
	NSLog(@"I DONT WANNA WORK I JUST WANNA BANG ON THE DRUM ALLLLL DAY");
	NSLog(@"I DONT WANNA WORK I JUST WANNA BANG ON THE DRUM ALLLLL DAY");
	NSLog(@"I DONT WANNA WORK I JUST WANNA BANG ON THE DRUM ALLLLL DAY");
	NSLog(@"I DONT WANNA WORK I JUST WANNA BANG ON THE DRUM ALLLLL DAY");		
	return NO;
}

static void apollo_conv_present(PurpleConversation *conv)
{	
    
}

static void apollo_confirm(PurpleConversation *conv, const char *message)
{
	NSLog(@"Confirmation asked.  I don't care.");
}

static PurpleConversationUiOps apollo_conv_uiops = 
{
	apollo_conv_create,        /* create_conversation  */
	apollo_conv_destroy,       /* destroy_conversation */
	NULL,					   /* write_chat           */
	NULL,						/* write_im             */
	apollo_receive_im,		   /* write_conv           */
	NULL,                      /* chat_add_users       */
	NULL,                      /* chat_rename_user     */
	NULL,                      /* chat_remove_users    */
	NULL,                      /* chat_update_user     */
	apollo_conv_present,	   /* present              */
	apollo_purple_has_focus,   /* has_focus            */
	NULL,                      /* custom_smiley_add    */
	NULL,                      /* custom_smiley_write  */
	NULL,                      /* custom_smiley_close  */
	apollo_confirm			   /*sendconfirm*/
};

static void apolloConnConnectProgress (PurpleConnection *gc, const char *text, size_t step, size_t step_count)
{
    NSLog(@"Connecting: gc=0x%x (%s) %i / %i", gc, text, step, step_count);
	[[ApolloCore sharedInstance]	connectionStatus:	step
									withMessage:		[NSString stringWithCString:text] 
									forAccount:			purple_connection_get_account(gc)
	];
}

static void apolloConnConnected(PurpleConnection *gc)
{
	NSLog(@"Connected: gc=%x", gc);
}

static void apolloConnDisconnected(PurpleConnection *gc)
{
	alexLog([NSString stringWithFormat:@"apolloConnDisconnected> Disconnected: gc=%x", gc]);
	NSLog(@"apolloConnDisconnected> Disconnected: gc=%x", gc);
	[[ApolloCore sharedInstance] disconnected:purple_connection_get_account(gc)];
/*	[[ApolloCore sharedInstance]	connectionStatus:	-1 
									withMessage:		@"unknown" 
									forAccount:			purple_connection_get_account(gc)
	];*/
}

static void apolloConnNotice(PurpleConnection *gc, const char *text)
{
	alexLog([NSString stringWithFormat:@"apolloConnNotice> Notice: gc=%x", gc]);
	NSLog(@"apolloConnNotice> Notice: gc=%x", gc);
    NSLog(@"Connection Notice: gc=%x (%s)", gc, text);
}

static void apolloConnReportDisconnect(PurpleConnection *gc, const char *text)
{
	alexLog([NSString stringWithFormat:@"apolloConnReportDisconnect> Connection Disconnected: gc=%x (%s)", gc, text]);
	NSLog(@"apolloConnReportDisconnect> Connection Disconnected: gc=%x (%s)", gc, text);
	[[ApolloCore sharedInstance]	connectionStatus:	-1 
									withMessage:		[NSString stringWithCString:text] 
									forAccount:			purple_connection_get_account(gc)
	];
}

static PurpleConnectionUiOps apollo_conn_uiops = {
    apolloConnConnectProgress,
    apolloConnConnected,
    apolloConnDisconnected,
    apolloConnNotice,
    apolloConnReportDisconnect
};


static void ui_init()
{
	//Init for all UI modules.  
	purple_conversations_set_ui_ops(&apollo_conv_uiops);
	purple_connections_set_ui_ops(&apollo_conn_uiops);
}

static PurpleCoreUiOps core_uiops = 
{
	NULL,
	NULL,
	ui_init,
	NULL,

	/* padding */
	NULL,
	NULL,
	NULL,
	NULL
};


static void connect_to_signals()
{
	void *connections  = purple_connections_get_handle();
	void *blist_handle = purple_blist_get_handle();
	static int handle;
	purple_signal_connect(connections, "signed-on",		&handle,	PURPLE_CALLBACK(signed_on), NULL);
	purple_signal_connect(connections, "signed-off",	&handle,	PURPLE_CALLBACK(signed_off), NULL);
	
	purple_signal_connect(blist_handle, "buddy-signed-on",		&handle,	PURPLE_CALLBACK(buddy_event),GINT_TO_POINTER(PURPLE_BUDDY_SIGNON));	
	purple_signal_connect(blist_handle, "buddy-signed-off",		&handle,	PURPLE_CALLBACK(buddy_event),GINT_TO_POINTER(PURPLE_BUDDY_SIGNOFF));	
	purple_signal_connect(blist_handle, "buddy-icon-changed",	&handle,	PURPLE_CALLBACK(buddy_event),GINT_TO_POINTER(PURPLE_BUDDY_ICON));	
	purple_signal_connect(blist_handle, "buddy-got-login-time",	&handle,	PURPLE_CALLBACK(buddy_event),GINT_TO_POINTER(PURPLE_BUDDY_SIGNON_TIME));
	purple_signal_connect(blist_handle, "buddy-status-changed",	&handle,	PURPLE_CALLBACK(buddy_event_status),NULL);	
	purple_signal_connect(blist_handle, "buddy-idle-changed",	&handle,	PURPLE_CALLBACK(buddy_event_idle_time),NULL);			
	
	purple_signal_connect(purple_conversations_get_handle(), "conversation-updated", &handle, PURPLE_CALLBACK(apollo_conv_update),NULL);	
}


static void init_libpurple()
{
	purple_util_set_user_dir("/Applications/Apollo.app/");

	purple_debug_set_enabled(FALSE);
//	purple_debug_set_enabled(TRUE);

	purple_core_set_ui_ops(&core_uiops);

	if (!sourceInfoDict) sourceInfoDict = [[NSMutableDictionary alloc] init];
	
	purple_eventloop_set_ui_ops(&adiumEventLoopUiOps);	
	
	purpleRunLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
	CFRetain(purpleRunLoop);

	purple_plugins_add_search_path("/Applications/Apollo.app/Plugins");

	if (!purple_core_init(UI_ID)) 
	{
		NSLog(@"libpurple initialization failed. Dumping core.\n");
		exit(-1);
	}

	purple_set_blist(purple_blist_new());
	purple_blist_load();

	purple_prefs_load();
	purple_plugins_load_saved("/Applications/Apollo.app/Plugins/");
	purple_pounces_load();
	
//	purple_init_ssl_plugin();
//	purple_init_ssl_openssl_plugin();
}
