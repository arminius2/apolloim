//
//  AddressBook.h
//  AddressBook integration on the iPhone                  
//
//  Created by Jaka Jancar <jaka@kubje.org>
//  Copyright (c) 2007 Jaka Jancar. Licensed under the new BSD license.
//

#import "AddressBook.h"
#import "sqlite3.h"

@interface AddressBook (Private)
- (void) checkSqliteReturnCode: (int) rc dbHandle: (sqlite3*) dbHandle whileDoing: (NSString *) whileDoing;
- (void) initSqliteDatabase: (sqlite3**) handle filePath: (NSString*) filePath desc: (NSString*) desc;
- (void) initSqliteStatement: (sqlite3_stmt**) stmt dbHandle: (sqlite3*) dbHandle query: (NSString*) query desc: (NSString*) desc;
@end

@implementation AddressBook
- (AddressBook*) init
{
    return [self initWithDbFilePath: @"/var/root/Library/AddressBook/AddressBook.sqlitedb"
            andImageDbFilePath: @"/var/root/Library/AddressBook/AddressBookImages.sqlitedb"
            andPeoplePickerPrefsFilePath: @"/var/root/Library/Preferences/com.apple.PeoplePicker.plist"];
}

- (AddressBook*) initWithDbFilePath: (NSString*) dbFilePath andImageDbFilePath: (NSString*) imageDbFilePath andPeoplePickerPrefsFilePath: (NSString*) prefsFilePath;
{
    [super init];
    
    // Initialize databases
    [self initSqliteDatabase: &db filePath: dbFilePath desc: @"AddressBook database"];
    [self initSqliteDatabase: &imageDb filePath: imageDbFilePath desc: @"AddressBook image database"];
    
	// Initialize PeoplePicker preferences
    peoplePickerPrefs = [NSDictionary dictionaryWithContentsOfFile: prefsFilePath];
    	
	// Initialize database statements
    [self initSqliteStatement: &getDisplayNameOfIMUserStmt
        dbHandle: db
        query:
        @"SELECT\n"
        "	ABPerson.Kind, ABPerson.First, ABPerson.Middle, ABPerson.Last, ABPerson.Organization\n"
        "FROM\n"
        "	ABPerson, ABMultiValue, ABMultiValueEntry\n"
        "WHERE\n"
        "	ABPerson.ROWID = ABMultiValue.record_id AND\n"
        "	ABMultiValueEntry.parent_id  = ABMultiValue.UID AND\n"
        "	ABMultiValue.property = 13 AND\n"
        "	ABMultiValueEntry.key = 1 AND\n"
        "	ABMultiValueEntry.value = ?1 AND\n"
        "	EXISTS (\n"
        "		SELECT\n"
        "			'1'\n"
        "		FROM\n"
        "			ABMultiValueEntry as InnerABMultiValueEntry\n"
        "		WHERE\n"
        "			InnerABMultiValueEntry.parent_id =  ABMultiValueEntry.parent_id AND\n"
        "			InnerABMultiValueEntry.key = 2 AND\n"
        "			InnerABMultiValueEntry.value = ?2\n"
        "   );\n"
        desc: @"getDisplayNameOfIMUser statement"];
        
    return self;
}

