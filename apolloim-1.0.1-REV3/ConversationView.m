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
#import <UIKit/UITextLabel.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIBox.h>

@implementation ConversationView
-(id)initWithFrame:(struct CGRect)frame withOwner:(User *)user withBuddy:(Buddy*)aBuddy andDelegate:(id)delegate
{
	AlexLog(@"Creating ConversationView with dimensions(%f, %f, %f, %f)", frame.origin.x, frame.origin.y,
				frame.size.width, frame.size.height);
	if ((self == [super initWithFrame: frame]) != nil) 
	{
		chat_font = [NSClassFromString(@"WebFontCache") 
					createFontWithFamily:@"Helvetica" traits:0 size:14];
		event_font = [NSClassFromString(@"WebFontCache") 
					createFontWithFamily:@"Helvetica" traits:0 size:12];
		_rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
	
		last_stamp = nil;

		_buddy = aBuddy;
		[self setAdjustForContentSizeChange:YES];
		[self setContentSize: CGSizeMake(frame.size.width, frame.size.height)];
		[self setOpaque:YES];
		
		[self setAllowsRubberBanding:YES];

		_delegate = delegate;
		
		_conversation = [[NSMutableArray alloc] init];

		UIBox * box = [[UIBox alloc] initWithFrame:_rect];
		[self addSubview: box];
		[self setContentSize: frame.size];
		current_y = frame.size.height;
	}
	return self;
}

- (void)dealloc 
{
	[_conversation release];
	_delegate = nil;
	[super dealloc];
}

- (BOOL) removeHTML:(NSMutableString *) from
{
	int del = 0;
	int i = 0;
	for(i; i< ([from length]); i++)
	{
		AlexLog(@"Trimming: %@",from);
		BOOL deleted = NO;
		if([from characterAtIndex: i] == '<')
			del ++;
			
		if(del > 0)
		{
			deleted = YES;
		}
		
		if([from characterAtIndex: i] == '>')
		{
			if(del > 0)
				del --;
		}
		
		if(deleted)
		{
			NSRange r = NSMakeRange(i, 1);
			[from deleteCharactersInRange: r];
			i--;
		}
	}

	// Replace the odd characters
	[from replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [from length])];
	[from replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [from length])];
	[from replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [from length])];
	[from replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [from length])];
	[from replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [from length])];
}

-(void) addTimeStamp
{
	float stamp_height = 20.0f;
	if(last_stamp == nil)
	{
		last_stamp = [[NSDate alloc] initWithTimeIntervalSinceNow: -100000];
	}

	AlexLog(@"Stamp Difference: %f", [last_stamp timeIntervalSinceNow]);	

	if([last_stamp timeIntervalSinceNow] < -(60.0 * 5.0))
	{
		float grey[4] = {0.47, 0.47, 0.47, 1.0};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

		last_stamp = [[NSDate alloc] init];

		NSString * label = [NSString stringWithFormat: @"%@",
					[last_stamp descriptionWithCalendarFormat:@"%I:%M %p" timeZone:nil
							locale:nil]];
		
		CGRect new_area = CGRectMake(0,current_y, 320.0, stamp_height);
		UITextLabel * stamp = [[UITextLabel alloc] initWithFrame: new_area];
		[stamp setText:label];
		[stamp setCentersHorizontally:YES];
		[stamp setFont:event_font];
		[stamp setColor: CGColorCreate(colorSpace, grey)];
		[self addSubview:stamp];

		current_y += stamp_height;

		float height = (current_y > _rect.size.height) ? current_y:_rect.size.height;
		[self setContentSize: CGSizeMake(_rect.size.width, height)];
		[self scrollRectToVisible: new_area animated:YES];
	}
}

-(void) addStatusMessage:(NSString *) msg fromUser:(Buddy *) buddy
{
	float stamp_height = 30.0f;
	NSString * label = [NSString stringWithFormat: @"%@ : %@",
						[buddy getDisplayName], msg];
	CGRect new_area = CGRectMake(0,current_y, 320.0, stamp_height);
	UITextLabel * stamp = [[UITextLabel alloc] initWithFrame: new_area];
	[stamp setText:label];
	[stamp setCentersHorizontally:YES];
	[stamp setFont:event_font];
	[self addSubview:stamp];

	current_y += stamp_height;

	float height = (current_y > _rect.size.height) ? current_y:_rect.size.height;
	[self setContentSize: CGSizeMake(_rect.size.width, height)];
	[self scrollRectToVisible: new_area animated:YES];
}

