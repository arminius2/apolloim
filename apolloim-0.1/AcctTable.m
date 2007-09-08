#import "AcctTable.h"

@implementation AcctTable

- (int)swipe:(int)fp8 withEvent:(struct __GSEvent *)fp12
{
/*	CGRect rect = GSEventGetLocationInWindow(fp12);
	CGPoint point = CGPointMake(rect.origin.x, rect.origin.y - 45);
	CGPoint offset = _startOffset; 
	point.x += offset.x;
	point.y += offset.y;*/
	NSLog(@"Swipe.");
	
//	int row = [self rowAtPoint:point];
	
//	[[self visibleCellForRow:row column:0] _showDeleteOrInsertion:YES withDisclosure:YES animated:YES isDelete:YES andRemoveConfirmation:YES];
	
	return [super swipe:fp8 withEvent:fp12];
}

@end