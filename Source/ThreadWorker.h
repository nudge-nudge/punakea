#import <Cocoa/Cocoa.h>


/*!
@class ThreadWorker
@abstract v0.7 - Throws a task onto another thread and notifies you when it's done.
@discussion

Usage:
<pre>
[ThreadWorker 
        workOn:self 
  withSelector:&#064;selector(longTask:) 
    withObject:someData
didEndSelector:&#064;selector(longTaskFinished:) ];
</pre>
The ThreadWorker class was designed to be simple and
to make multi-threading even simpler. You can offload
tasks to another thread and be notified when the task
is finished.

In this sense it is similar to the Java SwingWorker
class, though the need for such a class in Cocoa
and Objective-C is as different as the implementation.

Be sure to copy the ThreadWorker.h and ThreadWorker.m
files to your project directory.

To see how to use this class, see the documentation for
the "workOn" method below.

I recommend registering at the link below to let
SourceForge contact you when new versions of ThreadWorker
are released:

<a href="http://sourceforge.net/project/filemodule_monitor.php?filemodule_id=24102">http://sourceforge.net/project/filemodule_monitor.php?filemodule_id=24102</a>

I'm releasing this code into the Public Domain.
Do with it as you will. Enjoy!

Original author: Robert Harder, rob&#064;iharder.net


Change History

<pre>
0.7 -
 o  Added ability to mark thread as cancelled.
 o  Changed the behavior when "longTask" takes a second argument.
    Instead of passing a proxy to the primary thread's "self"
    it passes a references to the ThreadWorker. The recommended way
    to pass information from the primary, or originating, thread
    is to use an NSDictionary to pass in the Things You'll Need.
    See the Controller.m example.
 o  Changed thread's termination behavior so that as soon as your
    "longTask:" is finished, the thread will exit. This means if
    you left anything on the NSRunLoop (or more likely an NSURL
    did it without your knowledge), it will get dumped.

0.6.2 - Moved [super dealloc] to the end of the dealloc method and
ensured "init" returns nil if it fails.

0.6.1 - Added [super dealloc] to the dealloc method and moved the
dealloc declaration out of the private API and into the
public .h file as it should be.

0.6 - Eliminated the need for the runSelectorInCallingThread method
by making a proxy to the target available to the task working
in the new thread. This makes for much less overhead.
Also changed static method signature from withArgument to withObject.

0.5.1 - Oops. Forget a necessary thread lock for the NSConnection creation.

0.5 - Uses NSConnection to communicate between threads, so although we
might have been thread-safe before (depending on whether or not
addTimer in NSRunLoop is thread-safe), we're definitely thread-safe
now - or so we think. =)
In the process we had to do away with the helper functions that took
a bit of hassle out using runSelectorInCallingThread with arguments
that are not objects. Sorry.

0.4.1 - Fixed some typos in commented sections.

0.4 - Released into the Public Domain. Enjoy!

0.3 - Permitted "workOn" method to accept a second argument of type
ThreadWorker* to allow for passing of the parent ThreadWorker
to the secondary thread. This makes it easy and reliable to
call other methods on the calling thread.

0.2 - Added runSelectorInCallingThread so that you could make calls
back to the main, i.e. calling, thread from the secondary thread.

0.1 - Initial release.
</pre>
*/
@interface ThreadWorker : NSObject
{
   id               _target;            // The object whose selector will be called
   SEL              _selector;          // The selector that will be called in another thread
   id               _argument;          // The argument that will be passed to the selector
   SEL              _didEndSelector;    // Selector for final notice
   NSConnection    *_callingConnection; // Connection used to safely communicate between threads
   NSPort          *_port1;
   NSPort          *_port2;
   NSConnection    *_conn2;
   NSConditionLock *_cancelled;
   BOOL		        _endRunLoop;
}



