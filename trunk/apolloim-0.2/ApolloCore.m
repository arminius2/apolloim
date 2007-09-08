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
	connectionHandles = [[NSMutableArray alloc]init];
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
    ApolloIM_Connection newConnection = [[ApolloIM_Connection alloc]initWithAccount:account delegate:self];
    [connectionHandles addObject:newConnection];
    NSLog(@"ApolloCore> Telling %@ to connect...", [newConnection username]);
    [newConnection connect];  
}

- (void)destroyConnection:(Acct*)account
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
}

- (void)dealloc
{
    [connectionHandles release];
    [super dealloc];
}

@end
