//
//  DejalIntervalPicker.m
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

#import "DejalIntervalPicker.h"


@interface DejalIntervalPicker ()

@property (nonatomic, strong) NSTextFieldCell *firstAmountCell;
@property (nonatomic, strong) NSTextFieldCell *rangeSeparatorCell;
@property (nonatomic, strong) NSTextFieldCell *secondAmountCell;
@property (nonatomic, strong) NSTextFieldCell *unitsCell;
@property (nonatomic, strong) NSStepperCell *stepperCell;
@property (nonatomic, weak, readonly) NSTextFieldCell *leftmostCell;
@property (nonatomic, weak) NSTextFieldCell *selectedCell;
@property (nonatomic, weak) NSTextFieldCell *previouslySelectedCell;
@property (nonatomic, strong) NSMutableArray *includedUnitsMapping;
@property (nonatomic) CGFloat currentValue;
@property (nonatomic) NSRect pickerFrame;
@property (nonatomic) NSRect focusRingBounds;
@property (nonatomic) NSRect firstAmountFrame;
@property (nonatomic) NSRect rangeSeparatorFrame;
@property (nonatomic) NSRect secondAmountFrame;
@property (nonatomic) NSRect unitsFrame;
@property (nonatomic) NSRect stepperFrame;
@property (nonatomic) BOOL shouldAppendEdit;
@property (nonatomic, readonly) CGFloat currentMinimum;
@property (nonatomic, readonly) CGFloat currentMaximum;
@property (nonatomic, getter=isForeverOrNever, readonly) BOOL foreverOrNever;
@property (nonatomic, readonly, copy) NSArray *observedKeyPaths;
@property (nonatomic, readonly, copy) NSMenu *makeMenuForSelectedCell;
@property (nonatomic) BOOL ready;
@property (nonatomic) BOOL canAutoPopMenu;
@property (nonatomic) BOOL hasSetupObservers;
@property (nonatomic) NSControlSize privateControlSize;

@end


// ----------------------------------------------------------------------------------------
#pragma mark -
// ----------------------------------------------------------------------------------------


@implementation DejalIntervalPicker

@dynamic enabled;

/**
 Exposes the available bindings.
 
 @author DJS 2008-07.
 */

+ (void)initialize;
{
    [super initialize];
    
    [self exposeBinding:@"firstAmount"];
    [self exposeBinding:@"secondAmount"];
    [self exposeBinding:@"amount"];
    [self exposeBinding:@"units"];
    [self exposeBinding:@"timeInterval"];
}

/**
 Designated initializer.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Added canAutoPopMenu & ready.
 */

- (instancetype)initWithFrame:(NSRect)frameRect;
{
    if ((self = [super initWithFrame:frameRect]))
    {
        self.interval = [DejalInterval intervalWithAmount:1.0 units:DejalIntervalUnitsMinute];
        self.rangeFiltering = DejalIntervalPickerFirstLessThanSecond;
        self.minimumAmount = 0;
        self.maximumAmount = 999;
        self.includeSeconds = YES;
        self.includeMinutes = YES;
        self.includeHours = YES;
        self.includeDays = YES;
        self.includeWeeks = YES;
        self.includeMonths = YES;
        self.includeQuarters = NO;
        self.includeYears = YES;
        self.includeForever = NO;
        self.includeNever = NO;
        
        self.canAutoPopMenu = YES;
        
        [self performSelector:@selector(markReady) withObject:nil afterDelay:0.001];
    }
    
    return self;
}

/**
 Coding initializer.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Added canAutoPopMenu & ready.
 */

- (instancetype)initWithCoder:(NSCoder *)coder;
{
    self = [super initWithCoder:coder];
    
    if ([coder allowsKeyedCoding])
    {
        if ([coder decodeBoolForKey:@"usingRange"])
        {
            self.interval = [DejalInterval intervalWithRangeFirstAmount:[coder decodeFloatForKey:@"firstAmount"] secondAmount:[coder decodeFloatForKey:@"secondAmount"] units:[coder decodeIntegerForKey:@"units"]];
        }
        else
        {
            self.interval = [DejalInterval intervalWithAmount:[coder decodeFloatForKey:@"secondAmount"] units:[coder decodeIntegerForKey:@"units"]];
        }
        
        self.rangeFiltering = [coder decodeIntegerForKey:@"rangeFiltering"];
        self.minimumAmount = [coder decodeFloatForKey:@"minimumAmount"];
        self.maximumAmount = [coder decodeFloatForKey:@"maximumAmount"];
        self.includeSeconds = [coder decodeBoolForKey:@"includeSeconds"];
        self.includeMinutes = [coder decodeBoolForKey:@"includeMinutes"];
        self.includeHours = [coder decodeBoolForKey:@"includeHours"];
        self.includeDays = [coder decodeBoolForKey:@"includeDays"];
        self.includeWeeks = [coder decodeBoolForKey:@"includeWeeks"];
        self.includeMonths = [coder decodeBoolForKey:@"includeMonths"];
        self.includeQuarters = [coder decodeBoolForKey:@"includeQuarters"];
        self.includeYears = [coder decodeBoolForKey:@"includeYears"];
        self.includeForever = [coder decodeBoolForKey:@"includeForever"];
        self.includeNever = [coder decodeBoolForKey:@"includeNever"];
        
        self.canAutoPopMenu = YES;
        
        [self performSelector:@selector(markReady) withObject:nil afterDelay:0.001];
    }
    
    return self;
}

/**
 Coding support.
 
 @author DJS 2008-07.
 */

- (void)encodeWithCoder:(NSCoder *)coder;
{
    [super encodeWithCoder:coder];
    
    if ([coder allowsKeyedCoding])
    {
        [coder encodeBool:self.usingRange forKey:@"usingRange"];
        [coder encodeFloat:self.firstAmount forKey:@"firstAmount"];
        [coder encodeFloat:self.secondAmount forKey:@"secondAmount"];
        [coder encodeInteger:self.units forKey:@"units"];
        [coder encodeInteger:self.rangeFiltering forKey:@"rangeFiltering"];
        [coder encodeFloat:self.minimumAmount forKey:@"minimumAmount"];
        [coder encodeFloat:self.maximumAmount forKey:@"maximumAmount"];
        [coder encodeBool:self.includeSeconds forKey:@"includeSeconds"];
        [coder encodeBool:self.includeMinutes forKey:@"includeMinutes"];
        [coder encodeBool:self.includeHours forKey:@"includeHours"];
        [coder encodeBool:self.includeDays forKey:@"includeDays"];
        [coder encodeBool:self.includeWeeks forKey:@"includeWeeks"];
        [coder encodeBool:self.includeMonths forKey:@"includeMonths"];
        [coder encodeBool:self.includeQuarters forKey:@"includeQuarters"];
        [coder encodeBool:self.includeYears forKey:@"includeYears"];
        [coder encodeBool:self.includeForever forKey:@"includeForever"];
        [coder encodeBool:self.includeNever forKey:@"includeNever"];
    }
}

/**
 Secure coding is supported (there aren't any encoded objects).
 
 @author DJS 2015-02.
 */

+ (BOOL)supportsSecureCoding;
{
    return YES;
}

/**
 Removes observers and bindings.
 
 @author DJS 2008-07.
 */

- (void)cleanup;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeObservers];
    
    [self unbind:@"firstAmount"];
    [self unbind:@"secondAmount"];
    [self unbind:@"amount"];
    [self unbind:@"units"];
    [self unbind:@"timeInterval"];
}

/**
 Standard deallocator.
 
 @author DJS 2008-07.
 */

- (void)dealloc;
{
    [self cleanup];
    
    self.selectedCell = nil;
}

