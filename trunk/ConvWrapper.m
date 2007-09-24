//
//  ConvWrapper.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 9/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ConvWrapper.h"


@implementation ConvWrapper

- (id) initWithConvo:(PurpleConversation*)_conv {
	self = [super init];
	if (self != nil) {
		conv = _conv;
	}
	return self;
}


-(void)setPurpleConversation:(PurpleConversation*)_conv
{
	conv=_conv;
}
-(PurpleConversation*)conv
{
	return conv;
}

@end
