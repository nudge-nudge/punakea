#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "FMResultSet.h"

@interface FMDatabase : NSObject 
{
	sqlite3*    db;
	NSString*   databasePath;
    BOOL        logsErrors;
    BOOL        crashOnErrors;
    NSLock		*inUse;
    BOOL        inTransaction;
    BOOL        traceExecution;
    BOOL        checkedOut;
    NSInteger         busyRetryTimeout;
}

+ (FMDatabase*)databaseWithPath:(NSString*)inPath;
- (id)initWithPath:(NSString*)inPath;

- (BOOL) open;
- (void) close;
- (BOOL) goodConnection;

- (NSString*) lastErrorMessage;
- (NSInteger) lastErrorCode;
- (BOOL) hadError;
- (sqlite_int64) lastInsertRowId;

- (sqlite3*) sqliteHandle;

- (BOOL) executeUpdate:(NSString*)objs, ...;
- (id) executeQuery:(NSString*)obj, ...;

- (BOOL) rollback;
- (BOOL) commit;
- (BOOL) beginTransaction;
- (BOOL) beginDeferredTransaction;

- (BOOL)logsErrors;
- (void)setLogsErrors:(BOOL)flag;

- (BOOL)crashOnErrors;
- (void)setCrashOnErrors:(BOOL)flag;

- (void)lockDB;
- (void)unlockDB;

- (BOOL)traceExecution;
- (void)setTraceExecution:(BOOL)flag;

- (BOOL)checkedOut;
- (void)setCheckedOut:(BOOL)flag;

- (NSInteger)busyRetryTimeout;
- (void)setBusyRetryTimeout:(NSInteger)newBusyRetryTimeout;


+ (NSString*) sqliteLibVersion;



@end
