//
//  VDMSettingsViewController.m
//  VidM01
//
//  Created by Juergen Haas on 11/15/14.
//  Copyright (c) 2014 Blast. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VDMSettingsViewController.h"

static int demo_pick_idx = 0;

@implementation VDMSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    printf("   --- VDMSettingsViewController - viewDidLoad \n");
    
    // For sport selection scene:
    NSArray *arrayToLoadPicker = [[NSArray alloc] initWithObjects:@"Golf Full Swing",@"Golf Putt",@"Baseball",@"Ice Hockey",@"Tennis",@"Racquet Ball",@"Volley Ball",@"Trampoline",@"Basketball", nil];
    self.pickerViewArray = arrayToLoadPicker;
    // [arrayToLoadPicker release];
    
    self.sport_picker.delegate = self;      // this is needed to fill in the row titles in the pickerView (sport_picker)
    self.sport_picker.dataSource = self;    // this is needed to fill in the row titles in the pickerView (sport_picker) ?
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
    printf("   --- calling: pickerView - numberOfRowsInComponent - item_cnt: %d \n", item_count);
    return [_pickerViewArray count];
}
- (NSString *)pickerView:(UIPickerView *)sport_picker titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    printf("   --- calling: pickerView - titleForRow - forComponent \n");
    return [self.pickerViewArray objectAtIndex:row];
}

+(int) get_sport_picker_index
{
    return demo_pick_idx;
}


-(IBAction)selectedRow
{
    // int selectedIndex = [pickerView selectedRowInComponent:0];
    int selectedIndex = [_sport_picker selectedRowInComponent:0];
    printf("   --- IBAction: selectRow   selectedIndex: %d \n", selectedIndex);
    NSString *message = [NSString stringWithFormat:@"You selected: %@",[_pickerViewArray objectAtIndex:selectedIndex]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    // [alert release];
    
    //x sport_selection_index = selectedIndex;
    //x _sport_picker_index = selectedIndex;
    demo_pick_idx = selectedIndex + 1;        // zero means: not set
    printf("   --- VMDSettingsViewController - sport_pick_idx: %d \n", demo_pick_idx);
    
    //x int sp_idx = _sport_picker_index;
    //x printf("   --- sp_idx: %d \n", sp_idx);
}




@end
