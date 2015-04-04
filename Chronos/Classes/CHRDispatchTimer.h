//
//  CHRDispatchTimer.h
//  Chronos
//
//  Copyright (c) 2015 Comyar Zaheri. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//


#pragma mark - Imports

@import Foundation;
#import <libkern/OSAtomic.h>


#pragma mark - Forward Declarations

@class CHRDispatchTimer;


#pragma mark - Type Definitions

/**
 The block to execute if the timer fails to create a dispatch source during 
 initialization.
 */
typedef void (^CHRDispatchTimerInitFailureBlock)(void);

/**
 The block to execute when the timer is canceled.
 
 @param     timer
            The timer that fired.
 */
typedef void (^CHRDispatchTimerCancellationBlock)(__weak CHRDispatchTimer *timer);

/**
 The block to execute every time the timer is fired.
 
 @param     timer   
            The timer that fired.
 @param     invocation
            The current invocation number. The first invocation is 0.
 */
typedef void (^CHRDispatchTimerExecutionBlock)(__weak CHRDispatchTimer *timer, NSUInteger invocation);


#pragma mark - CHRDispatchTimer Interface

/**
 The CHRDispatchTimer class allows you to create Grand Central Dispatch-based
 timer objects. A timer waits until a certain time interval has elapsed and then
 fires, executing a given block. 
 
 A timer has limited accuracy when determining the exact moment to fire; the
 actual time at which a timer fires can potentially be a significant period of 
 time after the scheduled firing time.
 */
@interface CHRDispatchTimer : NSObject

- (instancetype)init NS_UNAVAILABLE;

// -----
// @name Creating a Dispatch Timer
// -----

#pragma mark Creating a Dispatch Timer

/**
 Initializes a CHRDispatchTimer object.
 
 The execution block will be executed on the default execution queue.
 
 @param     interval
            The execution interval, in seconds.
 @param     executionBlock
            The block to execute at the given interval.
 @return    The newly initialized CHRDispatch object.
 */
- (instancetype)initWithInterval:(NSTimeInterval)interval
                  executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock;

/**
 Initializes a CHRDispatchTimer object.
 
 @param     interval
            The execution interval, in seconds.
 @param     executionBlock
            The block to execute at the given interval.
 @param     executionQueue
            The queue that should execute the executionBlock.
 @return    The newly initialized CHRDispatch object.
 */
- (instancetype)initWithInterval:(NSTimeInterval)interval
                  executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock
                  executionQueue:(dispatch_queue_t)executionQueue;

/**
 Initializes a CHRDispatchTimer object.
 
 @param     interval
            The execution interval, in seconds.
 @param     executionBlock
            The block to execute at the given interval.
 @param     executionQueue
            The queue that should execute the executionBlock.
 @param     failureBlock
            The block to execute if the timer fails to initialize. 
 @return    The newly initialized CHRDispatch object.
 */
- (instancetype)initWithInterval:(NSTimeInterval)interval
                  executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock
                  executionQueue:(dispatch_queue_t)executionQueue
                    failureBlock:(CHRDispatchTimerInitFailureBlock)failureBlock
                    NS_DESIGNATED_INITIALIZER;

/**
 Creates and initializes a new CHRDispatchTimer object.
 
 The execution block will be executed on the default execution queue.
 
 @param     interval
            The execution interval, in seconds.
 @param     executionBlock
            The block to execute at the given interval.
 @return    The newly created CHRDispatch object.
 */
+ (CHRDispatchTimer *)timerWithInterval:(NSTimeInterval)interval
                         executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock;

/**
 Creates and initializes a new CHRDispatchTimer object.
 
 @param     interval
            The execution interval, in seconds.
 @param     executionBlock
            The block to execute at the given interval.
 @param     executionQueue
            The queue that should execute the executionBlock.
 @return    The newly created CHRDispatch object.
 */
+ (CHRDispatchTimer *)timerWithInterval:(NSTimeInterval)interval
                         executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock
                         executionQueue:(dispatch_queue_t)executionQueue;

/**
 Creates and initializes a new CHRDispatchTimer object.
 
 @param     interval
            The execution interval, in seconds.
 @param     executionBlock
            The block to execute at the given interval.
 @param     executionQueue
            The queue that should execute the executionBlock.
 @param     failureBlock
            The block to execute if the timer fails to initialize.
 @return    The newly created CHRDispatch object.
 */
+ (CHRDispatchTimer *)timerWithInterval:(NSTimeInterval)interval
                         executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock
                         executionQueue:(dispatch_queue_t)executionQueue
                           failureBlock:(CHRDispatchTimerInitFailureBlock)failureBlock;

// -----
// @name Using a Dispatch Timer
// -----

#pragma mark Using a Dispatch Timer

/**
 Starts the timer and begins executing the executionBlock at the set interval.
 
 @param     now
            YES if the timer should start immediately or interval seconds from
            the current time.
 */
- (void)start:(BOOL)now;

/**
 Stops the timer and does not reset the invocation count.
 */
- (void)pause;

/**
 Permanently cancels the timer.
 
 Attempting to send a start or pause message to a canceled timer is considered
 an error, and will result in an exception being thrown.
 */
- (void)cancel;

// -----
// @name Properties
// -----

#pragma mark Properties

/**
 The receiver's execution interval, in seconds.
 */
@property (readonly) NSTimeInterval interval;

/**
 The receiver's execution queue.
 */
@property (readonly) dispatch_queue_t executionQueue;

/**
 The receiver's execution block.
 */
@property (readonly, copy) CHRDispatchTimerExecutionBlock executionBlock;

/**
 The number of times the timer has fired.
 */
@property (atomic, readonly) NSUInteger invocations;

/**
 YES, if the timer is valid.
 
 A timer is considered invalid if it has received the cancel message.
 */
@property (atomic, readonly, getter=isValid) BOOL valid;

/**
 YES, if the timer is currently running.
 */
@property (atomic, readonly, getter=isRunning) BOOL running;

@end
