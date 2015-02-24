//
//  AppDelegate.h
//  DejalIntervalPicker Demo
//
//  Created by David Sinclair on 2012-03-24.
//  Copyright (c) 2012-2015 Dejal Systems, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DejalIntervalPicker.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *textField1;
@property (assign) IBOutlet NSTextField *textField2;
@property (assign) IBOutlet NSTextField *textField3;
@property (assign) IBOutlet DejalIntervalPicker *intervalPicker1;
@property (assign) IBOutlet DejalIntervalPicker *intervalPicker2;
@property (assign) IBOutlet DejalIntervalPicker *rangeIntervalPicker;
@property (assign) IBOutlet DejalIntervalPicker *smallIntervalPicker;
@property (assign) IBOutlet DejalIntervalPicker *miniIntervalPicker;

- (IBAction)intervalPickerChanged:(id)sender;

@end

