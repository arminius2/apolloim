#import	"StartView.h"
#import "ApolloCore.h"

static id sharedInst;
static NSRecursiveLock *lock;

enum {
	AIM_RECV_MESG		=	1,
	AIM_BUDDY_ONLINE	=	2, 
	AIM_BUDDY_OFFLINE	=	3, 
	AIM_BUDDY_AWAY		=	4, 
	AIM_BUDDY_UNAWAY	=	5,
	AIM_BUDDY_IDLE		=	6,	
	AIM_BUDDY_MSG_RECV	=   7,
	AIM_CONNECTED		=   8,
	AIM_DISCONNECTED	=	9,
	AIM_READ_MSGS		=   10,
	AIM_BUDDY_INFO		=	11	
};

#define PURPLE_GLIB_READ_COND  (G_IO_IN | G_IO_HUP | G_IO_ERR)
#define PURPLE_GLIB_WRITE_COND (G_IO_OUT | G_IO_HUP | G_IO_ERR | G_IO_NVAL)

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

- (id)init
{
    self = [super init];

	NSLog(@"ApolloCore> Initing new ApolloCORE...");
//	connectionHandles = [[NSMutableArray alloc]init];
	NSLog(@"ApolloCore> Core initialized.  Ready to create connecitons.");

    return self;
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
}

- (void)createConnection:(Acct*)account
{
   NSLog(@"ApolloCore> Creating new connection for %@", [account username]);	   
   
	/* Create the account */
	purple_account = purple_account_new([[account username]cString], [account connection]);    // libpurple call
	/* Get the password for the account */
	purple_account_set_password(purple_account, [[account password]cString]);                     // libpurple call
	/* It's necessary to enable the account first. */
	purple_account_set_enabled(purple_account, UI_ID, TRUE);                                  // libpurple call
	/* Now, to connect the account(s), create a status and activate it. */
	status = purple_savedstatus_new(NULL, PURPLE_STATUS_AVAILABLE);                           // libpurple call	
	purple_savedstatus_activate(status);                                                      // libpurple call
	connect_to_signals();
	g_main_loop_run(loop);
   
	return YES;
}

- (void)destroyConnection:(Acct*)account
{
}

- (void)sendIM:(NSString*)body     toBuddy:(Buddy*)buddy
{
}

- (void)receivedMessage:(NSString*)message fromUser:(Buddy*)user
{
}

- (Acct*)thisAccount
{
	return thisAccount;
}

static PurpleEventLoopUiOps		glib_eventloops= 
{
	g_timeout_add,
	g_source_remove,
	glib_input_add,
	g_source_remove,
	NULL,
#if GLIB_CHECK_VERSION(2,14,0)
	g_timeout_add_seconds,
#else
	NULL,
#endif

	/* padding */
	NULL,
	NULL,
	NULL
};

static PurpleConversationUiOps		apollo_conv_uiops= 
{
	NULL,                      /* create_conversation  */
	NULL,                      /* destroy_conversation */
	NULL,                      /* write_chat           */
	NULL,                      /* write_im             */
	apollo_write_conv,           /* write_conv           */
	NULL,                      /* chat_add_users       */
	NULL,                      /* chat_rename_user     */
	NULL,                      /* chat_remove_users    */
	NULL,                      /* chat_update_user     */
	NULL,                      /* present              */
	NULL,                      /* has_focus            */
	NULL,                      /* custom_smiley_add    */
	NULL,                      /* custom_smiley_write  */
	NULL,                      /* custom_smiley_close  */
	NULL,                      /* send_confirm         */
	NULL,
	NULL,
	NULL,
	NULL
};
static PurpleCoreUiOps				apollo_core_uiops = 
{
	NULL,
	NULL,
	apollo_ui_init,
	NULL,

	/* padding */
	NULL,
	NULL,
	NULL,
	NULL
};


typedef struct _PurpleGLibIOClosure {
	PurpleInputFunction function;
	guint result;
	gpointer data;
} PurpleGLibIOClosure;

static void init_libpurple()
{
	purple_util_set_user_dir(CUSTOM_USER_DIRECTORY);
	purple_debug_set_enabled(TRUE);
	purple_core_set_ui_ops(&apollo_core_uiops);
	purple_eventloop_set_ui_ops(&glib_eventloops);
	if (!purple_core_init(UI_ID)) {
		/* Initializing the core failed. Terminate. */
		fprintf(stderr,
				"libpurple initialization failed. Dumping core.\n"
				"Please report this!\n");
		abort();
	}
	purple_set_blist(purple_blist_new());
	purple_blist_load();
	purple_prefs_load();
	purple_pounces_load();
}

