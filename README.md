## DEPRECATED IN FAVOR OF [Chronos-Swift](https://github.com/comyarzaheri/Chronos-Swift)

![](header.png)

# Overview
[![Build Status](https://travis-ci.org/comyarzaheri/Chronos.svg)](https://travis-ci.org/comyarzaheri/Chronos)
[![Version](http://img.shields.io/cocoapods/v/Chronos.svg)](http://cocoapods.org/?q=Chronos)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Olympus-Library/Chronos)
[![Platform](http://img.shields.io/cocoapods/p/Chronos.svg)]()
[![License](http://img.shields.io/cocoapods/l/Chronos.svg)](https://github.com/Olympus-Library/Chronos/blob/master/LICENSE)

Chronos is a collection of useful Grand Central Dispatch utilities. If you have any specific requests or ideas for new utilities, don't hesitate to create a new issue.

## Utilities

* **DispatchTimer** - A repeating timer that fires according to a static interval, e.g. "Fire every 5 seconds".
* **VariableTimer** - A repeating timer that allows you to vary the interval between firings, e.g. "Fire according to the function `interval = 2 * count`." 

# Usage 

### Quick Start

##### CocoaPods

Add the following to your Podfile:

```ruby
pod 'Chronos'
```
##### Carthage 

Add the following to your Cartfile:

```ruby
github "comyarzaheri/Chronos" "master"
```

### Using a Dispatch Timer

```objective-c
#import <Chronos/Chronos.h>

/** Create and start a timer */
CHRDispatchTimer timer = [CHRDispatchTimer timerWithInterval:1.0 
                                              executionBlock:^(CHRDispatchTimer *__weak timer, NSUInteger invocation) {
  NSLog(@"%@", @"Execute repeating task here");
}];
[timer start:YES]; // Fire timer immediately

/** Pausing the timer */
[timer pause];

/** Permanently canceling the timer */
[timer cancel];

```

### Using a Variable Timer

```objective-c
#import <Chronos/Chronos.h>

/** Create and start a timer */
CHRVariableTimer *timer = [CHRVariableTimer timerWithIntervalProvider:^NSTimeInterval(CHRVariableTimer *__weak timer, NSUInteger nextInvocation) {
    return 2 * count; // Return interval according to function
} executionBlock:^(__weak id<CHRRepeatingTimer> timer, NSUInteger invocation) {
    NSLog(@"Execute repeating task here");
}];
[timer start:YES]; // Fire timer immediately

/** Pausing the timer */
[timer pause];

/** Permanently canceling the timer */
[timer cancel];
```

# Requirements

* iOS 7.0 or higher
* OS X 10.9 or higher

# License 

Chronos is available under the [MIT License](LICENSE).

# Contributors

* [@comyarzaheri](https://github.com/comyarzaheri)
* [@schun93](https://github.com/schun93)
