#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAnimator.h>
#import "StartView.h"
#import "ShellKeyboard.h"

@interface ApolloIMApp : UIApplication 
{
    UIWindow		*_window;
    StartView		*startView;
	
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate;
@end
