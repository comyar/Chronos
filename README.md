![](https://raw.githubusercontent.com/Olympus-Library/Resources/master/chronos-header.png)

# Overview
[![Build Status](https://travis-ci.org/Olympus-Library/Chronos.svg)](https://travis-ci.org/Olympus-Library/Chronos)
[![Version](http://img.shields.io/cocoapods/v/Chronos.svg)](http://cocoapods.org/?q=Chronos)
[![Platform](http://img.shields.io/cocoapods/p/Chronos.svg)]()
[![License](http://img.shields.io/cocoapods/l/Chronos.svg)](https://github.com/Olympus-Library/Chronos/blob/master/LICENSE)

Chronos is intended to be a collection of useful Grand Central Dispatch utilities. Currently Chronos only includes a timer utility, but the whole library is under active development. If you have any specific requests or ideas for new utilities, don't hesitate to create a new issue.

Chronos is part of a larger library for iOS and OS X called [Olympus](https://github.com/Olympus-Library), which is currently under active development.

# Usage 

### Quick Start

Chronos is available through Cocoa Pods. Add the following to your Podfile:

```ruby
pod 'Chronos'
```

###### Note: 

If you see the following error message:

> [!] Unable to find a specification for `Chronos`

Due to a bug in libgit2, your local copy of the Cocoapods Specs repository may need to be removed and re-cloned. More information on why and how to do this is available on the [Cocoapods blog](http://blog.cocoapods.org/Repairing-Our-Broken-Specs-Repository/).

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

# Requirements

* iOS 7.0 or higher
* OS X 10.9 or higher

# License 

Chronos is available under the [MIT License](LICENSE).

# Contributors

* [@comyarzaheri](https://github.com/comyarzaheri)
* [@schun93](https://github.com/schun93)
