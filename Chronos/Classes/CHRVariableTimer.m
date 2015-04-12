//
//  CHRVariableTimer.m
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

#import "CHRVariableTimer.h"
#import "CHRTimerInternal.h"


#pragma mark - Constants and Functions

static NSString * const CHRVariableTimerExecutionQueueNamePrefix = @"com.chronus.CHRVariableTimer";


#pragma mark CHRVariableTimer Class Extension

@interface CHRVariableTimer () {
    volatile int32_t    _running;
    volatile int32_t    _valid;
    volatile NSUInteger _invocations;
    volatile bool       _executionBlockDidScheduleTimer;
    volatile bool       _executing;
}

@property (readonly) dispatch_source_t timer;

@end


#pragma mark - CHRVariableTimer Implementation

@implementation CHRVariableTimer
@synthesize executionBlock = _executionBlock;
@synthesize executionQueue = _executionQueue;

- (void)dealloc
{
    [self cancel];
}

#pragma mark Creating a Variable Timer

- (instancetype)initWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                          executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
{
    NSString *executionQueueName = [NSString stringWithFormat:@"%@.%p", CHRVariableTimerExecutionQueueNamePrefix, self];
    dispatch_queue_t executionQueue = dispatch_queue_create([executionQueueName UTF8String], DISPATCH_QUEUE_SERIAL);
    return [self initWithIntervalProvider:intervalProvider
                           executionBlock:executionBlock
                           executionQueue:executionQueue];
}

- (instancetype)initWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                          executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                          executionQueue:(dispatch_queue_t)executionQueue
{
    return [self initWithIntervalProvider:intervalProvider
                           executionBlock:executionBlock
                           executionQueue:executionQueue
                             failureBlock:nil];
}

- (instancetype)initWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
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
        _executionBlock = [executionBlock copy];
        _intervalProvider = [intervalProvider copy];
        __weak CHRVariableTimer *weak = self;
        dispatch_source_set_event_handler(_timer, ^{
            CHRVariableTimer *strong = weak;
            if (strong) {
                NSUInteger executionInvocation = strong->_invocations++;
                strong->_executing = true;
                strong->_executionBlock(weak, executionInvocation);
                strong->_executing = false;
                if (!strong->_executionBlockDidScheduleTimer) {
                    [strong schedule];
                }
                strong->_executionBlockDidScheduleTimer = false;
            }
        });
    }
    return self;
}

+ (CHRVariableTimer *)timerWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                                 executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
{
    return [[CHRVariableTimer alloc]initWithIntervalProvider:intervalProvider
                                              executionBlock:executionBlock];
}

+ (CHRVariableTimer *)timerWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                                 executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                                 executionQueue:(dispatch_queue_t)executionQueue
{
    return [[CHRVariableTimer alloc]initWithIntervalProvider:intervalProvider
                                              executionBlock:executionBlock
                                              executionQueue:executionQueue];
}

+ (CHRVariableTimer *)timerWithIntervalProvider:(CHRVariableTimerIntervalProvider)intervalProvider
                                 executionBlock:(CHRRepeatingTimerExecutionBlock)executionBlock
                                 executionQueue:(dispatch_queue_t)executionQueue
                                   failureBlock:(CHRTimerInitFailureBlock)failureBlock
{
    return [[CHRVariableTimer alloc]initWithIntervalProvider:intervalProvider
                                              executionBlock:executionBlock
                                              executionQueue:executionQueue
                                                failureBlock:failureBlock];
}

#pragma mark Using a Timer

- (void)start:(BOOL)now
{
    [self validate];
    
    if (OSAtomicCompareAndSwap32Barrier(CHRTimerStateStopped, CHRTimerStateRunning, &_running)) {
        if (now) {
            dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, DISPATCH_TIME_FOREVER, chr_leeway(0.0));
        } else {
            [self schedule];
        }
        dispatch_resume(self.timer);
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

- (void)schedule
{
    if (self.isValid) {
        __weak CHRVariableTimer *weak = self;
        NSTimeInterval interval = self.intervalProvider(weak, _invocations);
        dispatch_source_set_timer(_timer, chr_startTime(interval, NO), interval * NSEC_PER_SEC, chr_leeway(interval));
        _executionBlockDidScheduleTimer = (_executing) ? true : false;
    }
}

- (void)validate
{
    if (!self.isValid) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Attempting to use invalid CHRVariableTimer."
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
