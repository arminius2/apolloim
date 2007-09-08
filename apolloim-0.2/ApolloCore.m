#import	"StartView.h"
#import "ApolloCore.h"

static id sharedInst;
static NSRecursiveLock *lock;

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
    self = [super init];

	NSLog(@"Initing new ApolloCORE...");

    return self;
}

- (void)dealloc
{

    [super dealloc];
}

@end
