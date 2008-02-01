/*
 Apollo: Libpurple based Objective-C IM Client
 By Alex C. Schaefer & Adam Bellmore

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
 
 Portions of this code are referenced from "Libpurple", courtesy of www.pidgin.im
 as well as AdiumX (www.adiumx.com).  This code is full GPLv2, and a GPLv2.txt 
 is contained in the source and program root for you to read.  If not, please
 refer to the above address to obtain your own copy.
 
 Any questions or comments should be posted at http://apolloim.googlecode.com
*/
#ifndef CONST_H

#define CONST_H

// Graphical Constants
#define SCREEN_WIDTH	320.0f;
#define SCREEN_HEIGHT	465.0f;

typedef enum 
{
	MESSAGE = 0,
	BUDDY_LOGOUT,
	BUDDY_LOGIN,
	BUDDY_AWAY,
	BUDDY_BACK,
	BUDDY_IDLE,
	BUDDY_ACTIVE,
	BUDDY_INFO,
	BUDDY_MESSAGE,
	BUDDY_STATUS,
	LOGIN_SUCCESS,
	LOGIN_FAIL,	
	CONNECT_FAILURE,
	DISCONNECT,			//An Account Got Disconnected
	DISCONNECTED,       //All Accounts are disconnected.
	CONNECT_MSG,
	MESSAGE_ERROR,
	NETWORK_EDGE,
	NETWORK_WIFI,
	NO_NETWORK_CANNOT_CONNECT,	
	NO_TYPE
} MessageType;

typedef enum
{
	OFFLINE = 0,
	ONLINE,
	LOGGING_IN
} UserStatus;

#define AIM 		@"AIM"
#define MSN		@"MSN"
#define GTALK		@"GTalk"
#define YAHOO		@"Yahoo"
#define IRC		@"IRC"
#define JABBER		@"Jabber"
#define ICQ		@"ICQ"
#define TESTP		@"TestProtocol"
#define DOTMAC		@".Mac"

#define PATH			[@"~/Library/Preferences/" stringByExpandingTildeInPath]
#define GLOBAL_PREF_PATH	[NSString stringWithFormat: @"%@/%@", PATH, @"Apollo.plist"]
#define USER_PREF_PATH(user)	[NSString stringWithFormat: @"%@/Apollo_%@_%@.plist", PATH, [user getStartingName], [user getProtocol]]

typedef enum
{
	PURPLE_BUDDY_NONE				= 0x00, /**< No events.                    */
	PURPLE_BUDDY_SIGNON			= 0x01, /**< The buddy signed on.          */
	PURPLE_BUDDY_SIGNOFF			= 0x02, /**< The buddy signed off.         */
	PURPLE_BUDDY_INFO_UPDATED		= 0x10, /**< The buddy's information (profile) changed.     */
	PURPLE_BUDDY_ICON				= 0x40, /**< The buddy's icon changed.     */
	PURPLE_BUDDY_MISCELLANEOUS	= 0x80, /**< The buddy's service-specific miscalleneous info changed.     */
	PURPLE_BUDDY_SIGNON_TIME		= 0x11, /**< The buddy's signon time changed.     */
	PURPLE_BUDDY_EVIL				= 0x12,  /**< The buddy's warning level changed.     */
	PURPLE_BUDDY_DIRECTIM_CONNECTED = 0x14, /**< Connected to the buddy via DirectIM.  */
	PURPLE_BUDDY_DIRECTIM_DISCONNECTED = 0x18, /**< Disconnected from the buddy via DirectIM.  */
	PURPLE_BUDDY_NAME				= 0x20 /**<Buddy name (UID) changed. */
	
} PurpleBuddyEvent;


enum {
	AIM_RECV_MESG		=	1,
	AIM_BUDDY_ONLINE	=	2, 
	AIM_BUDDY_OFFLINE	=	3, 
	AIM_BUDDY_AWAY		=	4, 
	AIM_BUDDY_UNAWAY	=	5,
	AIM_BUDDY_IDLE		=	6,	
	AIM_BUDDY_MSG_RECV	=   7,
	AIM_CONNECTED		=   8,
	AIM_DISCONNECTED	=	9,
	AIM_READ_MSGS		=   10,
	AIM_BUDDY_INFO		=	11	
};

#endif
