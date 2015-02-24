//
//  AppDelegate.m
//  DejalIntervalPicker Demo
//
//  Created by David Sinclair on 2012-03-24.
//  Copyright (c) 2012-2015 Dejal Systems, LLC. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // A demo of programmatically changing the picker setup:
    self.intervalPicker1.includeForever = YES;
    self.intervalPicker1.includeNever = YES;
    self.intervalPicker1.maximumAmount = 99;
    self.intervalPicker1.interval = [DejalInterval intervalWithAmount:75 units:DejalIntervalUnitsSecond];
    
    // Make into a range:
    [self.intervalPicker2 setupForLongTerm];
    self.intervalPicker2.usingRange = YES;
    [self.intervalPicker2 setRangeFiltering:DejalIntervalPickerFirstLessThanSecond];
    self.intervalPicker2.minimumAmount = 10;
    self.intervalPicker2.maximumAmount = 99;
    
    // Can set the amounts and units via individual properties:
    self.intervalPicker2.firstAmount = 10;
    self.intervalPicker2.secondAmount = 50;
    self.intervalPicker2.units = DejalIntervalUnitsMonth;
    
    // Or as a interval object:
    self.intervalPicker2.interval = [DejalInterval intervalWithRangeFirstAmount:10 secondAmount:50 units:DejalIntervalUnitsMonth];
    
    // Make the second picker and the following field disabled:
    self.intervalPicker2.enabled = NO;
    self.textField2.enabled = NO;
    
    // Use small and mini controls:
    self.smallIntervalPicker.controlSize = NSSmallControlSize;
    self.miniIntervalPicker.controlSize = NSMiniControlSize;
    
    // Populate from the user defaults, using the view identifiers (as set in IB):
    [self preparePicker:self.intervalPicker1];
    [self preparePicker:self.intervalPicker2];
    [self preparePicker:self.rangeIntervalPicker];
    [self preparePicker:self.smallIntervalPicker];
    [self preparePicker:self.miniIntervalPicker];
}

- (void)preparePicker:(DejalIntervalPicker *)picker;
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:picker.identifier];
    
    if (dict)
    {
        DejalInterval *interval = [DejalInterval objectWithDictionary:dict];
        
        if (interval)
        {
            picker.interval = interval;
        }
    }
}

- (IBAction)intervalPickerChanged:(id)sender;
{
    DejalIntervalPicker *picker = sender;
    DejalInterval *interval = picker.interval;
    
    NSLog(@"Interval picker %@: %@", picker, interval);  // log
    
    [[NSUserDefaults standardUserDefaults] setObject:interval.dictionary forKey:picker.identifier];
}

@end