- (BOOL)appendToConversation:(NSString *)text fromUser:(Buddy *)user
{
	[self addTimeStamp];

	float text_height = 20.0f;
	float seperator_height = 8.0f;
	float text_width = 240.0f;
	float widest_text = 0.0f;
	float highest_text = 0.0f;
	float cell_margin = 5.0;
	float top_text_inset = 10.0;
	float side_text_inset = 5.0;

	float bubble_margin_left = 23.0;
	float bubble_margin_right = 23.0;
	float bubble_margin_bottom = 19.0;
	float bubble_margin_top = 19.0;

	float text_margin_top = bubble_margin_top - top_text_inset;
	float text_margin_bottom = bubble_margin_bottom - top_text_inset;
	float text_margin_left = bubble_margin_left - side_text_inset;
	float text_margin_right = bubble_margin_right - side_text_inset;

	float self_color[4] = {0.0, 0.0, 1.0, 1.0};
	float their_color[4] = {1.0, 0.0, 0.0, 1.0};
	float status_color[4] = {1.0, 0.0, 1.0, 1.0};	
	float transparent[4] = {1.0, 1.0, 1.0, 0.0};	
	float dark_grey[4] = {0.34, 0.34, 0.34, 1.0};
	
	CGColorSpaceRef const colorSpace = CGColorSpaceCreateDeviceRGB();

	NSMutableArray * lines = [[NSMutableArray alloc] init];
	
	NSMutableString * m_text = [NSMutableString stringWithString:text];
	
	AlexLog(@"Before removing '%@'", m_text);
	[self removeHTML:m_text];
	AlexLog(@"After Removing '%@'", m_text);

	while(([m_text length] > 0))
	{
		NSMutableString * buf = [NSMutableString string];
		UITextLabel * line = [[UITextLabel alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[line setBackgroundColor:CGColorCreate(colorSpace, transparent)];
		[line setWrapsText: YES];
		[line setFont:chat_font];
		[line setColor:CGColorCreate(colorSpace, dark_grey)];
		BOOL long_enough = NO;
		NSRange first_char = NSMakeRange(0,1);
		NSRange last_char = NSMakeRange(0,1);
		float c_width = 0.0f;

		while(!long_enough && ([m_text length] > 0))
		{
			unichar c = [m_text characterAtIndex:0];
			[buf appendFormat: @"%C", c];
			[line setText:buf];
			[line _invalidateTextSize];
			[m_text deleteCharactersInRange:first_char];

			c_width = [line textSize].width;

			long_enough = c_width > (text_width - 20.0f);

			if(long_enough)
			{
				BOOL short_enough = NO;
				NSMutableString * r = [NSMutableString string];
				while(!short_enough)
				{
					unichar last = [buf characterAtIndex:[buf length]-1];
					last_char.location = [buf length] -1;
					switch( last )
					{
						case (unichar)' ':
						case (unichar)'\t':
						case (unichar)'\n':
						case (unichar)',':
							[line setText:buf];
							short_enough = YES;
							[m_text insertString:r atIndex: 0];
							break;

						default:
							if([buf length] < 1)
							{
								short_enough = YES;
								[buf insertString:r atIndex: 0];
							}
							else
							{
								[buf deleteCharactersInRange:last_char];
								[r insertString: [NSString stringWithFormat: @"%C", last] atIndex:0];
							}
							break;
					}
				}
			}
		}

		[lines addObject: line];

		AlexLog(buf);
	
		if(c_width > widest_text)
			widest_text = c_width;
	}

	if(widest_text < 10.0)
		widest_text = 10.0;

	highest_text = (text_height * [lines count]);

	AlexLog(@"Chat Size (%f, %f)", widest_text, highest_text);

	CGRect new_area =  CGRectMake(0, current_y, 320,
		text_margin_top+highest_text+text_margin_bottom+cell_margin);
	UIBox * chat_cell = [[UIBox alloc] initWithFrame: new_area];
	
	float x_anchor = 0.0;
	float bubble_area_width = widest_text + ((bubble_margin_left - side_text_inset) * 2);
	float bubble_area_height = highest_text + ((bubble_margin_top - top_text_inset) * 2);

	float bubble_center_height = bubble_area_height - (bubble_margin_top + bubble_margin_bottom);
	float bubble_center_width = bubble_area_width - (bubble_margin_left + bubble_margin_right);

	AlexLog(@"(%f, %f) -> (%f, %f)", bubble_area_width, bubble_area_height, bubble_center_width, bubble_center_height);

	UIImageView * tl = [[UIImageView alloc] init];
	UIImageView * tr = [[UIImageView alloc] init];
	UIImageView * bl = [[UIImageView alloc] init];
	UIImageView * br = [[UIImageView alloc] init];

	UIPushButton * mi = [[UIPushButton alloc] init];
	UIPushButton * tm = [[UIPushButton alloc] init];
	UIPushButton * bm = [[UIPushButton alloc] init];
	UIPushButton * le = [[UIPushButton alloc] init];
	UIPushButton * ri = [[UIPushButton alloc] init];

	if(user == nil)
	{
		[tl setImage:[UIImage applicationImageNamed: @"chat_graybubble_topleft.png"]];
		[tr setImage:[UIImage applicationImageNamed: @"chat_graybubble_topright.png"]];
		[bl setImage:[UIImage applicationImageNamed: @"chat_graybubble_bottomleft.png"]];
		[br setImage:[UIImage applicationImageNamed: @"chat_graybubble_bottomright.png"]];
		[mi setImage:[UIImage applicationImageNamed: @"chat_graybubble_middle.png"]];
		[tm setImage:[UIImage applicationImageNamed: @"chat_graybubble_topmiddle.png"]];
		[bm setImage:[UIImage applicationImageNamed: @"chat_graybubble_bottommiddle.png"]];
		[le setImage:[UIImage applicationImageNamed: @"chat_graybubble_left.png"]];
		[ri setImage:[UIImage applicationImageNamed: @"chat_graybubble_right.png"]];
		x_anchor = 320.0 - (bubble_area_width + cell_margin);
	}
	else
	{
		[tl setImage:[UIImage applicationImageNamed: @"chat_bluebubble_topleft.png"]];
		[tr setImage:[UIImage applicationImageNamed: @"chat_bluebubble_topright.png"]];
		[bl setImage:[UIImage applicationImageNamed: @"chat_bluebubble_bottomleft.png"]];
		[br setImage:[UIImage applicationImageNamed: @"chat_bluebubble_bottomright.png"]];
		[mi setImage:[UIImage applicationImageNamed: @"chat_bluebubble_middle.png"]];
		[tm setImage:[UIImage applicationImageNamed: @"chat_bluebubble_topmiddle.png"]];
		[bm setImage:[UIImage applicationImageNamed: @"chat_bluebubble_bottommiddle.png"]];
		[le setImage:[UIImage applicationImageNamed: @"chat_bluebubble_left.png"]];
		[ri setImage:[UIImage applicationImageNamed: @"chat_bluebubble_right.png"]];
		x_anchor = cell_margin;
	}

	UIBox * text_cell = [[UIBox alloc] init];
	[text_cell setFrame: CGRectMake(x_anchor, 0, 
				bubble_area_width,
				bubble_area_height+cell_margin)];

	/* Top bubble part */
	[tl setFrame: CGRectMake(0, 0, bubble_margin_left, bubble_margin_top)];
	[tm setFrame: CGRectMake(bubble_margin_left, 0, bubble_center_width, bubble_margin_top)];
	[tr setFrame: CGRectMake(bubble_margin_left + bubble_center_width, 0, bubble_margin_right, bubble_margin_top)];

	[le setFrame: CGRectMake(0, bubble_margin_top, bubble_margin_left, bubble_center_height)];
	[mi setFrame: CGRectMake(bubble_margin_left, bubble_margin_top, bubble_center_width, bubble_center_height)];
	[ri setFrame: CGRectMake(bubble_margin_left + bubble_center_width, bubble_margin_top, bubble_margin_right, bubble_center_height)];

	[bl setFrame: CGRectMake(0, bubble_area_height - bubble_margin_bottom, bubble_margin_right, bubble_margin_bottom)];
	[bm setFrame: CGRectMake(bubble_margin_left, bubble_area_height - bubble_margin_bottom, bubble_center_width, bubble_margin_bottom)];
	[br setFrame: CGRectMake(bubble_margin_left + bubble_center_width, bubble_area_height - bubble_margin_bottom, bubble_margin_right, bubble_margin_bottom)];

	[text_cell addSubview: tl];
	[text_cell addSubview: tr];
	[text_cell addSubview: tm];

	[text_cell addSubview: bl];
	[text_cell addSubview: br];
	[text_cell addSubview: bm];

	[text_cell addSubview: mi];
	[text_cell addSubview: le];
	[text_cell addSubview: ri];

	float text_y = text_margin_top;
	float text_x = text_margin_left;
	int i = 0;
	for(i; i<[lines count]; i++)
	{
		UITextLabel * l = [lines objectAtIndex:i];
		if(user == nil)
		{
			AlexLog(@"Shifting %f->%f", text_x, text_x + (widest_text - [l textSize].width));
			[l setFrame: CGRectMake(text_x + (widest_text - [l textSize].width), text_y, text_width, text_height)];
		}
		else
		{
			[l setFrame: CGRectMake(text_x, text_y, text_width, text_height)];
		}
		[text_cell addSubview: l];
		text_y += text_height;
	}

	[chat_cell addSubview: text_cell];
	[self addSubview: chat_cell];

	current_y += new_area.size.height;

	float height = (current_y > _rect.size.height) ? current_y:_rect.size.height;
	[self setContentSize: CGSizeMake(_rect.size.width, height)];
	[self scrollRectToVisible: new_area animated:YES];
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
