//
//  CHRVariableTimer.h
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


#pragma mark - Forward Declarations

@class CHRVariableTimer;


#pragma mark - Type Definitions

/**
 The block that supplies the interval from the current time to the next firing
 of the timer. It is guaranteed that this block will only ever be called once
 for a given nextInvocation value and that the value of nextInvocation is
 monotonically increasing between executions of this block.
 */
typedef NSTimeInterval (^CHRVariableTimerIntervalProvider)(__weak CHRVariableTimer *timer, NSUInteger nextInvocation);


#pragma mark - CHRVariableTimer Interface

/**
 The CHRVariableTimer class allows you to create Grand Central Dispatch-based
 timer objects that allow for variable intervals between successive firings.
 
 A timer has limited accuracy when determining the exact moment to fire; the
 actual time at which a timer fires can potentially be a significant period of
 time after the scheduled firing time.
 */
@interface CHRVariableTimer : NSObject <CHRRepeatingTimer>

- (instancetype)init NS_UNAVAILABLE;

// -----
// @name Creating a Variable Timer
// -----

#pragma mark Creating a Variable Timer

/**
 Initializes a CHRVariableTimer object.
 
 The execution block will be executed on the default execution queue.
 
 @param     intervalProvider
            The block that provides intervals for timer firing.
 @param     executionBlock
            The block to execute at the given interval.
 @return    The newly initialized CHRVariableTimer object.
 */
- (instancetype)initWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                          executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock;

/**
 Initializes a CHRVariableTimer object.
 
 @param     intervalProvider
            The block that provides intervals for timer firing.
 @param     executionBlock
            The block to execute at the given interval.
 @param     executionQueue
            The queue that should execute the executionBlock.
 @return    The newly initialized CHRVariableTimer object.
 */
- (instancetype)initWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                  executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                  executionQueue:(dispatch_queue_t)executionQueue;

/**
 Initializes a CHRVariableTimer object.
 
 @param     intervalProvider
            The block that provides intervals for timer firing.
 @param     executionBlock
            The block to execute at the given interval.
 @param     executionQueue
            The queue that should execute the executionBlock.
 @param     failureBlock
            The block to execute if the timer fails to initialize.
 @return    The newly initialized CHRVariableTimer object.
 */
- (instancetype)initWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                  executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                  executionQueue:(dispatch_queue_t)executionQueue
                    failureBlock:(CHRTimerInitFailureBlock)failureBlock
                        NS_DESIGNATED_INITIALIZER;

/**
 Creates a CHRVariableTimer object.
 
 The execution block will be executed on the default execution queue.
 
 @param     intervalProvider
            The block that provides intervals for timer firing.
 @param     executionBlock
            The block to execute at the given interval.
 @return    The newly initialized CHRVariableTimer object.
 */
+ (CHRVariableTimer *)timerWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                                 executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock;

/**
 Creates a CHRVariableTimer object.
 
 @param     intervalProvider
            The block that provides intervals for timer firing.
 @param     executionBlock
            The block to execute at the given interval.
 @param     executionQueue
            The queue that should execute the executionBlock.
 @return    The newly initialized CHRVariableTimer object.
 */
+ (CHRVariableTimer *)timerWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                                 executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                                 executionQueue:(dispatch_queue_t)executionQueue;

/**
 Creates a CHRVariableTimer object.
 
 @param     intervalProvider
            The block that provides intervals for timer firing.
 @param     executionBlock
            The block to execute at the given interval.
 @param     executionQueue
            The queue that should execute the executionBlock.
 @param     failureBlock
            The block to execute if the timer fails to initialize.
 @return    The newly initialized CHRVariableTimer object.
 */
+ (CHRVariableTimer *)timerWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                                 executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                                 executionQueue:(dispatch_queue_t)executionQueue
                                   failureBlock:(CHRTimerInitFailureBlock)failureBlock;

// -----
// @name Properties
// -----

#pragma mark Properties

/**
 The receiver's interval provider.
 */
@property (readonly, copy) CHRVariableTimerIntervalProvider intervalProvider;

@end
