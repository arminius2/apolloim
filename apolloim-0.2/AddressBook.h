//
//  AddressBook.h
//  AddressBook integration on the iPhone
//
//  Created by Jaka Jancar <jaka@kubje.org>  
//  Copyright (c) 2007 Jaka Jancar. Licensed under the new BSD license.
//

#import <Foundation/Foundation.h>
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
        