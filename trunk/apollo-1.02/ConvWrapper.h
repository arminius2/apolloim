#import <Foundation/Foundation.h>
#include <libpurple/internal.h>
#include <libpurple/conversation.h>

@interface ConvWrapper : NSObject 
{
	PurpleConversation* conv;
}
- (id) initWithConvo:(PurpleConversation*)_conv;
-(void)setPurpleConversation:(PurpleConversation*)_conv;
-(PurpleConversation*)conv;

@end
