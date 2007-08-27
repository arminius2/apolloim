//
//  AboutView.m
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AboutView.h"


@implementation AboutView
	-(id)initWithFrame:(struct CGRect)frame
	{
		if ((self == [super initWithFrame: frame]) != nil) 
		{
		//	aboutField =[[ConvoBox alloc]initWithFrame:CGRectMake(_rect.origin.x,_rect.origin.y, _rect.size.width,  _rect.size.height - 30.0f)];
		//	[aboutField setHTML:@"<b>Test</b>"];
		//	[self addSubview:aboutField];
		}
	}
	-(void)dealloc
	{
		[super dealloc];
	}
	
@end
