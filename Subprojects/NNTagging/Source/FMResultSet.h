#import <Cocoa/Cocoa.h>
#import "sqlite3.h"

@class FMDatabase;

@interface FMResultSet : NSObject {
    FMDatabase *parentDB;
    sqlite3_stmt *pStmt;
    //sqlite3 *db;
    NSString *query;
    NSMutableDictionary *columnNameToIndexMap;
    BOOL columnNamesSetup;
}

+ (id) resultSetWithStatement:(sqlite3_stmt *)stmt usingParentDatabase:(FMDatabase*)aDB;

- (void) close;

- (NSString *)query;
- (void)setQuery:(NSString *)value;

- (void)setPStmt:(sqlite3_stmt *)newsqlite3_stmt;
- (void)setParentDB:(FMDatabase *)newDb;



- (BOOL) next;

- (NSInteger) intForColumn:(NSString*)columnName;
- (NSInteger) intForColumnIndex:(NSInteger)columnIdx;

- (NSInteger) longForColumn:(NSString*)columnName;
- (NSInteger) longForColumnIndex:(NSInteger)columnIdx;

- (BOOL) boolForColumn:(NSString*)columnName;
- (BOOL) boolForColumnIndex:(NSInteger)columnIdx;

- (double) doubleForColumn:(NSString*)columnName;
- (double) doubleForColumnIndex:(NSInteger)columnIdx;

- (NSString*) stringForColumn:(NSString*)columnName;
- (NSString*) stringForColumnIndex:(NSInteger)columnIdx;

- (NSDate*) dateForColumn:(NSString*)columnName;
- (NSDate*) dateForColumnIndex:(NSInteger)columnIdx;

- (NSData*) dataForColumn:(NSString*)columnName;
- (NSData*) dataForColumnIndex:(NSInteger)columnIdx;

- (void) kvcMagic:(id)object;

@end
