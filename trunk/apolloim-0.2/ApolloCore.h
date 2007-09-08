#import <Foundation/Foundation.h>
#import "ApolloNotificationController.h"
#import "Buddy.h"

#include "ApolloIM-Callbacks.h"

@interface ApolloCore : NSObject
{
	NSMutableArray *connectionHandles;
	id _delegate;
}

+ (void)initialize;
+ (id)sharedInstance;

- (id)init;
- (void)setDelegate:(id)delegate;

- (void)createConnection;   //Create ApolloIM Connection that passes the delegate to it, have connection connect, add connection to connectionHandles
- (void)destroyConnection;  //Kill ApolloIM, remove from connecitonHandles

- (void)dealloc;

@end
