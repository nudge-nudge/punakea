#import "FMDatabase.h"

#import "lcl.h"

@implementation FMDatabase

+ (FMDatabase*)databaseWithPath:(NSString*)aPath {
    return [[[FMDatabase alloc] initWithPath:aPath] autorelease];
}

- (id)initWithPath:(NSString*)aPath {
    self = [super init];
	
    if (self) {
        databasePath        = [aPath copy];
        db                  = 0x00;
        logsErrors          = 0x00;
        crashOnErrors       = 0x00;
        busyRetryTimeout    = 0x00;
    }
	
	return self;
}

- (void)dealloc {
	[self close];
	[databasePath release];
	[super dealloc];
}

+ (NSString*) sqliteLibVersion {
    return [NSString stringWithFormat:@"%s", sqlite3_libversion()];
}

- (sqlite3*) sqliteHandle {
    return db;
}

- (BOOL) open {
	NSInteger err = sqlite3_open( [databasePath fileSystemRepresentation], &db );
	if(err != SQLITE_OK) {
        lcl_log(lcl_cnntagging,lcl_vError,@"Error opening tag database: %d", err);
		return NO;
	}
	
	return YES;
}

- (void) close {
	if (!db) {
        return;
    }
    
    NSInteger  rc;
    BOOL retry;
    NSInteger numberOfRetries = 0;
    do {
        retry   = NO;
        rc      = sqlite3_close(db);
        if (SQLITE_BUSY == rc) {
            retry = YES;
            usleep(20);
            if (busyRetryTimeout && (numberOfRetries++ > busyRetryTimeout)) {
                [NSException raise:@"FMDatabaseException" format:@"Database too busy."];
            }
        }
        else if (SQLITE_OK != rc) {
            lcl_log(lcl_cnntagging,lcl_vError,@"Error closing tag database: %d", rc);
        }
    }
    while (retry);
    
	db = nil;
}


- (BOOL) goodConnection {
    FMResultSet *rs = [self executeQuery:@"select name from sqlite_master where type='table'"];
    
    if (rs) {
        [rs close];
        return YES;
    }
    
    return NO;
}

- (NSString*) lastErrorMessage {
    return [NSString stringWithUTF8String:sqlite3_errmsg(db)];
}

- (BOOL) hadError {
    return ([self lastErrorCode] != SQLITE_OK);
}

- (NSInteger) lastErrorCode {
    return sqlite3_errcode(db);
}

- (sqlite_int64) lastInsertRowId {
    
    [self lockDB];
    
    sqlite_int64 ret = sqlite3_last_insert_rowid(db);
    
    [self unlockDB];
    
    return ret;
}