/**
 Prepare a text field cell.  In the future this should prepare a text field control instead, since cells will be going away eventually.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Changed the font from the label font to the control content font.
 */

- (NSTextFieldCell *)setupCellWithString:(NSString *)string isEditable:(BOOL)isEditable alignment:(NSTextAlignment)alignment;
{
    NSTextFieldCell *cell = [[NSTextFieldCell alloc] initTextCell:string];
    
    cell.drawsBackground = isEditable;
    cell.editable = isEditable;
    cell.bordered = NO;
    cell.controlSize = self.controlSize;
    cell.font = [NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:self.controlSize]];
    cell.alignment = alignment;
    
    return cell;
}

/**
 Prepares the stepper cell.
 
 @author DJS 2008-07.
 */

- (void)setupStepper;
{
    self.stepperCell = [NSStepperCell new];
    
    [self.stepperCell bind:@"value" toObject:self withKeyPath:@"currentValue" options:@{NSContinuouslyUpdatesValueBindingOption: @YES}];
    
    self.stepperCell.controlSize = self.controlSize;
    
    [self updateIncludedUnitsMapping];
}

/**
 Returns a string representation of an integer value.
 
 @author DJS 2008-07.
 */

- (NSString *)stringWithIntegerValue:(NSInteger)value;
{
    return [NSString stringWithFormat:@"%ld", (long)value];
}

/**
 Sets the control frame size and adjusts the cell frames accordingly.
 
 @author DJS 2008-07.
 */

- (void)setFrameSize:(NSSize)newSize;
{
    NSSize oldSize = self.frame.size;
    
    [super setFrameSize:newSize];
    
    [self setupCellFrames];
    
    if (newSize.width != oldSize.width)
    {
        [self sizeToFit];
    }
    
    [self updateCells];
}

/**
 Resizes the control to the optimal size for the contents, which is affected by the included units and ranges.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Added the intrinsic content size.
 */

- (void)sizeToFit;
{
    self.frameSize = self.intrinsicContentSize;
    self.needsDisplay = YES;
    [self invalidateIntrinsicContentSize];
}

/**
 Returns the optimal size for the contents, which is affected by the included units and ranges.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Renamed from idealSize to intrinsicContentSize (an Auto Layout method).
 */

- (NSSize)intrinsicContentSize;
{
    if (!self.stepperCell)
    {
        [self setupStepper];
    }
    
    NSSize size = [[self setupCellWithString:[self stringWithIntegerValue:self.maximumAmount] isEditable:YES alignment:NSRightTextAlignment] cellSize];
    
    if (self.usingRange)
    {
        size.width += [[self setupCellWithString:@"-" isEditable:YES alignment:NSCenterTextAlignment] cellSize].width + size.width;
    }
    
    size.width += [[self setupCellWithString:[DejalInterval intervalWithAmount:9.0 units:DejalIntervalUnitsSecond].fullUnitsName isEditable:YES alignment:NSLeftTextAlignment] cellSize].width;
    
    if (self.controlSize == NSMiniControlSize)
    {
        size.width += 2.0;
    }
    else if (self.controlSize == NSSmallControlSize)
    {
        size.width += 1.0;
    }
    
    size.width = floorf(size.width + [self.stepperCell cellSize].width + 3.0);
    size.height += 5.0;
    
    return size;
}

/**
 Prepares the cell frames based on the maximum values etc.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Tweaks to the sizing.
 */

- (void)setupCellFrames;
{
    NSRect baseFrame = self.bounds;
    NSRect frame = baseFrame;
    frame.size = [self.stepperCell cellSize];
    frame.origin.x = NSMaxX(baseFrame) - frame.size.width + 2.0;
    
    if (self.controlSize == NSMiniControlSize)
    {
        frame.origin.y += 1.0;
    }
    else
    {
        frame.origin.y -= 2.0;
    }
    
    self.stepperFrame = frame;
    
    frame = NSInsetRect(baseFrame, 2.0, 2.0);
    frame.size = [[self setupCellWithString:[self stringWithIntegerValue:self.maximumAmount] isEditable:YES alignment:NSRightTextAlignment] cellSize];
    
    if (self.controlSize == NSMiniControlSize)
    {
        frame.size.width += 1.0;
    }
    
    if (self.usingRange)
    {
        self.firstAmountFrame = frame;
        
        frame.origin.x += floorf(frame.size.width);
        frame.size = [[self setupCellWithString:@"-" isEditable:YES alignment:NSCenterTextAlignment] cellSize];
        
        self.rangeSeparatorFrame = frame;
        
        frame.origin.x += floorf(frame.size.width);
        frame.size = self.firstAmountFrame.size;
        
        if (self.controlSize == NSMiniControlSize)
        {
            frame.size.width += 1.0;
        }
    }
    
    self.secondAmountFrame = frame;
    
    frame.origin.x += floorf(frame.size.width);
    frame.size.width = (self.stepperFrame.origin.x - frame.origin.x) - 2.0;
    
    if (self.controlSize == NSMiniControlSize)
    {
        frame.size.width -= 1.0;
    }
    else if (self.controlSize == NSSmallControlSize)
    {
        frame.size.width -= 2.0;
    }
    
    self.unitsFrame = frame;
}

/**
 Makes the cells and adjusts their frames as appropriate.
 
 @author DJS 2008-07.
 */

- (void)setupCells;
{
    BOOL isResetting = (self.unitsCell != nil);
    
    [self sizeToFit];
    
    self.firstAmountCell = [self setupCellWithString:@"" isEditable:YES alignment:NSRightTextAlignment];
    self.rangeSeparatorCell = [self setupCellWithString:@"-" isEditable:YES alignment:NSCenterTextAlignment];
    self.secondAmountCell = [self setupCellWithString:@"" isEditable:YES alignment:NSRightTextAlignment];
    self.unitsCell = [self setupCellWithString:@"" isEditable:YES alignment:NSLeftTextAlignment];
    
    [self setupStepper];
    [self setupCellFrames];
    [self updateCells];
    
    if (isResetting)
    {
        [self removeObservers];
    }
    
    [self setupObservers];
}

/**
 Convenience method to set up the picker to include only Seconds, Minutes and Hours for the units.
 
 @author DJS 2008-07.
 */

- (void)setupForShortTerm;
{
    self.includeSeconds = YES;
    self.includeMinutes = YES;
    self.includeHours = YES;
    self.includeDays = NO;
    self.includeWeeks = NO;
    self.includeMonths = NO;
    self.includeQuarters = NO;
    self.includeYears = NO;
}

/**
 Convenience method to set up the picker to include only Days, Weeks, Months and Years for the units.
 
 @author DJS 2008-07.
 */

- (void)setupForLongTerm;
{
    self.includeSeconds = NO;
    self.includeMinutes = NO;
    self.includeHours = NO;
    self.includeDays = YES;
    self.includeWeeks = YES;
    self.includeMonths = YES;
    self.includeQuarters = NO;
    self.includeYears = YES;
}

/**
 Convenience method to set up the picker to include all common units.
 
 @author DJS 2008-07.
 */

- (void)setupForAllUnits;
{
    self.includeSeconds = YES;
    self.includeMinutes = YES;
    self.includeHours = YES;
    self.includeDays = YES;
    self.includeWeeks = YES;
    self.includeMonths = YES;
    self.includeQuarters = NO;
    self.includeYears = YES;
}

/**
 Sets the control to be enabled.
 
 @author DJS 2008-07.
 */

