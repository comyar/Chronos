//
//  CHRDispatchTimerTests.m
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
#import "CHRDispatchTimer.h"


#pragma mark - Constants and Functions

static NSTimeInterval DefaultAsyncTestTimeout = 10.0;
static inline dispatch_time_t timeout(NSTimeInterval seconds) {
    return dispatch_time(DISPATCH_TIME_NOW, (int64_t) seconds * NSEC_PER_SEC);
}


#pragma mark - CHRDispatchTimerTests Interface

@interface CHRDispatchTimerTests : XCTestCase

@end


#pragma mark - CHRDispatchTimerTests Implementation

@implementation CHRDispatchTimerTests

- (void)testTimerFireOnce
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CHRDispatchTimer *timer = [[CHRDispatchTimer alloc]initWithInterval:0.5
                                                         executionBlock:^(CHRDispatchTimer *__weak timer, NSUInteger invocation) {
                                                             XCTAssertEqual(0, invocation);
                                                             dispatch_semaphore_signal(semaphore);
                                                         }];
    [timer start:YES];
    dispatch_semaphore_wait(semaphore, timeout(DefaultAsyncTestTimeout));
    XCTAssertTrue(timer.isRunning);
    
    [timer cancel];
    
    XCTAssertFalse(timer.isValid);
    XCTAssertFalse(timer.isRunning);
}

- (void)testTimerSingleUse
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CHRDispatchTimer *timer = [[CHRDispatchTimer alloc]initWithInterval:0.5
                                                         executionBlock:^(CHRDispatchTimer *__weak timer, NSUInteger invocation) {
                                                             dispatch_semaphore_signal(semaphore);
                                                         }];
    [timer start:YES];
    dispatch_semaphore_wait(semaphore, timeout(DefaultAsyncTestTimeout));
    
    [timer cancel];
    
    XCTAssertThrowsSpecific([timer pause], NSException);
    XCTAssertThrowsSpecific([timer start:YES], NSException);
}

- (void)testTimerPauseAndStart
{
    __block NSUInteger lastInvocation = 0;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CHRDispatchTimer *timer = [[CHRDispatchTimer alloc]initWithInterval:0.5
                                                         executionBlock:^(CHRDispatchTimer *__weak timer, NSUInteger invocation) {
                                                             lastInvocation = invocation;
                                                             dispatch_semaphore_signal(semaphore);
                                                         }];
    [timer start:YES];
    dispatch_semaphore_wait(semaphore, timeout(DefaultAsyncTestTimeout));
    XCTAssertTrue(timer.isRunning);
    
    [timer pause];
    
    XCTAssertFalse(timer.isRunning);
    XCTAssertEqual(0, lastInvocation);
    [timer start:YES];
    
    dispatch_semaphore_wait(semaphore, timeout(DefaultAsyncTestTimeout));
    
    XCTAssertTrue(timer.isRunning);
    XCTAssertEqual(1, lastInvocation);
    
    [timer pause];
    [timer cancel];
}

- (void)testTimerCancelBeforeStart
{
    CHRDispatchTimer *timer = [[CHRDispatchTimer alloc]initWithInterval:0.5
                                                         executionBlock:^(CHRDispatchTimer *__weak timer, NSUInteger invocation) {
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
    CHRDispatchTimer *timer = [[CHRDispatchTimer alloc]initWithInterval:0.5
                                                         executionBlock:^(CHRDispatchTimer *__weak timer, NSUInteger invocation) {
                                                             dispatch_semaphore_signal(semaphore);
                                                         }];
    [timer pause];
    
    XCTAssertFalse(timer.isRunning);
    XCTAssertTrue(timer.isValid);
    
    [timer start:YES];
    
    XCTAssertTrue(timer.isRunning);
    XCTAssertTrue(timer.isValid);
    
    dispatch_semaphore_wait(semaphore, timeout(DefaultAsyncTestTimeout));
    
    [timer cancel];
}

@end
