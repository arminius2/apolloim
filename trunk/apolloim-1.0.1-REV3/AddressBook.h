//
//  AddressBook.h
//  AddressBook integration on the iPhone
//
//  Created by Jaka Jancar <jaka@kubje.org>  
//  Copyright (c) 2007 Jaka Jancar. Licensed under the new BSD license.
//

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

#import <Foundation/Foundation.h>
#import "common.h"
#import "sqlite3.h"

@interface AddressBook : NSObject {
    sqlite3         *db;
    sqlite3         *imageDb;
    NSDictionary    *peoplePickerPrefs;
    sqlite3_stmt    *getDisplayNameOfIMUserStmt;
}

/**
 * Initialize using iPhone defaults.
 *
 * Database file is expected at "/var/root/Library/AddressBook/AddressBook.sqlitedb",
 * image database file at "/var/root/Library/AddressBook/AddressBookImages.sqlitedb"
 * and user display preferences at "/var/root/Library/Preferences/com.apple.PeoplePicker.plist".
 */
- (AddressBook*) init;

/**
 * Initialize with custom paths to required files
 */
- (AddressBook*) initWithDbFilePath: (NSString*) dbFilePath andImageDbFilePath: (NSString*) imageDbFilePath andPeoplePickerPrefsFilePath: (NSString*) prefsFilePath;

/**
 * Get the display name of an IM contact from the users address book, if available.
 *
 * If the contact is unknown, nil is returned.
 *
 * User's display preferences are taken into account when formatting the display name.
 */
- (NSString*) getDisplayNameOfIMUser: (NSString*) username protocol: (NSString*) protocol;

- (void) dealloc;

@end
        