- (void)setEnabled:(BOOL)enabled;
{
    if (!enabled && self.currentEditor)
    {
        [self.selectedCell endEditing:self.currentEditor];
    }
    
    BOOL canEdit = !self.foreverOrNever;
    
    self.firstAmountCell.editable = canEdit;
    self.rangeSeparatorCell.editable = canEdit;
    self.secondAmountCell.editable = canEdit;
    
    self.firstAmountCell.enabled = enabled && canEdit;
    self.rangeSeparatorCell.enabled = enabled && canEdit;
    self.secondAmountCell.enabled = enabled && canEdit;
    self.unitsCell.enabled = enabled;
    self.stepperCell.enabled = enabled;
    
    [super setEnabled:enabled];
}

/**
 Updates the values of the cells.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Suspends auto-popping the menu to avoid doing so when just incrementing/decrementing values.
 */

- (void)updateCells;
{
    self.canAutoPopMenu = NO;
    
    if (self.currentEditor)
    {
        if (self.selectedCell == self.firstAmountCell)
        {
            self.currentEditor.string = [self stringWithIntegerValue:self.firstAmount];
        }
        else if (self.selectedCell == self.secondAmountCell)
        {
            self.currentEditor.string = [self stringWithIntegerValue:self.secondAmount];
        }
        else
        {
            self.currentEditor.string = self.interval.fullUnitsName;
        }
        
        [self.currentEditor selectAll:nil];
    }
    
    if (self.foreverOrNever)
    {
        self.firstAmountCell.stringValue = @"";
        self.secondAmountCell.stringValue = @"";
    }
    else
    {
        self.firstAmountCell.integerValue = self.firstAmount;
        self.secondAmountCell.integerValue = self.secondAmount;
    }
    
    if (self.interval)
    {
        self.unitsCell.stringValue = self.interval.fullUnitsName;
    }
    
    // Update the enabled state of the sub-cells:
    self.enabled = self.enabled;
    
    [self updateStepper];
    
    self.canAutoPopMenu = YES;
}

/**
 Updates the stepper cell.
 
 @author DJS 2008-07.
 */

- (void)updateStepper;
{
    self.stepperCell.minValue = self.currentMinimum;
    self.stepperCell.maxValue = self.currentMaximum;
    self.stepperCell.integerValue = self.currentValue;
    self.stepperCell.enabled = self.enabled;
}

/**
 Updates the internal mapping array based on the units that should be displayed.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Added IB designable support.
 */

- (void)updateIncludedUnitsMapping;
{
#if TARGET_INTERFACE_BUILDER
    if (!self.includeSeconds && !self.includeMinutes && !self.includeDays)
    {
        [self setupForAllUnits];
        self.enabled = YES;
    }
#endif
    
    self.includedUnitsMapping = [NSMutableArray array];
    
    if (self.includeSeconds)
    {
        [self.includedUnitsMapping addObject:@(DejalIntervalUnitsSecond)];
    }
    
    if (self.includeMinutes)
    {
        [self.includedUnitsMapping addObject:@(DejalIntervalUnitsMinute)];
    }
    
    if (self.includeHours)
    {
        [self.includedUnitsMapping addObject:@(DejalIntervalUnitsHour)];
    }
    
    if (self.includeDays)
    {
        [self.includedUnitsMapping addObject:@(DejalIntervalUnitsDay)];
    }
    
    if (self.includeWeeks)
    {
        [self.includedUnitsMapping addObject:@(DejalIntervalUnitsWeek)];
    }
    
    if (self.includeMonths)
    {
        [self.includedUnitsMapping addObject:@(DejalIntervalUnitsMonth)];
    }
    
    if (self.includeQuarters)
    {
        [self.includedUnitsMapping addObject:@(DejalIntervalUnitsQuarter)];
    }
    
    if (self.includeYears)
    {
        [self.includedUnitsMapping addObject:@(DejalIntervalUnitsYear)];
    }
    
    if (self.includeForever)
    {
        [self.includedUnitsMapping addObject:@(DejalIntervalUnitsForever)];
    }
    
    if (self.includeNever)
    {
        [self.includedUnitsMapping addObject:@(DejalIntervalUnitsNever)];
    }
    
    // Convert the units to the mapping index and back, to ensure it is a valid option:
    self.units = [self unitsForIncludedMappingIndex:[self includedMappingIndexForUnits:self.units]];
}

/**
 Returns the frame of the currently selected cell.
 
 @author DJS 2015-02.
 */

- (NSRect)selectedCellFrame;
{
    if (self.selectedCell == self.firstAmountCell)
    {
        return self.firstAmountFrame;
    }
    else if (self.selectedCell == self.secondAmountCell)
    {
        return self.secondAmountFrame;
    }
    else
    {
        return self.unitsFrame;
    }
}

/**
 Yawn.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Added Auto Layout content hugging.
 @version DJS 2015-04: Now sets the interval.
 */

