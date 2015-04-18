//
//  CHRTimerInternal.h
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


#ifndef Chronos_CHRTimerInterval
#define Chronos_CHRTimerInterval


#pragma mark - Type Definitions

typedef NS_ENUM(int32_t, CHRTimerState) {
    CHRTimerStateStopped    = 0,
    CHRTimerStateRunning    = 1,
    CHRTimerStateValid      = 2,
    CHRTimerStateInvalid    = 3
};


#pragma mark - Constants and Functions

/**
 Computes the leeway for the given interval. Currently set to 5% of the total
 interval time.
 */
static inline uint64_t chr_leeway(NSTimeInterval interval) {
    return 0.05 * interval * NSEC_PER_SEC;
}

/**
 Computes the start time of the timer, given the interval and whether the timer
 should start immediately.
 */
static inline dispatch_time_t chr_startTime(NSTimeInterval interval, BOOL now) {
    return dispatch_time(DISPATCH_TIME_NOW, (now)? 0 : interval * NSEC_PER_SEC);
}

#endif
