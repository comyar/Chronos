//
//  CHRVariableTimerTests.m
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

@import XCTest;
#import "CHRTestInternal.h"
#import "CHRVariableTimer.h"


#pragma mark - CHRVariableTimerTests Interface

@interface CHRVariableTimerTests : XCTestCase

@end


#pragma mark - CHRVariableTimerTests Implementation

@implementation CHRVariableTimerTests

- (void)testTimerCancelBeforeStart
{
    CHRVariableTimer *timer = [CHRVariableTimer timerWithIntervalProvider:^NSTimeInterval(CHRVariableTimer *__weak timer, NSUInteger nextInvocation) {
        return 0.25;
    } executionBlock:^(__weak id<CHRRepeatingTimer> timer, NSUInteger invocation) {
        // nothing to do
    }];
    
    XCTAssertFalse(timer.isRunning);
    XCTAssertTrue(timer.isValid);
    
    [timer cancel];
    
    XCTAssertFalse(timer.isValid);
    
    XCTAssertThrowsSpecific([timer start:YES], NSException);
}

- (void)testTimerPauseBeforeStart
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CHRVariableTimer *timer = [CHRVariableTimer timerWithIntervalProvider:^NSTimeInterval(CHRVariableTimer *__weak timer, NSUInteger nextInvocation) {
        return 0.25;
    } executionBlock:^(__weak id<CHRRepeatingTimer> timer, NSUInteger invocation) {
        dispatch_semaphore_signal(semaphore);
    }];
    [timer pause];
    
    XCTAssertFalse(timer.isRunning);
    XCTAssertTrue(timer.isValid);
    
    [timer start:YES];
    
    XCTAssertTrue(timer.isRunning);
    XCTAssertTrue(timer.isValid);
    
    dispatch_semaphore_wait(semaphore, chr_timeout(CHRDefaultAsyncTestTimeout));
    
    [timer cancel];
}


- (void)testStartPauseInsideStartInside
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableArray *executedInvocations = @[].mutableCopy;
    NSMutableArray *intervalInvocations = @[].mutableCopy;
    
    CHRVariableTimer *timer = [CHRVariableTimer timerWithIntervalProvider:^NSTimeInterval(CHRVariableTimer *__weak timer, NSUInteger nextInvocation) {
        [intervalInvocations addObject:@(nextInvocation)];
        return 0.25;
    } executionBlock:^(__weak id<CHRRepeatingTimer> timer, NSUInteger invocation) {
        XCTAssertEqual(invocation + 1, timer.invocations);
        [executedInvocations addObject:@(invocation)];
        if (invocation == 0) {
            [timer pause];
            [timer start:NO];
        } else if (invocation == 3) {
            [timer cancel];
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    [timer start:NO];
    
    dispatch_semaphore_wait(semaphore, chr_timeout(CHRDefaultAsyncTestTimeout));
    
    XCTAssertEqual(4, timer.invocations);
    
    NSArray *expectedExecutedInvocations = @[@(0), @(1), @(2), @(3)];
    NSArray *expectedIntervalInvocations = @[@(0), @(1), @(2), @(3)];
    XCTAssertEqualObjects(expectedExecutedInvocations, executedInvocations);
    XCTAssertEqualObjects(expectedIntervalInvocations, intervalInvocations);
}

- (void)testStartPauseInsideStartNowInside
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableArray *executedInvocations = @[].mutableCopy;
    NSMutableArray *intervalInvocations = @[].mutableCopy;
    
    CHRVariableTimer *timer = [CHRVariableTimer timerWithIntervalProvider:^NSTimeInterval(CHRVariableTimer *__weak timer, NSUInteger nextInvocation) {
        [intervalInvocations addObject:@(nextInvocation)];
        return 0.25;
    } executionBlock:^(__weak id<CHRRepeatingTimer> timer, NSUInteger invocation) {
        XCTAssertEqual(invocation + 1, timer.invocations);
        [executedInvocations addObject:@(invocation)];
        if (invocation == 0) {
            [timer pause];
            [timer start:YES];
        } else if (invocation == 3) {
            [timer cancel];
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    [timer start:NO];
    
    dispatch_semaphore_wait(semaphore, chr_timeout(CHRDefaultAsyncTestTimeout));
    
    XCTAssertEqual(4, timer.invocations);
    
    NSArray *expectedExecutedInvocations = @[@(0), @(1), @(2), @(3)];
    NSArray *expectedIntervalInvocations = @[@(0), @(2), @(3)];
    XCTAssertEqualObjects(expectedExecutedInvocations, executedInvocations);
    XCTAssertEqualObjects(expectedIntervalInvocations, intervalInvocations);
}

- (void)testStartNowPauseInsideStartNowInside
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableArray *executedInvocations = @[].mutableCopy;
    NSMutableArray *intervalInvocations = @[].mutableCopy;
    
    CHRVariableTimer *timer = [CHRVariableTimer timerWithIntervalProvider:^NSTimeInterval(CHRVariableTimer *__weak timer, NSUInteger nextInvocation) {
        [intervalInvocations addObject:@(nextInvocation)];
        return 0.25;
    } executionBlock:^(__weak id<CHRRepeatingTimer> timer, NSUInteger invocation) {
        XCTAssertEqual(invocation + 1, timer.invocations);
        [executedInvocations addObject:@(invocation)];
        if (invocation == 0) {
            [timer pause];
            [timer start:YES];
        } else if (invocation == 3) {
            [timer cancel];
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    [timer start:YES];
    
    dispatch_semaphore_wait(semaphore, chr_timeout(CHRDefaultAsyncTestTimeout));
    
    XCTAssertEqual(4, timer.invocations);
    
    NSArray *expectedExecutedInvocations = @[@(0), @(1), @(2), @(3)];
    NSArray *expectedIntervalInvocations = @[@(2), @(3)];
    XCTAssertEqualObjects(expectedExecutedInvocations, executedInvocations);
    XCTAssertEqualObjects(expectedIntervalInvocations, intervalInvocations);
}

@end