- (void)awakeFromNib;
{
    [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
    
    self.interval = [DejalInterval intervalWithAmount:self.amount units:self.units];
    self.selectedCell = self.leftmostCell;
    self.previouslySelectedCell = self.leftmostCell;
    self.canAutoPopMenu = YES;
    
    [self updateStepper];
}

/**
 Marks the control as ready, to work around an issue when loading via state restoration.
 
 @author DJS 2015-02.
 */

- (void)markReady;
{
    self.ready = YES;
}


// ----------------------------------------------------------------------------------------
#pragma mark - ACCESSOR METHODS
// ----------------------------------------------------------------------------------------


/**
 Returns the DejalInterval object using the standard accessor.  Provided as a convenience.
 
 @author DJS 2008-07.
*/

- (id)objectValue;
{
    return self.interval;
}

/**
 Sets the DejalInterval object using the standard accessor.  Provided as a convenience.  Only sets the value if it is a DejalInterval (or subclass).
 
 @author DJS 2008-07.
*/

- (void)setObjectValue:(id <NSCopying>)object;
{
    if ([[(NSObject *)object class] isKindOfClass:[DejalInterval class]])
    {
        self.interval = (DejalInterval *)object;
    }
}

/**
 Returns a string representation of the DejalInterval value.  Provided as a convenience.  Note that it isn't possible to set the value via a string.
 
 @author DJS 2008-07.
*/

- (NSString *)stringValue;
{
    return self.interval.amountWithFullUnitsName;
}

/**
 This is not currently supported for DejalIntervalPicker.  Invoking this just logs a warning in the Console.
 
 @author DJS 2008-09.
*/

- (void)setStringValue:(NSString *)string;
{
    NSLog(@"-setStringValue: is not supported by DejalIntervalPicker (tried to set to %@)", string);
}

/**
 Returns YES if the picker is using a range, or NO if it represents a single interval.
 
 @author DJS 2008-07.
 */

- (BOOL)usingRange;
{
    return self.interval.usingRange;
}

/**
 Sets whether or not the picker is using an interval range.
 
 @author DJS 2008-07.
 */

- (void)setUsingRange:(BOOL)usingRange;
{
    self.interval.usingRange = usingRange;
}

/**
 Returns the first amount of a range.
 
 @author DJS 2008-07.
 */

- (CGFloat)firstAmount;
{
    return self.interval.firstAmount;
}

/**
 Sets the first amount of a range.
 
 @author DJS 2008-07.
 */

- (void)setFirstAmount:(CGFloat)firstAmount;
{
    self.interval.firstAmount = firstAmount;
}

/**
 Returns the second amount of a range.
 
 @author DJS 2008-07.
 */

- (CGFloat)secondAmount;
{
    return self.interval.secondAmount;
}

/**
 Sets the second amount of a range.
 
 @author DJS 2008-07.
 */

- (void)setSecondAmount:(CGFloat)secondAmount;
{
    self.interval.secondAmount = secondAmount;
}

/**
 Returns the the amount of the interval.
 
 @author DJS 2008-07.
 */

- (CGFloat)amount;
{
    return self.interval.amount;
}

/**
 Sets the amount of an interval.
 
 @author DJS 2008-07.
 */

- (void)setAmount:(CGFloat)amount;
{
    self.interval.amount = amount;
}

/**
 Returns the units of the interval.
 
 @author DJS 2008-07.
 */

- (DejalIntervalUnits)units;
{
    return self.interval.units;
}

/**
 Sets the units of the interval.
 
 @author DJS 2008-07.
 */

- (void)setUnits:(DejalIntervalUnits)units;
{
    self.interval.units = units;
}

/**
 Returns the units as an integer; only used for the IB inspector value.
 
 @author DJS 2008-07.
 */

- (NSInteger)unitsAsInteger;
{
    return self.units;
}

/**
 Sets the units as an integer; only used for the IB inspector value.
 
 @author DJS 2008-07.
 */

- (void)setUnitsAsInteger:(NSInteger)unitsAsInteger;
{
    self.units = unitsAsInteger;
}

/**
 Returns the first amount of the receiver represented as a time interval, i.e. in seconds or fractions thereof.
 
 @author DJS 2008-07.
*/

- (NSTimeInterval)firstTimeInterval;
{
    return self.interval.firstTimeInterval;
}

/**
 Returns the second amount of the receiver represented as a time interval, i.e. in seconds or fractions thereof.
 
 @author DJS 2008-07.
*/

- (NSTimeInterval)secondTimeInterval;
{
    return self.interval.secondTimeInterval;
}

/**
 Returns the receiver represented as a time interval, i.e. in seconds or fractions thereof.
 
 @author DJS 2008-07.
*/

- (NSTimeInterval)amountTimeInterval;
{
    return self.interval.amountTimeInterval;
}

/**
 Returns the units based on the internal mapping index.
 
 @author DJS 2008-07.
 */

- (DejalIntervalUnits)unitsForIncludedMappingIndex:(NSUInteger)mappingIndex;
{
    if (mappingIndex < [self.includedUnitsMapping count])
    {
        return [self.includedUnitsMapping[mappingIndex] integerValue];
    }
    else
    {
        return [self.includedUnitsMapping[0] integerValue];
    }
}

/**
 Returns the mapping index for the units.
 
 @author DJS 2008-07.
 */

- (NSUInteger)includedMappingIndexForUnits:(DejalIntervalUnits)units;
{
    NSUInteger mappingIndex = 0;
    DejalIntervalUnits mappedUnits = DejalIntervalUnitsNever;
    BOOL found = NO;
    
    while (!found && mappingIndex < [self.includedUnitsMapping count])
    {
        mappedUnits = [self.includedUnitsMapping[mappingIndex] integerValue];
        found = (mappedUnits == units);
        
        if (!found)
        {
            mappingIndex++;
        }
    }
    
    if (!found)
    {
        return 0;
    }
    else
    {
        return mappingIndex;
    }
}

/**
 Returns the minimum value for the currently selected cell.
 
 @author DJS 2008-07.
 */

- (CGFloat)currentMinimum;
{
    if (self.selectedCell == self.unitsCell)
    {
        return 0;
    }
    
    if (!self.usingRange || self.rangeFiltering == DejalIntervalPickerAnyRange)
    {
        return self.minimumAmount;
    }
    
    CGFloat minimum = self.minimumAmount;
    BOOL isFirstAmountSelected = (self.selectedCell == self.firstAmountCell);
    
    if (isFirstAmountSelected && self.rangeFiltering == DejalIntervalPickerFirstGreaterThanSecond)
    {
        minimum = self.secondAmount + 1;
    }
    else if (isFirstAmountSelected && self.rangeFiltering == DejalIntervalPickerFirstGreaterOrEqualToSecond)
    {
        minimum = self.secondAmount;
    }
    else if (!isFirstAmountSelected && self.rangeFiltering == DejalIntervalPickerFirstLessThanSecond)
    {
        minimum = self.firstAmount + 1;
    }
    else if (!isFirstAmountSelected && self.rangeFiltering == DejalIntervalPickerFirstLessOrEqualToSecond)
    {
        minimum = self.firstAmount;
    }
    
    return minimum;
}

/**
 Returns the maximum value for the currently selected cell.
 
 @author DJS 2008-07.
 */

- (CGFloat)currentMaximum;
{
    if (self.selectedCell == self.unitsCell)
    {
        return [self.includedUnitsMapping count] - 1;
    }
    
    if (!self.usingRange || self.rangeFiltering == DejalIntervalPickerAnyRange)
    {
        return self.maximumAmount;
    }
    
    CGFloat maximum = self.maximumAmount;
    BOOL isFirstAmountSelected = (self.selectedCell == self.firstAmountCell);
    
    if (isFirstAmountSelected && self.rangeFiltering == DejalIntervalPickerFirstLessThanSecond)
    {
        maximum = self.secondAmount - 1;
    }
    else if (isFirstAmountSelected && self.rangeFiltering == DejalIntervalPickerFirstLessOrEqualToSecond)
    {
        maximum = self.secondAmount;
    }
    else if (!isFirstAmountSelected && self.rangeFiltering == DejalIntervalPickerFirstGreaterThanSecond)
    {
        maximum = self.firstAmount - 1;
    }
    else if (!isFirstAmountSelected && self.rangeFiltering == DejalIntervalPickerFirstGreaterOrEqualToSecond)
    {
        maximum = self.firstAmount;
    }
    
    return maximum;
}

/**
 Returns the value of the currently selected cell.
 
 @author DJS 2008-07.
 */

- (CGFloat)currentValue;
{
    if (self.selectedCell == self.firstAmountCell)
    {
        return self.firstAmount;
    }
    else if (self.selectedCell == self.secondAmountCell)
    {
        return self.secondAmount;
    }
    else
    {
        return [self includedMappingIndexForUnits:self.units];
    }
}

/**
 Sets the value of the currently selected cell.
 
 @author DJS 2008-07.
 */

- (void)setCurrentValue:(CGFloat)value;
{
    if (self.selectedCell == self.firstAmountCell)
    {
        self.firstAmount = value;
    }
    else if (self.selectedCell == self.secondAmountCell)
    {
        self.secondAmount = value;
    }
    else
    {
        self.units = [self unitsForIncludedMappingIndex:value];
    }
    
    [self updateCells];
}

/**
 Returns the control size: one of NSRegularControlSize (the default), NSSmallControlSize, or NSMiniControlSize.
 
 @author DJS 2015-02.
 */

- (NSControlSize)controlSize;
{
    return self.privateControlSize;
}

/**
 Sets the control size.
 
 @author DJS 2015-02.
 */

- (void)setControlSize:(NSControlSize)controlSize;
{
    [super setControlSize:controlSize];
    
    // The control size doesn't actually change, so remember the correct value myself:
    self.privateControlSize = controlSize;
}

/**
 Returns the baseline offset for Auto Layout.  (Doesn't seem to be used?)
 
 @author DJS 2015-02.
 */

- (CGFloat)baselineOffsetFromBottom;
{
    return 5.0;
}

/**
 Returns the cell on the left of the control, which depends on whether or not the receiver has units of Forever or Never, or is using a range.
 
 @author DJS 2008-07.
 */

- (NSTextFieldCell *)leftmostCell;
{
    if (self.foreverOrNever)
    {
        return self.unitsCell;
    }
    else if (self.usingRange)
    {
        return self.firstAmountCell;
    }
    else
    {
        return self.secondAmountCell;
    }
}

/**
 Returns YES if the units are Forever or Never.
 
 @author DJS 2008-07.
 */

- (BOOL)isForeverOrNever;
{
    return self.units == DejalIntervalUnitsForever || self.units == DejalIntervalUnitsNever;
}


// ----------------------------------------------------------------------------------------
#pragma mark - BINDINGS METHODS
// ----------------------------------------------------------------------------------------


/**
 Returns the properties that are observed by KVO.
 
 @author DJS 2008-07.
 */

- (NSArray *)observedKeyPaths;
{
    return @[@"selectedCell", @"controlSize", @"interval", @"usingRange", @"firstAmount", @"secondAmount", @"amount", @"units", @"timeInterval", @"includeNever", @"includeSeconds", @"includeMinutes", @"includeHours", @"includeDays", @"includeWeeks", @"includeMonths", @"includeQuarters", @"includeYears", @"includeForever", @"minimumAmount", @"maximumAmount"];
}

/**
 Adds KVO observers for the desired properties.
 
 @author DJS 2008-07.
 @version DJS 2015-04: Added a flag to indicate if the observers have been set up.
 */

- (void)setupObservers;
{
    if (self.hasSetupObservers)
    {
        return;
    }
    
    self.hasSetupObservers = YES;
    
    for (NSString *keyPath in self.observedKeyPaths)
    {
        [self addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    }
}

/**
 Removes the KVO observers.
 
 @author DJS 2008-07.
 @version DJS 2015-04: Added a flag to indicate if the observers have been set up.
 */

- (void)removeObservers;
{
    if (!self.hasSetupObservers)
    {
        return;
    }
    
    for (NSString *keyPath in self.observedKeyPaths)
    {
        [self removeObserver:self forKeyPath:keyPath];
    }
    
    self.hasSetupObservers = NO;
}

/**
 Bindings support.
 
 @author DJS 2008-07.
 */

- (Class)valueClassForBinding:(NSString *)bindingName;
{
    return [NSNumber class];
}

/**
 KVO observer.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Tweaked the controlSize calls.
 @version DJS 2016-08: Added a delegate invocation.
 */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
{
    if ([keyPath isEqualToString:@"selectedCell"])
    {
        [self updateStepper];
        [self setNeedsDisplay:YES];
    }
    else if ([keyPath isEqualToString:@"usingRange"] || [keyPath isEqualToString:@"minimumAmount"] || [keyPath isEqualToString:@"maximumAmount"])
    {
        [self setupCellFrames];
        [self updateCells];
        [self setNeedsDisplay:YES];
    }
    else if ([keyPath isEqualToString:@"controlSize"])
    {
        [self setupCells];
        [self sizeToFit];
    }
    else
    {
        // Avoid infinite recursion, since -updateIncludedUnitsMapping sets the units property:
        if (![keyPath isEqualToString:@"units"])
        {
            [self updateIncludedUnitsMapping];
        }
        
        [self updateCells];
        [self sizeToFit];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(intervalPicker:intervalDidChange:)])
        {
            [self.delegate intervalPicker:self intervalDidChange:self.interval];
        }
    }
}