- (NSString*) getDisplayNameOfIMUser: (NSString*) username protocol: (NSString*) protocol
{
    int rc;
    
    sqlite3_reset(getDisplayNameOfIMUserStmt);
    sqlite3_clear_bindings(getDisplayNameOfIMUserStmt);

    rc = sqlite3_bind_text(getDisplayNameOfIMUserStmt, 1, [username UTF8String], -1, SQLITE_STATIC);
    [self checkSqliteReturnCode: rc dbHandle: db whileDoing: @"Binding username to statement."];
    
    rc = sqlite3_bind_text(getDisplayNameOfIMUserStmt, 2, [protocol UTF8String], -1, SQLITE_STATIC);
    [self checkSqliteReturnCode: rc dbHandle: db whileDoing: @"Binding protocol to statement."];

    rc = sqlite3_step(getDisplayNameOfIMUserStmt);
    if (rc == SQLITE_DONE) {
        // no match
        return nil;
    }else if (rc == SQLITE_ROW) {
        // match found
        if (sqlite3_column_int(getDisplayNameOfIMUserStmt, 0) == 1) {
            // company
            const char *organization = (const char *)sqlite3_column_text(getDisplayNameOfIMUserStmt, 4);
            if ( (organization == NULL) || (strlen(organization) == 0) )
                return nil;
            return [NSString stringWithUTF8String: organization];
        }else{
            // person
            const char *firstName = (const char *)sqlite3_column_text(getDisplayNameOfIMUserStmt, 1);
            const char *middleName = (const char *)sqlite3_column_text(getDisplayNameOfIMUserStmt, 2);
            const char *lastName = (const char *)sqlite3_column_text(getDisplayNameOfIMUserStmt, 3);
            
            BOOL firstNameSet = ( (firstName != NULL) && (strlen(firstName) > 0) );
            BOOL middleNameSet = ( (middleName != NULL) && (strlen(middleName) > 0) );
            BOOL lastNameSet = ( (lastName != NULL) && (strlen(lastName) > 0) );
            
            NSMutableString *displayName = [NSMutableString string];
            
            int personNameOrdering = [[peoplePickerPrefs valueForKey: @"personNameOrdering"] intValue];
            switch (personNameOrdering) {
                case 0:
                    // <First> <Middle> <Last>
                    if (firstNameSet)
                        [displayName appendString: [NSString stringWithUTF8String: firstName]];
                
                    if (middleNameSet) {
                        if ([displayName length])
                            [displayName appendString: @" "];
                        [displayName appendString: [NSString stringWithUTF8String: middleName]];
                    }
                    
                    if (lastNameSet) {
                        if ([displayName length])
                            [displayName appendString: @" "];
                        [displayName appendString: [NSString stringWithUTF8String: lastName]];
                    }
                    break;
                case 1:
                    // <Last> <Middle> <First>
                    if (lastNameSet)
                        [displayName appendString: [NSString stringWithUTF8String: lastName]];
                
                    if (middleNameSet) {
                        if ([displayName length])
                            [displayName appendString: @" "];
                        [displayName appendString: [NSString stringWithUTF8String: middleName]];
                    }
                    
                    if (firstNameSet) {
                        if ([displayName length])
                            [displayName appendString: @" "];
                        [displayName appendString: [NSString stringWithUTF8String: firstName]];
                    }
                    break;
                default:
                    [NSException raise: NSGenericException format: @"Invalid personNameOrdering: %d", personNameOrdering];
            }
            
            if (![displayName length]) // nothing available
                return nil;
                
            return displayName;
        }
    }else{
        // error
        [self checkSqliteReturnCode: rc dbHandle: db whileDoing: @"Retrieving a row from the result."];
        
        // It might come to this during a short period of time during synchronization
        // with iTunes when DB is busy. Decide how to handle (return nil, block...).
    }
    
}

- (void) dealloc;
{
    sqlite3_finalize(getDisplayNameOfIMUserStmt);
    
    sqlite3_close(db);
    sqlite3_close(imageDb);
    
    [super dealloc];
}

/***** Private *****/

- (void) checkSqliteReturnCode: (int) rc dbHandle: (sqlite3*) dbHandle whileDoing: (NSString *) whileDoing
{
    if (rc != SQLITE_OK)
    {
        [NSException raise: NSGenericException
            format: @"Sqlite error while doing '%@': %@ (code %@)", 
            whileDoing,
            [NSString stringWithUTF8String: sqlite3_errmsg(dbHandle)],
            [NSNumber numberWithInt: rc]];
    }
}

- (void) initSqliteDatabase: (sqlite3**) handle filePath: (NSString*) filePath desc: (NSString*) desc
{
    if (![[NSFileManager defaultManager] isReadableFileAtPath: filePath])
    {
        [NSException raise: NSGenericException format: @"File for '%@' does not exist or is not readable: %@", desc, filePath];
    }
	
    //rc = sqlite3_open_v2([imageDbFilePath UTF8String], &imageDb, SQLITE_OPEN_READONLY, NULL);
    int rc = sqlite3_open([filePath UTF8String], handle);
	[self checkSqliteReturnCode: rc dbHandle: *handle whileDoing: @"Opening database."];
	
	// Enable extended result codes for more detail
    sqlite3_extended_result_codes(*handle, 1);
}

- (void) initSqliteStatement: (sqlite3_stmt**) stmt dbHandle: (sqlite3*) dbHandle query: (NSString*) query desc: (NSString*) desc
{
	int rc = sqlite3_prepare_v2(dbHandle, [query UTF8String], -1, stmt, NULL);
	[self checkSqliteReturnCode: rc dbHandle: dbHandle whileDoing: @"Compiling SQL statement."];
}

@end