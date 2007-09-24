//
//  SendBox.h
//  ApolloIM
//
//  Created by Alex C. Schaefer on 8/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UITextView.h>

@interface SendBox : UITextView
{

}

- (id)initWithFrame:(struct CGRect)fp8;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (BOOL)canBecomeFirstResponder;
- (BOOL)webView:(id)fp8 shouldBeginEditingInDOMRange:(id)fp12;
@end
