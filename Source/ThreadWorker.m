#import "ThreadWorker.h"


@interface ThreadWorker (PrivateAPI)

/*!
 * @method initWithTarget:selector:argument:didEndSelector:
 * @param target Object to receive the work in another thread.
 * @param selector Selector to call on target.
 * @param argument Argument to pass through selector to target.
 * @param didEndSelector Optional selector to call on target when the
 *        thread (and your work) is done.
 * @discussion
 * Only legitimate initialization routine.
 */
- (ThreadWorker *)  initWithTarget:(id)target 
                    selector:(SEL)selector 
                    argument:(id)argument
                    didEndSelector:(SEL)didEndSelector;

    
/*!
 * @method startThread:callingPortArray:
 * @discussion
 * This is the method that is first detached in another thread.
 */
- (void) startThread:(NSArray *)callingPortArray;


/*!
 * @method runPrimaryTask:
 * @discussion
 * First method run in newly-created NSRunLoop.
 */
-(void)runPrimaryTask:(id)notUsed;

    

@end // PrivateAPI




@implementation ThreadWorker


/*!
 * This is a public class method that you call 
 * to kick off a task in a new thread.
 */
+ (ThreadWorker *) workOn:(id)target 
                   withSelector:(SEL)selector 
                   withObject:(id)argument
                   didEndSelector:(SEL)didEndSelector;  // Optional
{
    ThreadWorker *tw;
    NSPort *port1;
    NSPort *port2;
    NSConnection *conn;
    NSArray *callingPortArray;
    
    // Make sure the target has that selector
    if( ![target respondsToSelector:selector] )
    {	
        NSLog( @"\nThreadWorker reports: Target %@ does not respond to selector %@.", target, selector );
        return nil;
    }   // end if: error
    
    // Create an instance of ThreadWorker
    tw = [[[ThreadWorker alloc] 
            initWithTarget:target 
            selector:selector 
            argument:argument
            didEndSelector:didEndSelector] autorelease];

    if( !tw )
        return nil;
    
    // Set up connection to "target"
    port1 = [NSPort port];
    port2 = [NSPort port];
    conn = [NSConnection connectionWithReceivePort:port1 sendPort:port2];
    [conn setRootObject:target];
    callingPortArray = [NSArray arrayWithObjects:port2, port1, conn, nil];
    
    // Launch thread in an internal selector that will handle the strange NSThread requirements.
    [NSThread detachNewThreadSelector:@selector(startThread:) toTarget:tw withObject:callingPortArray];

    return tw;
}   // end workOn




/*!
 * Private init method that establishes instance variables.
 */
- (ThreadWorker *) initWithTarget:(id)target 
                   selector:(SEL)selector 
                   argument:(id)argument
                   didEndSelector:(SEL)didEndSelector
{    
    if( ![super init] )
        return nil;

    // Set instance variables
    _target   		= target;
    _selector		= selector;
    _argument 		= argument;
    _didEndSelector	= didEndSelector;
    _cancelled          = [[NSConditionLock alloc] initWithCondition:NO];

    // Retain instance variables
    [_target   		retain];
    [_argument 		retain];

    return self;
}   // end initWithTarget


/*!
 * When deallocating, release instance variables.
 */
- (void)dealloc
{
    // Release instance variables
    [_target            release];
    [_argument          release];
    [_cancelled         release];

    // Releasing these makes the program crash...
    //[_callingConnection release];
    //[_conn2 release];
    //[_port1 release];
    //[_port2 release];
    
    // Clear instance variables - Probably unnecessary.
    _target            = nil;
    _argument          = nil;
    _callingConnection = nil;
    _conn2             = nil;
    _port1             = nil;
    _port2             = nil;
    _cancelled         = nil;

    [super dealloc];
}   // end dealloc




/*!
 * Marks thread as cancelled but cannot actually cause thread to quit.
 */
-(void)markAsCancelled
{
    // Get lock if we're currently NOT cancelled
    if( [_cancelled tryLockWhenCondition:NO] )
        [_cancelled unlockWithCondition:YES];
}	// end markAsCancelled





/*!
 * Indicates whether or not thread is cancelled.
 */
-(BOOL)cancelled
{
    return [_cancelled condition];
}	// end cancelled





/*!
 * Private method that is called in a detached thread.
 * It sets up the thread maintenance - primarily the
 * auto release pool - and calls the user's method.
 */
- (void)startThread:(NSArray *)callingPortArray
{
    NSAutoreleasePool *pool;
    
    // Thread startup maintenance
    pool = [[NSAutoreleasePool alloc] init];
    
    // Set up connections on new thread
    _port1 = [callingPortArray objectAtIndex:0];
    _port2 = [callingPortArray objectAtIndex:1];
    _conn2 = [callingPortArray objectAtIndex:2];
    _callingConnection = [NSConnection connectionWithReceivePort:_port1 sendPort:_port2];

    // Prime the run loop
    
    [[NSRunLoop currentRunLoop] 
        addTimer:[NSTimer scheduledTimerWithTimeInterval:0 
            target:self 
            selector:@selector(runPrimaryTask:) 
            userInfo:nil 
            repeats:NO] 
        forMode:NSDefaultRunLoopMode];
    //[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
    //                         beforeDate:[NSDate distantFuture]];
    
    //[self runPrimaryTask:nil];
    
    // Run one iteration of the run loop
    _endRunLoop = NO;
    BOOL isRunning;
    do {
        isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                             beforeDate:[NSDate distantFuture]];
        //NSLog(@"isRunning: %d, _endRunLoop: %d", isRunning, _endRunLoop );
    } while ( isRunning && !_endRunLoop);   

    
    [pool release];
}   // end startThread


/*!
 * Private method that is the first method run in the
 * newly-created NSRunLoop.
 */
-(void)runPrimaryTask:(id)notUsed
{
    id userInfo;
        
    // Call user's selector with this ThreadWorker as
    // an argument, if a second argument is taken.
    if( [[_target methodSignatureForSelector:_selector] numberOfArguments] == 4 ) // 2 hidden + 2 exposed
        userInfo = [_target performSelector:_selector withObject:_argument
                                 withObject:self];
    else
        userInfo = [_target performSelector:_selector withObject:_argument];
    
    // Call finalizing method in calling thread
    if( _didEndSelector )
        [(id)[_callingConnection rootProxy] performSelector:_didEndSelector withObject:userInfo];

    // Clean up thread maintenance]
    [_callingConnection invalidate];
    [_conn2 invalidate];
    [_port1 invalidate];
    [_port2 invalidate];
    
    _endRunLoop = YES;
}   // end runPrimaryTask


/*!
 * Just a little note to say, "Good job, Rob!" to
 * the original author of this Public Domain software.
 */
+ (NSString *)description
{   return @"ThreadWorker v0.7. Public Domain. Original author: Robert Harder, rob@iharder.net. Keep up-to-date at http://iHarder.net";
}   // end description



@end

