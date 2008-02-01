/* 
 * Adium is the legal property of its developers, whose names are listed in the copyright file included
 * with this source distribution.
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 * Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
 
 //
//  adiumPurpleDnsRequest.h
//  Adium
//
//  Created by Graham Booker on 2/24/07.
//
//	From the Adium project.
//Purple
#include <libpurple/internal.h>
#include <libpurple/account.h>
#include <libpurple/conversation.h>
#include <libpurple/core.h>
#include <libpurple/debug.h>
#include <libpurple/dnsquery.h>
#include <libpurple/eventloop.h>
#include <libpurple/ft.h>
#include <libpurple/log.h>
#include <libpurple/notify.h>
#include <libpurple/prefs.h>
#include <libpurple/prpl.h>
#include <libpurple/pounce.h>
#include <libpurple/savedstatuses.h>
#include <libpurple/sound.h>
#include <libpurple/status.h>
#include <libpurple/util.h>
#include <libpurple/whiteboard.h>
#include <libpurple/defines.h>
#include <glib.h>
#include <string.h>
#include <unistd.h>
#import <Foundation/Foundation.h>

@interface AdiumPurpleDnsRequest : NSObject {
	PurpleDnsQueryData *query_data;
	PurpleDnsQueryResolvedCallback resolved_cb;
	PurpleDnsQueryFailedCallback failed_cb;
	BOOL success;
	int errorNumber;
	BOOL cancel;
}
+ (AdiumPurpleDnsRequest *)lookupRequestForData:(PurpleDnsQueryData *)query_data;
- (id)initWithData:(PurpleDnsQueryData *)data resolvedCB:(PurpleDnsQueryResolvedCallback)resolved failedCB:(PurpleDnsQueryFailedCallback)failed;
- (void)startLookup:(id)sender;
- (void)lookupComplete:(NSValue *)resValue;
- (void)cancel;
@end