- (void) bindObject:(id)obj toColumn:(NSInteger)idx inStatement:(sqlite3_stmt*)pStmt; {
    
    // FIXME - someday check the return codes on these binds.
    if ([obj isKindOfClass:[NSData class]]) {
        sqlite3_bind_blob(pStmt, idx, [obj bytes], [obj length], SQLITE_STATIC);
    }
    else if ([obj isKindOfClass:[NSDate class]]) {
        sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        
        if (strcmp([obj objCType], @encode(BOOL)) == 0) {
            sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
        }
        else if (strcmp([obj objCType], @encode(NSInteger)) == 0) {
            sqlite3_bind_int64(pStmt, idx, [obj longValue]);
        }
        else if (strcmp([obj objCType], @encode(CGFloat)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
        }
        else if (strcmp([obj objCType], @encode(double)) == 0) {
            sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
        }
        else {
            sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
        }
    }
    else {
        sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
    }
}

- (id) executeQuery:(NSString*)objs, ... {
    
    [self lockDB];
    
    FMResultSet *rs = nil;
    
    NSString *sql = objs;
    NSInteger rc;
    sqlite3_stmt *pStmt;
    
    if (traceExecution && sql) {
        lcl_log(lcl_cnntagging,lcl_vTrace,@"FMDatabase executeQuery: %@", sql);
    }
    
    NSInteger numberOfRetries = 0;
    BOOL retry;
    do {
        retry   = NO;
        rc      = sqlite3_prepare(db, [sql UTF8String], -1, &pStmt, 0);
        
        if (SQLITE_BUSY == rc) {
            retry = YES;
            usleep(20);
            
            if (busyRetryTimeout && (numberOfRetries++ > busyRetryTimeout)) {
                [NSException raise:@"FMDatabaseException" format:@"Database too busy."];
            }
        }
        else if (SQLITE_OK != rc) {
            
            rc = sqlite3_finalize(pStmt);
            
            if (logsErrors) {
                lcl_log(lcl_cnntagging,lcl_vError,@"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                lcl_log(lcl_cnntagging,lcl_vError,@"DB Query: %@", sql);
                if (crashOnErrors) {
                    [NSException raise:@"FMDatabaseException" format:@"(%lx) \"%@\"", [self lastErrorCode], [self lastErrorMessage]];
                }
            }
            
            [self unlockDB];
            return nil;
        }
    }
    while (retry);
    
    id obj;
    NSInteger idx = 0;
    NSInteger queryCount = sqlite3_bind_parameter_count(pStmt); // pointed out by Dominic Yu (thanks!)
    va_list argList;
    va_start(argList, objs);
    
    while (idx < queryCount) {
        obj = va_arg(argList, id);
        idx++;
        
        [self bindObject:obj toColumn:idx inStatement:pStmt];
        
    }
    
    va_end(argList);
    
    // the statement gets close in rs's dealloc or [rs close];
    rs = [FMResultSet resultSetWithStatement:pStmt usingParentDatabase:self];
    [rs setQuery:sql];
    
    return rs;
}


- (BOOL) executeUpdate:(NSString*)objs, ... {
    
	[self lockDB];
    
    NSString *sql       = objs;
    NSInteger rc              = 0x00;
    sqlite3_stmt *pStmt = 0x00;
    
    if (traceExecution && sql) {
        lcl_log(lcl_cnntagging,lcl_vTrace,@"FMDatabase executeUpdate: %@", sql);
    }
    
    NSInteger numberOfRetries = 0;
    BOOL retry;
    do {
        retry   = NO;
        rc      = sqlite3_prepare(db, [sql UTF8String], -1, &pStmt, 0);
        if (SQLITE_BUSY == rc) {
            retry = YES;
            usleep(20);
            if (busyRetryTimeout && (numberOfRetries++ > busyRetryTimeout)) {
                [NSException raise:@"FMDatabaseException" format:@"Database too busy."];
            }
        }
        else if (SQLITE_OK != rc) {
            NSInteger ret = rc;
            rc = sqlite3_finalize(pStmt);
            
            if (logsErrors) {
                lcl_log(lcl_cnntagging,lcl_vError,@"DB Error: %d \"%@\"", [self lastErrorCode], [self lastErrorMessage]);
                lcl_log(lcl_cnntagging,lcl_vError,@"DB Query: %@", sql);
                if (crashOnErrors) {
                    [NSException raise:@"FMDatabaseException" format:@"(%lx) \"%@\"", [self lastErrorCode], [self lastErrorMessage]];
                }
            }
            
            [self unlockDB];
            return ret;
        }
    }
    while (retry);
    
    
    id obj;
    NSInteger idx = 0;
    NSInteger queryCount = sqlite3_bind_parameter_count(pStmt);
    va_list argList;
    va_start(argList, objs);
    
    while (idx < queryCount) {
        
        obj = va_arg(argList, id);
        idx++;
        
        [self bindObject:obj toColumn:idx inStatement:pStmt];
    }
    
    va_end(argList);
    
    /* Call sqlite3_step() to run the virtual machine. Since the SQL being
    ** executed is not a SELECT statement, we assume no data will be returned.
    */
    numberOfRetries = 0;
    do {
        rc      = sqlite3_step(pStmt);
        retry   = NO;
        
        if (SQLITE_BUSY == rc) {
            // this will happen if the db is locked, like if we are doing an update or insert.
            // in that case, retry the step... and maybe wait just 10 milliseconds.
            retry = YES;
            usleep(20);
            if (busyRetryTimeout && (numberOfRetries++ > busyRetryTimeout)) {
                [NSException raise:@"FMDatabaseException" format:@"Database too busy."];
            }
        }
        else if (SQLITE_DONE == rc || SQLITE_ROW == rc) {
            // all is well, let's return.
        }
        else if (SQLITE_ERROR == rc) {
            lcl_log(lcl_cnntagging,lcl_vError,@"Error calling sqlite3_step (%d: %s) eu", rc, sqlite3_errmsg(db));
            lcl_log(lcl_cnntagging,lcl_vError,@"DB Query: %@", sql);
            [NSException raise:@"SQLITE_ERROR eu" format:@"sqlite3_step"];
        }
        else if (SQLITE_MISUSE == rc) {
            // uh oh.
            lcl_log(lcl_cnntagging,lcl_vError,@"Error calling sqlite3_step (%d: %s) eu", rc, sqlite3_errmsg(db));
            lcl_log(lcl_cnntagging,lcl_vError,@"DB Query: %@", sql);
            [NSException raise:@"SQLITE_MISUSE eu" format:@"sqlite3_step"];
        }
        else {
            // wtf?
            lcl_log(lcl_cnntagging,lcl_vError,@"Unknown error calling sqlite3_step (%d: %s) eu", rc, sqlite3_errmsg(db));
            lcl_log(lcl_cnntagging,lcl_vError,@"DB Query: %@", sql);
            [NSException raise:@"sqlite unknown eu" format:@"sqlite3_step"];
        }
        
    } while (retry);
    
    assert( rc!=SQLITE_ROW );
    
    /* Finalize the virtual machine. This releases all memory and other
    ** resources allocated by the sqlite3_prepare() call above.
    */
    rc = sqlite3_finalize(pStmt);
    
    [self unlockDB];
    
    return (rc == SQLITE_OK);
}

- (BOOL) rollback {
    BOOL b = [self executeUpdate:@"ROLLBACK TRANSACTION;"];
    if (b) {
		[self unlockDB];
    }
    return b;
}

- (BOOL) commit {
    BOOL b =  [self executeUpdate:@"COMMIT TRANSACTION;"];
    if (b) {
		[self unlockDB];
    }
    return b;
}

- (BOOL) beginDeferredTransaction {
    BOOL b =  [self executeUpdate:@"BEGIN DEFERRED TRANSACTION;"];
    if (b) {
        [self lockDB];
    }
    return b;
}

- (BOOL) beginTransaction {
    BOOL b =  [self executeUpdate:@"BEGIN EXCLUSIVE TRANSACTION;"];
    if (b) {
        [self lockDB];
    }
    return b;
}

- (BOOL)logsErrors {
    return logsErrors;
}
- (void)setLogsErrors:(BOOL)flag {
    logsErrors = flag;
}

- (BOOL)crashOnErrors {
    return crashOnErrors;
}
- (void)setCrashOnErrors:(BOOL)flag {
    crashOnErrors = flag;
}

- (void)lockDB
{
	[inUse lock];
}

- (void)unlockDB
{
	[inUse unlock];
}

- (BOOL)traceExecution {
    return traceExecution;
}
- (void)setTraceExecution:(BOOL)flag {
    traceExecution = flag;
}

- (BOOL)checkedOut {
    return checkedOut;
}
- (void)setCheckedOut:(BOOL)flag {
    checkedOut = flag;
}


- (NSInteger)busyRetryTimeout {
    return busyRetryTimeout;
}
- (void)setBusyRetryTimeout:(NSInteger)newBusyRetryTimeout {
    busyRetryTimeout = newBusyRetryTimeout;
}


@end
