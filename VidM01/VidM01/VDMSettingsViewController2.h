//
//  VDMSettingsViewController2.h
//  VidM01
//
//  Created by Juergen Haas on 1/12/15.
//  Copyright (c) 2015 Blast. All rights reserved.
//

#ifndef VidM01_VDMSettingsViewController2_h
#define VidM01_VDMSettingsViewController2_h


#endif


#import <UIKit/UIKit.h>

static bool production_mode;    // turn off debugging/development features

@interface VDMSettingsViewController2 : UIViewController <UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    // IBOutlet UIPickerView *pickerView;    // sport selection scene
    // NSArray *pickerViewArray;             // sport selection scene
    
    //x @public
    //x   int sport_selection_index;
}

@property (nonatomic, retain) NSArray *pickerViewArray;      // sport selection scene
-(IBAction)selectedRow;                                      // sport selection scene

@property (strong, nonatomic) IBOutlet UIPickerView *demo_picker;
// @property (strong, nonatomic) IBOutlet UIPickerView *demo_picker;


+ (int) get_demo_picker_index;
+ (void) set_demo_picker_index :(int)idx;
+ (void) set_production_mode :(bool)mode;

@end
