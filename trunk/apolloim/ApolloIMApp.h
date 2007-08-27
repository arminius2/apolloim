#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAnimator.h>
#import "StartView.h"

@interface ApolloIMApp : UIApplication 
{
    UIWindow		*_window;
    StartView		*startView;
	
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate;
- (void)applicationSuspend:(struct __GSEvent *)event;
- (void)applicationResume:(struct __GSEvent *)event;

@end
