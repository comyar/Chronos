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
#import "CHRRepeatingTimer.h"
#import <libkern/OSAtomic.h>


#pragma mark - CHRDispatchTimer Interface

/**
 The CHRDispatchTimer class allows you to create Grand Central Dispatch-based
 timer objects. A timer waits until a certain time interval has elapsed and then
 fires, executing a given block. 
 
 A timer has limited accuracy when determining the exact moment to fire; the
 actual time at which a timer fires can potentially be a significant period of 
 time after the scheduled firing time.
 */
@interface CHRDispatchTimer : NSObject <CHRRepeatingTimer>

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
                  executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock;

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
                  executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
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
                  executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                  executionQueue:(dispatch_queue_t)executionQueue
                    failureBlock:(CHRTimerInitFailureBlock)failureBlock
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
                         executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock;

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
                         executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
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
                         executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                         executionQueue:(dispatch_queue_t)executionQueue
                           failureBlock:(CHRTimerInitFailureBlock)failureBlock;

// -----
// @name Properties
// -----

#pragma mark Properties

/**
 The receiver's execution interval, in seconds.
 */
@property (readonly) NSTimeInterval interval;

/**
 The receiver's execution block.
 */
@property (readonly, copy) CHRRepeatingTimerExecutionBlock executionBlock;

@end