// ----------------------------------------------------------------------------------------
#pragma mark - DRAWING METHODS
// ----------------------------------------------------------------------------------------


/**
 Returns that this control is not opaque.
 
 @author DJS 2008-07.
 */

- (BOOL)isOpaque;
{
    return NO;
}

/**
 Draws the frame around the control.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Changed the border colors to fit with Yosemite controls.
 */

- (void)drawBorder;
{
    NSRect borderFrame = self.bounds;
    
    borderFrame.size.width -= [self.stepperCell cellSize].width - 1.0;
    
    if (self.controlSize == NSMiniControlSize)
    {
        borderFrame.size.width -= 1.0;
    }
    else if (self.controlSize == NSSmallControlSize)
    {
        borderFrame.size.width -= 2.0;
    }
    
    NSRectEdge sides[] = {NSMaxYEdge, NSMaxXEdge, NSMinXEdge, NSMinYEdge, NSMaxYEdge};
    CGFloat enabledGrays[] = {0.75, 0.75, 0.75, 0.75};
    CGFloat disabledGrays[] = {0.85, 0.85, 0.85, 0.85};
    
    if (self.enabled)
    {
        borderFrame = NSDrawTiledRects(borderFrame, borderFrame, sides, enabledGrays, 4);
    }
    else
    {
        borderFrame = NSDrawTiledRects(borderFrame, borderFrame, sides, disabledGrays, 4);
    }
 
    [[NSColor whiteColor] set];
    NSRectFill(borderFrame);
    
    NSRect focusBounds = borderFrame;
    
    focusBounds.origin.x -= 1.0;
    focusBounds.origin.y -= 1.0;
    focusBounds.size.width += 2.0;
    focusBounds.size.height += 3.0;
    
    self.focusRingBounds = focusBounds;
}

/**
 Draws the amount and units cells.
 
 @author DJS 2008-07.
 */

- (void)drawAmountAndUnitsCells;
{
    if (!self.foreverOrNever)
    {
        if (self.usingRange)
        {
            if (NSMaxX(self.firstAmountFrame) < NSMinX(self.stepperFrame))
            {
                [self.firstAmountCell drawWithFrame:self.firstAmountFrame inView:self];
            }
            
            if (NSMaxX(self.rangeSeparatorFrame) < NSMinX(self.stepperFrame))
            {
                [self.rangeSeparatorCell drawWithFrame:self.rangeSeparatorFrame inView:self];
            }
        }
        
        if (NSMaxX(self.secondAmountFrame) < NSMinX(self.stepperFrame))
        {
            [self.secondAmountCell drawWithFrame:self.secondAmountFrame inView:self];
        }
    }
    
    if (NSMinX(self.unitsFrame) < NSMinX(self.stepperFrame))
    {
       [self.unitsCell drawWithFrame:self.unitsFrame inView:self];
    }
}

/**
 Draws the stepper cell.
 
 @author DJS 2008-07.
 */

- (void)drawStepperCell;
{
    [self.stepperCell drawWithFrame:self.stepperFrame inView:self];
}

/**
 Draws the cells and border of the receiver.
 
 @author DJS 2008-07.
 */

- (void)drawRect:(NSRect)dirtyRect;
{
    // Lazily set up the first time this is drawn:
    if (!self.unitsCell)
    {
        [self setupCells];
    }
    
    [self drawBorder];
    [self drawAmountAndUnitsCells];
    [self drawStepperCell];
}


// ----------------------------------------------------------------------------------------
#pragma mark - EVENT METHODS
// ----------------------------------------------------------------------------------------


/**
 Handles mouse tracking to select the appropriate cell.
 
 @author DJS 2008-07.
 */

- (BOOL)trackMouse:(NSEvent *)theEvent withLocation:(NSPoint)locationInControlFrame forRightEdge:(CGFloat)rightEdge ofTextFieldCell:(NSTextFieldCell *)cell;
{
    if (locationInControlFrame.x > rightEdge)
    {
        return NO;
    }
    
    [self editCell:cell];
    
    return YES;
}

/**
 Handles mouse tracking in the stepper cell.
 
 @author DJS 2008-07.
 */

- (void)trackMouseInStepper:(NSEvent *)theEvent withLocation:(NSPoint)locationInControlFrame;
{
    if (!NSMouseInRect(locationInControlFrame, self.stepperFrame, self.flipped))
    {
        return;
    }
    
    [self editCell:nil];
    
    [self.stepperCell trackMouse:theEvent inRect:self.bounds ofView:self untilMouseUp:YES];
    
    self.shouldAppendEdit = NO;
}

/**
 Handles mouse clicks.
 
 @author DJS 2008-07.
 */

