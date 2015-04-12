//
//  CHRRepeatingTimer.h
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

#import "CHRTimer.h"


#pragma mark - Forward Declarations

@protocol CHRRepeatingTimer;


#pragma mark - Type Definitions

/**
 The block to execute every time the timer is fired.
 
 @param     timer
            The timer that fired.
 @param     invocation
            The current invocation number. The first invocation is 0.
 */
typedef void (^CHRRepeatingTimerExecutionBlock)(__weak id<CHRRepeatingTimer> timer, NSUInteger invocation);


#pragma mark - CHRRepeatingTimer Protocol

/**
 The CHRRepeatingTimer protocol defines methods and properties for a timer that
 repeatedly executes after a constant or variable time interval.
 */
@protocol CHRRepeatingTimer <CHRTimer>

@end
