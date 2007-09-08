#import <Foundation/Foundation.h>
#import "ApolloNotificationController.h"
#import "Buddy.h"

#import "ApolloIM-Connection.h"

@interface ApolloCore : NSObject
{
	NSMutableArray *connectionHandles;
	id _delegate;
}

+ (void)initialize;
+ (id)sharedInstance;

- (id)init;
- (void)setDelegate:(id)delegate;

- (void)createConnection:(Acct*)account;   //Create ApolloIM Connection that passes the delegate to it, have connection connect, add connection to connectionHandles
- (void)destroyConnection:(Acct*)account;  //Kill ApolloIM, remove from connectionHandles
- (ApolloIM_Connection*)findConnection:(Acct*)account; //Find a connection from it's account and return it

- (void)sendIMFromAcct:(Acct*)account toBuddy:  (Buddy*)buddy     withMessage:(NSString*)message;
- (void)recvIMFromAcct:(Acct*)account fromBuddy:(Buddy*)buddy     withMessage:(NSString*)message;

- (void)buddyEventFrom:(Acct*)account fromBuddy:(Buddy*)buddy     withEvent:(int)event;  //Away/Back

- (void)dealloc;

@end
