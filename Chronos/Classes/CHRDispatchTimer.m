//
//  CHRDispatchTimer.m
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

#import "CHRDispatchTimer.h"


#pragma mark - Constants and Functions

static const int STOPPED    = 0;
static const int RUNNING    = 1;
static const int INVALID    = 0;
static const int VALID      = 1;
static NSString * const CHRDispatchTimerExecutionQueueNamePrefix = @"com.chronus.execution";

/**
 Computes the leeway for the given interval. Currently set to 5% of the total
 interval time.
 */
static inline uint64_t leeway(NSTimeInterval interval) {
    return 0.05 * interval * NSEC_PER_SEC;
}

/**
 Computes the start time of the timer, given the interval and whether the timer
 should start immediately.
 */
static inline dispatch_time_t startTime(NSTimeInterval interval, BOOL now) {
    return dispatch_time(DISPATCH_TIME_NOW, (now)? 0 : interval * NSEC_PER_SEC);
}


#pragma mark - CHRDispatchTimer Class Extension

@interface CHRDispatchTimer () {
    volatile int32_t    _running;
    volatile int32_t    _valid;
    volatile NSUInteger _invocations;
}

@property (readonly) dispatch_source_t timer;

@end


#pragma mark - CHRDispatchTimer Implementation

@implementation CHRDispatchTimer
@synthesize invocations = _invocations;

- (void)dealloc
{
    [self cancel];
}

#pragma mark Creating a Dispatch Timer

- (instancetype)initWithInterval:(NSTimeInterval)interval
                  executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock
{
    NSString *executionQueueName = [NSString stringWithFormat:@"%@.%p", CHRDispatchTimerExecutionQueueNamePrefix, self];
    dispatch_queue_t executionQueue = dispatch_queue_create([executionQueueName UTF8String], DISPATCH_QUEUE_SERIAL);
    return [self initWithInterval:interval
                   executionBlock:executionBlock
                   executionQueue:executionQueue];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval
                  executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock
                  executionQueue:(dispatch_queue_t)executionQueue
{
    return [self initWithInterval:interval
                   executionBlock:executionBlock
                   executionQueue:executionQueue
                     failureBlock:nil];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval
                  executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock
                  executionQueue:(dispatch_queue_t)executionQueue
                    failureBlock:(CHRDispatchTimerInitFailureBlock)failureBlock
{
    if (self = [super init]) {
        _executionQueue = executionQueue;
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _executionQueue);
        if (!_timer) {
            if (failureBlock) {
                failureBlock();
            } else {
                NSLog(@"%@", @"Failed to create dispatch source for timer.");
            }
            return nil;
        }
        _valid = VALID;
        _interval = interval;
        _executionBlock = [executionBlock copy];
        __weak CHRDispatchTimer *weak = self;
        dispatch_source_set_event_handler(_timer, ^{
            _executionBlock(weak, _invocations);
            ++_invocations;
        });
    }
    return self;
}

+ (CHRDispatchTimer *)timerWithInterval:(NSTimeInterval)interval
                         executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock
{
    return [[CHRDispatchTimer alloc]initWithInterval:interval
                                      executionBlock:executionBlock];
}

+ (CHRDispatchTimer *)timerWithInterval:(NSTimeInterval)interval
                         executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock
                         executionQueue:(dispatch_queue_t)executionQueue
{
    return [[CHRDispatchTimer alloc]initWithInterval:interval
                                      executionBlock:executionBlock
                                      executionQueue:executionQueue];
}

+ (CHRDispatchTimer *)timerWithInterval:(NSTimeInterval)interval
                         executionBlock:(CHRDispatchTimerExecutionBlock)executionBlock
                         executionQueue:(dispatch_queue_t)executionQueue
                           failureBlock:(CHRDispatchTimerInitFailureBlock)failureBlock
{
    return [[CHRDispatchTimer alloc]initWithInterval:interval
                                      executionBlock:executionBlock
                                      executionQueue:executionQueue
                                        failureBlock:failureBlock];
}

#pragma mark Using a Dispatch Timer

- (void)start:(BOOL)now 
{
    [self validate];
    
    if (OSAtomicCompareAndSwap32Barrier(STOPPED, RUNNING, &_running)) {
        dispatch_source_set_timer(_timer, startTime(_interval, now), _interval * NSEC_PER_SEC, leeway(_interval));
        dispatch_resume(_timer);
    }
}

- (void)pause
{
    [self validate];
    
    if (OSAtomicCompareAndSwap32Barrier(RUNNING, STOPPED, &_running)) {
        dispatch_suspend(_timer);
    }
}

- (void)cancel
{
    if (OSAtomicCompareAndSwap32Barrier(VALID, INVALID, &_valid)) {
        _running = STOPPED;
        dispatch_source_cancel(_timer);
    }
}

- (void)validate
{
    if (!_valid) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Attempting to use invalid CHRDispatchTimer"
                                     userInfo:nil];
    }
}

#pragma mark Getters

- (BOOL)isRunning
{
    return (_running & RUNNING);
}

- (BOOL)isValid
{
    return (_valid & VALID);
}

@end
