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
#import "CHRTimerInternal.h"


#pragma mark - Constants and Functions

static NSString * const CHRDispatchTimerExecutionQueueNamePrefix = @"com.chronus.CHRDispatchTimer";


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
@synthesize executionQueue  = _executionQueue;
@synthesize executionBlock  = _executionBlock;

- (void)dealloc
{
    [self cancel];
}

#pragma mark Creating a Dispatch Timer

- (instancetype)initWithInterval:(NSTimeInterval)interval
                  executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
{
    NSString *executionQueueName = [NSString stringWithFormat:@"%@.%p", CHRDispatchTimerExecutionQueueNamePrefix, self];
    dispatch_queue_t executionQueue = dispatch_queue_create([executionQueueName UTF8String], DISPATCH_QUEUE_SERIAL);
    return [self initWithInterval:interval
                   executionBlock:executionBlock
                   executionQueue:executionQueue];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval
                  executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                  executionQueue:(dispatch_queue_t)executionQueue
{
    return [self initWithInterval:interval
                   executionBlock:executionBlock
                   executionQueue:executionQueue
                     failureBlock:nil];
}

- (instancetype)initWithInterval:(NSTimeInterval)interval
                  executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                  executionQueue:(dispatch_queue_t)executionQueue
                    failureBlock:(CHRTimerInitFailureBlock)failureBlock
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
        _valid = CHRTimerStateValid;
        _interval = interval;
        _executionBlock = [executionBlock copy];
        __weak CHRDispatchTimer *weak = self;
        dispatch_source_set_event_handler(_timer, ^{
            CHRDispatchTimer *strong = weak;
            if (strong) {
                strong.executionBlock(weak, strong->_invocations++);
            }
        });
    }
    return self;
}

+ (CHRDispatchTimer *)timerWithInterval:(NSTimeInterval)interval
                         executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
{
    return [[CHRDispatchTimer alloc]initWithInterval:interval
                                      executionBlock:executionBlock];
}

+ (CHRDispatchTimer *)timerWithInterval:(NSTimeInterval)interval
                         executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                         executionQueue:(dispatch_queue_t)executionQueue
{
    return [[CHRDispatchTimer alloc]initWithInterval:interval
                                      executionBlock:executionBlock
                                      executionQueue:executionQueue];
}

+ (CHRDispatchTimer *)timerWithInterval:(NSTimeInterval)interval
                         executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                         executionQueue:(dispatch_queue_t)executionQueue
                           failureBlock:(CHRTimerInitFailureBlock)failureBlock
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
    
    if (OSAtomicCompareAndSwap32Barrier(CHRTimerStateStopped, CHRTimerStateRunning, &_running)) {
        dispatch_source_set_timer(_timer, chr_startTime(_interval, now), _interval * NSEC_PER_SEC, chr_leeway(_interval));
        dispatch_resume(_timer);
    }
}

- (void)pause
{
    [self validate];
    
    if (OSAtomicCompareAndSwap32Barrier(CHRTimerStateRunning, CHRTimerStateStopped, &_running)) {
        dispatch_suspend(_timer);
    }
}

- (void)cancel
{
    if (OSAtomicCompareAndSwap32Barrier(CHRTimerStateValid, CHRTimerStateInvalid, &_valid)) {
        if (_running == CHRTimerStateStopped) {
            dispatch_resume(_timer);
        }
        _running = CHRTimerStateStopped;
        dispatch_source_cancel(_timer);
    }
}

- (void)validate
{
    if (_valid != CHRTimerStateValid) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Attempting to use invalid CHRDispatchTimer."
                                     userInfo:nil];
    }
}

#pragma mark Getters

- (BOOL)isRunning
{
    return _running == CHRTimerStateRunning;
}

- (BOOL)isValid
{
    return _valid == CHRTimerStateValid;
}

- (NSUInteger)invocations
{
    return _invocations;
}

@end
