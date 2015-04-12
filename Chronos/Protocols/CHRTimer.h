//
//  CHRTimer.h
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


#pragma mark - Type Definitions

/**
 The block to execute if the timer fails to initialize.
 */
typedef void (^CHRTimerInitFailureBlock)(void);


#pragma mark - CHRTimer Protocol

/**
 The CHRTimer protocol declares methods and properties for a timer. 
 
 A timer has limited accuracy when determining the exact moment to fire; the
 actual time at which a timer fires can potentially be a significant period of
 time after the scheduled firing time.
 */
@protocol CHRTimer <NSObject>

// -----
// @name Using a Timer
// -----

#pragma mark Using a Timer

/**
 Starts the timer.
 
 @param     now
            YES if the timer should start immediately.
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
 The receiver's execution queue.
 */
@property (readonly) dispatch_queue_t executionQueue;

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
