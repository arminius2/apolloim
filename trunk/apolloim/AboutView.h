//
//  AboutView.h
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import "ConvoBox.h"
#import <UIKit/UITransitionView.h>

@interface AboutView : UIView {
    CGRect				_rect;	
	ConvoBox		*aboutField;	
	
}

- (id)initWithFrame:(struct CGRect)frame;
- (void)dealloc;

@end
