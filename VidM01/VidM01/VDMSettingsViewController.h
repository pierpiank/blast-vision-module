//
//  VDMSettingsViewController.h
//  VidM01
//
//  Created by Juergen Haas on 11/15/14.
//  Copyright (c) 2014 Blast. All rights reserved.
//

#ifndef VidM01_VDMSettingsViewController_h
#define VidM01_VDMSettingsViewController_h


#endif


#import <UIKit/UIKit.h>


@interface VDMSettingsViewController : UIViewController <UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    
    // IBOutlet UIPickerView *pickerView;    // sport selection scene
    // NSArray *pickerViewArray;             // sport selection scene

    //x @public
    //x   int sport_selection_index;
}

@property (nonatomic, retain) NSArray *pickerViewArray;      // sport selection scene
-(IBAction)selectedRow;                                      // sport selection scene

//x @property (strong, nonatomic) IBOutlet UIPickerView *sport_selection;
@property (strong, nonatomic) IBOutlet UIPickerView *sport_picker;

//x @property int sport_picker_index;

+(int) get_sport_picker_index;

@end
