/*
 ConversationView.m: the view for the conversation.
 By Adam Bellmore

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/
#import "ConversationView.h"
#import "Account.h"
#import <UIKit/UITextLabel.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIBox.h>

@implementation ConversationView
-(id)initWithFrame:(struct CGRect)frame withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate
{
	NSLog(@"Creating ConversationView with dimensions(%f, %f, %f, %f)", frame.origin.x, frame.origin.y,
				frame.size.width, frame.size.height);
	if ((self == [super initWithFrame: frame]) != nil) 
	{
		_rect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	
		[self setAdjustForContentSizeChange:YES];
		[self setContentSize: CGSizeMake(frame.size.width, frame.size.height)];
		[self setOpaque:YES];

		_delegate = delegate;
		
		_conversation = [[NSMutableArray alloc] init];

		UIBox * box = [[UIBox alloc] initWithFrame:frame];
		[self addSubview: box];
		[self setContentSize: frame.size];
		current_y = frame.size.height;
	}
	return self;
}

- (void)dealloc {
	[_conversation release];
	_delegate = nil;
	[super dealloc];
}

- (BOOL)appendToConversation:(NSString *)text fromUser:(Buddy *)user
{
	float seperator = 10.0f;
	float text_height = 18.0f;
	float width = _rect.size.width;
	
	float self_color[4] = {0.0, 0.0, 1.0, 1.0};
	float their_color[4] = {1.0, 0.0, 0.0, 1.0};
	CGColorSpaceRef const colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGRect user_area = CGRectMake(0.0f, current_y, width, text_height);
	UITextLabel * username = [[UITextLabel alloc] initWithFrame:user_area];
	[username setWrapsText:YES];
	[username setText:user];
	
	if(user != nil)
		[username setColor:CGColorCreate(colorSpace, their_color)];
	else
		[username setColor:CGColorCreate(colorSpace, self_color)];
		
	[self addSubview: username];
	current_y += text_height;
	
	CGRect new_area = CGRectMake(0.0f, current_y, width, text_height);
	
	NSMutableString * m_text = [NSMutableString stringWithCapacity: [text length]];
	[m_text insertString:text atIndex:0];
	
	BOOL all_drawn = NO;
	while(!all_drawn)
	{
		NSMutableString * buf = [NSMutableString stringWithCapacity: [m_text length]];
		[buf insertString:m_text atIndex:0];
		new_area.origin.y = current_y;
		
		UIBox * bk = [[UIBox alloc] initWithFrame:new_area];
		
		CGRect conv_area = CGRectMake(new_area.origin.x+15.0,
										new_area.origin.y,
										new_area.size.width,
										new_area.size.height);
		UITextLabel * conv = [[UITextLabel alloc] initWithFrame:conv_area];
		[conv setWrapsText:YES];
		
		float text_width;
		BOOL short_enough = NO;
		while(!short_enough)
		{
			[conv setText: buf];
			text_width = [conv textSize].width;
			if(text_width <= width && [buf characterAtIndex:[buf length]-1] == (unichar)' ')
			{
				short_enough = YES;
			}
			else if(text_width <= width && [buf characterAtIndex:[buf length]-1] == (unichar)'\t')
			{
				short_enough = YES;
			}
			else if(text_width <= width && [buf characterAtIndex:[buf length]-1] == (unichar)'\n')
			{
				short_enough = YES;
			}
			else if(text_width <= width && [buf isEqualToString: m_text])
			{
				short_enough = YES;
			}
			else
			{
				NSRange r = NSMakeRange([buf length] - 1, 1);
				[buf deleteCharactersInRange: r];
			}
		}
		[self addSubview: bk];
		[self addSubview: conv];
		
		current_y += text_height;		
		NSRange r = NSMakeRange(0, [buf length]);
		[m_text deleteCharactersInRange: r];
		
		if([m_text length] == 0)
			all_drawn=YES;
	}
	
	CGRect sep_area = CGRectMake(new_area.origin.x,
										current_y,
										new_area.size.width,
										seperator);
	UIBox * sep_box = [[UIBox alloc] initWithFrame:sep_area];
		
	[self addSubview: sep_box];
	
	current_y += seperator;

	float height = (current_y > _rect.size.height) ? current_y:_rect.size.height;
	
	[self setContentSize: CGSizeMake(_rect.size.width, height)];

	[self scrollRectToVisible: sep_area animated:YES];

	return YES;
}

- (void) scrollToEnd
{
	CGRect to_view = CGRectMake(0, [self contentSize].height-1, [self contentSize].width, 1);
	[self scrollRectToVisible: to_view animated:YES]; 
}

- (void)contentMouseUpInView:(id)fp8 withEvent:(struct GSEvent *)fp12
{
	[_delegate toggle];
}


@end