static guint glib_input_add(gint fd, PurpleInputCondition condition, PurpleInputFunction function, gpointer data)
{
	PurpleGLibIOClosure *closure = g_new0(PurpleGLibIOClosure, 1);
	GIOChannel *channel;
	GIOCondition cond = 0;

	closure->function = function;
	closure->data = data;

	if (condition & PURPLE_INPUT_READ)
		cond |= PURPLE_GLIB_READ_COND;
	if (condition & PURPLE_INPUT_WRITE)
		cond |= PURPLE_GLIB_WRITE_COND;

	channel = g_io_channel_unix_new(fd);
	closure->result = g_io_add_watch_full(channel, G_PRIORITY_DEFAULT, cond,
					      purple_glib_io_invoke, closure, purple_glib_io_destroy);

	g_io_channel_unref(channel);
	return closure->result;
}

static gboolean purple_glib_io_invoke(GIOChannel *source, GIOCondition condition, gpointer data)
{
	PurpleGLibIOClosure *closure = data;
	PurpleInputCondition purple_cond = 0;

	if (condition & PURPLE_GLIB_READ_COND)
		purple_cond |= PURPLE_INPUT_READ;
	if (condition & PURPLE_GLIB_WRITE_COND)
		purple_cond |= PURPLE_INPUT_WRITE;

	closure->function(closure->data, g_io_channel_unix_get_fd(source), purple_cond);

	return TRUE;
}

static void purple_glib_io_destroy(gpointer data)
{
	g_free(data);
}

static void apollo_write_conv(PurpleConversation *conv, const char *who, const char *alias,const char *message, PurpleMessageFlags flags, time_t mtime)
{
	const char *name;
	if (alias && *alias)
		name = alias;
	else if (who && *who)
		name = who;
	else
		name = NULL;

	NSLog(@"(%s) %s %s: %s\n", purple_conversation_get_name(conv),
			purple_utf8_strftime("(%H:%M:%S)", localtime(&mtime)),
			name, message);
}
static void apollo_ui_init()
{
	purple_conversations_set_ui_ops(&apollo_conv_uiops);
}

static void signed_on(PurpleConnection *gc, gpointer event)
{
	PurpleAccount *account = purple_connection_get_account(gc);
	NSLog(@"Account connected: %s %s\n", account->username, account->protocol_id);
}

static void signed_off(PurpleConnection *gc, gpointer event)
{
	PurpleAccount *account = purple_connection_get_account(gc);
	NSLog(@"Account disconnected: %s %s\n", account->username, account->protocol_id);
}

static void connect_to_signals()
{
	static int handle;
	purple_signal_connect(purple_connections_get_handle(), "signed-on", &handle, PURPLE_CALLBACK(signed_on), NULL);	
	purple_signal_connect(purple_connections_get_handle(), "signed-off", &handle, PURPLE_CALLBACK(signed_off), NULL);	
//	purple_signal_connect(purple_connections_get_handle(), "buddy-signed-on", &handle, PURPLE_CALLBACK(signed_onoff), NULL);	
}

/*- (void)destroyConnection:(Acct*)account
{
    [[self findConnection:account]release];
}

- (ApolloIM_Connection*)findConnection:(Acct*)account
{
    int i;
    for(i=0; i<[connectionHandles count] i++)
    {
        if([[[connectHandles objectAtIndex:i]username]isEqualToString:[account username]])
            return [connectionHandles objectAtIndex:i];
    }
    
    return nil;
}

- (void)sendIMFromAcct:(Acct*)account toBuddy:  (Buddy*)buddy     withMessage:(NSString*)message
{
    //- (void)sendIM:(NSString*)body toBuddy:(Buddy*)buddy;
    ApolloIM_Connection conn = [self findConnection];
    if(conn !=nil)
        [conn sendIM:message toBuddy:buddy];
        else
        NSLog(@"ApolloCore>> This connection doesn't exist and as such cannot send IMs");
}

- (void)recvIMFromAcct:(Acct*)account fromBuddy:(Buddy*)buddy     withMessage:(NSString*)message
{
    //Payloads are just array's containing the following:
    //Index 0: im event enum
    //Index 1:  a buddy object that is basically the from
    //Index 2:  message from event, if it is a recev'd message, it'd be here.  if it was a connection error message, it'd behere    
    NSMutableArray* payload = [[NSMutableArray alloc]init];
    [payload addObject:AIM_RECV_MESG];
    [payload addObject:buddy];
    [payload addObject:message];        
    [_delegate imEvent:payload];
}

- (void)buddyEventFrom:(Acct*)account fromBuddy:(Buddy*)buddy     withEvent:(int)event
{
    NSMutableArray* payload = [[NSMutableArray alloc]init];
    [payload addObject:event];
    [payload addObject:buddy];
    [payload addObject:@"NOMESSAGE"];        
    [_delegate imEvent:payload];
}*/

- (void)dealloc
{
//    [connectionHandles release];
    [super dealloc];
}

@end