/*!
@method workOn:withSelector:withObject:didEndSelector:
@param target The object to receive the selector message. It is retained.
@param selector The selector to be called on the target in the worker thread.
@param userInfo An optional argument if you wish to pass one to the selector
       and target. It is retained.
@param didEndSelector An optional selector to call on the target. Use the
       value 0 (zero) if you don't want a selector called at the end.
@result Returns an autoreleased ThreadWorker that manages the worker thread.
 
@abstract Call this class method to work on something in another thread. 
@discussion
 
Example:
 <pre>
    NSDictionary *thingsIllNeed = [NSDictionary dictionaryWithObjectsAndKeys:
       self, &#064;"self",
       myProgressIndicator, &#064;"progress",
       myStatusField, &#064;"status", nil];
 
    [ThreadWorker workOn:self 
                  withSelector:&#064;selector(longTask:) 
                  withObject:thingsIllNeed
                  didEndSelector:&#064;selector(longTaskFinished:)];
 </pre>

The longTask method in self will then be called and should look
something like this:
 <pre>
    - (id)longTask:(id)userInfo
    {
        // Do something that takes a while and uses 'userInfo' if you want
        id otherSelf = [userInfo objectForKey:&#064;"self"];
 		   NSProgressIndicator *progress =
            (NSProgressIndicator *)[userInfo objectForKey:&#064;"progress"];
 		   NSTextField *status =
            (NSTextField *)[userInfo objectForKey:&#064;"status"];
 
        return userInfo; // Will be passed to didEndSelector
    }    
 </pre>
Optionally you can have this "longTask" method accept a second argument
which will be the controlling ThreadWorker instance which you can use
to see if the ThreadWorker has been marked as cancelled.
Your "longTask" method might then look like this:
 <pre>
    - (id)longTask:(id)userInfo anyNameHere:(ThreadWorker *)tw
   {
       ...
       while(... && ![tw cancelled]){
           ...
       }
   }
 </pre>
You can name the second parameter anythign you want. You only have to
match it when you create the ThreadWorker like so:
 <pre>
    [ThreadWorker workOn:self 
                  withSelector:&#064;selector(longTask: anyNameHere:) 
                  withObject:userInfo
                  didEndSelector:&#064;selector(longTaskFinished:)];
 
 </pre>
When your longTask method is finished, whatever is returned from it will
be passed to the didEndSelector (if it's not nil) as that selector's
only argument. The didEndSelector will be called on the original thread,
so if you launched the thread as a result of a user clicking on something,
the longTaskFinished will be called on the main thread, which is what you
need if you want to then modify any GUI components.
The longTaskFinished method might look something like this, then:
 <pre>
    - (void)longTaskFinished:(id)userInfo
    {
        //Do something now that the thread is done
        // ...
    }    
 </pre>
Of course you will have to have imported the ThreadWorker.h
file in your class's header file. The top of your header file
might then look like this:
 <pre>
    import <Cocoa/Cocoa.h>
    import "ThreadWorker.h"
 </pre>
Enjoy.

 */
+ (ThreadWorker *)
    workOn:(id)target 
    withSelector:(SEL)selector 
    withObject:(id)userInfo
    didEndSelector:(SEL)didEndSelector;


    /*!
     @method markAsCancelled
     @abstract Mark the ThreadWorker as cancelled.
     @discussion
     Marks the ThreadWorker as cancelled but doesn't actually
     cancel the thread. It is up to you to check whether or
     not the ThreadWorker is cancelled using a two-argument
     "longTask:..." method like so:
<pre>
     - (id)longTask:(id)userInfo anyNameHere:(ThreadWorker *)tw
     {
         ...
         while(... && ![tw cancelled]){
             ...
         }
     }
</pre>
     */
-(void)markAsCancelled;


    /*!
     @method cancelled
     @abstract Returns whether or not someone has tried to cancel the thread.
     @discussion Returns whether or not someone has tried to cancel the thread.
     */
-(BOOL)cancelled;



    /*!
    @method dealloc
    @abstract Make sure we clean up after ourselves.
    @discussion Make sure we clean up after ourselves.
    */
- (void) dealloc;


    /*!
    @method description
     @abstract Just a little note to say, "Good job, Rob!"
     @discussion
     Just a little note to say, "Good job, Rob!" to
     the original author of this Public Domain software.
     */
+ (NSString *)description;




@end

