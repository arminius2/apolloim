#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ApolloIMApp.h"

int main(int argc, const char *argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int ret = UIApplicationMain(argc, argv, [ApolloIMApp class]);
	[pool release];
	return ret;
}