- (void)mouseDown:(NSEvent *)theEvent;
{
    if (!self.enabled)
    {
        return;
    }
    
    NSPoint locationInControlFrame = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if (self.usingRange && [self trackMouse:theEvent withLocation:locationInControlFrame forRightEdge:NSMaxX(self.firstAmountFrame) ofTextFieldCell:self.firstAmountCell])
    {
        return;
    }
    
    if ([self trackMouse:theEvent withLocation:locationInControlFrame forRightEdge:NSMaxX(self.secondAmountFrame) ofTextFieldCell:self.secondAmountCell])
    {
        return;
    }
    
    if ([self trackMouse:theEvent withLocation:locationInControlFrame forRightEdge:self.stepperFrame.origin.x ofTextFieldCell:self.unitsCell])
    {
        return;
    }
    
    [self trackMouseInStepper:theEvent withLocation:locationInControlFrame];
}

/**
 Begins editing the specified cell.
 
 @author DJS 2008-07.
 */

- (void)editCell:(NSTextFieldCell *)cell;
{
    if (self.selectedCell)
    {
        [self.selectedCell endEditing:self.currentEditor];
    }
    
    if (!cell)
    {
        cell = self.previouslySelectedCell;
    }
    
    if (!cell)
    {
        cell = self.leftmostCell;
    }
    
    NSText *fieldEditor = [self.window fieldEditor:YES forObject:cell];
    NSInteger length = [[cell stringValue] length];
    NSRect frame;
    
    if (cell == self.firstAmountCell)
    {
        frame = self.firstAmountFrame;
    }
    else if (cell == self.secondAmountCell)
    {
        frame = self.secondAmountFrame;
    }
    else
    {
        frame = self.unitsFrame;
    }
    
    if (cell != self.unitsCell)
    {
        frame.origin.x -= 1.0;
        frame.size.width += 1.0;
    }
    
    [cell selectWithFrame:frame inView:self editor:fieldEditor delegate:self start:0 length:length];
    
    self.selectedCell = cell;
    self.previouslySelectedCell = self.selectedCell;
    self.shouldAppendEdit = NO;
}

/**
 Handles the end of editing a cell.
 
 @author DJS 2008-07.
 */

- (void)textDidEndEditing:(NSNotification *)note;
{
    [self.selectedCell endEditing:[note object]];
    
    self.selectedCell = nil;
    
    NSMutableDictionary *dict = [[note userInfo] mutableCopy];
    
    dict[@"NSFieldEditor"] = [note object];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSControlTextDidEndEditingNotification object:self userInfo:dict];
    
    [self sendAction:self.action to:self.target];
}

/**
 Moves the first responder to the view previous to the receiver in the key loop, or the units cell of the receiver if there aren't any other views.
 
 @author DJS 2008-07.
 */

- (void)selectPreviousKeyView;
{
    [self.window selectKeyViewPrecedingView:self];
    
    if (self.window.firstResponder == self.window)
    {
        [self editCell:self.unitsCell];
    }
}

/**
 Moves the first responder to the view after the receiver in the key loop, or the leftmost cell of the receiver if there aren't any other views.
 
 @author DJS 2008-07.
 */

- (void)selectNextKeyView;
{
    [self.window selectKeyViewFollowingView:self];
    
    if (self.window.firstResponder == self.window)
    {
        [self editCell:self.leftmostCell];
    }
}

/**
 Moves the selection to the previous cell, if any, or to the previous view in the key loop.
 
 @author DJS 2008-07.
 */

- (void)selectPreviousCellOrKeyView:(BOOL)canSelectKeyView;
{
    if (self.selectedCell == self.unitsCell && !self.foreverOrNever)
    {
        [self editCell:self.secondAmountCell];
    }
    else if (self.selectedCell == self.secondAmountCell && self.usingRange && !self.foreverOrNever)
    {
        [self editCell:self.firstAmountCell];
    }
    else if (canSelectKeyView)
    {
        [self selectPreviousKeyView];
    }
    else
    {
        [self editCell:self.unitsCell];
    }
}

/**
 Moves the selection to the next cell, if any, or to the next view in the key loop.
 
 @author DJS 2008-07.
 */

- (void)selectNextCellOrKeyView:(BOOL)canSelectKeyView;
{
    if (self.selectedCell == self.firstAmountCell && !self.foreverOrNever)
    {
        [self editCell:self.secondAmountCell];
    }
    else if (self.selectedCell == self.secondAmountCell)
    {
        [self editCell:self.unitsCell];
    }
    else if (canSelectKeyView)
    {
        [self selectNextKeyView];
    }
    else if (!self.foreverOrNever)
    {
        [self editCell:self.leftmostCell];
    }
    else
    {
        [self editCell:self.unitsCell];
    }
}

/**
 Returns the amount incremented by the step, constrained to the minimum and maximum values.
 
 @author DJS 2008-07.
 */

- (NSInteger)incrementAmount:(NSInteger)amount withStep:(NSInteger)step minimum:(NSInteger)minimum maximum:(NSInteger)maximum;
{
    amount += step;
    
    if (amount > maximum)
    {
        amount = minimum + ((amount - maximum) - 1);
    }
    
    return amount;
}

/**
 Returns the amount decremented by the step, constrained to the minimum and maximum values.
 
 @author DJS 2008-07.
 */

- (NSInteger)decrementAmount:(NSInteger)amount withStep:(NSInteger)step minimum:(NSInteger)minimum maximum:(NSInteger)maximum;
{
    amount -= step;
    
    if (amount < minimum)
    {
        amount = maximum - ((minimum - amount) - 1);
    }
    
    return amount;
}

/**
 Returns the selected amount incremented by the step, constrained to the minimum and maximum for the current cell.
 
 @author DJS 2008-07.
 */

- (void)incrementSelectedValueWithStep:(NSInteger)step;
{
    if (self.selectedCell == self.firstAmountCell)
    {
        self.firstAmount = [self incrementAmount:self.firstAmount withStep:step minimum:self.currentMinimum maximum:self.currentMaximum];
    }
    else if (self.selectedCell == self.secondAmountCell)
    {
        self.secondAmount = [self incrementAmount:self.secondAmount withStep:step minimum:self.currentMinimum maximum:self.currentMaximum];
    }
    else
    {
        NSUInteger mappingIndex = [self includedMappingIndexForUnits:self.units];
        
        mappingIndex = [self incrementAmount:mappingIndex withStep:step minimum:0 maximum:self.currentMaximum];
        
        self.units = [self unitsForIncludedMappingIndex:mappingIndex];
    }
    
    self.shouldAppendEdit = NO;
    
    [self updateCells];
}

/**
 Returns the selected amount decremented by the step, constrained to the minimum and maximum for the current cell.
 
 @author DJS 2008-07.
 */

- (void)decrementSelectedValueWithStep:(NSInteger)step;
{
    if (self.selectedCell == self.firstAmountCell)
    {
        self.firstAmount = [self decrementAmount:self.firstAmount withStep:step minimum:self.currentMinimum maximum:self.currentMaximum];
    }
    else if (self.selectedCell == self.secondAmountCell)
    {
        self.secondAmount = [self decrementAmount:self.secondAmount withStep:step minimum:self.currentMinimum maximum:self.currentMaximum];
    }
    else
    {
        NSUInteger mappingIndex = [self includedMappingIndexForUnits:self.units];
        
        mappingIndex = [self decrementAmount:mappingIndex withStep:step minimum:0 maximum:self.currentMaximum];
        
        self.units = [self unitsForIncludedMappingIndex:mappingIndex];
    }
    
    self.shouldAppendEdit = NO;
    
    [self updateCells];
}

/**
 Sets the value of the current cell to the minimum available value.
 
 @author DJS 2008-07.
 */

- (void)chooseMinimumSelectedValue;
{
    if (self.selectedCell == self.firstAmountCell)
    {
        self.firstAmount = self.currentMinimum;
    }
    else if (self.selectedCell == self.secondAmountCell)
    {
        self.secondAmount = self.currentMinimum;
    }
    else
    {
        self.units = [self unitsForIncludedMappingIndex:self.currentMinimum];
    }
    
    self.shouldAppendEdit = NO;
    
    [self updateCells];
}

