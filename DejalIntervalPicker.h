//
//  DejalIntervalPicker.h
//  Dejal Open Source
//
//  Created by David Sinclair on 2008-07-11.
//  Copyright (c) 2008-2015 Dejal Systems, LLC. All rights reserved.
//
//  This is a custom control for OS X to chose a time interval or range, similar to
//  a date picker.  It supports tabbing between values, incrementing or decrementing
//  them via up/down or +/- keys, type-selection, and a popup menu for each value,
//  among other features.  See the README for more information.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


// Dependency: this class requires DejalInterval, part of the DejalObject open source project:
#import "DejalInterval.h"


typedef NS_ENUM(NSInteger, DejalIntervalPickerRangeFiltering)
{
    DejalIntervalPickerAnyRange = 0,
    DejalIntervalPickerFirstLessThanSecond = 1,
    DejalIntervalPickerFirstLessOrEqualToSecond = 2,
    DejalIntervalPickerFirstGreaterOrEqualToSecond = 3,
    DejalIntervalPickerFirstGreaterThanSecond = 4
};


IB_DESIGNABLE
@interface DejalIntervalPicker : NSControl <NSSecureCoding>

@property (nonatomic, copy) DejalInterval *interval;
@property (nonatomic) IBInspectable CGFloat firstAmount;
@property (nonatomic) IBInspectable CGFloat secondAmount;
@property (nonatomic) CGFloat amount;
@property (nonatomic) DejalIntervalUnits units;
@property (nonatomic) IBInspectable NSInteger unitsAsInteger;
@property (nonatomic, readonly) NSTimeInterval firstTimeInterval;
@property (nonatomic, readonly) NSTimeInterval secondTimeInterval;
@property (nonatomic, readonly) NSTimeInterval amountTimeInterval;
@property (nonatomic) IBInspectable BOOL usingRange;
@property (nonatomic) DejalIntervalPickerRangeFiltering rangeFiltering;
@property (nonatomic) IBInspectable CGFloat minimumAmount;
@property (nonatomic) IBInspectable CGFloat maximumAmount;
@property (nonatomic) IBInspectable BOOL includeSeconds;
@property (nonatomic) IBInspectable BOOL includeMinutes;
@property (nonatomic) IBInspectable BOOL includeHours;
@property (nonatomic) IBInspectable BOOL includeDays;
@property (nonatomic) IBInspectable BOOL includeWeeks;
@property (nonatomic) IBInspectable BOOL includeMonths;
@property (nonatomic) IBInspectable BOOL includeQuarters;
@property (nonatomic) IBInspectable BOOL includeYears;
@property (nonatomic) IBInspectable BOOL includeForever;
@property (nonatomic) IBInspectable BOOL includeNever;

// Provided by the NSControl superclass, but provided here to make inspectable:
@property (getter=isEnabled) IBInspectable BOOL enabled;

- (void)setupForShortTerm;
- (void)setupForLongTerm;
- (void)setupForAllUnits;

- (void)becomeFirstResponderInDirection:(NSSelectionDirection)selectionDirection;

@end

