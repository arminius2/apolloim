/*
 ApolloTOC.m: Objective-C firetalk interface.
 By Alex C. Schaefer
 Modification of BoomBot's objc/firetalk wrapper

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

#import "ApolloTOC.h"

@interface ApolloTOC (PrivateMethods)

- (void)registerFiretalkCallbacks;
- (void)error:(int)code ftConnection:(void *)ftConnection;
- (void)connectionSucessful:(void *)ftConnection;
- (void)recievedMessage:(NSString*)message fromUser:(NSString*)user isAutomessage:(BOOL)automessage ftConnection:(void *)ftConnection;
- (void)runloopCheck:(NSTimer*)timer;
- (void)disconnected:(void *)ftConnection reason:(int)reason;

@end