/**
 Sets the value of the current cell to the maximum available value.
 
 @author DJS 2008-07.
 */

- (void)chooseMaximumSelectedValue;
{
    if (self.selectedCell == self.firstAmountCell)
    {
        self.firstAmount = self.currentMaximum;
    }
    else if (self.selectedCell == self.secondAmountCell)
    {
        self.secondAmount = self.currentMaximum;
    }
    else
    {
        self.units = [self unitsForIncludedMappingIndex:self.currentMaximum];
    }
    
    self.shouldAppendEdit = NO;
    
    [self updateCells];
}

/**
 Helper method for the -showMenu method.
 
 @param menu The menu that was just built.
 @returns The menu item with the checkmark, or nil if none.
 
 @author DJS 2015-04.
 */

- (NSMenuItem *)selectedItemForMenu:(NSMenu *)menu;
{
    for (NSMenuItem *menuItem in menu.itemArray)
    {
        if (menuItem.state == NSOnState)
        {
            return menuItem;
        }
    }
    
    return nil;
}

/**
 Drops down a menu for the selected cell, with a range of suitable values.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Made the menu line up with the cell.
 */

- (void)showMenu;
{
    NSMenu *menu = [self makeMenuForSelectedCell];
    NSPoint location = self.selectedCellFrame.origin;
    
    location.x -= 19.0;
    location.y += 16.0;
    
    menu.font = self.unitsCell.font;
    
    [menu popUpMenuPositioningItem:[self selectedItemForMenu:menu] atLocation:location inView:self];
}

/**
 Handles tab, arrow, page up/down, etc keyboard events for the current cell.
 
 @author DJS 2008-07.
 */

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)selector;
{
    if (selector == @selector(insertBacktab:))
    {
        [self selectPreviousCellOrKeyView:YES];
    }
    else if (selector == @selector(insertTab:))
    {
        [self selectNextCellOrKeyView:YES];
    }
    else if (selector == @selector(moveLeft:) || selector == @selector(moveLeftAndModifySelection:) || selector == @selector(moveWordLeft:) || selector == @selector(moveBackwardAndModifySelection:))
    {
        [self selectPreviousCellOrKeyView:NO];
    }
    else if (selector == @selector(moveRight:) || selector == @selector(moveRightAndModifySelection:) || selector == @selector(moveWordRight:) || selector == @selector(moveForwardAndModifySelection:) || selector == @selector(insertTabIgnoringFieldEditor:))
    {
        [self selectNextCellOrKeyView:NO];
    }
    else if (selector == @selector(selectPreviousKeyView:))
    {
        [self selectPreviousKeyView];
    }
    else if (selector == @selector(selectNextKeyView:))
    {
        [self selectNextKeyView];
    }
    else if (selector == @selector(moveUp:))
    {
        [self incrementSelectedValueWithStep:1];
    }
    else if (selector == @selector(moveDown:))
    {
        [self decrementSelectedValueWithStep:1];
    }
    else if (selector == @selector(moveUpAndModifySelection:) || selector == @selector(pageUp:) || selector == @selector(scrollPageUp:) || selector == @selector(moveBackward:))
    {
        [self incrementSelectedValueWithStep:5];
    }
    else if (selector == @selector(moveDownAndModifySelection:) || selector == @selector(pageDown:) || selector == @selector(scrollPageDown:) || selector == @selector(moveForward:))
    {
        [self decrementSelectedValueWithStep:5];
    }
    else if (selector == @selector(moveToBeginningOfDocument:) || selector == @selector(scrollToBeginningOfDocument:))
    {
        [self chooseMinimumSelectedValue];
    }
    else if (selector == @selector(moveToEndOfDocument:) || selector == @selector(scrollToEndOfDocument:))
    {
        [self chooseMaximumSelectedValue];
    }
    else if (selector == @selector(complete:))
    {
        [self showMenu];
    }
    else if (selector == @selector(deleteBackward:) || selector == @selector(insertNewline:) || selector == @selector(cancelOperation:))
    {
        return NO;
    }
    
    // Ignore anything else
    
    return YES;
}

/**
 Handles typing values for the current cell.
 
 @author DJS 2008-07.
 */

- (void)textView:(NSTextView *)textView changeAmountWithReplacementString:(NSString *)replacementString;
{
    // If the replacement string contains any non-digit characters, reject it outright:
    if ([[replacementString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]] length])
    {
        return;
    }
    
    // We'll adjust the field editor string as desired, then change the text ourselves:
    NSString *editorString = [textView string];
    NSUInteger editorLength = [editorString length];
    
    if (![replacementString length])
    {
        // If deleting (i.e. no replacement string), and there's more than one character, delete the last character and append next time, otherwise overwrite next time:
        if (editorLength > 1)
        {
            editorString = [editorString substringToIndex:editorLength - 1];
            self.shouldAppendEdit = YES;
        }
        else
        {
            self.shouldAppendEdit = NO;
        }
    }
    else
    {
        // If the minimum is more than one, trim off the first digit and append to the end; otherwise append if we can, or overwrite:
        
        if (self.currentMinimum > 1 && editorLength > 1 && editorLength == [[self stringWithIntegerValue:self.currentMaximum] length])
        {
            editorString = [[editorString substringFromIndex:1] stringByAppendingString:replacementString];
            
            // But if the resulting value would be less than the minimum, replace the first digit with the minimum's first digit, so the result is valid:
            if ([editorString floatValue] < self.currentMinimum)
            {
                editorString = [[[self stringWithIntegerValue:self.currentMinimum] substringToIndex:1] stringByAppendingString:[editorString substringFromIndex:1]];
            }
        }
        else if (self.shouldAppendEdit && editorLength < [[self stringWithIntegerValue:self.currentMaximum] length])
        {
            editorString = [editorString stringByAppendingString:replacementString];
        }
        else
        {
            editorString = [replacementString copy];
        }
        
        // Always append if we can:
        self.shouldAppendEdit = YES;
    }
    
    // Validate the value range:
    CGFloat value = [editorString floatValue];
    
    if (value < self.currentMinimum)
    {
        value = self.currentMinimum;
    }
    
    if (value > self.currentMaximum)
    {
        value = self.currentMaximum;
    }
    
    // Keep our property up-to-date:
    if (self.selectedCell == self.firstAmountCell)
    {
        self.firstAmount = value;
    }
    else
    {
        self.secondAmount = value;
    }
    
    // Update all of the cells to synchronize the amount to the field editor, cell, and other cells:
    [self updateCells];
}

/**
 Handles changes to the units cell.
 
 @author DJS 2008-07.
 */

- (void)textView:(NSTextView *)textView changeUnitsWithReplacementString:(NSString *)replacementString;
{
    // Ignore deleting (i.e. no replacement string):
    if (![replacementString length])
    {
        return;
    }
    
    // We'll adjust the field editor string as desired, then change the text ourselves:
    NSString *editorString = [textView string];
    NSUInteger editorMaximum = [editorString length] - 1;
    DejalInterval *interval = [DejalInterval intervalWithAmount:0 units:DejalIntervalUnitsSecond];
    NSInteger mappingMaximum = self.currentMaximum;
    NSUInteger characterIndex = 0;
    BOOL found = NO;
    
    // Scan through all of the available units strings, and see if the replacement string matches the beginning of any, at any character position:
    while (!found && characterIndex <= (editorMaximum))
    {
        NSString *tempString = [[editorString substringToIndex:characterIndex] stringByAppendingString:replacementString];
        NSInteger mappingIndex = 0;
        
        while (!found && mappingIndex <= mappingMaximum)
        {
            interval.units = [self unitsForIncludedMappingIndex:mappingIndex];
            found = [interval.fullUnitsName.lowercaseString hasPrefix:tempString.lowercaseString];
            
            mappingIndex++;
        }
        
        characterIndex++;
    }
    
    if (!found)
    {
        return;
    }
    
    // If we found a match, use it:
    self.units = interval.units;
    
    // Update all of the cells to synchronize the units to the field editor and cell:
    [self updateCells];
}

