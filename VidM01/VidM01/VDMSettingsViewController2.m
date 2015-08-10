//
//  VDMSettingsViewController2.m
//  VidM01
//
//  Created by Juergen Haas on 1/12/15.
//  Copyright (c) 2015 Blast. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VDMViewController.h"

#import "VDMSettingsViewController2.h"

static int demo_pick_idx = 0;

@implementation VDMSettingsViewController2

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    printf("   --- VDMSettingsViewController2 - viewDidLoad \n");
    
    // For demo selection screen:
    NSArray *array_to_load_picker__production = [[NSArray alloc] initWithObjects:
                                                 @"Tennis Serve 1",              //  1
                                                 @"Tennis Serve 2",              //  2
                                                 @"Ice Hockey 1",                //  3
                                                 @"Ice Hockey 2",                //  4
                                                 @"Baseball 1",                  //  5
                                                 @"Trampoline Jump 1",           //  6    // remove this
                                                 @"Basketball Jump 1",           //  7
                                                 @"Golf Driver Swing 1",         //  8
                                                 // @"Golf Putt 1",
                                                 // @"Golf Putt 2 Carpet",
                                                 @"Golf Putt 3 Outdoors",        //  9
                                                 @"Golf Putt 3 Outdoors Full",   // 10
                                                 @"Golf Putt Steve 1",           // 11
                                                 @"Golf Putt Steve 1 Full",      // 12
                                                 @"Golf Putt Steve 2",           // 13
                                                 @"Golf Putt Steve 2 Full",      // 14
                                                 @"Golf Putt Steve 3",           // 15
                                                 @"Golf Putt Steve 3 Full",      // 16
                                                 @"Golf Putt Howard T Full",     // 17
                                                 @"Golf Putt Callaway Ball",     // 18
                                                 @"Golf Putt Blastman Logo",     // 19
                                                 @"Golf Putt Fizzy Blastman",    // 20
                                                 @"Golf Putt Black Clubhead",    // 21
                                                 @"Golf Putt Black Clubhead 2",  // 22
                                                 nil];
    
    NSArray *array_to_load_picker = [[NSArray alloc] initWithObjects:
                                     @"Tennis Serve 1",              //  1
                                     @"Tennis Serve 2",              //  2
                                     @"Ice Hockey 1",                //  3
                                     @"Ice Hockey 2",                //  4
                                     @"Baseball 1",                  //  5
                                     @"Trampoline Jump 1",           //  6
                                     @"Basketball Jump 1",           //  7
                                     @"Golf Driver Swing 1",         //  8
                                     @"Golf Putt 1",                 //  9
                                     @"Golf Putt 2 Carpet",          // 10
                                     @"Golf Putt 3 Outdoors",        // 11
                                     @"Golf Putt 3 Outdoors Full",   // 12
                                     @"Golf Putt Steve 1",           // 13
                                     @"Golf Putt Steve 1 Full",      // 14
                                     @"Golf Putt Steve 2",           // 15
                                     @"Golf Putt Steve 2 Full",      // 16
                                     @"Golf Putt Steve 3",           // 17
                                     @"Golf Putt Steve 3 Full",      // 18
                                     @"Golf Putt Howard T Full",     // 19
                                     @"Golf Putt Callaway Ball",     // 20
                                     @"Golf Putt Blastman Logo",     // 21
                                     @"Golf Putt Fuzzy Blastman",    // 22
                                     @"Golf Putt Black Clubhead",    // 23
                                     @"Golf Putt Black Clubhead 2",  // 24
                                     nil];
    
   
    if (production_mode) { self.pickerViewArray = array_to_load_picker__production; }
    else                 { self.pickerViewArray = array_to_load_picker; }
    
    // [arrayToLoadPicker release];
    
    self.demo_picker.delegate = self;      // this is needed to fill in the row titles in the pickerView (sport_picker)
    self.demo_picker.dataSource = self;    // this is needed to fill in the row titles in the pickerView (sport_picker) ?
    
    
    CGColorSpaceRef colorspace       = CGColorSpaceCreateDeviceRGB();
    CGFloat components_yellow1[]     = {1.0, 1.0, 0.8, 1.0};
    CGColorRef color_yellow1         = CGColorCreate(colorspace, components_yellow1);

    // self.view.backgroundColor = [UIColor yellowColor];
    self.view.backgroundColor = [UIColor colorWithCGColor :color_yellow1];
    
    [self.demo_picker selectRow:15 inComponent:0 animated:YES];       // set initial selection
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    printf("   --- did receive memory warning");
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI Actions


/*
 // These function are overwritten for the pickerView (sport selection) widget:
 - (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
 return 1;
 }
 - (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
 printf("   --- calling: pickerView - numberOfRowsInComponent \n");
 return [_pickerViewArray count];
 }
 - (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
 printf("   --- calling: pickerView - titleForRow - forComponent \n");
 return [self.pickerViewArray objectAtIndex:row];
 }
 */

// These function are overwritten for the pickerView (sport selection) widget:
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)sport_picker {
    printf("   --- calling: numberOfComponentsInPickerView \n");
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)sport_picker numberOfRowsInComponent:(NSInteger)component {
    int item_count = [_pickerViewArray count];
    // printf("   --- calling: pickerView - numberOfRowsInComponent - item_cnt: %d \n", item_count);
    return [_pickerViewArray count];
}
- (NSString *)pickerView:(UIPickerView *)sport_picker titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    // printf("   --- calling: pickerView - titleForRow - forComponent \n");
    return [self.pickerViewArray objectAtIndex:row];
}

+ (int) get_demo_picker_index
{
    return demo_pick_idx;
}

+ (void) set_demo_picker_index :(int)idx
{
    demo_pick_idx = idx;
}

+ (void) set_production_mode :(bool)mode
{
    production_mode = mode;
}


-(IBAction)selectedRow
{
    // int selectedIndex = [pickerView selectedRowInComponent:0];
    int selectedIndex = [_demo_picker selectedRowInComponent:0];
    printf("   --- IBAction: selectRow   selectedIndex: %d \n", selectedIndex);
    NSString *message = [NSString stringWithFormat:@"You selected: %@",[_pickerViewArray objectAtIndex:selectedIndex]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    // [alert release];
    
    demo_pick_idx = selectedIndex + 1;        // zero means: not set
    printf("   --- VMDSettingsViewController2 - demo_pick_idx: %d \n", demo_pick_idx);
    [VDMViewController set_regression_test :false];
}


- (IBAction)regression_test :(UIButton *)sender
{
    printf("   --- IBAction: Regression Test \n");
    // [VDMViewController regression_test];        // calling (static) class method
    [VDMViewController set_regression_test :true];
}


@end