/**
 Displays a menu if the spacebar is pressed, or supports decrementing and incrementing via - and + keys.
 
 @author DJS 2008-07.
 */

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString;
{
    // Pop the menu if the spacebar is pressed:
    if ([replacementString isEqualToString:@" "])
    {
        [self showMenu];
        return NO;
    }
    
    // Special case: allow decrementing and incrementing via - and + keys:
    if ([replacementString isEqualToString:@"-"] || [replacementString isEqualToString:@"_"])
    {
        [self decrementSelectedValueWithStep:1];
    }
    else if ([replacementString isEqualToString:@"+"] || [replacementString isEqualToString:@"="])
    {
        [self incrementSelectedValueWithStep:1];
    }
    
    if (self.selectedCell == self.unitsCell)
    {
        [self textView:textView changeUnitsWithReplacementString:replacementString];
    }
    else
    {
        [self textView:textView changeAmountWithReplacementString:replacementString];
    }
    
    return NO;
}

/**
 Returns the range to select; always the full cell text.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Automatically shows the menu.
 */

- (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange;
{
    // If there's some text in the cell, but the proposed selection is empty, the user must have clicked an already-selected cell, so show the menu if allowed:
    if (textView.string.length && !newSelectedCharRange.length && self.canAutoPopMenu)
    {
        [self performSelector:@selector(showMenu) withObject:nil afterDelay:0.01];
    }
    
    return NSMakeRange(0, [[textView string] length]);
}

/**
 Returns YES if the receiver is enabled.
 
 @author DJS 2008-07.
 */

- (BOOL)acceptsFirstResponder;
{
    return self.enabled;
}

/**
 Returns YES to indicate that this is an editable control.
 
 @author DJS 2008-07.
 */

- (BOOL)needsPanelToBecomeKey;
{
    return YES;
}

/**
 Makes the receiver the first responder, and selects the cell in the specified direction.
 
 @author DJS 2008-07.
 */

- (void)becomeFirstResponderInDirection:(NSSelectionDirection)selectionDirection;
{
    if (selectionDirection == NSSelectingNext)
    {
        [self editCell:self.leftmostCell];
    }
    else if (selectionDirection == NSSelectingPrevious)
    {
        [self editCell:self.unitsCell];
    }
    else
    {
        [self editCell:self.selectedCell];
    }
}

/**
 Populates the menu.
 
 @author DJS 2008-07.
 @version DJS 2015-04: Added support for a selected item.
 */

- (void)addItemToMenu:(NSMenu *)menu withTitle:(NSString *)title tag:(NSInteger)tag minimum:(NSInteger)minimum maximum:(NSInteger)maximum wantSeparator:(BOOL)wantSeparator selected:(BOOL)selected;
{
    if (tag < minimum || tag > maximum)
    {
        return;
    }
    
    if (!title)
    {
        title = [self stringWithIntegerValue:tag];
    }
    
    if (wantSeparator && [menu numberOfItems])
    {
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(menuItemChosen:) keyEquivalent:@""];
    NSDictionary *attributes = @{NSFontAttributeName : [self.unitsCell font]};
    
    item.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attributes];
    item.target = self;
    item.tag = tag;
    
    if (selected)
    {
        item.state = NSOnState;
    }
    
    [menu addItem:item];
}

/**
 Remembers the chosen menu item
 
 @author DJS 2008-07.
 */

- (void)menuItemChosen:(id)sender;
{
    self.currentValue = [sender tag];
}

/**
 Prepares a menu for the selected cell.
 
 @author DJS 2008-07.
 @version DJS 2015-04: Added support for a selected item, and cleaned up the amounts array.
 */

- (NSMenu *)makeMenuForSelectedCell;
{
    NSMenu *menu = [[NSMenu alloc] init];
    
    if (self.selectedCell == self.unitsCell)
    {
        DejalInterval *interval = [DejalInterval intervalWithAmount:0 units:DejalIntervalUnitsSecond];
        
        for (NSInteger mappingIndex = 0; mappingIndex <= self.currentMaximum; mappingIndex++)
        {
            interval.units = [self unitsForIncludedMappingIndex:mappingIndex];
            
            BOOL wantSeparator = (interval.units == DejalIntervalUnitsDay || interval.units == DejalIntervalUnitsForever || interval.units == DejalIntervalUnitsNever);
            BOOL selected = self.units == interval.units;
            
            [self addItemToMenu:menu withTitle:interval.fullUnitsName tag:mappingIndex minimum:0 maximum:self.currentMaximum wantSeparator:wantSeparator selected:selected];
        }
    }
    else
    {
        NSArray *amounts = @[@0, @1, @2, @3, @4, @5, @10, @15, @20, @25, @30, @40, @50, @60, @90, @120];
        NSInteger selectedAmount = self.selectedCell == self.firstAmountCell ? self.firstAmount : self.secondAmount;
        BOOL foundSelected = NO;
        
        for (NSNumber *amountNum in amounts)
        {
            NSInteger amount = amountNum.integerValue;
            BOOL selected = amount == selectedAmount;
            
            if (selected)
            {
                foundSelected = YES;
            }
            else if (amount > selectedAmount && !foundSelected)
            {
                [self addItemToMenu:menu withTitle:nil tag:selectedAmount minimum:self.currentMinimum maximum:self.currentMaximum wantSeparator:NO selected:YES];
                foundSelected = YES;
            }
            
            [self addItemToMenu:menu withTitle:nil tag:amount minimum:self.currentMinimum maximum:self.currentMaximum wantSeparator:NO selected:selected];
        }
        
        if (!foundSelected)
        {
            [self addItemToMenu:menu withTitle:nil tag:selectedAmount minimum:self.currentMinimum maximum:self.currentMaximum wantSeparator:NO selected:YES];
        }
    }
    
    return menu;
}


// ----------------------------------------------------------------------------------------
#pragma mark - FOCUS RING METHODS
// ----------------------------------------------------------------------------------------


/**
 Draws the mask for the keyboard focus ring.
 
 @author DJS 2008-07.
 */

- (void)drawFocusRingMask;
{
    NSRectFill(self.focusRingBounds);
}

/**
 Returns the bounds for the keyboard focus ring mask.
 
 @author DJS 2008-07.
 */

- (NSRect)focusRingMaskBounds;
{
    return self.focusRingBounds;
}

/**
 Makes the receiver the first responder; invoked after a delay.
 
 @author DJS 2008-07.
 */

- (void)delayedBecomeFirstResponder:(NSNumber *)selectionDirection;
{
    [self becomeFirstResponderInDirection:[selectionDirection integerValue]];
}

/**
 Makes the receiver the first responder, if it can.
 
 @author DJS 2008-07.
 @version DJS 2015-02: Changed to use the ready flag; needed to avoid issues when loading via state restoration.
 */

- (BOOL)becomeFirstResponder;
{
    BOOL okay = [super becomeFirstResponder];
    NSSelectionDirection selectionDirection = self.window.keyViewSelectionDirection;
    
    if (okay)
    {
        if (self.ready)
        {
            [self becomeFirstResponderInDirection:selectionDirection];
        }
        else
        {
            // We're not fully set up yet, so postpone this a bit:
            [self performSelector:@selector(delayedBecomeFirstResponder:) withObject:@(selectionDirection) afterDelay:0.01];
        }
    }
    
    return okay;
}

@end

