//
//  VDMViewController.m
//  VidM01
//
//  Created by Juergen Haas on 3/1/14.
//  Copyright (c) 2014 Blast. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVAudioSession.h>


#import "VDMViewController.h"

#import <opencv2/highgui/cap_ios.h>
using namespace cv;

// #import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <stdio.h>
#include <fstream>      // std::ofstream
// #include <math.h>

#import "VDMDrawView.h"
#import "VDMSettingsViewController.h"
#import "VDMSettingsViewController2.h"

#import "VDMViewController.h"

#import "VDMRegressionTest.h"




@interface VDMViewController ()

@end



@implementation VDMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    production_mode = false; // true;
    [VDMSettingsViewController2 set_production_mode :production_mode];   // calling (static) class method
    
    // [self.view addSubview:_image_field1];
    
    // [self process_movie];                              // <<<<<<<<<<<<<  process movie ------ TEMPORARY FOR TESTING
    
	// Do any additional setup after loading the view, typically from a nib.
    
    /*
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Accu Motion Metrics" message:@"Testing" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    [alert show];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_image_field1];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    // self.videoCamera.grayscale = NO;
    
    self.videoCamera.delegate = self;
    */
    
    // int self_width = self.view.bounds.size.width;
    // int image_field_width = _image_field1.frame.size.width;
    /*
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, image_field_width, 1)];
    // lineView.backgroundColor = [UIColor blackColor];
    lineView.backgroundColor = [UIColor redColor];
    [self.image_field1 addSubview:lineView];
    // [self.image_field1 addSubview:_draw_field1];
    // You might also keep a reference to this view if you are about to change its coordinates. Just create a member and a property for this...
    */
    
 //   [self.draw_field2 addSubview:image_field1];
    
    /*
    VDMDrawView *draw_view1 = [[VDMDrawView alloc] initWithFrame:CGRectMake(0, 50, image_field_width, 1)];
    draw_view1.backgroundColor = [UIColor redColor];
    [self.draw_field2 addSubview:draw_view1];
    */
    
    /*
    VDMDrawView *draw_view1 = [[VDMDrawView alloc] initWithFrame:CGRectMake(0, 50, image_field_width, 5)];
    draw_view1.backgroundColor = [UIColor greenColor];
    [self.image_field1 addSubview:draw_view1];
    */
    
    // [_draw_field_graph addSubview:_sensor_data_graph];
    // [_sensor_data_graph addSubview:_draw_field_graph];

    thePath = nullptr;
    path_is_set = false;
    sport = 0;
    pix_arr_arr_length = 3; // 2; // 3; // 5;      // store the last two images
    pix_arr_arr_ptr = 0;
    movie_flow = -1;
    movie_is_running = 0;
    video_cnt = 0;                  // initialize
    down_sampling_factor = 1;       // initialize - for downsampling frame rate (tennis only)
    new_fps_reduction_factor = 1;   // initialize - for downsampling frame rate
    fps_reduction_factor = 1;       // initialize - for downsampling frame rate
    demo_id = 0;                    // initialize
    
    motion_intensity_arr_length = 4000;
    num_valid_motion_intensity_values = 0;
    motion_intensity_arr = (int *) calloc(motion_intensity_arr_length, sizeof(int));
    
    box_width_half  = 30;    // blue box half width
    box_height_half = 30;    // blue box half height
    
    box2_width_half  = 60; // 70; // 80; // 50; // 40; //  30;    // blue box half width
    box2_height_half = 60; // 70; // 80; // 50; // 40; //  30;    // blue box half height
    
    box3_width_half  = 60; // 70; // 80; // 50; // 40; //  30;    // green box half width
    box3_height_half = 60; // 70; // 80; // 50; // 40; //  30;    // green box half height
    
    video_scale_factor_x = 0;
    video_scale_factor_y = 0;
    
    
    // Allocate clubhead_subimg and club_shaft_subimg:
    clubhead_subimg_arr_length   = 3 * (box2_width_half * 2) * (box2_height_half * 2);    // store [red,green,blue] for each pixel
    club_shaft_subimg_arr_length = 3 * (box3_width_half * 2) * (box3_height_half * 2);    // store [red,green,blue] for each pixel
    clubhead_subimg   = (unsigned char*) calloc(clubhead_subimg_arr_length, sizeof(unsigned char));
    club_shaft_subimg = (unsigned char*) calloc(club_shaft_subimg_arr_length, sizeof(unsigned char));
    
    // Allocate clubhead_subimg_mask and club_shaft_subimg_mask:
    clubhead_subimg_mask_arr_length   = clubhead_subimg_arr_length / 3;    // only one element is needed for 3 elements in clubhead_subimg (red, green, blue)
    club_shaft_subimg_mask_arr_length = club_shaft_subimg_arr_length / 3;  // only one element is needed for 3 elements in clubhead_subimg (red, green, blue)
    clubhead_subimg_mask   = (int *) calloc(clubhead_subimg_arr_length, sizeof(int));
    club_shaft_subimg_mask = (int *) calloc(club_shaft_subimg_arr_length, sizeof(int));
    
    // Allocate linear_regression_points_x/y:
    linear_regression_points_x = (int *) calloc(club_shaft_subimg_mask_arr_length, sizeof(int));
    linear_regression_points_y = (int *) calloc(club_shaft_subimg_mask_arr_length, sizeof(int));
    
    
    // Allocate sub-image for equalizing the ball image (for pattern detection and rotation tracking):
    ball_box_width = 300;    // pixels
    ball_box_height = 300;   // pixels
    ball_box_subimg_arr_length = 4 * ball_box_width * ball_box_height;
    ball_box_subimg0 = (unsigned char*) calloc(ball_box_subimg_arr_length, sizeof(unsigned char));
    ball_box_subimg1 = (unsigned char*) calloc(ball_box_subimg_arr_length, sizeof(unsigned char));
    ball_box_subimg2 = (unsigned char*) calloc(ball_box_subimg_arr_length, sizeof(unsigned char));
    ball_box_subimg_swap = 1;
    ball_rotation_angle_acc = 0.0f;
    ball_rotation_angle_at_subimg0 = 0.0f;
    ball_rotation_angle_at_subimg1 = 0.0f;
    ball_rotation_angle_at_subimg2 = 0.0f;
    prev_ball_box_subimg_rotated_arr_length = 2 * ball_box_width * ball_box_height;
    prev_ball_box_subimg_rotated = (double *) calloc(prev_ball_box_subimg_rotated_arr_length, sizeof(double));
    
    
    [self.draw_field2 set_clubhead_subimg_mask :clubhead_subimg_mask :clubhead_subimg_arr_length :box2_width_half :box2_height_half :&video_scale_factor_x :&video_scale_factor_y];
    [self.draw_field2 set_club_shaft_subimg_mask :club_shaft_subimg_mask :club_shaft_subimg_arr_length :box3_width_half :box3_height_half :&video_scale_factor_x :&video_scale_factor_y];
    [self.draw_field2 turn_clubhead_subimg_mask_on];
    
    [self.draw_field2 set_marker_line1:10 :10 :20 :20];   // initialize ball marker line1
    
    // Reset draw parameters for red circle around ball:
    [_draw_field2 set_marker_circle_radius1 :30];
    [_draw_field2 set_marker_circle_offset_x :-100];
    [_draw_field2 set_marker_circle_offset_y :-100];
    
    // [ _draw_field2 set_force_and_distance_etc :0.0f :0.0f :0.0f :0.0f ];
    [ _draw_field2 set_impact_ghost :-100 :-100 ];      // move out of view
    [ _draw_field2 set_ninety_deg_ghost :-100 :-100 ];  // move out of view
    // [ _draw_field2 set_shaft_line :0.0 :0.0 ];
    
    // Draw green box around clubhead: (now used for shaft tracking?)
    [_draw_field2 set_box3_offset_x :-100];
    [_draw_field2 set_box3_offset_y :-100];
    
    rotation_blastman_mode = 1;      // use blastman for rotation detection
    int num_blastman1_points = 7;
    [self.draw_field2 init_blastman :num_blastman1_points];
    
    blastman_points_x = (float *) calloc(num_blastman1_points, sizeof(float));     // This is deallocated at the end.
    blastman_points_y = (float *) calloc(num_blastman1_points, sizeof(float));
    
    max_num_ball_positions = 50;
    int record_length = 3;     // x, y, score
    int array_length = 50 * record_length;
    top_n_ball_positions = (int *) calloc(array_length, sizeof(int));
    
    ball_speed_arr_length = 80;                                                    // Display graphs of ball speed and ball rmp.
    head_speed_arr_length = 80;                                                    // Display graphs of ball speed and ball rmp.
    ball_rpm_arr_length   = 80;
    ball_speed_arr = (float *) calloc(ball_speed_arr_length, sizeof(float));
    head_speed_arr = (float *) calloc(head_speed_arr_length, sizeof(float));
    ball_rpm_arr   = (float *) calloc(ball_rpm_arr_length, sizeof(float));
    ball_speed_arr_start_idx = 0;
    head_speed_arr_start_idx = 0;
    ball_rpm_arr_start_idx   = 0;
    
    
    ball_orientation = 0.0f;
    ninety_degree_point = 0.0f;
    force_for_ball_momentum = 0.0f;
    ball_travel_distance = 0.0f;
    
    [ _draw_field_graph set_ball_speed_graph :ball_speed_arr :ball_speed_arr_length :ball_speed_arr_start_idx ];
    [ _draw_field_graph set_head_speed_graph :head_speed_arr :head_speed_arr_length :head_speed_arr_start_idx ];
    [ _draw_field_graph set_ball_rpm_graph   :ball_rpm_arr   :ball_rpm_arr_length   :ball_rpm_arr_start_idx ];
    [ _draw_field_graph turn_graph_display_off];
    
    graph_display_state = 0;
    mask_display_state = 0;
    
    skid_end_frame_no = 0;
    roll_end_frame_no = 0;
    
    regression_test_status = 0;
    
    mySynthesizer = [[AVSpeechSynthesizer alloc] init];
    
    NSString * speech_comment = @"Welcome to Blast Vision Intelligence. Please select a video.";
    NSString* speech_text = [NSString stringWithFormat:@"%@", speech_comment];
    [self system_sound: 1];
    [self say_phrase :speech_text];

    
    printf("   --- VDMViewController - viewDidLoad\n");
    
    /*x
    // [VDMViewController set_regression_test :true];   // TESTING
    if (regression_test_switch)
    {
        printf("   --- VDMViewController - viewDidLoad - regression_test_switch: %d \n", regression_test_switch);
        // @autoreleasepool
        // {
            // // [VDMSettingsViewController2 set_production_mode :true];    // calling static method
            // // [VDMSettingsViewController2 set_demo_picker_index :22];    // calling static method
            [self run_demo_putt_black_clubhead2];
            // // [self regression_test];
        // }
    }
    x*/
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text Field Delegate
- (BOOL) textFieldShouldReturn:(UITextField *)text_field2
{
    [self.text_field2 resignFirstResponder];    // to remove "focus"
    return YES;    // so that keyboard goes away when pressing return key
    // Also remember to link this text field to this delegate (in storeboard drag the mouse cursor from the text field to the viewcontroller (and selet "Delegate"))
}


#pragma mark - UI Actions

- (IBAction)start_button1:(id)sender {
    // Start the camera when pressing the button
    [self.videoCamera start];
}


- (IBAction) button1 :(id)sender
{
    self.output_label.text = _text_field1.text;
    self.text_field2.text = _text_field1.text;
    
    // To format label from code:
    _output_label.font = [UIFont boldSystemFontOfSize:16];
    
    // To close keyboard when button is pressed:
    [_text_field1 resignFirstResponder];
}


- (IBAction) button2 :(id)sender                                                     // Main video analysis function (labeled "Start Vid")
{
    if (regression_test_switch)
    {
        printf("   --- VDMViewController - button2 (Start Vid) - regression_test_switch: %d \n", regression_test_switch);
        // [self run_demo_putt_black_clubhead2];
        [self regression_test];
    }
    else
    {
        int demo_selection_idx = [VDMSettingsViewController2 get_demo_picker_index];   // calling (static) class method!
        printf("   --- demo_selection_idx: %d    production_mode: %d \n", demo_selection_idx, production_mode);
        // @"Tennis Serve 1",@"Tennis Serve 2",@"Ice Hockey 1",@"Ice Hockey 2",@"Baseball 1",@"Trampoline Jump 1",@"Basketball Jump 1",@"Golf Driver Swing 1",
        // @"Golf Putt 1",@"Golf Putt 2 Carpet",@"Golf Putt 3 Outdoors",@"Golf Putt 3 Outdoors Full",
        // 1                 2                 3               4               5             6                    7                    8
        // 9              10                   11                       12
        if (production_mode)       // array_to_load_picker__production
        {
            switch (demo_selection_idx)
            {
                case  1: [self run_demo_t1]; break;
                case  2: [self run_demo_t2]; break;
                case  3: [self run_demo_h1]; break;
                case  4: [self run_demo_h2]; break;
                case  5: [self run_demo_b1]; break;
                case  6: [self run_demo_p2]; break;
                case  7: [self run_demo_basketball_1]; break;
                case  8: [self run_demo_g1]; break;
                case  9: [self run_demo_g4]; break;
                case 10: [self run_demo_g4_full]; break;
                case 11: [self run_demo_putt_s1_trimmed]; break;
                case 12: [self run_demo_putt_s1_full]; break;
                case 13: [self run_demo_putt_s2_trimmed]; break;
                case 14: [self run_demo_putt_s2_full]; break;
                case 15: [self run_demo_putt_s3_trimmed]; break;
                case 16: [self run_demo_putt_s3_full]; break;
                case 17: [self run_demo_putt_howard_twitty_3_trimmed]; break;
                case 18: [self run_demo_putt_callaway_ball]; break;
                case 19: [self run_demo_putt_blastman_logo]; break;
                case 20: [self run_demo_putt_fuzzy_blastman]; break;
                case 21: [self run_demo_putt_black_clubhead]; break;
                case 22: [self run_demo_putt_black_clubhead2]; break;
                default: [self default_video];
            }
        }
        else  // development mode
        {
            switch (demo_selection_idx)
            {
                case  1: [self run_demo_t1]; break;
                case  2: [self run_demo_t2]; break;
                case  3: [self run_demo_h1]; break;
                case  4: [self run_demo_h2]; break;
                case  5: [self run_demo_b1]; break;
                case  6: [self run_demo_p2]; break;
                case  7: [self run_demo_basketball_1]; break; // basketball
                case  8: [self run_demo_g1]; break;
                case  9: [self run_demo_g2]; break;
                case 10: [self run_demo_g3]; break;           // putt with blastman on carpet
                case 11: [self run_demo_g4]; break;           // putt with blastman - granger - outdoors - 2015-01-27
                case 12: [self run_demo_g4_full]; break;      // putt with blastman - granger - outdoors - 2015-01-27 full length
                case 13: [self run_demo_putt_s1_trimmed]; break;
                case 14: [self run_demo_putt_s1_full]; break;
                case 15: [self run_demo_putt_s2_trimmed]; break;
                case 16: [self run_demo_putt_s2_full]; break;
                case 17: [self run_demo_putt_s3_trimmed]; break;
                case 18: [self run_demo_putt_s3_full]; break;
                case 19: [self run_demo_putt_howard_twitty_3_trimmed]; break;
                case 20: [self run_demo_putt_callaway_ball]; break;
                case 21: [self run_demo_putt_blastman_logo]; break;
                case 22: [self run_demo_putt_fuzzy_blastman]; break;
                case 23: [self run_demo_putt_black_clubhead]; break;
                case 24: [self run_demo_putt_black_clubhead2]; break;
                default: [self default_video];
            }
        }
    }
    
    [select_video_button setTitle:video_label forState:UIControlStateNormal];
}


- (void) default_video        // see process_movie()
{
    path_is_set = false;
    sport = 50; // 70; // 50; // 100;               // 30 = baseball   50 = putt   70 = basketball   100 = auto-curation
    video_fps_override = 0;
    image_orientation = 0;    // default: up
    movie_flow = 1;
    [self blast_video_synch];                                                      // <<<<<<<<<<<<< Play video
    printf("   === End of default_video()");
}


- (IBAction) frame_step :(id)sender {
    [self system_sound: 2];
    if (movie_flow == -1)
    {
        path_is_set = false;
        sport = 0;
        video_fps_override = 0;
        image_orientation = 0;    // default: up
        movie_flow = 0;
        [self blast_video_synch];                                                  // <<<<<<<<<<<<< Play video
    }
    else
    {
        movie_flow = 0;
    }
}


- (IBAction) frame_continue:(id)sender {
    if (movie_flow == -1)
    {
        path_is_set = false;
        sport = 0;
        video_fps_override = 0;
        image_orientation = 0;    // default: up
        movie_flow = 2;
        [self blast_video_synch];                                                  // <<<<<<<<<<<<< Play video
    }
    else if (movie_flow == 2)
    {
        movie_flow = 0;
    }
    else if (movie_flow == 0)
    {
        movie_flow = 2;
    }
    else
    {
        movie_flow = 2;
        printf("   setting movie_flow: %d \n", movie_flow);
    }
}



- (IBAction)demo_t1:(id)sender {
    // [select_video_button setTitle:@"Video 7" forState:UIControlStateNormal];     // testing
    [self run_demo_t1];
}

- (IBAction)demo_t2:(id)sender {
    [self run_demo_t2];
}

- (IBAction)demo_h1:(id)sender {
    [self run_demo_h1];
}

- (IBAction)demo_h2:(id)sender {
    [self run_demo_h2];
}

- (IBAction)demo_b1:(id)sender {
    [self run_demo_b1];
}

- (IBAction)demo_p1:(id)sender {
    [self run_demo_p1];
}

- (IBAction)demo_g1:(id)sender {
    [self run_demo_g1];
}

- (IBAction)demo_g2:(id)sender {
    // [self run_demo_g3];                  // putt with blastman on carpet
    // [self run_demo_putt_howard_twitty_3_trimmed];
    [self run_demo_putt_s2_trimmed];
}


//---------------------------------------------------------------------------------------------------------------------
- (IBAction)select_video :(id)sender
{
    printf("   --- Selecting video\n");
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    // picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
     picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    // picker.sourceType = UIImagePickerControllerSourceTypeCamera;      // take a picture
    
    picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];   // remove this to show images
    NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    if (![sourceTypes containsObject:(NSString *)kUTTypeMovie ])
    {
        NSLog(@"No videos found.");
    }
    else
    {
        // [self presentModalViewController:picker animated:YES];
        [self presentViewController:picker animated:YES completion:NULL];
    }
    // imagePicker release;
}


// This overwrite method is called after UIImagePickerController is finished (after user selects image or video):
-(void) imagePickerController:(UIImagePickerController *)UIPicker didFinishPickingMediaWithInfo:(NSDictionary *) info
{
    printf("   --- Executing imagePickerController - didFinishPickingMediaWithInfo \n");
    
    // NSLog(@"%@", info);
    
    [UIPicker dismissModalViewControllerAnimated:YES];
    // imageview.image=[info objectForKey:"UIImagePickerControllerOriginalImage"];
    // NSLog("Image Path=%@",imageview.image);
    NSURL* file_url1 = (NSURL *)[info valueForKey:UIImagePickerControllerReferenceURL];
    NSString *urlString = [file_url1 absoluteString];
    printf("   --- image url: %s \n", [urlString UTF8String]);
    
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeVideo] || [type isEqualToString:(NSString *)kUTTypeMovie])
    {
        NSURL *urlvideo = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *url_video_string = [urlvideo absoluteString];
        printf("   --- video url: %s \n", [url_video_string UTF8String]);
        
        NSError *err;
        if ([urlvideo checkResourceIsReachableAndReturnError:&err] == NO)
        {
            // [[NSAlert alertWithError:err] runModal];
            printf("       video file does not exist.\n");
        }
        else
        {
            printf("       video file exists.\n");
        }
        
        int sport_selection_idx = [VDMSettingsViewController get_sport_picker_index];         // calling (static) class method!
        printf("      --- imagePickerController:didFinishPickingMediaWithInfo - sport_selection_idx: %d \n", sport_selection_idx);
        
        // 10: tennis   20: ice hockey   30: baseball   40: trampoline   50: putt   60: golf full swing   70: racquet ball   80: volley ball   90: trampoline
        switch (sport_selection_idx)
        {
            case 1: sport =  60; image_orientation = 1; max_num_frames = 800; break;  // golf full swing
            case 2: sport =  50; image_orientation = 1; max_num_frames = 800; break;  // golf putt
            case 3: sport =  30; image_orientation = 0;                       break;  // baseball
            case 4: sport =  20; image_orientation = 0;                       break;  // ice hockey
            case 5: sport =  10; image_orientation = 0; max_num_frames = 270; break;  // tennis
            case 6: sport = 110; image_orientation = 0;                       break;  // racquet ball
            case 7: sport =  80; image_orientation = 0;                       break;  // volley ball
            case 8: sport =  40; image_orientation = 0;                       break;  // trampoline
            case 9: sport =  70; image_orientation = 0; max_num_frames = 150; break;  // basketball
            default: sport =  0; image_orientation = 1;                               // image orientation 1: upside down
        }

        //x sport = 60;
        // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/golf_full_swing/golf_full_swing_Granger_FO_SlowMO_Driver_trimmed.mov"];
        // thePath = @"/private/var/mobile/Containers/Data/Application/86470EBE-01A9-4F1C-A4F1-2A7912850C31/tmp/trim.A8105372-D250-43AB-B651-50360A05C109.MOV";
        // video url: file:///private/var/mobile/Containers/Data/Application/C20263EC-5D2F-4E17-8F6F-F3548567A343/tmp/trim.64785168-5547-4873-A245-D0D46A247242.MOV
        NSString * url_video_substring1 = [url_video_string substringFromIndex:15];      // /var/mobile/Containers/Data/Application/C20263EC-5D2F-4E17-8F6F-F3548567A343/tmp/trim.64785168-5547-4873-A245-D0D46A247242.MOV
        thePath = url_video_substring1;
        path_is_set = true;
        
        // image_orientation = 1;         // image orientation upside down
        [self blast_video_synch];      // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    }

    
    // NSString *video_file_path = [file_url1 path];
    // printf("   --- video_file_path: %s \n", [video_file_path UTF8String]);
    // BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:video_file_path];
    // printf("      video file exists: %d \n", fileExists);

    // BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:urlString];
    // printf("      video file exists: %d \n", fileExists);
    
    // NSError *err;
    // if ([file_url1 checkResourceIsReachableAndReturnError:&err] == NO)
    // {
    //    // [[NSAlert alertWithError:err] runModal];
    //     printf("       video file does not exist.\n");
    // }
    // else
    // {
    //     printf("       video file exists.\n");
    // }
}

/*x
// public override UICollectionViewCell GetCell (UICollectionView collectionView, NSIndexPath indexPath)
-(void) test
{
    var imageCell = (ImageCell)collectionView.DequeueReusableCell (cellId, indexPath);
    imageMgr.RequestImageForAsset ((PHAsset)fetchResults [(uint)indexPath.Item], thumbnailSize,
                                   PHImageContentMode.AspectFill, new PHImageRequestOptions (), (img, info) => {
                                       imageCell.ImageView.Image = img;
                                   });
    return imageCell;
}
x*/
//---------------------------------------------------------------------------------------------------------------------


// These two functions are overwritten to hide the nagivation bar on the main screen (so it doesn't interfere with the video display); 
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];   //it hides
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];    // it shows
}


/*x
// These function are overwritten for the pickerView (sport selection) widget:
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    printf("   --- calling: pickerView - numberOfRowsInComponent \n");
    return [pickerViewArray count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    printf("   --- calling: pickerView - titleForRow - forComponent \n");
    return [self.pickerViewArray objectAtIndex:row];
}

-(IBAction)selectedRow
{
    printf("   --- IBAction: selectRow\n");
    int selectedIndex = [pickerView selectedRowInComponent:0];
    NSString *message = [NSString stringWithFormat:@"You selected: %@",[pickerViewArray objectAtIndex:selectedIndex]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    // [alert release];
}
x*/




- (IBAction)exit_button:(id)sender {
    exit(0);
}




// Demos:

- (void) run_demo_t1                // tennis djokovic
{
    [self set_demo_t1];
    [self blast_video_synch];
    [select_video_button setTitle:video_label forState:UIControlStateNormal];
}

- (void) set_demo_t1               // tennis djokovic
{
    sport = 10;
    demo_id = 1010;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/djokovic_serve_01.mp4"];
    video_label = @"Tennis 1";
    path_is_set = true;
    max_num_frames = 90;
    image_orientation = 0;         // image orientation not upside down
    video_fps_override = 0;        // reset
}


- (void) run_demo_t2               // tennis jh
{
    [self set_demo_t2];
    [self blast_video_synch];
    [select_video_button setTitle:video_label forState:UIControlStateNormal];
}

- (void) set_demo_t2               // tennis jh
{
    sport = 10;
    demo_id = 1011;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/tennis_serve_jh05.mp4"];
    video_label = @"Tennis 2";
    path_is_set = true;
    max_num_frames = 35; // 36; // 90;
    image_orientation = 0;         // image orientation not upside down
    video_fps_override = 0;        // reset
}


- (void) run_demo_h1               // ice hockey slapshot - mishit
{
    [self set_demo_h1];
    [self blast_video_synch];
    [select_video_button setTitle:video_label forState:UIControlStateNormal];
}

- (void) set_demo_h1               // ice hockey slapshot - mishit
{
    sport = 20;
    demo_id = 2010;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ice_hockey_mishit_2014_05_21_trimmed.mov"];
    video_label = @"Hockey 1";
    path_is_set = true;
    max_num_frames = 40; // 30;
    image_orientation = 0;         // image orientation not upside down
    video_fps_override = 0;        // reset
}


- (void) run_demo_h2               // ice hockey slapshot - fast puck
{
    [self set_demo_h2];
    [self blast_video_synch];
    [select_video_button setTitle:video_label forState:UIControlStateNormal];
}

- (void) set_demo_h2               // ice hockey slapshot - fast puck
{
    sport = 20;
    demo_id = 2011;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ice_hockey_slapshot_0376_trimmed.mov"];
    video_label = @"Hockey 2";
    path_is_set = true;
    max_num_frames = 40; // 100;
    image_orientation = 0;         // image orientation not upside down
    video_fps_override = 0;        // reset
}


- (void) run_demo_b1               // baseball slow motion
{
    [self set_demo_b1];
    [self blast_video_synch];
    [select_video_button setTitle:video_label forState:UIControlStateNormal];
}

- (void) set_demo_b1               // baseball slow motion
{
    sport = 30;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball_hit_slo_mo_01.mp4"];
    video_label = @"Baseball 1";
    path_is_set = true;
    max_num_frames = 170;
    image_orientation = 0;         // image orientation not upside down
    video_fps_override = 1000;     // baseball slow motion
}


- (void) run_demo_p1               // trampoline  -- THIS BUTTON HAS BEEN REPURPOSED
{
    /*
    sport = 40;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/trampoline_double_flip.mov"];
    video_label = @"Tramp 1";
    path_is_set = true;
    max_num_frames = 350;
    image_orientation = 0;         // image orientation not upside down
    video_fps_override = 57;
    [self blast_video_synch];
    */
    
    graph_display_state++;
    if (graph_display_state == 5) { graph_display_state = 1; }
    if (graph_display_state == 1)
    {
        [ _draw_field_graph turn_ball_speed_graph_on ];
        [ _draw_field_graph turn_ball_rpm_graph_off ];
        [ _draw_field_graph turn_head_speed_graph_off ];
    }
    else if (graph_display_state == 2)
    {
        [ _draw_field_graph turn_ball_speed_graph_off ];
        [ _draw_field_graph turn_head_speed_graph_off ];
        [ _draw_field_graph turn_ball_rpm_graph_on ];
    }
    else if (graph_display_state == 3)
    {
        [ _draw_field_graph turn_ball_speed_graph_on ];
        [ _draw_field_graph turn_ball_rpm_graph_on ];
        [ _draw_field_graph turn_head_speed_graph_off ];
    }
    else if (graph_display_state == 4)
    {
        [ _draw_field_graph turn_head_speed_graph_on ];
        [ _draw_field_graph turn_ball_speed_graph_on ];
        [ _draw_field_graph turn_ball_rpm_graph_on ];
    }
    [_draw_field_graph setNeedsDisplay];
    
    mask_display_state++;
    if ((mask_display_state % 2) == 0)                // TEMP FOR TESTING
    {
        [self.draw_field2 turn_clubhead_subimg_mask_off];
    }
    else
    {
        [self.draw_field2 turn_clubhead_subimg_mask_on];
    }
    [_draw_field2 setNeedsDisplay];
}


- (void) run_demo_p2               // trampoline 
{
     sport = 40;
     thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/trampoline_double_flip.mov"];
     path_is_set = true;
     max_num_frames = 350;
     image_orientation = 0;         // image orientation not upside down
     video_fps_override = 57;
     [self blast_video_synch];
}


- (void) run_demo_basketball_1
{
    sport = 70;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/basketball/Dunk1_VertHeight.mp4"];
    video_label = @"Tramp 1";
    path_is_set = true;
    max_num_frames = 150;
    image_orientation = 0;         // image orientation not upside down
    // obj_rot_ref_frame = 35;
    // video_fps_override = 29;
    [self blast_video_synch];
}


- (void) run_demo_g1               // golf full swing
{
    [self set_demo_g1];
    [self blast_video_synch];
}

- (void) set_demo_g1               // golf full swing
{
    sport = 60;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/golf_full_swing/golf_full_swing_Granger_FO_SlowMO_Driver_trimmed.mov"];
    video_label = @"G Swing 1";
    path_is_set = true;
    max_num_frames = 60; // 75;
    image_orientation = 1;         // image orientation upside down
    video_fps_override = 0;        // reset
}


- (void) run_demo_g2               // golf putt
{
    [self set_demo_g2];
    [self blast_video_synch];
}

- (void) set_demo_g2               // golf putt
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/blast_putt_with_ball_marks_trimmed.mp4"];
    video_label = @"G Putt 1";
    path_is_set = true;
    max_num_frames = 50;
    image_orientation = 0;         // image orientation not upside down
    obj_rot_ref_frame = 35;
    video_fps_override = 29;
}


- (void) run_demo_g3               // golf putt 3
{
    [self set_demo_g3];
    [self blast_video_synch];
}

- (void) set_demo_g3               // golf putt 3
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_carpet_trimmed.mov"];
    video_label = @"G Putt 2";
    path_is_set = true;
    max_num_frames = 200;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    // video_fps_override = 29;
}


- (void) run_demo_g4               // golf putt 4
{
    [self set_demo_g4];
    [self blast_video_synch];
}

- (void) set_demo_g4               // golf putt 4
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_2_Granger_trimmed.mov"];
    video_label = @"G Putt 3";
    path_is_set = true;
    max_num_frames = 200;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    // video_fps_override = 29;
}


- (void) run_demo_g4_full               // golf putt 4 full length
{
    [self set_demo_g4_full];
    [self blast_video_synch];
}

- (void) set_demo_g4_full               // golf putt 4 full length
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_2_Granger_full.mov"];
    video_label = @"G Putt 4";
    path_is_set = true;
    max_num_frames = 800;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    // video_fps_override = 29;
}


- (void) run_demo_putt_s1_trimmed         // golf putt steve 1 full
{
    [self set_demo_putt_s1_trimmed];
    [self blast_video_synch];
}

- (void) set_demo_putt_s1_trimmed         // golf putt steve 1 full
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_steve_1_trimmed_10.mov"];
    path_is_set = true;
    max_num_frames = 400;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
}


- (void) run_demo_putt_s1_full         // golf putt steve 1 trimmed
{
    [self set_demo_putt_s1_full];
    [self blast_video_synch];
}

- (void) set_demo_putt_s1_full         // golf putt steve 1 trimmed
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_steve_1_full.mov"];
    path_is_set = true;
    max_num_frames = 1000;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
}


- (void) run_demo_putt_s2_trimmed         // golf putt steve 2 trimmed
{
    [self set_demo_putt_s2_trimmed];
    [self blast_video_synch];
}

- (void) set_demo_putt_s2_trimmed         // golf putt steve 2 trimmed
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_steve_2_trimmed_10.mov"];
    path_is_set = true;
    max_num_frames = 400;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
}


- (void) run_demo_putt_s2_full         // golf putt steve 2 trimmed
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_steve_2_full.mov"];
    path_is_set = true;
    max_num_frames = 1000;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    [self blast_video_synch];
}


- (void) run_demo_putt_s3_trimmed         // golf putt steve 3 full
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_steve_3_trimmed.mov"];
    path_is_set = true;
    max_num_frames = 400;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    [self blast_video_synch];
}


- (void) run_demo_putt_s3_full         // golf putt steve 3 trimmed
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_steve_3_full.mov"];
    path_is_set = true;
    max_num_frames = 1000;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    [self blast_video_synch];
}


- (void) run_demo_putt_howard_twitty_3_trimmed         // golf putt howard twitty
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_02_20_howard_twitty-3_trimmed.mov"];
    path_is_set = true;
    max_num_frames = 400;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    [self blast_video_synch];
}


- (void) run_demo_putt_callaway_ball         // golf putt with callaway logo on ball (for rotation tracking)
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_02_14_1_Granger_full.mov"];
    path_is_set = true;
    max_num_frames = 400;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    [self blast_video_synch];
}


- (void) run_demo_putt_blastman_logo         // golf putt with blastman logo
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_03_19_IMG_0044_trimmed.mov"];
    path_is_set = true;
    max_num_frames = 400;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    [self blast_video_synch];
}


- (void) run_demo_putt_fuzzy_blastman         // golf putt with blastman logo
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_03_19_IMG_0050_trimmed.mov"];
    path_is_set = true;
    max_num_frames = 400;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    [self blast_video_synch];
}


- (void) run_demo_putt_black_clubhead         // golf putt with black clubhead
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_03_19_IMG_0044_trimmed.mov"];
    path_is_set = true;
    max_num_frames = 400;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    [self blast_video_synch];
}


- (void) run_demo_putt_black_clubhead2         // golf putt with black clubhead
{
    sport = 50;
    thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_03_24_0009.mov"];
    path_is_set = true;
    max_num_frames = 800;
    image_orientation = 1;         // image orientation not upside down
    obj_rot_ref_frame = 35;        // not used anymore
    [self blast_video_synch];
}






#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
- (void)processImage:(Mat&)image;
{
    // Do some OpenCV stuff with the image
    
    Mat image_copy;
    cvtColor(image, image_copy, CV_BGRA2BGR);
    
    // invert image
    bitwise_not(image_copy, image_copy);
    cvtColor(image_copy, image, CV_BGR2BGRA);

}
#endif


/*
- (void)imagePickerController:(UIImagePickerController *)picker
                              didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString * mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:kUTTypeMovie])
        [self readMovie:[info objectForKey:UIImagePickerControllerMediaURL]];
    
    [self dismissModalViewControllerAnimated:YES];
}
*/


/*x
#ifdef __cplusplus
void process_video (int mode)
// - (void)process_video.NSString
{
    NSLog(@"   This is process_video");
    
    // Add Mediaplayer framework and do #import <MediaPlayer/MediaPlayer.h> in viewController.
    
    // Get the path of the local video:
    
 //   NSString*thePath=[[NSBundle mainBundle] pathForResource:@"/Users/jhaas/XcodeProjects/metrics_from_video/data/videos/fed_serve.MOV" ofType:@"MOV"];                // MOV video file
    // NSString *filepath   =   [[NSBundle mainBundle] pathForResource:@"/Users/jhaas/XcodeProjects/metrics_from_video/data/videos/two_serves.mp4" ofType:@"m4v"];    // MP4 video file
    
 //   NSURL*theurl=[NSURL fileURLWithPath:thePath];
    
    
    // Initialize the moviePlayer with your path:
    
   // self.moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:theurl];
    // [self.moviePlayer.view setFrame:CGRectMake(40, 197, 240, 160)];
    // [self.moviePlayer prepareToPlay];
    // [self.moviePlayer setShouldAutoplay:NO]; // And other options you can look through the documentation.
    // [self.view addSubview:self.moviePlayer.view];
    
    
    // To control what is to be done after playback:
    
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    // playBackFinished will be your own method.
}
#endif
x*/


-(void) process_video_test {
    printf("   process_video_test ... %i/%i \n", numerator, denominator );
    
    // Add Mediaplayer framework and do #import <MediaPlayer/MediaPlayer.h> in viewController.
    
    // Get the path of the local video:
    
    // NSString* thePath = [[NSBundle mainBundle] pathForResource:@"/Users/jhaas/XcodeProjects/metrics_from_video/data/videos/fed_serve.MOV" ofType:@"MOV"];                // MOV video file
   //  NSString* thePath = [[NSBundle mainBundle] pathForResource:@"fed_serve.MOV" ofType:@"MOV"];                // MOV video file
    
    
    NSString * thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/fed_serve.MOV"];     // works
    // NSString * thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/two_serves.mp4"];     // works
    
    const char * movie_path = [thePath UTF8String];
    printf("   Reading file %s \n", movie_path);
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:thePath];
    printf("      file exists: %d \n", fileExists);
    
    // NSURL * theurl = [NSURL fileURLWithPath:thePath];
    
    // Initialize the moviePlayer with your path:
    
    /*
    MPMoviePlayerController * moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:theurl];
    [moviePlayer.view setFrame:CGRectMake(40, 197, 340, 260)];
    [moviePlayer prepareToPlay];
    [moviePlayer setShouldAutoplay:NO]; // And other options you can look through the documentation.
    // [self addSubview:self.moviePlayer.view];
    [_image_field1 addSubview:moviePlayer.view];
    [moviePlayer play];
    */
    
    // http://stackoverflow.com/questions/12822420/ios-how-to-use-mpmovieplayercontroller
    // NSURL *movieURL = [NSURL URLWithString:@"http://example.com/somefile.mp4"];
    NSURL * movieURL = [NSURL fileURLWithPath:thePath];
    MPMoviePlayerViewController * movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    // [movieController setShouldAutoplay:NO]; // And other options you can look through the documentation.
    [self presentMoviePlayerViewControllerAnimated:movieController];
    [movieController.moviePlayer play];
    
    // you should keep a reference to your MPMoviePlayerViewController in order to dismiss it later with
    
    // [self dismissMoviePlayerViewControllerAnimated:movieController];
    
}


#pragma mark - Main video synchronization function - blast_video_synch
- (void) blast_video_synch                                                         // Main video synchronization function ------------------------------------------------------------------------------------
{
    [self system_sound: 16];
    
    if (production_mode)
    {
        [self.draw_field2 turn_clubhead_subimg_mask_off];
    }
    
                       [ _draw_field2 turn_text_display_off ];
    if (sport == 50) { [ _draw_field2 turn_text_display_on  ]; }      // Turn text display on for Putt
    
    shift_box2_x = -100;     // remove blue box from view
    shift_box2_y = -100;
    
    shift_box3_x = -100;     // remove green box from view
    shift_box3_y = -100;
    
    // First make sure previous video is terminated (cancelled):
    video_cnt++;
    printf("                  -1- blast_video_synch - movie_flow: %d   movie_is_running: %d   video_cnt: %d   sport: %d \n", movie_flow, movie_is_running, video_cnt, sport);
    
    

    
    /*
    if (movie_is_running)
    {
        while (movie_flow != 10)                                                   // wait until previous video is cancelled (runs in seperate thread) - it should set movie_flow to 10 when it is cancelled
        {
            movie_flow = 9;                                                        // 9 means the previous video is requested to terminate
            [NSThread sleepForTimeInterval:0.1];
            printf("                  -2- blast_video_synch - movie_flow: %d   movie_is_running: %d \n", movie_flow, movie_is_running);
            return;
        }
    }
    */

    
    // Testing threading:
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        
        /*
        if (regression_test_switch)
        {
            while (regression_test_status != 1)     // 1 means: previous video is finished
            {
                printf("      ---*--- blast_video_synch -- regression_test_status: %d \n", regression_test_status);
                [NSThread sleepForTimeInterval:0.25];
            }
            regression_test_status = 0;    // so that the next video waits until this one is finished
        }
        */
        
        printf("   -1- In new thread --- \n");
        
        if (movie_is_running)
        {
            while (movie_is_running) // (movie_flow != 10)                             // wait until previous video is cancelled (runs in seperate thread) - it should set movie_flow to 10 when it is cancelled
            {
                movie_flow = 9;                                                        // 9 means the previous video is requested to terminate
                [NSThread sleepForTimeInterval:0.1];
                printf("                  -2- blast_video_synch - movie_flow: %d   movie_is_running: %d \n", movie_flow, movie_is_running);
            }
        }

        printf("   -2- In new thread --- \n");

        movie_flow = 1;             // initialize to regular playing mode - may want to use condition: if (movie_flow != 0)  (starting in step by step mode)
        movie_is_running = 1;
        
        NSDate *methodStart = [NSDate date];
        
        
        [NSThread sleepForTimeInterval:0.2];    // give 0.2 sec. for garbage collection before starting new movie?
        
        printf("   Running separate thread.\n");
        self.output_label.text = [NSString stringWithFormat:@"   test_count: %d \n", test_count++];
        
        max_ball_speed_mph      = 0.0f;
        max_clubhead_speed_mph  = 0.0f;
        impact_clubhead_speed_mph = 0.0f;
        max_swing_speed_mph     = 0.0f;
        impact_frame_no         = 0;              // initialize
        impact_ball_position_x  = 0.0f;
        impact_ball_position_y  = 0.0f;
        down_sampling_factor    = 1;              // reset
        fps_reduction_factor    = 1;              // reset

        impact_obj_pos_x = -100;                  // keep out of view
        impact_obj_pos_y = -100;                  // keep out of view
        
        ninety_deg_obj_pos_x = -100;              // keep out of view
        ninety_deg_obj_pos_y = -100;              // keep out of view

        prev_obj_center_x = 0.0f;                 // reset
        prev_obj_center_y = 0.0f;                 // reset
        
        prev_ball_radius = 0.0f;                  // reset
        
        
        int phase = 1;
        [self process_movie :phase];                                               // <<<<<<<<<<<<<  process movie to find impact frame
        
        
        if (! (movie_flow == 10))    // if movie was not cancelled
        {
           [self system_sound: 1];
        }

        // [NSThread sleepForTimeInterval:0.4];    // give 0.4 sec. for garbage collection before starting new movie?
        //x if (! regression_test_switch)              // don't run phase 2 in regression test mode
        //x {
           movie_flow = 0;                         // pause so that user can review the data and graphs
           while (movie_flow == 0)
           {
               [NSThread sleepForTimeInterval:0.1];
           }
 
           if (! (movie_flow == 10))    // if movie was not cancelled
           {
              phase = 2;
              [self process_movie :phase];                                            // <<<<<<<<<<<<<  process movie to show video in synch with sensor graph
           }
        //x }
 
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            
            [self.output_label setNeedsDisplay];
        });
        
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"   --- ExecutionTime = %f", executionTime);
        
        if (! (movie_flow == 10))    // if movie was not cancelled
        {
           [self talk];
        }
        
        movie_is_running = 0;
        regression_test_status = 1;    // 1 means: video is finished
        
        printf("      === End of dispatch_async in blast_video_synch() \n");
    });
    
    printf("   === End of blast_video_synch() \n");
}



-(void) talk
{
    if (max_ball_speed_mph > 0.0f)
    {
        printf("                  --- talk - video_cnt: %d \n", video_cnt);
        // int ball_speed_max_int = (int) max_ball_speed_mph;
        // NSString* speech_text = [NSString stringWithFormat:@"outstanding - ball speed %d mile per hour", ball_speed_max_int];
        NSString * speech_comment = @"Nice";
        if (sport == 10) // tennis
        {
            if ((video_cnt % 2) == 1) { speech_comment = @"Good serve"; }
            else { speech_comment = @"Outstanding"; }
        }
        if (sport == 20) // ice hockey
        {
            if ((video_cnt % 2) == 1) { speech_comment = @"Nice swing"; }
            else { speech_comment = @"Excellent"; }
        }
        if (sport == 30) // baseball
        {
            if ((video_cnt % 2) == 1) { speech_comment = @"Great hit"; }
            else { speech_comment = @"Great swing"; }
        }
        if (sport == 50) // putt
        {
            if ((video_cnt % 2) == 1) { speech_comment = @"Nice touch"; }
            else { speech_comment = @"Perfect"; }
        }
        if (sport == 60) // full swing
        {
            if ((video_cnt % 2) == 1) { speech_comment = @"Great shot Granger"; }
            else { speech_comment = @"Terrific"; }
        }
        if (sport == 70) // full swing
        {
            if ((video_cnt % 2) == 1) { speech_comment = @"Nice slam"; }
            else { speech_comment = @"Cool"; }
        }
        NSString* speech_text = [NSString stringWithFormat:@"%@ - ball speed %1.1f mile per hour", speech_comment, max_ball_speed_mph];
        // [self system_sound: 1];
        [self say_phrase :speech_text];
    }
}



-(void) say_phrase :(NSString*)phrase
{
    printf("   --- Calling voice synthesizer ... %s \n", [phrase UTF8String]);
    NSString* speech_text = phrase;
    // NSString* speech_text = @"seven hundred and five";
    // NSString* speech_text = @"312";
    
    // NSString* text = textView.text;
    // float rate = rateSlider.value;
    float rate = 0.08f; // 0.10f;
    // float pitch = pitchSlider.value;
    float pitch = 1.25; // 0.25; // 0.5;
    AVSpeechUtterance* myTestUtterance = [[AVSpeechUtterance alloc] initWithString:speech_text];
    myTestUtterance.rate = rate;
    myTestUtterance.pitchMultiplier = pitch;
    // myTestUtterance.volume = 0.9f;
    myTestUtterance.volume = 20.0f;
    [mySynthesizer speakUtterance:myTestUtterance];
}



-(void) system_sound :(int)index
{
    NSError* error;
    [[AVAudioSession sharedInstance]
     setCategory:AVAudioSessionCategoryPlayAndRecord
     error:&error];
    if (error == nil) {
        SystemSoundID myAlertSound;
        // NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/new-mail.caf"];
        NSURL *url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Modern/airdrop_invite.caf"];
        switch (index)
        {
            case  2: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/Tock.caf"]; break;
            case  3: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Anticipate.caf"]; break;
            case  4: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Bloom.caf"]; break;
            case  5: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Calypso.caf"]; break;
            case  6: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Choo_Choo.caf"]; break;
            case  7: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Descent.caf"]; break;
            case  8: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Fanfare.caf"]; break;
            case  9: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Fanfare.caf"]; break;
            case 10: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Ladder.caf"]; break;
            case 11: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Minuet.caf"]; break;
            case 12: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/News_Flash.caf"]; break;
            case 13: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Noir.caf"]; break;
            case 14: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Sherwood_Forest.caf"]; break;
            case 15: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/New/Spell.caf"]; break;
            case 16: url = [NSURL URLWithString:@"/System/Library/Audio/UISounds/jbl_begin.caf"]; break;
        }
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &myAlertSound);
        
        AudioServicesPlaySystemSound(myAlertSound);
        
    }
    
    /*
    /System/Library/Audio/UISounds/Modern/airdrop_invite.caf
    /System/Library/Audio/UISounds/Modern/calendar_alert_chord.caf
    /System/Library/Audio/UISounds/Modern/camera_shutter_burst.caf
    /System/Library/Audio/UISounds/Modern/camera_shutter_burst_begin.caf
    /System/Library/Audio/UISounds/Modern/camera_shutter_burst_end.caf
    /System/Library/Audio/UISounds/Modern/sms_alert_aurora.caf
    /System/Library/Audio/UISounds/Modern/sms_alert_bamboo.caf
    /System/Library/Audio/UISounds/Modern/sms_alert_circles.caf
    /System/Library/Audio/UISounds/Modern/sms_alert_complete.caf
    /System/Library/Audio/UISounds/Modern/sms_alert_hello.caf
    /System/Library/Audio/UISounds/Modern/sms_alert_input.caf
    /System/Library/Audio/UISounds/Modern/sms_alert_keys.caf
    /System/Library/Audio/UISounds/Modern/sms_alert_note.caf
    /System/Library/Audio/UISounds/Modern/sms_alert_popcorn.caf
    /System/Library/Audio/UISounds/Modern/sms_alert_synth.caf
    /System/Library/Audio/UISounds/New/Anticipate.caf
    /System/Library/Audio/UISounds/New/Bloom.caf
    /System/Library/Audio/UISounds/New/Calypso.caf
    /System/Library/Audio/UISounds/New/Choo_Choo.caf
    /System/Library/Audio/UISounds/New/Descent.caf
    /System/Library/Audio/UISounds/New/Fanfare.caf
    /System/Library/Audio/UISounds/New/Ladder.caf
    /System/Library/Audio/UISounds/New/Minuet.caf
    /System/Library/Audio/UISounds/New/News_Flash.caf
    /System/Library/Audio/UISounds/New/Noir.caf
    /System/Library/Audio/UISounds/New/Sherwood_Forest.caf
    /System/Library/Audio/UISounds/New/Spell.caf
    /System/Library/Audio/UISounds/New/Suspense.caf
    /System/Library/Audio/UISounds/New/Telegraph.caf
    /System/Library/Audio/UISounds/New/Tiptoes.caf
    /System/Library/Audio/UISounds/New/Typewriters.caf
    /System/Library/Audio/UISounds/New/Update.caf
    /System/Library/Audio/UISounds/ReceivedMessage.caf
    /System/Library/Audio/UISounds/RingerChanged.caf
    /System/Library/Audio/UISounds/SIMToolkitCallDropped.caf
    /System/Library/Audio/UISounds/SIMToolkitGeneralBeep.caf
    /System/Library/Audio/UISounds/SIMToolkitNegativeACK.caf
    /System/Library/Audio/UISounds/SIMToolkitPositiveACK.caf
    /System/Library/Audio/UISounds/SIMToolkitSMS.caf
    /System/Library/Audio/UISounds/SentMessage.caf
    /System/Library/Audio/UISounds/Swish.caf
    /System/Library/Audio/UISounds/Tink.caf
    /System/Library/Audio/UISounds/Tock.caf
    /System/Library/Audio/UISounds/Voicemail.caf
    /System/Library/Audio/UISounds/alarm.caf
    /System/Library/Audio/UISounds/beep-beep.caf
    /System/Library/Audio/UISounds/begin_record.caf
    /System/Library/Audio/UISounds/begin_video_record.caf
    /System/Library/Audio/UISounds/ct-busy.caf
    /System/Library/Audio/UISounds/ct-call-waiting.caf
    /System/Library/Audio/UISounds/ct-congestion.caf
    /System/Library/Audio/UISounds/ct-error.caf
    /System/Library/Audio/UISounds/ct-keytone2.caf
    /System/Library/Audio/UISounds/ct-path-ack.caf
    /System/Library/Audio/UISounds/dtmf-0.caf
    /System/Library/Audio/UISounds/dtmf-1.caf
    /System/Library/Audio/UISounds/dtmf-2.caf
    /System/Library/Audio/UISounds/dtmf-3.caf
    /System/Library/Audio/UISounds/dtmf-4.caf
    /System/Library/Audio/UISounds/dtmf-5.caf
    /System/Library/Audio/UISounds/dtmf-6.caf
    /System/Library/Audio/UISounds/dtmf-7.caf
    /System/Library/Audio/UISounds/dtmf-8.caf
    /System/Library/Audio/UISounds/dtmf-9.caf
    /System/Library/Audio/UISounds/dtmf-pound.caf
    /System/Library/Audio/UISounds/dtmf-star.caf
    /System/Library/Audio/UISounds/end_record.caf
    /System/Library/Audio/UISounds/end_video_record.caf
    /System/Library/Audio/UISounds/jbl_ambiguous.caf
    /System/Library/Audio/UISounds/jbl_begin.caf
    /System/Library/Audio/UISounds/jbl_cancel.caf
    /System/Library/Audio/UISounds/jbl_confirm.caf
    /System/Library/Audio/UISounds/jbl_no_match.caf
    /System/Library/Audio/UISounds/lock.caf
    /System/Library/Audio/UISounds/long_low_short_high.caf
    /System/Library/Audio/UISounds/low_power.caf
    /System/Library/Audio/UISounds/mail-sent.caf
    /System/Library/Audio/UISounds/middle_9_short_double_low.caf
    /System/Library/Audio/UISounds/new-mail.caf
    /System/Library/Audio/UISounds/photoShutter.caf
    /System/Library/Audio/UISounds/shake.caf
    /System/Library/Audio/UISounds/short_double_high.caf
    /System/Library/Audio/UISounds/short_double_low.caf
    /System/Library/Audio/UISounds/short_low_high.caf
    /System/Library/Audio/UISounds/sms-received1.caf
    /System/Library/Audio/UISounds/sms-received2.caf
    /System/Library/Audio/UISounds/sms-received3.caf
    /System/Library/Audio/UISounds/sms-received4.caf
    /System/Library/Audio/UISounds/sms-received5.caf
    /System/Library/Audio/UISounds/sms-received6.caf
    /System/Library/Audio/UISounds/sq_alarm.caf
    /System/Library/Audio/UISounds/sq_beep-beep.caf
    /System/Library/Audio/UISounds/sq_lock.caf
    /System/Library/Audio/UISounds/sq_tock.caf
    /System/Library/Audio/UISounds/tweet_sent.caf
    /System/Library/Audio/UISounds/unlock.caf
    /System/Library/Audio/UISounds/ussd.caf
    /System/Library/Audio/UISounds/vc~ended.caf
    /System/Library/Audio/UISounds/vc~invitation-accepted.caf
    /System/Library/Audio/UISounds/vc~ringing.caf
    */
}



// TODO: process_movie
-(void) process_movie :(int)phase
{
    printf("   process_movie ... \n" );
    
    NSDate *movie_start_time = [NSDate date];
    
    // TODO: Set the sport code to select video
    if (sport == 0)     // Need to change "default_video()"
    {
        sport = 50; // 100; // 10; // 70; // 10: tennis   20: ice hockey   30: baseball   40: trampoline   50: putt   60: golf full swing   70: basketball   100: auto-curation
    }
    
    if (phase == 1)
    {
        if (sport == 50)  { [ _draw_field_graph turn_graph_display_on]; }          //  turn graphs on for putt
    }
    else
    {
        [ _draw_field_graph turn_graph_display_off];
    }
    
    int image_field_width  = 0;
    int image_field_height = 0;
    
    NSString *home_dir = [NSHomeDirectory() stringByAppendingPathComponent:@""];
    const char * home_dir_path = [home_dir UTF8String];
    printf("   home_dir_path: %s \n", home_dir_path);

    
    if (! path_is_set)    // path may already have been set by imagePickerController:didFinishPickingMediaWithInfo
    {
        max_num_frames = 90;    // 105; // 104; // 110; // 80; // 160; // 800;
        if (sport == 10)   // tennis
        {
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/fed_serve.MOV"];              max_num_frames = 90;     // works
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/granger_serve.MOV"];          max_num_frames = 90;     // works
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/two_serves.mp4"];             max_num_frames = 90;     // works
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/federer_two_serves.mp4"];     max_num_frames = 90;     // works ***
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Roger_Federer_slow_motion_serve_01.mp4"];     max_num_frames = 90;  // works
          //   thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/djokovic_serve_01.mp4"];         max_num_frames = 90;     // TODO: tennis video demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/tennis_serve_jh05.mp4"];      max_num_frames = 90;
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball/convert_baseball_video_03.m4v"];   max_num_frames = 170;
            thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/tennis/serve01_jh_2014-11-30_trimmed.mov"];   max_num_frames = 270;
        }
        else if (sport == 20)   // ice hockey
        {
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ice_hockey_slapshot_trimmed.mov"];              max_num_frames = 100;   // ice hockey -- works
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ice_hockey_slapshot_red_car_trimmed.mov"];      max_num_frames = 100;   // ice hockey -- has issues
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ice_hockey_slapshot_2014_05_21.MOV"];           max_num_frames = 100;   // ice hockey
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ice_hockey_slapshot_2014_05_21_rotated.mov"];   max_num_frames = 100;   // ice hockey
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ice_hockey_mishit_2014_05_21_trimmed.mov"];     max_num_frames = 100;   // ice hockey slapshot - mishit
               thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ice_hockey_slapshot_0376_trimmed.mov"];         max_num_frames =  40;   // ice hockey slapshot - fast puck
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/roller_hockey_Nick_18.17.41.mov"];              max_num_frames = 100;   // roller hockey slapshot - problem format
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/roller_hockey_nick_18.17.41_trimmed2.mov"];     max_num_frames = 100;   // roller hockey slapshot
        }
        else if (sport == 30)   // baseball
        {
               thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball_hit_slo_mo_01.mp4"];               max_num_frames = 170;   video_fps_override = 1000;  // baseball slow motion
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball_2014_08_24.MOV"];                  max_num_frames = 170;   // crashes
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball/convert_baseball_video_01.mov"];   max_num_frames = 170;   // doesn't work
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball/convert_baseball_video_02.mov"];   max_num_frames = 170;   // doesn't work
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball/convert_baseball_video_02.m4v"];   max_num_frames = 170;
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball/baseball_behind_net.MOV"];         max_num_frames = 170;   image_orientation = 1;    // image orientation upside down
        }
        else if (sport == 40)   // tampoline
        {
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/trampoline_double_flip.MOV"];   max_num_frames = 350;   video_fps_override = 57; // 29;  // trampoline
               thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/trampoline_double_flip.mov"];   max_num_frames = 350;   video_fps_override = 57; // 29;  // trampoline
        }
        else if (sport == 50)   // putt
        {
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/blast_putt_trimmed.mp4"];                            max_num_frames =   18;   video_fps_override = 29;
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/blast_putt_video_orig.mp4"];                    max_num_frames =   30;   video_fps_override = 29;   obj_rot_ref_frame = 18;  // demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/blast_putt_with_ball_marks_trimmed.mp4"];       max_num_frames =   50;   video_fps_override = 29;   obj_rot_ref_frame = 35;  // demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2014_12_09_trimmed.mov"];                  max_num_frames =  190;   obj_rot_ref_frame = 35;                           // demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_with_black_mark.mp4"];                     max_num_frames =  190;   obj_rot_ref_frame = 35;                           // demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_with_black_mark.mp4"];                     max_num_frames =  190;   obj_rot_ref_frame = 35;                           // demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2014_12_09_black_marks.mov"];              max_num_frames =  220;   obj_rot_ref_frame = 35;                           // demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2014_12_31_indoor_trimmed.mov"];           max_num_frames =  320;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - image orientation upside down
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2014_12_31_indoor_trimmed2.mov"];          max_num_frames =  320;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - image orientation upside down
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_carpet_trimmed.mov"];                      max_num_frames =  200;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - image orientation upside down
      //       thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_2_Granger_trimmed.mov"];        max_num_frames =  200;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - image orientation upside down                 -- include in regression test
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_2_Granger_full.mov"];           max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - image orientation upside down
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_steve_1_full.mov"];             max_num_frames = 1000;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - image orientation upside down
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_steve_1_trimmed_10.mov"];       max_num_frames = 1000;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - image orientation upside down
      //       thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_steve_2_trimmed_10.mov"];       max_num_frames =  200;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - image orientation upside down                 -- include in regression test
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_01_27_steve_2_full.mov"];             max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - image orientation upside down
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_02_14_1_Granger_full.mov"];           max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - callaway balls                                -- include in regression test
      //       thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_02_14_2_Granger_full.mov"];           max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - callaway balls -- DOES NOT RECOGNIZE BALL (too small?) - NEED TO FIX
   //          thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_02_14_3_Granger_full.mov"];           max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - callaway balls -- DOES NOT RECOGNIZE BALL (too small?) - NEED TO FIX - FIXED
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_03_17_left_handed_trimmed.mov"];      max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 0;  // left handed - low resolution 568x320 - bad video
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_02_20_1_riviera_trimmed.mov"];        max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - worn blastman logo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_02_20_danny_lee-2_trimmed.mov"];      max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - callaway balls                                -- include in regression test
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_02_20_howard_twitty-1_trimmed.mov"];  max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - worn blastman logo                            -- include in regression test
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_02_20_howard_twitty-2_trimmed.mov"];  max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - cross on ball                                 -- include in regression test
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_02_20_howard_twitty-3_trimmed.mov"];  max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - worn blastman logo -- make this faster        -- include in regression test
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_03_19_IMG_0022_lefty_trimmed.mov"];   max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - "practice" logo -- LEFTY SWING - NEED TO FIX FOR LEFT SWING
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_03_19_IMG_0044_trimmed.mov"];         max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - blastman logo                            -- include in regression test
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_03_19_IMG_0050_trimmed.mov"];         max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - blastman logo -- ball is not clear after impact
          //   thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_03_24_0008.mov"];                     max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - half cross mark -- black club head
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_03_24_0009.mov"];                     max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - half cross mark -- black club head
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_07_10_0135_568x320.MOV"];             max_num_frames =  800;   video_fps_override = 240;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - low resolution test
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_07_10_0140_568x320.MOV"];             max_num_frames =  800;   video_fps_override = 240;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - low resolution test
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_07_08_IMG_0138.MOV"];                 max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_07_08_IMG_0139.MOV"];                 max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_07_08_IMG_0140.MOV"];                 max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo
             thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_07_08_IMG_0141.MOV"];                 max_num_frames =  2000;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - PROBLEM WITH SHAFT AND BALL ROTATION TRACKGING -- works now - trim and add to regression test
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_07_08_IMG_0142.MOV"];                 max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - BALL IS NOT DETECTED
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/putt_2015_07_08_IMG_0143.MOV"];                 max_num_frames =  800;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - BALL IS NOT DETECTED
        }
        else if (sport == 60)   // golf full swing
        {
            thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/golf_full_swing/golf_full_swing_Granger_FO_SlowMO_Driver_trimmed.mov"];   max_num_frames = 75;   image_orientation = 1;    // demo - image orientation upside down
        }
        else if (sport == 70)   // baseketball
        {
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/basketball/Dunk3_VertHeight_trimmed.mp4"];   max_num_frames = 100;   image_orientation = 0;    // demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/basketball/Dunk1_VertHeight.mp4"];   max_num_frames = 150;   image_orientation = 0;   // demo
            // thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/basketball/highschool_slamdunk.mp4"];   max_num_frames = 150;   image_orientation = 0;   // demo
            thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/basketball/highschool_slamdunk_01.mp4"];   max_num_frames = 150;   image_orientation = 0;   // demo
        }
        else if (sport == 100)   // auto-curation
        {
            thePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt/multi_putt_0008.mp4"];   max_num_frames = 2400;   obj_rot_ref_frame = 35;   image_orientation = 1;  // demo - multi-action for auto-curation testing -- ALSO NEED TO IMPROVE BALL DETECTION
        }
    }
    
    
    const char * movie_path = [thePath UTF8String];
    printf("   Reading file %s  --  sport: %d \n", movie_path, sport);
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:thePath];
    printf("      file exists: %d \n", fileExists);
    
    // NSURL * theurl = [NSURL fileURLWithPath:thePath];
    video_url = [NSURL fileURLWithPath:thePath];

    [self readMovie:video_url];                                                                   // <<<<<<<<<<<<<<<<<<
    
    int pix_arr_length = 0;           // set below
    unsigned char* prev0_pix_arr;     // allocated below
    unsigned char* prev1_pix_arr;     // allocated below
    unsigned char* prev2_pix_arr;     // allocated below
    pix_arr_ptr = 0;                  // first img is saved to prev1_pix_arr
    
    signed char* img_sect_align;            // allocated below
    signed char* img_sect_align_curr_pprev; // allocated below
    
    
    // Load and show the sensor data graph:
    if (phase == 2)
    {
        // NSString * graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/granger_fast_serve_gyros.png"];        [_draw_field_graph set_x_slide_offset :335];
        NSString * graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/tennis_serve_jump_height.png"];           [_draw_field_graph set_x_slide_offset :30];
        
        if (sport == 20)        // hockey
        {
            graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ice_hockey_slapshot_trimmed.png"];
        }
        else if (sport == 30)   // baseball
        {
         // graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball_gyro_sample1.png"];
            graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball_gyro_sample2.png"];
        }
        else if (sport == 40)   // trampoline
        {
            graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/trampoline_double_flip_trimmed.png"];
        }
        else if (sport == 50)   // putt
        {
            // graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball_gyro_sample1.png"];
            graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt_blast_gyro_graph.png"];
        }
        else if (sport == 60)   // full swing
        {
            graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/golf_full_swing/golf_full_swing_gyro_graph_trimmed.png"];
        }
        else if (sport == 70)   // basketball jump
        {
            graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/basketball/basketball_2014-08-16.12_36_27_small.png"];      // THIS IS NOT A FULL SWING GRAPH
        }
        else if (sport == 100)   // auto-curation
        {
            // graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/baseball_gyro_sample1.png"];
            graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/putt_blast_gyro_graph.png"];
        }
        
        NSURL * graph_url = [NSURL fileURLWithPath:graph_path];
        NSData *graph_data = [NSData dataWithContentsOfURL:graph_url];
        UIImage *graph_img = [[UIImage alloc] initWithData:graph_data];
        [self.sensor_data_graph performSelectorOnMainThread:@selector(setImage:) withObject:graph_img waitUntilDone:YES];       // display sensor data graph
    }
    else // phase == 1
    {
        NSString * graph_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/blank.png"];
        NSURL * graph_url = [NSURL fileURLWithPath:graph_path];
        NSData *graph_data = [NSData dataWithContentsOfURL:graph_url];
        UIImage *graph_img = [[UIImage alloc] initWithData:graph_data];
        [self.sensor_data_graph performSelectorOnMainThread:@selector(setImage:) withObject:graph_img waitUntilDone:YES];       // display blank sensor data graph
    }

    
    [_draw_field_graph set_synch_offset :(38 - impact_frame_no)];    // impact at video frame no 38 aligns with the impact in the sensor data
    
    
    // /*
    
    // TODO: Initializations:
    down_sampling_factor     = 1;              // reset
    new_fps_reduction_factor = 1;              // reset
    fps_reduction_factor     = 1;              // reset

    activity_started = false;
    reference_ball_image_is_set = 0;
    bool arrays_are_allocated = 0;
    int start_frame = 0;
    circle_shift_x = -100;
    circle_shift_y = -100;
    obj_rot_angle  = 0.0f;
    obj_rot_angle1 = 0.0f;
    obj_rot_angle2 = 0.0f;
    delta_rotation_angle = 0.0f;
    prev_chest_point_offset_x = 0.0f;
    prev_chest_point_offset_y = 0.0f;
    marker_line_offset_angle = 0.0f;
    ball_radius = 0.0f;   // reset
    ball_radius_shape_based = 0.0f;       // reset
    // obj_rot_ref_frame = 0;
    ball_rpm     = 0;    // reset
    max_ball_rpm = 0;    // reset
    impact_ratio = 0.0f;  // reset
    [_draw_field2 set_rotation_angle :0.0f];   // reset
    
    shaft_line_slope = 0.0;
    shaft_line_slope_minus_1 = 0.0;
    shaft_line_slope_minus_2 = 0.0;
    shaft_line_slope_minus_3 = 0.0;
    shaft_line_slope_minus_4 = 0.0;
    shaft_line_slope_minus_5 = 0.0;
    shaft_line_slope_minus_6 = 0.0;
    shaft_line_slope_minus_7 = 0.0;
    shaft_line_slope_minus_8 = 0.0;
    shaft_line_slope_minus_9 = 0.0;
    shaft_line_slope_minus_10 = 0.0;
    
    shaft_line_offset = 0.0;
    shaft_line_offset_minus_1 = 0.0;
    shaft_line_offset_minus_2 = 0.0;
    shaft_line_offset_minus_3 = 0.0;
    shaft_line_offset_minus_4 = 0.0;
    shaft_line_offset_minus_5 = 0.0;
    shaft_line_offset_minus_6 = 0.0;
    shaft_line_offset_minus_7 = 0.0;
    shaft_line_offset_minus_8 = 0.0;
    shaft_line_offset_minus_9 = 0.0;
    shaft_line_offset_minus_10 = 0.0;
    
    clubhead_speed_mph         = 0.0f;
    clubhead_speed_mph_minus_1 = 0.0f;
    clubhead_speed_mph_minus_2 = 0.0f;
    clubhead_speed_mph_minus_3 = 0.0f;

    ball_speed   = 0.0f;   // reset
    ball_speed_1 = 0.0f;   // reset
    ball_speed_2 = 0.0f;
    ball_speed_3 = 0.0f;
    ball_speed_4 = 0.0f;
    
    ball_rpm_minus_1 = 0;   // reset
    ball_rpm_minus_2 = 0;
    ball_rpm_minus_3 = 0;
    ball_rpm_minus_4 = 0;
    ball_rpm_minus_5 = 0;
    ball_rpm_minus_6 = 0;
    ball_rpm_minus_7 = 0;
    ball_rpm_minus_8 = 0;
    
    clubhead_speed_mph_minus_4 = 0;
    clubhead_speed_mph_minus_3 = 0;
    clubhead_speed_mph_minus_2 = 0;
    clubhead_speed_mph_minus_1 = 0;
    
    for (int i = 0; i < ball_speed_arr_length; i++)  { ball_speed_arr[i] = -999999.0f; }  // reset
    for (int i = 0; i < head_speed_arr_length; i++)  { head_speed_arr[i] = -999999.0f; }  // reset
    for (int i = 0; i < ball_rpm_arr_length; i++)    { ball_rpm_arr[i]   = -999999.0f; }  // reset
    ball_speed_arr_start_idx = 0;
    head_speed_arr_start_idx = 0;
    ball_rpm_arr_start_idx   = 0;
    
    ball_orientation = 0.0f;
    ninety_degree_point = 0.0f;
    meters_per_pixel = 0.0f;
    
    ball_rotation_angle_acc = 0.0f;
    ball_rotation_angle_at_subimg0 = 0.0f;
    ball_rotation_angle_at_subimg1 = 0.0f;
    ball_rotation_angle_at_subimg2 = 0.0f;
    
    if (phase == 1)
    {
       impact_obj_pos_x = -100;         // move out of view
       impact_obj_pos_y = -100;
    }
    
    shift_box2_x = -100;     // remove blue box from view
    shift_box2_y = -100;
    
    shift_box3_x = -100;     // remove green box from view
    shift_box3_y = -100;
    
    ninety_deg_obj_pos_x = -100;     // move out of view
    ninety_deg_obj_pos_y = -100;
    
    club_shaft_end_x = -100;
    club_shaft_end_y = -100;
    club_shaft_is_set = false;
    
    prev_shaft_x_pivot = 0.0;
    prev_shaft_y_pivot = 0.0;
    prev_shaft_length = 0.0;
    
    force_for_ball_momentum = 0.0f;
    ball_travel_distance = 0.0f;
    
    // Reset draw parameters for red circle around ball:
    [_draw_field2 set_marker_circle_radius1 :10];
    [_draw_field2 set_marker_circle_offset_x :-100];
    [_draw_field2 set_marker_circle_offset_y :-100];
    
    // Draw green box around clubhead: (now used for shaft tracking?)
    [_draw_field2 set_box3_offset_x :-100];
    [_draw_field2 set_box3_offset_y :-100];

    [ _draw_field2 set_force_and_distance_etc :0.0f :0.0f :0.0f :0.0f :0.0f ];
    [ _draw_field2 set_impact_ghost :-100 :-100 ];      // move out of view
    [ _draw_field2 set_ninety_deg_ghost :-100 :-100 ];  // move out of view
    [ _draw_field2 set_shaft_line :0.0 :0.0 ];
    
    skid_end_frame_no = 0;
    roll_end_frame_no = 0;
    
    [ _draw_field_graph set_ball_speed_arr_impact_frame_no :0];
    [ _draw_field_graph set_head_speed_arr_impact_frame_no :0];
    [ _draw_field_graph set_ball_speed_graph_is_filled :false];   // not currently used
    [ _draw_field_graph set_impact_marker_line_draw_pos_x :0];    // reset

    // Reset clubhead_subimg_mask:
    for (int i = 0; i < clubhead_subimg_mask_arr_length; i++) { clubhead_subimg_mask[i] = 0; }
    
    
    printf("   --- sport: %d   max_num_frames: %d \n", sport, max_num_frames);
    for (int frame_no = start_frame; frame_no <= max_num_frames; frame_no++)                     // TODO: ----------------------------------------------------------------------- main loop -----------------
    {
        prev_fps_reduction_factor = fps_reduction_factor;
        fps_reduction_factor = new_fps_reduction_factor;
        
        if (movie_flow == 0)            // handling the "step" button
        {
            movie_flow = 1;
            while (movie_flow == 1)     // wait until the step button is pressed again (setting movie_flow to 0)
            {
                [NSThread sleepForTimeInterval:0.1];
                // printf("                  -3- process_movie - movie_flow: %d   movie_is_running: %d \n", movie_flow, movie_is_running);

                if (movie_flow == 9)    // new video requests to shut down this one
                {
                    // [_movieReader startReading];
                    [_movieReader cancelReading];
                    // movie_flow = 10;     // 10 means: video is terminated
                    break;                  // exit the loop
                }
            }
        }
        
        
        if (movie_flow == 9)    // new video requests to shut down this one
        {
            // [_movieReader startReading];
            printf("                  -4- process_movie - terminating current movie [_movieReader cancelReading]  movie_is_running: %d \n", movie_is_running);
            [_movieReader cancelReading];
            // movie_flow = 10;     // 10 means: video is terminated
            break;                  // exit the loop
        }
        
        
        
        printf("   frame_no: %d \n", frame_no);
        
        // for (int i = 0; i < 10; i++)   // read 10 frames at a time (for testing)
        // {
             [self readNextMovieFrame :frame_no :prev0_pix_arr :prev1_pix_arr :prev2_pix_arr :img_sect_align :img_sect_align_curr_pprev];                                      // <<<<<<<<<<<<<<<<<< read frame
        // }
        
        // if (sport == 50)
        // {
            // Check if this frame is repeated - if so, discard it (immediately read the next one) -- compare "curr_img" with "prev_img"
            // if (images_are_identical(curr_img, prev_img))
            // {
            //     [self readNextMovieFrame :frame_no :prev0_pix_arr :prev1_pix_arr :prev2_pix_arr :img_sect_align :img_sect_align_curr_pprev];                              // <<<<<<<<<<<<<<<<<< read frame
            // }
        // }
        
        // [_draw_field2 set_offset_y:frame_no];
        // [_draw_field2 setNeedsDisplay];            // try to force update
        // [_draw_field2 drawRect:<#(CGRect)#>];
        
        if (frame_no == 1)
        {
            image_field_width  = _image_field1.frame.size.width;
            image_field_height = _image_field1.frame.size.height;
            video_scale_factor_x = ((float) image_field_width) / ((float) movie_frame_width);
            video_scale_factor_y = ((float) image_field_height) / ((float) movie_frame_height);
            
            
            // int scaled_box_width = (int) (((float)[_draw_field2 get_box_width]) * scale_factor_x);
            int scaled_box_width = (int) (((float) (box_width_half)) * video_scale_factor_x);    // red box - box_width_half = 30
            [_draw_field2 set_box_width :scaled_box_width];
            
            // int scaled_box_height = (int) (((float)[_draw_field2 get_box_height]) * scale_factor_y);
            int scaled_box_height = (int) (((float) (box_height_half)) * video_scale_factor_y);    // red box - box_height_half = 30
            [_draw_field2 set_box_height :scaled_box_height];
            
            
            int scaled_box2_width = (int) (((float) (box2_width_half)) * video_scale_factor_x);    // blue box - box_width_half = 30
            [_draw_field2 set_box2_width :scaled_box2_width];
            
            int scaled_box2_height = (int) (((float) (box2_height_half)) * video_scale_factor_y);    // blue box - box_height_half = 30
            [_draw_field2 set_box2_height :scaled_box2_height];
            
            
            int scaled_box3_width = (int) (((float) (box3_width_half)) * video_scale_factor_x);    // green box - box_width_half = 30
            [_draw_field2 set_box3_width :scaled_box3_width];
            
            int scaled_box3_height = (int) (((float) (box3_height_half)) * video_scale_factor_y);    // green box - box_height_half = 30
            [_draw_field2 set_box3_height :scaled_box3_height];
            
            
            
            pix_arr_length = movie_frame_width * movie_frame_height;
            // prev0_pix_arr = new unsigned char[pix_arr_length * 4];      // 4 bytes per pixel    // THIS USES THE STACK -- SHOULD USE HEAP (using "calloc" and "free")
            // prev1_pix_arr = new unsigned char[pix_arr_length * 4];      // 4 bytes per pixel
            // prev2_pix_arr = new unsigned char[pix_arr_length * 4];      // 4 bytes per pixel
            
            prev0_pix_arr = (unsigned char *) calloc(pix_arr_length * 4, sizeof(unsigned char));     // 4 bytes per pixel // This is deallocated at the end.
            prev1_pix_arr = (unsigned char *) calloc(pix_arr_length * 4, sizeof(unsigned char));     // 4 bytes per pixel // This is deallocated at the end.
            prev2_pix_arr = (unsigned char *) calloc(pix_arr_length * 4, sizeof(unsigned char));     // 4 bytes per pixel // This is deallocated at the end.

            
            // pix_arr_arr = new unsigned char * [pix_arr_arr_length];
            pix_arr_arr = (unsigned char * *) calloc(pix_arr_arr_length, sizeof(unsigned char * *));
            for (int img_no = 0; img_no < pix_arr_arr_length; img_no++)
            {
                // pix_arr_arr[img_no] = new unsigned char[pix_arr_length * 4];          // 4 bytes per pixel
                pix_arr_arr[img_no] = (unsigned char *) calloc(pix_arr_length * 4, sizeof(unsigned char));     // 4 bytes per pixel // This is deallocated at the end.
            }
            
            
            img_sect_align_num_rows = 10; // 7;
            img_sect_align_num_cols = 10; // 7;
            int num_img_sections = img_sect_align_num_rows * img_sect_align_num_cols;
            img_sect_align            = new signed char[num_img_sections * 2];                  // alloc space for x-shift and y-shift for each section
            img_sect_align_curr_pprev = new signed char[num_img_sections * 2];                  // alloc space for x-shift and y-shift for each section
            for (int i = 0; i < (num_img_sections * 2); i++) { img_sect_align[i] = 0; }      // initialize
            
            prev_pos_x_max = 0;               // initialize (for speed computation)
            prev_pos_y_max = 0;
            
            pprev_pos_x_max = 0;
            pprev_pos_y_max = 0;
            
            ppprev_pos_x_max = 0;
            ppprev_pos_y_max = 0;
            
            
            prev_pos_box2_x_max = 0;
            prev_pos_box2_y_max = 0;
            
            pprev_pos_box2_x_max = 0;
            pprev_pos_box2_y_max = 0;
            
            ppprev_pos_box2_x_max = 0;
            ppprev_pos_box2_y_max = 0;
            
            pppprev_pos_box2_x_max = 0;
            pppprev_pos_box2_y_max = 0;
            
            
            prev_shaft_x_max = 0;
            prev_shaft_y_max = 0;
            
            pprev_shaft_x_max = 0;
            pprev_shaft_y_max = 0;
            
            ppprev_shaft_x_max = 0;
            ppprev_shaft_y_max = 0;
            
            pppprev_shaft_x_max = 0;
            pppprev_shaft_y_max = 0;
            
            
            prev_center_of_mass_x = 0.0f;          // initialize
            prev_center_of_mass_y = 0.0f;          // initialize
            
            ball_radius = 0.0f;                    // initalize
            ball_speed_mph = 0.0f;                 // initialize
            max_ball_speed_mph = 0.0f;             // initialize
            max_clubhead_speed_mph = 0.0f;         // initialize
            impact_clubhead_speed_mph = 0.0f;
            if (phase == 1)
            {
               impact_frame_no = 0;                // initialize
            }
            
            prev_obj_center_x = 0.0f;              // reset
            prev_obj_center_y = 0.0f;              // reset
            
            prev_ball_radius = 0.0f;               // reset
            
            object_action_path_state = 0;          // initialize
            clubhead_action_path_state = 0;        // initialize
            clubhead_tracking_confidence = 0;      // initialize
            club_shaft_tracking_confidence = 0;    // initialize
            
            obj_color_red   = -1;                  // initialize
            obj_color_green = -1;
            obj_color_blue  = -1;
            
            int graph_image_field_width_reference = 642;
            // int graph_image_field_height_reference = 144;
            int graph_image_field_width  = _sensor_data_graph.frame.size.width;       // default (iPad retina 8.1): 642 pixelx
            int graph_image_field_height = _sensor_data_graph.frame.size.height;      // default (iPad retina 8.1): 144 pixels
            printf("   --- graph_image_field_width: %d   graph_image_field_height: %d \n",  graph_image_field_width, graph_image_field_height);
            float slider_accel_scaling = ((float)graph_image_field_width) / ((float)graph_image_field_width_reference);
            [_draw_field_graph set_slider_accel_scaling :slider_accel_scaling];
            int dummy1 = 1.0f;
            
            if (phase == 2)
            {
                // [_draw_field_graph set_x_slide_offset :335];                           // case: tennis         assuming image: granger_fast_serve_gyros.png
                if (sport == 20) { [_draw_field_graph set_x_slide_offset :((int)(230.0f * dummy1))]; }         // case: ice hockey     assuming image: ice_hockey_slapshot_trimmed.png
            //  if (sport == 30) { [_draw_field_graph set_x_slide_offset :((int)(455.0f * dummy1))]; }         // case: baseball       assuming image:
                if (sport == 30) { [_draw_field_graph set_x_slide_offset :((int)(470.0f * dummy1))]; }         // case: baseball       assuming image:
                if (sport == 40) { [_draw_field_graph set_x_slide_offset :((int)(90.0f * dummy1))]; }  // 96   // case: trampoline     assuming image: trampoline_double_flip.png
                if (sport == 50) { [_draw_field_graph set_x_slide_offset :((int)(-60.0f * dummy1))]; }         // case: putt           assuming image: putt_blast_gyro_graph.png
                if ((sport == 50) && (obj_rot_ref_frame == 35)) {[_draw_field_graph set_x_slide_offset :((int)(30.0f * dummy1))]; }         // case: putt       assuming image: putt_blast_gyro_graph.png       obj_rot_ref_frame == 35 identifies the 2nd putt demo
                if (sport == 60) {[_draw_field_graph set_x_slide_offset :((int)(410.0f * dummy1))]; }          // case: full swing       assuming image:
                // if (sport == 60) {[_draw_field_graph set_x_slide_offset :((int)(130.0f * dummy1))]; }          // case: full swing       for iPhone 6 -- should use view width, etc.
                if (sport == 70) {[_draw_field_graph set_x_slide_offset :((int)(-114.0f * dummy1))]; }          // case: basketball jump       assuming image: basketball_2014-08-16.12_36_27_small.png
            }
           
            // Debug:
            int x_slide_offset_check = [_draw_field_graph get_x_slide_offset];
            printf("         --- x_slide_offset_check: %d \n", x_slide_offset_check);
            
            if (sport == 10)         // tennis
            {
                float slider_accel = 6.00f * dummy1;
                if (demo_id == 1011) // tennis serve jh
                {
                    [_draw_field_graph set_x_slide_offset :((int)(-10.0f * dummy1))];
                    slider_accel = 7.50f * dummy1;
                }
                [_draw_field_graph set_slider_accel :slider_accel];
            }
            else if (sport == 20)    // hockey
            {
                float slider_accel = 6.00f * dummy1;
                [_draw_field_graph set_slider_accel :slider_accel];
            }
            else if (sport == 30)    // baseball
            {
                float slider_accel = 2.00f * dummy1;
                [_draw_field_graph set_slider_accel :slider_accel];
            }
            else if (sport == 40)    // trampoline
            {
                float slider_accel = 1.38f * dummy1; // 1.36f;
                [_draw_field_graph set_slider_accel :slider_accel];
            }
            else if (sport == 50)    // putt
            {
                float slider_accel = 18.00f * dummy1;
                if (obj_rot_ref_frame == 35) { slider_accel = 15; } // hack: obj_rot_ref_frame == 35 identifies the second putt demo
                [_draw_field_graph set_slider_accel :slider_accel];
            }
            else if (sport == 60)    // full swing
            {
                float slider_accel = 2.80f * dummy1;
                //x if (obj_rot_ref_frame == 35) { slider_accel = 15; } // hack: obj_rot_ref_frame == 35 identifies the second putt demo
                [_draw_field_graph set_slider_accel :slider_accel];
            }
            else if (sport == 70)    // basketball jump
            {
                float slider_accel = 3.35f * dummy1;
                [_draw_field_graph set_slider_accel :slider_accel];
            }

            arrays_are_allocated = 1;
        }

        int scaled_shift_x = shift_x * video_scale_factor_x;
        int scaled_shift_y = shift_y * video_scale_factor_y;
        
        int scaled_impact_obj_pos_x = impact_obj_pos_x * video_scale_factor_x;
        int scaled_impact_obj_pos_y = impact_obj_pos_y * video_scale_factor_y;
        
        int scaled_ninety_deg_obj_pos_x = ninety_deg_obj_pos_x * video_scale_factor_x;
        int scaled_ninety_deg_obj_pos_y = ninety_deg_obj_pos_y * video_scale_factor_y;
        
        int scaled_box2_shift_x = shift_box2_x * video_scale_factor_x;
        int scaled_box2_shift_y = shift_box2_y * video_scale_factor_y;
        
        int scaled_box3_shift_x = shift_box3_x * video_scale_factor_x;
        int scaled_box3_shift_y = shift_box3_y * video_scale_factor_y;
        
        int scaled_circle_shift_x = (int) (((float) circle_shift_x) * video_scale_factor_x);
        int scaled_circle_shift_y = (int) (((float) circle_shift_y) * video_scale_factor_y);
        float scaled_circle_radius  = circle_radius * ((video_scale_factor_x + video_scale_factor_y) / 2.0f);
        
        
        
        printf("      frame_no: %d   circle_shift_x: %d   circle_shift_y: %d  scaled_circle_shift_x: %d   scaled_circle_shift_y: %d   circle_radius: %5.2f   scaled_circle_radius: %5.2f \n",  frame_no, circle_shift_x, circle_shift_y, scaled_circle_shift_x, scaled_circle_shift_y, circle_radius, scaled_circle_radius);
        // printf("      frame_no: %d   offset_y: %d   shift_x: %d   shift_y: %d   image_field_width: %d   movie_frame_width: %d   video_scale_factor_x: %2.2f \n", frame_no, [_draw_field2 get_offset_y], shift_x, shift_y, image_field_width, movie_frame_width, video_scale_factor_x);

        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            //Run UI Updates
            self.output_label.text = [NSString stringWithFormat:@" Current Frame:  %d\n", frame_no];
            [self.output_label setNeedsDisplay];                                                                                 // update display
            
            self.ball_speed.text = [NSString stringWithFormat:@" Ball Speed:   %3.1f mph\n", ball_speed_mph];
            [self.ball_speed setNeedsDisplay];                                                                                   // update display
            
            self.max_ball_speed_label.text = [NSString stringWithFormat:@" Max Ball Speed:  %3.1f mph\n", max_ball_speed_mph];
            if (sport == 60)   // full swing
            {
                self.max_ball_speed_label.text = [NSString stringWithFormat:@" Ball Speed:  %3.1f mph\n", max_ball_speed_mph];
            }
            [self.max_ball_speed_label setNeedsDisplay];                                                                         // update display
            
            self.impact_frame_no_label.text = [NSString stringWithFormat:@" Impact Frame:  %d\n", impact_frame_no];
            [self.impact_frame_no_label setNeedsDisplay];                                                                        // update display
            
            self.rpm_label.text = [NSString stringWithFormat:@" Ball RPM:  %d rpm\n", ball_rpm];
            [self.rpm_label setNeedsDisplay];                                                                                    // update display
            
            self.max_rpm_label.text = [NSString stringWithFormat:@" Max Ball RPM:  %d rpm\n", max_ball_rpm];
            if (sport == 60)   // full swing
            {
                self.max_rpm_label.text = [NSString stringWithFormat:@" Swing Speed:  %3.1f mph\n", max_swing_speed_mph];
            }
            [self.rpm_label setNeedsDisplay];                                                                                    // update display
            
            //x self.head_speed_label.text = [NSString stringWithFormat:@" Head Speed %1.1f mph\n", max_clubhead_speed_mph];
            self.head_speed_label.text = [NSString stringWithFormat:@" Head Speed %1.1f mph\n", impact_clubhead_speed_mph];
            [self.head_speed_label setNeedsDisplay];                                                                             // update display
            
            self.impact_ratio.text = [NSString stringWithFormat:@" Smash Factor:  %1.1f\n", impact_ratio];
            [self.impact_ratio setNeedsDisplay];                                                                                 // update display
            

            
            // Draw red box around ball:
            [_draw_field2 set_offset_x :scaled_shift_x];
            [_draw_field2 set_offset_y :scaled_shift_y];
            
            // Draw ghost of ball at imnpact position:
            [_draw_field2 set_impact_ghost :scaled_impact_obj_pos_x :scaled_impact_obj_pos_y];
            
            // Draw ghost of ball at ninety degree position:
            [_draw_field2 set_ninety_deg_ghost :scaled_ninety_deg_obj_pos_x :scaled_ninety_deg_obj_pos_y];
            
            // Draw blue box around clubhead:
            [_draw_field2 set_box2_offset_x :scaled_box2_shift_x];
            [_draw_field2 set_box2_offset_y :scaled_box2_shift_y];
            
            // Draw green box around clubhead: (now used for shaft tracking?)
            [_draw_field2 set_box3_offset_x :scaled_box3_shift_x];
            [_draw_field2 set_box3_offset_y :scaled_box3_shift_y];
            
            // Draw red circle around ball:
            [_draw_field2 set_marker_circle_radius1 :scaled_circle_radius];
            [_draw_field2 set_marker_circle_offset_x :scaled_circle_shift_x];
            [_draw_field2 set_marker_circle_offset_y :scaled_circle_shift_y];
            
            int display_fps = video_fps / fps_reduction_factor;
            [_draw_field2 set_force_and_distance_etc :force_for_ball_momentum :ball_travel_distance :ball_orientation :ninety_degree_point :display_fps];
            
            // Draw club shaft line:
            [ _draw_field2 set_shaft_line :linear_regression_line_slope :linear_regression_line_offset ];

            
            // Draw blastman:
            [_draw_field2 set_blastman_points :num_blastman_points :blastman_points_x :blastman_points_y :video_scale_factor_x :video_scale_factor_y];
            
            [_draw_field2 setNeedsDisplay];

            // printf("         draw_field2  offset_x: %d  offset_y: %d \n", [_draw_field2 get_offset_x], [_draw_field2 get_offset_y]);

            
            // Draw vertical line (slider) moving from left to right:
            if (phase == 2)
            {
                [_draw_field_graph set_offset_x:frame_no];
                [_draw_field_graph set_offset_y:30];
                //x [_draw_field_graph setNeedsDisplay];
                
                // printf("         draw_field_graph offset_x: %d \n", [_draw_field_graph get_offset_x]);
            }
            else if (frame_no == 1) // phase == 1 // move the slider out of the way // this only works from this separate thread ("main_queue"))
            {
                [_draw_field_graph set_offset_x:-400];
                [_draw_field_graph set_offset_y:30];
                //x [_draw_field_graph setNeedsDisplay];
            }
            
            int roll_end_frame_no1 = frame_no;
            [_draw_field_graph set_vertial_marker_lines :impact_frame_no :skid_end_frame_no :roll_end_frame_no1];
            
            [_draw_field_graph setNeedsDisplay];
        });

        // if (sport == 50)
        // {
        //     [NSThread sleepForTimeInterval:0.4];    // 0.1 // (in seconds) slow down temporarily for testing
        // }
    }                                                                          // ----------------------------------------------------------------------- end of main loop -----------------------
    // */
    
    
    NSDate *movie_finish_time = [NSDate date];
    NSTimeInterval movie_execution_time = [movie_finish_time timeIntervalSinceDate:movie_start_time];
    // NSLog(@"movie_execution_time = %f", movie_execution_time);
    
    [_movieReader cancelReading];    // recent change 2015-07-19
    
    printf("   Finished process_movie - execution time: %f seconds  impact_frame: %d \n", movie_execution_time, impact_frame_no);
    
    
    if (sport == 100) { [self print_motion_intensity_arr]; }

    
    if (arrays_are_allocated)               // this arrays are allocated at frame == 1
    {
        // delete [] curr_img;
        // delete [] prev0_pix_arr;     // used for curr_img
        // delete [] prev1_pix_arr;
        // delete [] prev2_pix_arr;
        
        if (prev0_pix_arr) { free(prev0_pix_arr); }
        if (prev1_pix_arr) { free(prev1_pix_arr); }
        if (prev2_pix_arr) { free(prev2_pix_arr); }
        
        delete [] img_sect_align;
        
        for (int img_no = 0; img_no < pix_arr_arr_length; img_no++)
        {
            // delete [] pix_arr_arr[img_no];
            if (pix_arr_arr[img_no]) { free(pix_arr_arr[img_no]); }
        }
        // delete [] pix_arr_arr;
        if (pix_arr_arr) { free(pix_arr_arr); }
    }
    
    
    if (movie_flow == 9) // || (phase == 2))    // new video requests to shut down this one
    {
        movie_flow = 10;     // 10 means: video is terminated (so the next one can start)
        // movie_is_running = 0;
    }
    printf("                  -9- process_movie - movie_flow: %d   movie_is_running: %d \n", movie_flow, movie_is_running);
}



/*
// See http://www.7twenty7.com/blog/2010/11/video-processing-with-av-foundation
- (void) readMovie:(NSURL *)url
{
	AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:nil];
	[asset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracks"] completionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            AVAssetTrack * videoTrack = nil;
                            NSArray * tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
                            if ([tracks count] == 1)
                            {
                                videoTrack = [tracks objectAtIndex:0];
                                
                                NSError * error = nil;
                                
                                // _movieReader is a member variable
                                _movieReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];     // <<<<<<<<<<<<<<<<<<<<
                                if (error)
                                    // NSLog(error.localizedDescription);
                                    NSLog(@"   ### Error in AVAssetReader initialization");
                                    
                                NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
                                NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
                                NSDictionary* videoSettings = 
                                [NSDictionary dictionaryWithObject:value forKey:key]; 
 
                                
                                [_movieReader addOutput:[AVAssetReaderTrackOutput 
                                                         assetReaderTrackOutputWithTrack:videoTrack 
                                                         outputSettings:videoSettings]];
                                [_movieReader startReading];
                            }
                        });
     }];
    
    printf("   Finished executiong readMovie(url)\n");
}
*/



- (void) readMovie:(NSURL *)url
{
	AVURLAsset * asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    // 1. Construct an AVAssetReader:
    NSError * error = nil;
    _movieReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    
    // 2. Get the video track(s) from your asset:
    NSArray* video_tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack* video_track = [video_tracks objectAtIndex:0];
    
    // 3. Set the desired video frame format:
    //    Note that certain video formats just will not work, and if you're doing something real-time,
    //    certain video formats perform better than others (BGRA is faster than ARGB, for instance).
    NSMutableDictionary* video_settings_dictionary = [[NSMutableDictionary alloc] init];
    // [dictionary setObject:[NSNumber numberWithInt:<format code from CVPixelBuffer.h>] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    // NSDictionary* video_settings_dictionary =
    video_settings_dictionary =
       [NSMutableDictionary dictionaryWithObject:value forKey:key];
    
    // 4. Construct the actual track output and add it to the asset reader:
    AVAssetReaderTrackOutput* asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:video_track outputSettings:video_settings_dictionary];
    [_movieReader addOutput:asset_reader_output];
    
    // 5. Kick off the asset reader:
    [_movieReader startReading];
    
    // 6. Read off the samples:
    /*
    CMSampleBufferRef buffer;
    int frame_cnt = 0;
    while (    ( [_movieReader status]==AVAssetReaderStatusReading )
           &&  (frame_cnt < 200))
    {
        buffer = [asset_reader_output copyNextSampleBuffer];
        frame_cnt++;
        if ((frame_cnt % 10) == 0)
        {
            printf("      frame_cnt: %d \n", frame_cnt);
        }
    }
    printf("      frame_cnt: %d \n", frame_cnt);
    */
    
    
    // Get and set frame rate
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    int fps = videoTrack.nominalFrameRate;
    video_fps = fps;
    if (video_fps_override > 0) { video_fps = video_fps_override; }
    if ((sport == 10) && (video_fps > 230)) { down_sampling_factor = 4; }   // for tennis with fps = 240 set downsampling factor to 4 (to avoid crashing in readNextMovieFrame())
    printf("   === fps: %d   video_fps: %d (used)   down_sampling_factor: %d \n", fps, video_fps, down_sampling_factor);
}



- (void) readNextMovieFrame:(int)frame_no :(unsigned char*)prev0_pix_arr :(unsigned char*)prev1_pix_arr :(unsigned char*)prev2_pix_arr :(signed char*)img_sect_align :(signed char*)img_sect_align_curr_pprev
{
    // NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    // printf("   --- _movieReader.status: %d \n", _movieReader.status);    // set to 2 when at end of movie
    
    /*    
    // Try to restart the video
    if (_movieReader.status == AVAssetReaderStatusCompleted)
    {
        printf("   --- _movieReader.status: %d \n", _movieReader.status);    // set to 2 when at end of movie
        NSError * error = nil;
        AVURLAsset * asset = [AVURLAsset URLAssetWithURL:video_url options:nil];
        _movieReader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        NSArray* video_tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack* video_track = [video_tracks objectAtIndex:0];
        NSMutableDictionary* video_settings_dictionary = [[NSMutableDictionary alloc] init];
        NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
        NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        video_settings_dictionary =
        [NSMutableDictionary dictionaryWithObject:value forKey:key];
        AVAssetReaderTrackOutput* asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:video_track outputSettings:video_settings_dictionary];
        [_movieReader addOutput:asset_reader_output];
        [_movieReader startReading];
        
    //     // [_movieReader startReading];    // re-start from beginnging
    //     [self readMovie:video_url];                                                                 
    }
    */
    
    if (_movieReader.status == AVAssetReaderStatusReading)
    {
        AVAssetReaderTrackOutput * output = [_movieReader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
        
        //x fps_reduction_factor = 1; // 2;
        if (fps_reduction_factor == 2)
        {
            if (sampleBuffer)
            {
                CFRelease(sampleBuffer);                          // skip a frame
            }
            sampleBuffer = [output copyNextSampleBuffer];         // by immediately reading the next one
        }
        
        if (sampleBuffer)
        {
            //  int fps = AVAssetTrack ... nominalFrameRate
            
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            
            // Lock the image buffer
            CVPixelBufferLockBaseAddress(imageBuffer,0);
            
            // Get information of the image
            // uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
            size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
            size_t width       = CVPixelBufferGetWidth(imageBuffer);
            size_t height      = CVPixelBufferGetHeight(imageBuffer);
            
            if (frame_no == 1)
            {
                printf("      video width: %zu  height: %zu\n",  width, height);    // 1920 x 1080 (30fps)     1280 x 720 (120fps)
                movie_frame_width  = width;
                movie_frame_height = height;
                movie_frame_num_pixels = movie_frame_width * movie_frame_height;
                movie_frame_size_factor = ((float) movie_frame_width) / 1280.0f; //
                movie_frame_bytes_per_row = bytesPerRow;
            }
           
            // /*
            // Get the pixel array (byte array):
            unsigned char* pix_arr = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);                 // <<<<<<<<<<<<< creating pix_arr
            if ((frame_no >= 1) && (image_orientation == 1))       // don't call rotate_image_180 if movie_frame_width and movie_frame_height are not assigned yet
            {
                [self rotate_image_180 :bytesPerRow :pix_arr];
            }
            // curr_img = pix_arr;
            if (frame_no > 1)
            {
                [self copy_to_prev_pix_arr :pix_arr :prev0_pix_arr];
                curr_img = prev0_pix_arr;
            }
            
            // search_for_feature(width, height, bytesPerRow, pixel);
            /*
            if (frame_no >= 75) // 80)
            {
               [self search_for_feature: width :height :bytesPerRow :pix_arr];                                  // <<<<<<<<<<<<< search for feature
            }
            */
            
            
            // Align subsequent images:
            
   // /*
        if (((! (sport == 10)) || (video_fps < 230) || ((frame_no % down_sampling_factor) == 0)))   // TESTING - for tennis slow motion video: process only every 4th image
        {
            if (frame_no > 3)     // there needs to be a previous frame
            {
                if (frame_no > 3) // 70) // 75) // 10) // && (frame_no < 50))
                {
                    int * align_shift            = new int[2];
                    int * align_shift_curr_pprev = new int[2];
                    
                    // [self align_images :frame_no :bytesPerRow :pix_arr :prev_img  :align_shift  :img_sect_align];
                    // [self find_moving_objects :frame_no :bytesPerRow :prev_img :pix_arr :align_shift  :img_sect_align];
                    
                    [self align_images :frame_no :bytesPerRow :prev_img :pprev_img  :align_shift  :img_sect_align];                                                                 // <<<<<<<<<<<<<<<<
                    [self align_images :frame_no :bytesPerRow :curr_img :pprev_img  :align_shift_curr_pprev  :img_sect_align_curr_pprev];                                           // <<<<<<<<<<<<<<<<

                    if      (sport == 10)    // tennis
                    {
                        [self find_moving_objects__tennis :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];             // <<<<<<<<<<<<<<<<
                    }
                    else if (sport == 20)    // ice hockey
                    {
                        [self find_moving_objects__ice_hockey :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];         // <<<<<<<<<<<<<<<<
                    }
                    else if (sport == 30)    // baseball
                    {
                        [self find_moving_objects__baseball :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];           // <<<<<<<<<<<<<<<<
                    }
                    else if (sport == 40)    // trampoline
                    {
                        if ((frame_no % 2) == 0)    // only use even frame numbers since this particular video is a screen capture that duplicated frames
                        {
                            [self find_moving_objects__trampoline :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];     // <<<<<<<<<<<<<<<<
                        }
                    }
                    else if (sport == 50)    // putt
                    {
                        [self find_moving_objects__putt :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];           // <<<<<<<<<<<<<<<<
                    }
                    else if (sport == 60)    // full swing
                    {
                        [self find_moving_objects__full_swing :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];           // <<<<<<<<<<<<<<<<
                    }
                    else if (sport == 70)    // basketball
                    {
                        [self find_moving_objects__jumps :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];
                    }
                    else if (sport == 100)    // auto-curation
                    {
                        [self find_interesting_events :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];
                    }
                    
                    delete [] align_shift;
                }
            }
        }
   // */
            // if ((frame_no % 50) == 0) { [NSThread sleepForTimeInterval:1.0]; } // take a break every 50 frames for garbage collection  // DOESN'T HELP
            
            
            
            // Save this image buffer as "prev_image_buffer" to be accessible as previous image (frame) in next frame:
            if (    (frame_no > 1)
                &&  ((sport != 40) || ((frame_no % 2) == 0)))     // TEMPORARY WORKAROUND to deal with duplicated frames in the trampoline video
            {
                /*      // This can be deleted once the pix_arr_arr[] method is verified
                if (pix_arr_ptr == 0)
                {
                    prev_img  = prev1_pix_arr;          // prev_img is instantiated below (using allocation of prev1_pix_arr)
                    pprev_img = prev2_pix_arr;
                    pix_arr_ptr = 1;
                }
                else // if pix_arr_ptr == 1
                {
                    prev_img  = prev2_pix_arr;
                    pprev_img = prev1_pix_arr;
                    pix_arr_ptr = 0;
                }
                */

                
                int lookback_frames = 2; // 1;                     // this parameters determines whether we are comparing the current frame with the previous frame (lookback_frame = 1) or with frame before that (lookback_frame = 2)
                int pprev_ptr = pix_arr_arr_ptr - lookback_frames;    if (pprev_ptr < 0) { pprev_ptr = pix_arr_arr_length + pprev_ptr; }     // use addition since pprev_ptr is negative
                prev_img  = pix_arr_arr[pix_arr_arr_ptr];        // prev_img is instantiated below (using allocation of  pix_arr_arr[pix_arr_ptr])
                pprev_img = pix_arr_arr[pprev_ptr];              // pix_arr_arr[pprev_ptr] was filled in by previous call to copy_to_prev_pix_arr() below
                
                int display_img_ptr = pix_arr_arr_ptr - 1;    if (display_img_ptr < 0) { display_img_ptr = pix_arr_arr_length - 1; }    // this should be in synch with the image overlay (red square)
                display_img = pix_arr_arr[display_img_ptr];
                
                pix_arr_arr_ptr++;      if (pix_arr_arr_ptr == pix_arr_arr_length) { pix_arr_arr_ptr = 0; }          // this is where the next image will be stored
               
                [self copy_to_prev_pix_arr: pix_arr :prev_img];     // prev_img is now pointing to the next element in pix_arr_arr[] (this is how all elements in pix_arr_arr[] are filled in)
                
                /*
                // Test if we can modify the image (display_img):
                int red = 255;
                int green = 0;
                int blue = 0;
                int alpha = 0;
                for (int pix_x = 60; pix_x < 100; pix_x++)
                {
                    for (int pix_y = 50; pix_y < 70; pix_y++)
                    {
                        size_t pixel_arr_idx = pix_y * bytesPerRow + pix_x * 4;
                        display_img[pixel_arr_idx + 2] = (char)red;
                        display_img[pixel_arr_idx + 1] = (char)green;
                        display_img[pixel_arr_idx]     = (char)blue;
                    }
                }
                */
                
                // int pix1 = pix_arr[300];
                // int prev_pix1 = prev_pix_arr[300];
                // printf("             after copy to prev pix arr -- pix1: %d   prev_pix1: %d \n",  pix1, prev_pix1);
            }
   
            // UIColor *color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha)];
            

  
  if (((! (sport == 10)) || (video_fps < 230) || ((frame_no % down_sampling_factor) == 0)))   // TESTING - for tennis slow motion video: process only every 4th image
  {
            //-----------------
            if (frame_no > 2)          // pprev_img needs to be filled in at this point
            {
                @autoreleasepool       // so that temporary allocations of video_display_image.CGImage do not accumulate
                {
                    // Try to display the image in the UIImageView (see http://www.benjaminloulier.com/posts/ios4-and-direct-access-to-the-camera/)
                    // Create a CGImageRef from the CVImageBufferRef
                    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                    //  CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
                    //  CGContextRef newContext = CGBitmapContextCreate(pprev_img,   width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);    // show the prevous image, since the ball marker refer to the previous image
                    CGContextRef newContext = CGBitmapContextCreate(display_img,   width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);    // show the prevous image, since the ball marker refer to the previous image
                    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
                    
                    // We release some components
                    CGContextRelease(newContext);
                    CGColorSpaceRelease(colorSpace);
                    
                    
                    // We display the result on the custom layer. All the display stuff must be done in the main thread because
                    // UIKit is not thread safe, and as we are not in the main thread (remember we didn't use the main_queue)
                    // we use performSelectorOnMainThread to call our CALayer and tell it to display the CGImage.
                    [self.customLayer performSelectorOnMainThread:@selector(setContents:) withObject: (__bridge id) newImage waitUntilDone:YES];
                    
                    // We display the result on the image view (We need to change the orientation of the image so that the video is displayed correctly).
                    // Same thing as for the CALayer we are not in the main thread so ...
                    UIImage * video_display_image;
                    // if (false) // (sport == 40)
                    // {
                    //     image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
                    // }
                    // if (false) // (image_orientation == 1)
                    // {
                    //     image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationDown];      // upside down
                    // }
                    // else // image orientation == 0 // default
                    // {
                    // UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
                    // UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationUp];
                    video_display_image = [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationUp];                           // TODO: default image orienation
                    //       [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationUp];                    // UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationUpMirrored];
                    // [UIImage imageWithCGImage:newImage];                    // UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationUpMirrored];
                    // UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRightMirrored];
                    // UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationDownMirrored];        // works, but is mirrored
                    // UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationDown];
                    // image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationDown];
                    // }
                    
                    
                    // We relase the CGImageRef
                    CGImageRelease(newImage);
                    // CGImageRelease(video_display_image.CGImage);    // this needed because of bug in iOS -- but it causes crash when this thread returns ( [UIImage deallloc] )
                    // video_display_image = nil;                      // this is used because ARC (automatic reference counting) uses it to trigger garbage collection
                    
                    [self.image_field1 performSelectorOnMainThread:@selector(setImage:) withObject:video_display_image waitUntilDone:YES];    // display image
                    
                    // NEED TO DEALLOCATE video_display_image!
                    // [video_display_image release];     // cannot use with automatic reference counting
                    // video_display_image = nil;         // doesn't help
                    
                    //    [self.image_field1 setImage:image];
                    
                    //     UIImageView *image_field2 = [[UIImageView alloc] initWithImage:image];
                    // self.imgToDisplay.image = [[UIImage alloc] initWithData:image];
                    //     [self.view addSubview:image_field2];
                    // [NSThread sleepForTimeInterval:1.0];    // temporary for testing
                    // [self.image_field1 setNeedsDisplay];    // TESTING
                    //     [image_field2 setNeedsDisplay];    // TESTING
                }
            }
            //-----------------
  }
  
            
            // Unlock the image buffer
            CVPixelBufferUnlockBaseAddress(imageBuffer,0);
            CFRelease(sampleBuffer);
        }
    }
    
    // [pool drain]; // ??

}



-(void) search_for_feature:(size_t)width :(size_t)height :(size_t)bytesPerRow :(unsigned char*)pixel
{
    // Access pixel at x, y:
    // Middle pixel: (height / 2) * bytesPerRow + (width / 2) * 4
    // size_t x = 100;
    // size_t y = 200;
    /*
    size_t x = 1300;
    size_t y = 100;
    size_t pixel_arr_idx = y * bytesPerRow + x * 4;
    
    int red   = pixel[pixel_arr_idx + 2];
    int green = pixel[pixel_arr_idx + 1];
    int blue  = pixel[pixel_arr_idx];
    // int alpha = 1;
    
    printf("      red: %d  green: %d  blue: %d \n",  red, green, blue);
    */
    
    [self search_for_yellow_square:width :height :bytesPerRow :pixel];
}


-(void) search_for_yellow_square:(size_t)width :(size_t)height :(size_t)bytesPerRow :(unsigned char*)pixel
{
    int box_width = 10; // 20;
    int box_height = 10; // 20;
    
    size_t pixel_arr_idx = 0;
    int red = 0;
    int green = 0;
    int blue = 0;
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    int step_size = 2;
    for (size_t x = 0; x < (width - box_width); x += step_size)
    {
        for (size_t y = 0; y < (height - box_height); y += step_size)
        {
            int red_acc = 0;
            int green_acc = 0;
            int blue_acc = 0;
            int cnt = 0;
            for (int bx = 0; bx < box_width; bx++)
            {
                for (int by = 0; by < box_height; by++)
                {
                    pixel_arr_idx = ((y + by) * bytesPerRow) + ((x + bx) * 4);
                    red   = pixel[pixel_arr_idx + 2];
                    green = pixel[pixel_arr_idx + 1];
                    blue  = pixel[pixel_arr_idx];
                    
                    red_acc += red;
                    green_acc += green;
                    blue_acc += blue;
                    
                    cnt++;
                }
            }
            
            red_ave = red_acc / cnt;
            green_ave = green_acc / cnt;
            blue_ave = blue_acc / cnt;
            
            /*
            pixel_arr_idx = y * bytesPerRow + x * 4;
            red   = pixel[pixel_arr_idx + 2];
            green = pixel[pixel_arr_idx + 1];
            blue  = pixel[pixel_arr_idx];
            */
            
            if ([self is_yellow:red_ave :green_ave :blue_ave])
            {
                printf("      yellow spot at x: %zu  y: %zu \n", x, y);
                
                [self set_overlay_box :x :y];                                   // Set position of blue box
            }
        }
    }
}



-(void) set_overlay_box :(int)x :(int)y                                         // Set position of red box
{
    shift_x = x;
    shift_y = y;
}


-(void) set_overlay_box2 :(int)x :(int)y                                        // Set position of blue box (club head)
{
    shift_box2_x = x;
    shift_box2_y = y;
}


-(void) set_overlay_box3 :(int)x :(int)y                                        // Set position of green box (club shaft)
{
    shift_box3_x = x;
    shift_box3_y = y;
}


-(void) draw_blastman :(int) num_points :(float *)points_x :(float *)points_y
{
    num_blastman_points = num_points;
    for (int point_no = 0; point_no < num_points; point_no++)
    {
        blastman_points_x[point_no] = points_x[point_no];
        blastman_points_y[point_no] = points_y[point_no];
    }
}


-(void) set_overlay_circle :(int)x :(int)y :(float)radius                       // Set position of red circle
{
    circle_shift_x = x;
    circle_shift_y = y;
    circle_radius = radius;
}



-(bool) is_yellow:(int)red :(int)green :(int)blue
{
    bool return_val = false;
    // if ((red > 200) && (green > 200) && (blue < 100))
    if ((red > 190) && (green > 190) && (blue < 150))
    {
        return_val = true;
    }
    
    return return_val;
}


-(bool) is_light_color:(int)red :(int)green :(int)blue
{
    bool return_val = false;
    // if ((red > 200) && (green > 200) && (blue < 100))
    // if ((red > 190) && (green > 190) && (blue < 150))
    // if ((red > 190) && (green > 190) && (blue < 190))
    if ((red > 190) && (green > 190) && (blue < red))
    {
        return_val = true;
    }
    
    return return_val;
}


-(bool) is_light_or_yellow:(int)red :(int)green :(int)blue
{
    bool return_val = false;
    if (    ((red > 190) && (green > 190) && (blue < red))
        ||  ((abs(green-red) < 40) && (blue < (red - 10)) && (blue < (green - 10))))
    {
        return_val = true;
    }
    
    return return_val;
}


-(bool) is_white_color:(int)red :(int)green :(int)blue
{
    bool return_val = false;
    // if ((red > 120) && (green > 120) && (blue > 120))
    // if ((red > 150) && (green > 150) && (blue > 150))
    // if (    ((red > 190) && (green > 190) && (blue > 170))
    // if (    ((red > 160) && (green > 160) && (blue > 160))
       if (    ((red > 140) && (green > 140) && (blue > 140))
    //     &&  ((abs(green-red) < 40) && (abs(blue-red) < 40) && (blue < (red - 25)) && (blue < (green - 20))))
           &&  ((abs(green-red) < 38) && (abs(blue-red) < 38) && (blue < (red - 20)) && (blue < (green - 15))))
    {
        return_val = true;
    }
    
    return return_val;
}



-(bool) is_white_color_putt:(int)red :(int)green :(int)blue
{
    bool return_val = false;
    // if (    ((red > 120) && (green > 120) && (blue > 120))
    if (    ((red > 160) && (green > 160) && (blue > 160))
        &&  ((abs(green-red) < 60) && (abs(blue-red) < 60) ))
    {
        return_val = true;
    }
    
    return return_val;
}


-(bool) is_white_color_putt2:(int)red :(int)green :(int)blue
{
    bool return_val = false;
 // if (    ((red > 120) && (green > 120) && (blue > 120))
    if (    ((red > 160) && (green > 160) && (blue > 160))
        &&  ((abs(green-red) < 40) && (abs(blue-red) < 40) && (abs(blue-green) < 40) ))
    {
        return_val = true;
    }
    
    return return_val;
}



-(bool) is_black_color:(int)red :(int)green :(int)blue
{
    bool return_val = false;
    // if ((red < 80) && (green < 80) && (blue < 80))
    if     ((red < 120) && (green < 120) && (blue < 120))
        // &&  ((abs(green-red) < 60) && (abs(blue-red) < 60) && (abs(blue-green) < 60)))
    {
        return_val = true;
    }
    
    return return_val;
}


-(bool) is_light_blue_color:(int)red :(int)green :(int)blue
{
    bool return_val = false;
    if (    ((red > 100) && (green > 100) && (blue > 100))
        &&  (blue > (red + 25)) && (blue > (green + 5)))
    {
        return_val = true;
    }
    
    return return_val;
}


-(bool) is_light_blue_color2:(int)red :(int)green :(int)blue
{
    bool return_val = false;
    if (    ((red > 100) && (green > 100) && (blue > 100))
        &&  (blue > (red + 35)) && (blue > (green + 10)))
    {
        return_val = true;
    }
    
    return return_val;
}


-(bool) is_red_color:(int)red :(int)green :(int)blue
{
    bool return_val = false;
    if (    ((red > 10) && (green > 10) && (blue > 10))
        &&  (red > (blue + 40)) && (red > (green + 40)))
    {
        return_val = true;
    }
    
    return return_val;
}


- (void) copy_to_prev_pix_arr:(unsigned char*)pix_arr :(unsigned char*)prev_pix_arr
{
    int pix_arr_length = movie_frame_width * movie_frame_height * 4;

    /*
    for (int pix_no = 0; pix_no < 70; pix_no++)
    {
        int curr_pix = pix_arr[pix_no];
        int prev_pix = prev_pix_arr[pix_no];
        printf("                   ---/--- pix_no: %d   prev_pix: %d   curr_pix: %d \n",  pix_no, prev_pix, curr_pix);
    }
    */
    
    /*
    --- pix_no: 0   prev_pix: 27   curr_pix: 28
    --- pix_no: 1   prev_pix: 24   curr_pix: 25
    --- pix_no: 2   prev_pix: 20   curr_pix: 21
    --- pix_no: 3   prev_pix: 255   curr_pix: 255
    --- pix_no: 4   prev_pix: 27   curr_pix: 27
    --- pix_no: 5   prev_pix: 24   curr_pix: 24
    --- pix_no: 6   prev_pix: 20   curr_pix: 20
    --- pix_no: 7   prev_pix: 255   curr_pix: 255
    */

    
    for (int pix_no = 0; pix_no < pix_arr_length; pix_no++)
    {
        prev_pix_arr[pix_no] = pix_arr[pix_no];
    }
}


- (void) align_images: (int)frame_no :(size_t)bytesPerRow :(unsigned char*)pix_arr :(unsigned char*)prev_pix_arr  :(int *)align_shift  :(signed char*)img_sect_align
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    
    // printf("      Aligning frame %d with previous frame.\n", frame_no);
    
    int diff = 0;
    int diff_min = 99999999;
    int shift_x_min = 0;
    int shift_y_min = 0;
    
    int shift_range = 10; // 40;
    for (int shift_x1 = -shift_range; shift_x1 <= shift_range; shift_x1 += 1)
    {
        for (int shift_y1 = -shift_range; shift_y1 <= shift_range; shift_y1 += 1)
        {
            diff = [self image_diff: bytesPerRow :shift_x1 :shift_y1 :prev_pix_arr :pix_arr];
            // diff = [self image_diff: bytesPerRow :shift_x1 :shift_y1 :pix_arr :pix_arr];
            // printf("                      |||  shift_x1: %d  shift_y1: %d   diff: %d   diff_min: %d   shift_x_min: %d   shift_y_min: %d \n",  shift_x1, shift_y1, diff, diff_min, shift_x_min, shift_y_min);
            
            if (diff < diff_min)
            {
                diff_min = diff;
                shift_x_min = shift_x1;
                shift_y_min = shift_y1;
            }
        }
    }
    
    printf("      --- Alignment of frame %d   diff_min: %d  shift_x: %d   shift_y: %d \n",  frame_no, diff_min, shift_x_min, shift_y_min);
    
    align_shift[0] = shift_x_min;   // applied to previous image
    align_shift[1] = shift_y_min;   // applied to previous image
    
    
    
    // Now fill in img_sect_align
    
    int num_rows = img_sect_align_num_rows;    // this needs to be consistent with allocation of img_sect_align
    int num_cols = img_sect_align_num_cols;    // this needs to be consistent with allocation of img_sect_align
    int col_width  = image_width / num_cols;
    int row_height = image_height / num_rows;
    
    /*
    // Start with the sections at the center and move outwards:
    int row1 = num_rows / 2;
    int col1 = num_cols / 2;
    for (col1 = (num_cols / 2); col1 < num_cols; col1++)
    {
        [self align_img_section :frame_no :bytesPerRow :shift_x_min :shift_y_min :prev_pix_arr :pix_arr :img_sect_align :row1 :col1 :row_height :col_width];
    }
    */
    
// /*
    for (int img_sect_col = 0; img_sect_col < img_sect_align_num_cols; img_sect_col++)
    {
        for (int img_sect_row = 0; img_sect_row < img_sect_align_num_rows; img_sect_row++)
        {
            [self align_img_section :frame_no :bytesPerRow :shift_x_min :shift_y_min :prev_pix_arr :pix_arr :img_sect_align :img_sect_row :img_sect_col :row_height :col_width];
        }
    }
// */
    
    // Print out img_sect_align:
    /*
    printf("               img_sect_align matrix: \n");
    for (int img_sect_col = 0; img_sect_col < img_sect_align_num_cols; img_sect_col++)
    {
        for (int img_sect_row = 0; img_sect_row < img_sect_align_num_rows; img_sect_row++)
        {
            int idx = img_sect_row * img_sect_align_num_cols + img_sect_col;
            int shift_x2 = img_sect_align[idx * 2];
            int shift_y2 = img_sect_align[idx * 2 + 1];
            printf("                  row: %d  col: %d  shift_x: %d  shift_y: %d: \n", img_sect_row, img_sect_col, shift_x2, shift_y2);
        }
    }
    */
}



- (void) align_img_section: (int)frame_no :(size_t)bytesPerRow :(int)center_align_x :(int)center_align_y :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr  :(signed char*)img_sect_align  :(int)row :(int)col :(int)row_height :(int)col_width
{
    // printf("            align_img_section - row1: %d  col1: %d \n", row, col);
    int box_width = col_width;
    int box_height = row_height;
    
    int box_step_size = box_width / 20; // 40; // 80; // 2;
    int box_diff_threshold = 30;  // not used
    int x = col * col_width;      // upper left corner of box to be aligned
    int y = row * row_height;     //
    
    // printf("      @@@bbb@@@  col_width: %d,  row_height: %d,  box_step_size: %d \n",  col_width, row_height, box_step_size);
    
    int diff_min = 999999999;
    int shift_x_min = 0;
    int shift_y_min = 0;
    
    int shift_range = 1;
    for (int shift_x2 = -shift_range; shift_x2 <= shift_range; shift_x2 += 1)
    {
        for (int shift_y2 = -shift_range; shift_y2 <= shift_range; shift_y2 += 1)
        {
            int align_shift_x = center_align_x + shift_x2;
            int align_shift_y = center_align_y + shift_y2;
            int diff2 = [self get_diff_in_box1 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
            if (diff2 < diff_min)
            {
                diff_min = diff2;
                shift_x_min = align_shift_x;
                shift_y_min = align_shift_y;
            }
            // printf("                    align_img_section - col: %d  row: %d  shift_x2: %d  shift_y2: %d  diff2: %d     align_shift_x: %d  align_shift_y: %d \n",  col, row, shift_x2, shift_y2, diff2, align_shift_x, align_shift_y);
        }
    }
    
    int idx = (row * img_sect_align_num_cols) + col;
    img_sect_align[idx * 2]     = shift_x_min;
    img_sect_align[idx * 2 + 1] = shift_y_min;
}



- (int) image_diff :(size_t)bytesPerRow :(int)shift_x1 :(int)shift_y1 :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr;
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    int half_width = image_width / 2;
    int half_height = image_height / 2;
    int diff = 0;
    
    
    // int idx0 = (half_height * bytesPerRow) + (half_width * 4);
    // int pix1      = pix_arr[idx0];
    // int prev_pix1 = prev_pix_arr[idx0];
    // printf("             image_diff - after copy to prev pix arr --  half_width: %d   half_height: %d   pix1: %d   prev_pix1: %d \n",  half_width, half_height, pix1, prev_pix1);
    
    
    int radius = 100; // 200;
    int step_size = 10; // 10;
    for (int x = (half_width - radius); x <= (half_width + radius); x += step_size)
    {
        for (int y = (half_height - radius); y <= (half_height + radius); y += step_size)
        {
            int idx1 = (y * bytesPerRow) + (x * 4);
            int idx2 = ((y + shift_y1) * bytesPerRow) + ((x + shift_x1) * 4);
            diff += (int) fabs(pix_arr[idx1] - prev_pix_arr[idx2]);
            
            // if ((x == half_width) && (y == half_height))
            // {
            //     int pix1 = pix_arr[idx1];
            //     int prev_pix1 = prev_pix_arr[idx2];
            //     int diff1 = pix1 - prev_pix1;
            //     printf("                     image_diff -- shift_x1: %d   shift_y1: %d   idx1: %d   idx2: %d  pix1: %d   prev_pix1: %d  diff1: %d  \n",  shift_x1, shift_y1, idx1, idx2, pix1, prev_pix1, diff1);
            // }
        }
    }
    return diff;
}



- (void) find_moving_objects__tennis:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    int img_half_width = image_width / 2;
    // int half_height = image_height / 2;
    
    int align_shift_x = align_shift[0];     // these are redundant (see img_sect_align)
    int align_shift_y = align_shift[1];
    
    int align_shift_x_curr_pprev = align_shift_curr_pprev[0];     // these are redundant (see img_sect_align_curr_pprev)
    int align_shift_y_curr_pprev = align_shift_curr_pprev[1];
    
    printf("         - find_moving_objects - align_shift_x: %d  align_shift_y: %d \n",  align_shift_x, align_shift_y);
    [self set_overlay_box :0 :0];       // default position of blue box
    
    // Look for isolated areas where the two images differ:
    
    int box_width = 10; // 20;
    int box_height = 10; // 20;
    
    size_t pixel_arr_idx = 0;
    int red = 0;
    int green = 0;
    int blue = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int red_ave_max = 0;
    int green_ave_max = 0;
    int blue_ave_max = 0;
    
    int step_size = 2;
    
    int diff_box = 0;
    int diff_box_ave = 0;
    int diff_box_acc = 0;
    int diff_box_cnt = 0;
    
    int diff_box_curr_pprev = 0;
    
    // int diff_box_left = 0;
    // int diff_box_right = 0;
    // int diff_box_up = 0;
    // int diff_box_down = 0;
    
    // NEED TO MAKE SURE THE align_shift PARAMETERS DON'T LEAD TO INDICES OUT THE IMAGE ARRAYS
    int margin_x = 30; // 70; // 100; // 200; // 400; // 200; // 100;
    int margin_y_top = 40; // 20;
    int margin_y_bottom = 500;
    // int margin_y_bottom = min(500, (int)(((float)image_height) * 0.4f));
    
    int red_acc = 0;
    int green_acc = 0;
    int blue_acc = 0;
    
    int score = 0;
    int score_max = -999999;
    int pos_x_max = 0;
    int pos_y_max = 0;
    
    int box_step_size = 2;
    
    int color_score = 0;
    
    int box_diff_threshold = 70; // 100; // 150; // 200; // 250; // 300 // 200 // 100
    //x int box_diff_threshold = 40; // 50;

    for (int x = margin_x; x < ((image_width - box_width) - margin_x); x += step_size)
    {
        for (int y = margin_y_top; y < ((image_height - box_height) - margin_y_bottom); y += step_size)
        {
            // Compare prev_img with pprev_img.
            diff_box = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
            //x diff_box = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];

            
            // Make sure the difference is not due to image shift:
            /*
            if (diff_box > box_diff_threshold)
            {
                int diff_box_verify = [self verify_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                if (diff_box_verify < diff_box)
                {
                    diff_box = diff_box_verify;
                }
            }
            */
            
            diff_box_acc += diff_box;
            diff_box_cnt++;
            
            if (diff_box > box_diff_threshold)    // x, y position is a candidate for moving object
            {
                // Compare curr_img with pprev_img (difference should be close to zero).
                //x diff_box_curr_pprev = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :curr_img :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                // WE SHOULD USE pix_arr (prev_img) AS REFERENCE AND APPLY align shift TO curr_img (align_shift_prev_curr = alin_shift_prev_pprev minus align_shift_curr_pprev
                diff_box_curr_pprev = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :curr_img :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                
                if (diff_box_curr_pprev < 50) // 50)
                //x if (diff_box_curr_pprev < 70) // 60) // 50)
                {
                    // Check if neighboring 10x10 boxes show a difference
                    // int box_diff_threshold_2 = box_diff_threshold / 2;
                    // int box_diff_threshold_2 = box_diff_threshold - (box_diff_threshold / 3);
                    // int box_diff_threshold_2 = 0;
                    // int x_left = x - box_width;
                    //x diff_box_left = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    // diff_box_left = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    
                    // if (diff_box_left > box_diff_threshold_2)
                    if (true)
                    {
                        // int x_right = x + box_width;
                        // diff_box_right = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_right :y];
                        // diff_box_right = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_right :y];
                        
                        if (true) // (diff_box_right > box_diff_threshold_2)
                        {
                            // int y_up = y - box_height;
                            // diff_box_up = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y_up];
                            // diff_box_up = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y_up];
                            
                            if (true) // (diff_box_up > box_diff_threshold_2)
                            {
                                // int y_down = y + box_height;
                                // diff_box_down = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y_down];
                                // diff_box_down = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y_down];
                                
                                if (true) // (diff_box_down > box_diff_threshold_2)
                                {
                                    // Check color
                                    red_acc = 0;
                                    green_acc = 0;
                                    blue_acc = 0;
                                    int cnt2 = 0;
                                    for (int bx = 0; bx < box_width; bx++)
                                    {
                                        for (int by = 0; by < box_height; by++)
                                        {
                                            pixel_arr_idx = ((y + by) * bytesPerRow) + ((x + bx) * 4);
                                            red   = pix_arr[pixel_arr_idx + 2];
                                            green = pix_arr[pixel_arr_idx + 1];
                                            blue  = pix_arr[pixel_arr_idx];
                                            
                                            red_acc += red;
                                            green_acc += green;
                                            blue_acc += blue;
                                            
                                            cnt2++;
                                        }
                                    }
                                    red_ave   = red_acc / cnt2;
                                    green_ave = green_acc / cnt2;
                                    blue_ave  = blue_acc / cnt2;
                                    // if ([self is_yellow:red_ave :green_ave :blue_ave])
                                    // if ([self is_light_color :red_ave :green_ave :blue_ave])
                                    if ([self is_light_or_yellow :red_ave :green_ave :blue_ave])
                                    // if (true)
                                    {
                                        int color_diff = 0;
                                        if (obj_color_red != -1)    // colors are valid
                                        {
                                            color_diff = (red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue);
                                        }
                                        
                                        // printf("               red_ave: %d   obj_color_red: %d      green_ave: %d   obj_color_green: %d      blue_ave: %d   obj_color_blue: %d \n",  red_ave, obj_color_red, green_ave, obj_color_green, blue_ave, obj_color_blue);
                                        
                                        if (color_diff < 120) // 170)
                                        // if (true)
                                        {
                                            // Check if the obj frame is fixed:
                                            int obj_frame_diff = [self compute_object_frame_diff :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                            
                                            //                      if (obj_frame_diff < 40) // 80) // 100) // 150) // 200)
                                            // if (obj_frame_diff < 100)
                                            if (obj_frame_diff < 100)
                                            // if (true)
                                            {
                                                // Identify set of pixels that differ and check if they fit into an octagon; then check if that shape and color appear the marked location in the previous frame:
                                                // [self identify_2d_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                                
                                                color_score = 100 - ((red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue));
                                                
                                                // score = diff_box - obj_frame_diff;
                                                score = diff_box - diff_box_curr_pprev;
                                                
                                                // printf("         diff_box: %d  at x: %d  y: %d  obj_frame_diff: %d   diff_box_curr_pprev: %d   score: %d   color_score: %d   color_diff: %d \n",  diff_box, x, y, obj_frame_diff, diff_box_curr_pprev, score, color_score, color_diff);
                                                // printf("            - red_ave: %d   green_ave: %d   blue_ave: %d \n",  red_ave, green_ave, blue_ave);
                                                
                                                // score += color_score;
                                                
                                                if (score > score_max)
                                                {
                                                    score_max = score;
                                                    pos_x_max = x;
                                                    pos_y_max = y;
                                                    
                                                    red_ave_max = red_ave;
                                                    green_ave_max = green_ave;
                                                    blue_ave_max = blue_ave;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    int obj_center = 0;
    if ((pos_x_max != 0) && (pos_y_max != 0))
    {
        obj_center = [self find_center_of_moving_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :pos_x_max :pos_y_max];
    }
    int obj_center_x = obj_center / 1000000;
    int obj_center_y = obj_center % 1000000;
    // printf("         --- object center - x: %d  y: %d \n",  obj_center_x, obj_center_y);
    
    if (obj_center_x != 0) // (sharpness > 1.0f)
    {
        obj_color_red   = red_ave_max;
        obj_color_green = green_ave_max;
        obj_color_blue  = blue_ave_max;
        
        
        // Compute speed:
        if (     (! (object_action_path_state >= 90))                                              // not past point of no return (otherwise cancel speed computation)
             ||  ((fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max))))     // OR moving outwards
        {
            float obj_radius = 11.94; // 16.0f; // 13.16f;                    // pixels
            if (ball_radius > 1.0f)
            {
                obj_radius = ball_radius;                 // pixels
            }
            float obj_diameter = 2 * obj_radius;          // pixels
            // float frame_rate = 30;                     // frames / sec
            float frame_rate = video_fps / down_sampling_factor;                 // frames / sec
            float time_per_frame = 1.0f / frame_rate;     // sec
            float ball_diameter = 0.0667f;                // meters
            float meters_per_pixel = ball_diameter / obj_diameter;   // meters
            
            float delta_x = prev_pos_x_max - pos_x_max;
            float delta_y = prev_pos_y_max - pos_y_max;
            float distance_traveled_in_pixels = 0.0f;
            if ((prev_pos_x_max != 0) && (prev_pos_y_max != 0))    // if previous position is valid
            {
                distance_traveled_in_pixels = sqrtf(delta_x * delta_x + delta_y * delta_y);
                
                float distance_traveled_in_meters = distance_traveled_in_pixels * meters_per_pixel;
                
                float speed = distance_traveled_in_meters / time_per_frame;    // meters / sec
                ball_speed_mph = speed * 2.2369f;   // convert m/s in mph
                
                printf("      speed: %2.2f   obj_radius: %2.2f   distance_traveled_in_meters: %2.2f   distance_traveled_in_pixels: %2.2f   frame_rate: %2.2f   time_per_frame: %2.2f \n",  speed, obj_radius, distance_traveled_in_meters, distance_traveled_in_pixels, frame_rate, time_per_frame);
                
                
                // Track object_action_path_state:
                if (    (fabs(delta_x) > (3.0 * fabs(delta_y)))                                       // mostly horizontal movement
                    &&  (fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))   // moving outwards
                {
                    object_action_path_state = 60;
                    
                    int large_displacement = img_half_width / (video_fps / 10.0f);
                    if (fabs(delta_x) > large_displacement)                                           // moving fast
                    {
                        object_action_path_state = 90;                                                // point of no return
                        
                        if (impact_frame_no == 0)                                                     // impact most likely occurred right before high horizontal velocity is observed
                        {
                            impact_frame_no = frame_no - 1;
                            if (sport == 20) { impact_frame_no = frame_no - 6; }
                        }
                    }
                    
                    if (ball_speed_mph > max_ball_speed_mph)
                    {
                        max_ball_speed_mph = ball_speed_mph;
                    }
                }
            }
            else { ball_speed_mph = 0.0f; }
        }
        
        prev_pos_x_max = pos_x_max;
        prev_pos_y_max = pos_y_max;
    }
    else
    {
        prev_pos_x_max = 0;
        prev_pos_y_max = 0;
        
        ball_speed_mph = 0.0f;
    }

    
    // [self set_overlay_box :(pos_x_max + (box_width / 2)) :(pos_y_max + (box_height / 2))];                         // Set position of blue box
    [self set_overlay_box :obj_center_x :obj_center_y];                                                               // Set position of blue box

    diff_box_ave = diff_box_acc / diff_box_cnt;                                                                       // the average is approx. 16
    
    // printf("         === frame_no: %d   diff_box_ave: %d \n", frame_no, diff_box_ave);
}




- (void) find_moving_objects__ice_hockey:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    int img_half_width = image_width / 2;
    // int half_height = image_height / 2;
    
    int align_shift_x = align_shift[0];     // these are redundant (see img_sect_align)
    int align_shift_y = align_shift[1];
    
    int align_shift_x_curr_pprev = align_shift_curr_pprev[0];     // these are redundant (see img_sect_align_curr_pprev)
    int align_shift_y_curr_pprev = align_shift_curr_pprev[1];
    
    printf("         - find_moving_objects - align_shift_x: %d  align_shift_y: %d \n",  align_shift_x, align_shift_y);
    [self set_overlay_box :0 :0];       // default position of blue box
    
    // Look for isolated areas where the two images differ:
    
    int box_width = 20; // 10; // 20;
    int box_height = 10; // 20;
    
    size_t pixel_arr_idx = 0;
    int red = 0;
    int green = 0;
    int blue = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int red_ave_max = 0;
    int green_ave_max = 0;
    int blue_ave_max = 0;
    
    int step_size = 2;
    
    int diff_box = 0;
    int diff_box_ave = 0;
    int diff_box_acc = 0;
    int diff_box_cnt = 0;
    int diff_box_max = 0;
    
    int diff_box_curr_pprev = 0;
    int diff_box_curr_pprev_max = 0;
    
    // int diff_box_left = 0;
    // int diff_box_right = 0;
    // int diff_box_up = 0;
    // int diff_box_down = 0;
    
    // NEED TO MAKE SURE THE align_shift PARAMETERS DON'T LEAD TO INDICES OUT THE IMAGE ARRAYS
    int margin_x = 70; // 100; // 200; // 400; // 200; // 100;
    // int margin_y_top = (image_height / 2) + 0; // 200; // 600; // 40; 20;
    int margin_y_top = (image_height / 2) + 200; // 600; // 40; 20;
    int margin_y_bottom = 40; // 20;
    
    int red_acc = 0;
    int green_acc = 0;
    int blue_acc = 0;
    
    int score = 0;
    int score_max = -999999;
    int pos_x_max = 0;
    int pos_y_max = 0;
    
    int box_step_size = 2;
    
    int color_score = 0;
    
//  int box_diff_threshold = 70; // 100; // 150; // 200;
    int box_diff_threshold = 40; // 70; // 100; // 150; // 200;
//  int diff_box_curr_pprev_threshold = 50;
    int diff_box_curr_pprev_threshold = 60; // 50;
    //x int box_diff_threshold = 40; // 50;
    
    for (int x = margin_x; x < ((image_width - box_width) - margin_x); x += step_size)
    {
        for (int y = margin_y_top; y < ((image_height - box_height) - margin_y_bottom); y += step_size)
        {
            // Compare prev_img with pprev_img.
            diff_box = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
            //x diff_box = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
            
            
            // Make sure the difference is not due to image shift:
            /*
             if (diff_box > box_diff_threshold)
             {
                 int diff_box_verify = [self verify_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                 if (diff_box_verify < diff_box)
                 {
                     diff_box = diff_box_verify;
                 }
             }
            */
            
            diff_box_acc += diff_box;
            diff_box_cnt++;
            
            if (diff_box > box_diff_threshold)    // x, y position is a candidate for moving object
            {
                // Compare curr_img with pprev_img (difference should be close to zero).
                //x diff_box_curr_pprev = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :curr_img :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                // WE SHOULD USE pix_arr (prev_img) AS REFERENCE AND APPLY align shift TO curr_img (align_shift_prev_curr = alin_shift_prev_pprev minus align_shift_curr_pprev
                diff_box_curr_pprev = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :curr_img :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                
                if (diff_box_curr_pprev < diff_box_curr_pprev_threshold)
                {
                    // Check if neighboring 10x10 boxes show a difference
                    // int box_diff_threshold_2 = box_diff_threshold / 2;
                    // int box_diff_threshold_2 = box_diff_threshold - (box_diff_threshold / 3);
                    // int box_diff_threshold_2 = 0;
                    // int x_left = x - box_width;
                    //x diff_box_left = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    // diff_box_left = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    
                    // if (diff_box_left > box_diff_threshold_2)
                    if (true)
                    {
                        // int x_right = x + box_width;
                        // diff_box_right = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_right :y];
                        // diff_box_right = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_right :y];
                        
                        if (true) // (diff_box_right > box_diff_threshold_2)
                        {
                            // int y_up = y - box_height;
                            // diff_box_up = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y_up];
                            // diff_box_up = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y_up];
                            
                            if (true) // (diff_box_up > box_diff_threshold_2)
                            {
                                // int y_down = y + box_height;
                                // diff_box_down = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y_down];
                                // diff_box_down = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y_down];
                                
                                if (true) // (diff_box_down > box_diff_threshold_2)
                                {
                                    // Check color
                                    red_acc = 0;
                                    green_acc = 0;
                                    blue_acc = 0;
                                    int cnt2 = 0;
                                    for (int bx = 0; bx < box_width; bx++)
                                    {
                                        for (int by = 0; by < box_height; by++)
                                        {
                                            pixel_arr_idx = ((y + by) * bytesPerRow) + ((x + bx) * 4);
                                            red   = pix_arr[pixel_arr_idx + 2];
                                            green = pix_arr[pixel_arr_idx + 1];
                                            blue  = pix_arr[pixel_arr_idx];
                                            
                                            red_acc += red;
                                            green_acc += green;
                                            blue_acc += blue;
                                            
                                            cnt2++;
                                        }
                                    }
                                    red_ave   = red_acc / cnt2;
                                    green_ave = green_acc / cnt2;
                                    blue_ave  = blue_acc / cnt2;
                                    // if ([self is_yellow:red_ave :green_ave :blue_ave])
                                    // if ([self is_light_color :red_ave :green_ave :blue_ave])
                                    // if ([self is_light_or_yellow :red_ave :green_ave :blue_ave])
                                    if (true)
                                    {
                                        int color_diff = 0;
                                        if (obj_color_red != -1)    // colors are valid
                                        {
                                            color_diff = (red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue);
                                        }
                                        
                                        // printf("               red_ave: %d   obj_color_red: %d      green_ave: %d   obj_color_green: %d      blue_ave: %d   obj_color_blue: %d \n",  red_ave, obj_color_red, green_ave, obj_color_green, blue_ave, obj_color_blue);
                                        
                                        // if (color_diff < 120) // 170)
                                        if (true)
                                        {
                                            // Check if the obj frame is fixed:
                                            int obj_frame_diff = [self compute_object_frame_diff :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                            
                                            //                      if (obj_frame_diff < 40) // 80) // 100) // 150) // 200)
                                            // if (obj_frame_diff < 100)
                                            // if (obj_frame_diff < 100)
                                            if (true)
                                            {
                                                // Identify set of pixels that differ and check if they fit into an octagon; then check if that shape and color appear the marked location in the previous frame:
                                                // [self identify_2d_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                                
                                                color_score = 100 - ((red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue));
                                                
                                                // score = diff_box - obj_frame_diff;
                                                score = diff_box - diff_box_curr_pprev;
                                                
                                                // printf("         diff_box: %d  at x: %d  y: %d  obj_frame_diff: %d   diff_box_curr_pprev: %d   score: %d   color_score: %d   color_diff: %d \n",  diff_box, x, y, obj_frame_diff, diff_box_curr_pprev, score, color_score, color_diff);
                                                // printf("            - red_ave: %d   green_ave: %d   blue_ave: %d \n",  red_ave, green_ave, blue_ave);
                                                
                                                // score += color_score;
                                                
                                                if (score > score_max)
                                                {
                                                    score_max = score;
                                                    pos_x_max = x;
                                                    pos_y_max = y;
                                                    
                                                    red_ave_max = red_ave;
                                                    green_ave_max = green_ave;
                                                    blue_ave_max = blue_ave;
                                                    
                                                    diff_box_max = diff_box;
                                                    diff_box_curr_pprev_max = diff_box_curr_pprev;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    int obj_center = 0;
    if ((pos_x_max != 0) && (pos_y_max != 0))
    {
        obj_center = [self find_center_of_moving_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :pos_x_max :pos_y_max];
    }
    int obj_center_x = obj_center / 1000000;
    int obj_center_y = obj_center % 1000000;
    // printf("         --- object center - x: %d  y: %d \n",  obj_center_x, obj_center_y);
    
    if (obj_center_x != 0) // (sharpness > 1.0f)
    {
        obj_color_red   = red_ave_max;
        obj_color_green = green_ave_max;
        obj_color_blue  = blue_ave_max;
        
        
        // Compute speed:
        if (    (! (object_action_path_state >= 90))                                              // not past point of no return (otherwise cancel speed computation)
            ||  ((fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max))))     // OR moving outwards
        {
            float obj_radius = 13.16f;                    // pixels
            if (ball_radius > 1.0f)
            {
                obj_radius = ball_radius;                 // pixels
            }
            float obj_diameter = 2 * obj_radius;          // pixels
            // float frame_rate = 30;                     // frames / sec
            float frame_rate = video_fps;                 // frames / sec
            float time_per_frame = 1.0f / frame_rate;     // sec
            float ball_diameter = 0.0667f;                // meters
            float meters_per_pixel = ball_diameter / obj_diameter;   // meters
            
            float delta_x = prev_pos_x_max - pos_x_max;
            float delta_y = prev_pos_y_max - pos_y_max;
            float distance_traveled_in_pixels = 0.0f;
            if ((prev_pos_x_max != 0) && (prev_pos_y_max != 0))    // if previous position is valid
            {
                distance_traveled_in_pixels = sqrtf(delta_x * delta_x + delta_y * delta_y);
                
                float distance_traveled_in_meters = distance_traveled_in_pixels * meters_per_pixel;
                
                float speed = distance_traveled_in_meters / time_per_frame;    // meters / sec
                ball_speed_mph = speed * 2.2369f;   // convert m/s in mph
                
                printf("      speed: %2.2f   distance_traveled_in_meters: %2.2f   distance_traveled_in_pixels: %2.2f \n",  speed, distance_traveled_in_meters, distance_traveled_in_pixels);
                
                
                // Track object_action_path_state:
                if (    (fabs(delta_x) > (3.0 * fabs(delta_y)))                                       // mostly horizontal movement
                    &&  (fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))   // moving outwards
                {
                    object_action_path_state = 60;
                    
                    // int large_displacement = img_half_width / (video_fps / 10.0f);
                    int large_displacement = 30;   // for mishits
                    if (fabs(delta_x) > large_displacement)                                           // moving fast
                    {
                        object_action_path_state = 90;                                                // point of no return
                        
                        if (impact_frame_no == 0)                                                     // impact most likely occurred right before high horizontal velocity is observed
                        {
                            impact_frame_no = frame_no - 1;
                            if (sport == 20) { impact_frame_no = frame_no - 1; }    // -6
                        }
                    }
                    
                    if (ball_speed_mph > max_ball_speed_mph)
                    {
                        max_ball_speed_mph = ball_speed_mph;
                    }
                }
            }
            else { ball_speed_mph = 0.0f; }
        }
        
        prev_pos_x_max = pos_x_max;
        prev_pos_y_max = pos_y_max;
    }
    else
    {
        prev_pos_x_max = 0;
        prev_pos_y_max = 0;
        
        ball_speed_mph = 0.0f;
    }
    
    
    // [self set_overlay_box :(pos_x_max + (box_width / 2)) :(pos_y_max + (box_height / 2))];                         // Set position of blue box
    [self set_overlay_box :obj_center_x :obj_center_y];                                                               // Set position of blue box
    
    diff_box_ave = diff_box_acc / diff_box_cnt;                                                                       // the average is approx. 16
    
    
    printf("      === diff_box_max: %d   diff_box_curr_pprev_max: %d   pos_x_max: %d   pos_y_max: %d \n",  diff_box_max, diff_box_curr_pprev_max, pos_x_max, pos_y_max);
    // printf("         === frame_no: %d   diff_box_ave: %d \n", frame_no, diff_box_ave);
}




- (void) find_moving_objects__baseball:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    int img_half_width = image_width / 2;
    // int half_height = image_height / 2;
    
    int align_shift_x = align_shift[0];     // these are redundant (see img_sect_align)
    int align_shift_y = align_shift[1];
    
    int align_shift_x_curr_pprev = align_shift_curr_pprev[0];     // these are redundant (see img_sect_align_curr_pprev)
    int align_shift_y_curr_pprev = align_shift_curr_pprev[1];
    
    printf("         - find_moving_objects - align_shift_x: %d  align_shift_y: %d  prev_pos_x_max: %d  prev_pos_y_max: %d\n",  align_shift_x, align_shift_y, prev_pos_x_max, prev_pos_y_max);
    [self set_overlay_box :0 :0];       // default position of blue box
    
    // Look for isolated areas where the two images differ:
    
    int box_width = 10; // 20;
    int box_height = 10; // 20;
    
    size_t pixel_arr_idx = 0;
    int red = 0;
    int green = 0;
    int blue = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int red_ave_max = 0;
    int green_ave_max = 0;
    int blue_ave_max = 0;
    
    int step_size = 2;
    
    int diff_box = 0;
    int diff_box_ave = 0;
    int diff_box_acc = 0;
    int diff_box_cnt = 0;
    
    int diff_box_curr_pprev = 0;
    
    // int diff_box_left = 0;
    // int diff_box_right = 0;
    // int diff_box_up = 0;
    // int diff_box_down = 0;
    
    // NEED TO MAKE SURE THE align_shift PARAMETERS DON'T LEAD TO INDICES OUT THE IMAGE ARRAYS
    int margin_x = image_width / 60; // 70;
    int margin_y_top = image_height / 3;
    int margin_y_bottom = image_height / 40;
    
    int red_acc = 0;
    int green_acc = 0;
    int blue_acc = 0;
    
    int score = 0;
    int score_max = -999999;
    int pos_x_max = 0;
    int pos_y_max = 0;
    
    int box_step_size = 2;
    
    int color_score = 0;
    
    int box_diff_threshold = 160; // 200; // 250; // 280; // 300; // 260; // 210;
    //x int box_diff_threshold = 40; // 50;
    
    for (int x = margin_x; x < ((image_width - box_width) - margin_x); x += step_size)
    {
        for (int y = margin_y_top; y < ((image_height - box_height) - margin_y_bottom); y += step_size)
        {
            // Compare prev_img with pprev_img.
            diff_box = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
            
            
            // Make sure the difference is not due to image shift:
            /*
             if (diff_box > box_diff_threshold)
             {
             int diff_box_verify = [self verify_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
             if (diff_box_verify < diff_box)
             {
             diff_box = diff_box_verify;
             }
             }
             */
            
            diff_box_acc += diff_box;
            diff_box_cnt++;
            
            if (diff_box > box_diff_threshold)    // x, y position is a candidate for moving object
            {
    //            printf("         --- baseball - diff_box: %d   diff_box_threshold: %d \n",  diff_box, box_diff_threshold);
                // Compare curr_img with pprev_img (difference should be close to zero).
                // WE SHOULD USE pix_arr (prev_img) AS REFERENCE AND APPLY align shift TO curr_img (align_shift_prev_curr = alin_shift_prev_pprev minus align_shift_curr_pprev
    //          diff_box_curr_pprev = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :curr_img :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                
                if (true) // (diff_box_curr_pprev < 50) // 50)  // in super slow moation we cannot use this (ball moves to slow)
                {
                    // Check if neighboring 10x10 boxes show a difference
                    // int box_diff_threshold_2 = box_diff_threshold / 2;
                    // int box_diff_threshold_2 = box_diff_threshold - (box_diff_threshold / 3);
                    // int box_diff_threshold_2 = 0;
                    // int x_left = x - box_width;
                    //x diff_box_left = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    // diff_box_left = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    
                    // if (diff_box_left > box_diff_threshold_2)
                    if (true)
                    {
                        // int x_right = x + box_width;
                        // diff_box_right = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_right :y];
                        // diff_box_right = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_right :y];
                        
                        if (true) // (diff_box_right > box_diff_threshold_2)
                        {
                            // int y_up = y - box_height;
                            // diff_box_up = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y_up];
                            // diff_box_up = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y_up];
                            
                            if (true) // (diff_box_up > box_diff_threshold_2)
                            {
                                // int y_down = y + box_height;
                                // diff_box_down = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y_down];
                                // diff_box_down = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y_down];
                                
                                if (true) // (diff_box_down > box_diff_threshold_2)
                                {
                                    // Check color
                                    red_acc = 0;
                                    green_acc = 0;
                                    blue_acc = 0;
                                    int cnt2 = 0;
                                    for (int bx = 0; bx < box_width; bx++)
                                    {
                                        for (int by = 0; by < box_height; by++)
                                        {
                                            pixel_arr_idx = ((y + by) * bytesPerRow) + ((x + bx) * 4);
                                            red   = pix_arr[pixel_arr_idx + 2];
                                            green = pix_arr[pixel_arr_idx + 1];
                                            blue  = pix_arr[pixel_arr_idx];
                                            
                                            red_acc += red;
                                            green_acc += green;
                                            blue_acc += blue;
                                            
                                            cnt2++;
                                        }
                                    }
                                    red_ave   = red_acc / cnt2;
                                    green_ave = green_acc / cnt2;
                                    blue_ave  = blue_acc / cnt2;
                                    // if ([self is_yellow:red_ave :green_ave :blue_ave])
                                    // if ([self is_light_color :red_ave :green_ave :blue_ave])
                                    if ([self is_white_color :red_ave :green_ave :blue_ave])
                                    // if (true)
                                    {
                                        // printf("      --- baseball - passed is_white_color - red_ave: %d  green_ave: %d  blue_ave: %d \n", red_ave, green_ave, blue_ave);
                                        int color_diff = 0;
                                        if (obj_color_red != -1)    // colors are valid
                                        {
                                            color_diff = (red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue);
                                        }
                                        
                                        // printf("               red_ave: %d   obj_color_red: %d      green_ave: %d   obj_color_green: %d      blue_ave: %d   obj_color_blue: %d \n",  red_ave, obj_color_red, green_ave, obj_color_green, blue_ave, obj_color_blue);
                                        
                                        // if (color_diff < 120) // 170)
                                        if (true)
                                        {
                                            // Check if the obj frame is fixed:
                                            int obj_frame_diff = [self compute_object_frame_diff :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                            
                                            //                      if (obj_frame_diff < 40) // 80) // 100) // 150) // 200)
                                            // if (obj_frame_diff < 100)
                                            if (obj_frame_diff < 100)
                                            // if (true)
                                            {
                                                // Identify set of pixels that differ and check if they fit into an octagon; then check if that shape and color appear the marked location in the previous frame:
                                                // [self identify_2d_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                                
                                                color_score = 100 - ((red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue));
                                                
                                                // Check how close this position is to the previous position:
                                                int displacement_score = 100;
                                                if (frame_no > 10)
                                                {
                                                    float delta_x = fabs(prev_pos_x_max - x);
                                                    float delta_y = fabs(prev_pos_y_max - y);
                                                    float displacement = sqrt(delta_x * delta_x + delta_y * delta_y);
                                                    displacement_score -= ((int) displacement);
                                                }
                                                
                                                // score = diff_box - obj_frame_diff;
                                                score = diff_box - diff_box_curr_pprev + displacement_score;
                                                score += (red_ave + green_ave + blue_ave) / 8;     // the ball is a light color object
                                                
                                                printf("         diff_box: %d  at x: %d  y: %d  obj_frame_diff: %d   diff_box_curr_pprev: %d   score: %d   color_score: %d   color_diff: %d \n",  diff_box, x, y, obj_frame_diff, diff_box_curr_pprev, score, color_score, color_diff);
                                                printf("            - red_ave: %d   green_ave: %d   blue_ave: %d \n",  red_ave, green_ave, blue_ave);
                                                
                                                // score += color_score;
                                                
                                                if (score > score_max)
                                                {
                                                    score_max = score;
                                                    pos_x_max = x;
                                                    pos_y_max = y;
                                                    
                                                    red_ave_max = red_ave;
                                                    green_ave_max = green_ave;
                                                    blue_ave_max = blue_ave;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    int obj_center = 0;
    if ((pos_x_max != 0) && (pos_y_max != 0))
    {
        obj_center = [self find_center_of_moving_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :pos_x_max :pos_y_max];
    }
    int obj_center_x = obj_center / 1000000;
    int obj_center_y = obj_center % 1000000;
    // printf("         --- object center - x: %d  y: %d \n",  obj_center_x, obj_center_y);
    
    if (obj_center_x != 0) // (sharpness > 1.0f)
    {
        obj_color_red   = red_ave_max;
        obj_color_green = green_ave_max;
        obj_color_blue  = blue_ave_max;
        
        printf("         --- baseball - red_ave_max: %d  green_ave_max: %d  blue_ave_max: %d \n",  red_ave_max, green_ave_max, blue_ave_max);
        
        // Compute speed:
        if (   (frame_no > 40)        // temporary for demo
            && (    (! (object_action_path_state >= 90))                                               // not past point of no return (otherwise cancel speed computation)
                ||  ((fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))))     // OR moving outwards
        {
            float obj_radius = 13.16f;                    // pixels
            if (ball_radius > 1.0f)
            {
                obj_radius = ball_radius;                 // pixels
            }
            float obj_diameter = 2 * obj_radius;          // pixels
            // float frame_rate = 30;                     // frames / sec
            float frame_rate = video_fps;                 // frames / sec
            float time_per_frame = 1.0f / frame_rate;     // sec
            float ball_diameter = 0.075;                  // meters (baseball diameter)
            float meters_per_pixel = ball_diameter / obj_diameter;   // meters
            
            float delta_x = prev_pos_x_max - pos_x_max;
            float delta_y = prev_pos_y_max - pos_y_max;
            float distance_traveled_in_pixels = 0.0f;
            if ((prev_pos_x_max != 0) && (prev_pos_y_max != 0))    // if previous position is valid
            {
                distance_traveled_in_pixels = sqrtf(delta_x * delta_x + delta_y * delta_y);
                
                float distance_traveled_in_meters = distance_traveled_in_pixels * meters_per_pixel;
                
                float speed = distance_traveled_in_meters / time_per_frame;    // meters / sec
                ball_speed_mph = speed * 2.2369f;   // convert m/s in mph
                
                printf("      speed: %2.2f   obj_radius: %2.2f   distance_traveled_in_meters: %2.2f   distance_traveled_in_pixels: %2.2f   frame_rate: %2.2f   time_per_frame: %2.2f \n",  speed, obj_radius, distance_traveled_in_meters, distance_traveled_in_pixels, frame_rate, time_per_frame);
                
                
                // Track object_action_path_state:
                if (    (fabs(delta_x) > (3.0 * fabs(delta_y)))                                       // mostly horizontal movement
                    &&  (fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))   // moving outwards
                {
                    object_action_path_state = 60;
                    
                    // int large_displacement = img_half_width / (video_fps / 10.0f);
                    int large_displacement = 15;     // use for super slow motion
                    if (   (fabs(delta_x) > (large_displacement - 10))                                // moving at certain speed
                        && (fabs(delta_x) < (large_displacement + 10)))
                    {
                        object_action_path_state = 90;                                                // point of no return
                        
                        if (impact_frame_no == 0)                                                     // impact most likely occurred right before high horizontal velocity is observed
                        {
                            int synch_factor = -8; // -16;
                            impact_frame_no = frame_no + synch_factor;
                        }
                        
                        if (ball_speed_mph > max_ball_speed_mph)
                        {
                            max_ball_speed_mph = ball_speed_mph;
                        }
                    }
                }
            }
            else { ball_speed_mph = 0.0f; }
        }
        
        printf("      pos_x_max: %d   pos_y_max: %d   prev_pos_x_max: %d   prev_pos_y_max: %d \n", pos_x_max, pos_y_max, prev_pos_x_max, prev_pos_y_max);
        prev_pos_x_max = pos_x_max;
        prev_pos_y_max = pos_y_max;
    }
    else
    {
        // Identify impact if the ball can't be detected for a short time
        // impact_frame_no = 100;
        if (   (prev_pos_x_max > (img_half_width - 60))
            && (prev_pos_x_max < (img_half_width + 60))
            && (impact_frame_no == 0)
           )
        {
            int sync_factor = 6;
            impact_frame_no = frame_no + sync_factor;
        }
        
        prev_pos_x_max = 0;
        prev_pos_y_max = 0;
        
        ball_speed_mph = 0.0f;
    }
    
    
    // [self set_overlay_box :(pos_x_max + (box_width / 2)) :(pos_y_max + (box_height / 2))];                         // Set position of blue box
    [self set_overlay_box :obj_center_x :obj_center_y];                                                               // Set position of blue box
    
    diff_box_ave = diff_box_acc / diff_box_cnt;                                                                       // the average is approx. 16
    
    // printf("         === frame_no: %d   diff_box_ave: %d \n", frame_no, diff_box_ave);
}




- (void) find_moving_objects__trampoline:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    // int img_half_width = image_width / 2;
    // int half_height = image_height / 2;
    
    int align_shift_x = align_shift[0];     // these are redundant (see img_sect_align)
    int align_shift_y = align_shift[1];
    
    // int align_shift_x_curr_pprev = align_shift_curr_pprev[0];     // these are redundant (see img_sect_align_curr_pprev)
    // int align_shift_y_curr_pprev = align_shift_curr_pprev[1];
    
    printf("         - find_moving_objects__trampoline - align_shift_x: %d  align_shift_y: %d  prev_pos_x_max: %d  prev_pos_y_max: %d\n",  align_shift_x, align_shift_y, prev_pos_x_max, prev_pos_y_max);
    [self set_overlay_box :0 :0];       // default position of blue box
    
    // Look for isolated areas where the two images differ:
    
    int box_width = 50; // 10; // 20;
    int box_height = 50; // 10; // 20;
    
    size_t pixel_arr_idx = 0;
    int red = 0;
    int green = 0;
    int blue = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int red_ave_max = 0;
    int green_ave_max = 0;
    int blue_ave_max = 0;
    
    int step_size = 4; // 2;
    
    int diff_box = 0;
    // int diff_box_ave = 0;
    // int diff_box_acc = 0;
    // int diff_box_cnt = 0;
    
    int diff_box_curr_pprev = 0;
    
    // int diff_box_left = 0;
    // int diff_box_right = 0;
    // int diff_box_up = 0;
    // int diff_box_down = 0;
    
    // NEED TO MAKE SURE THE align_shift PARAMETERS DON'T LEAD TO INDICES OUT THE IMAGE ARRAYS
    int margin_x = 220; //  image_width / 60; // 70;
    int margin_y =  20; //  image_height / 40; // 40; // 20;
    
    int red_acc = 0;
    int green_acc = 0;
    int blue_acc = 0;
    
    int score = 0;
    int score_max = -999999;
    int pos_x_max = 0;
    int pos_y_max = 0;
    
    int box_step_size = 2;
    
    int color_score = 0;
    
    int box_diff_threshold = 60; // 40; // 50; // 50; // 70; // 300;
    //x int box_diff_threshold = 40; // 50;
    
    for (int x = margin_x; x < ((image_width - box_width) - margin_x); x += step_size)
    {
        for (int y = margin_y; y < ((image_height - box_height) - margin_y); y += step_size)
        {
            // Compare prev_img with pprev_img.
            diff_box = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
            
            // diff_box_acc += diff_box;
            // diff_box_cnt++;
            
            if (diff_box > box_diff_threshold)    // x, y position is a candidate for moving object
            // if (true)
            {
                // printf("         diff_box: %d   diff_box_threshold: %d \n", diff_box, box_diff_threshold);
                // Compare curr_img with pprev_img (difference should be close to zero).
                // WE SHOULD USE pix_arr (prev_img) AS REFERENCE AND APPLY align shift TO curr_img (align_shift_prev_curr = alin_shift_prev_pprev minus align_shift_curr_pprev
                //          diff_box_curr_pprev = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :curr_img :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                
                if (true) // (diff_box_curr_pprev < 50) // 50)  // in super slow moation we cannot use this (ball moves to slow)
                {
                    // Check if neighboring 10x10 boxes show a difference
                    // int box_diff_threshold_2 = box_diff_threshold / 2;
                    // int box_diff_threshold_2 = box_diff_threshold - (box_diff_threshold / 3);
                    // int box_diff_threshold_2 = 0;
                    // int x_left = x - box_width;
                    //x diff_box_left = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    // diff_box_left = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    
                    // if (diff_box_left > box_diff_threshold_2)
                    if (true)
                    {
                                    // Check color
                                    red_acc = 0;
                                    green_acc = 0;
                                    blue_acc = 0;
                                    int cnt2 = 0;
                                    for (int bx = 0; bx < box_width; bx++)
                                    {
                                        for (int by = 0; by < box_height; by++)
                                        {
                                            pixel_arr_idx = ((y + by) * bytesPerRow) + ((x + bx) * 4);
                                            red   = pix_arr[pixel_arr_idx + 2];
                                            green = pix_arr[pixel_arr_idx + 1];
                                            blue  = pix_arr[pixel_arr_idx];
                                            
                                            red_acc += red;
                                            green_acc += green;
                                            blue_acc += blue;
                                            
                                            cnt2++;
                                        }
                                    }
                                    red_ave   = red_acc / cnt2;
                                    green_ave = green_acc / cnt2;
                                    blue_ave  = blue_acc / cnt2;
                                    // if ([self is_white_color :red_ave :green_ave :blue_ave])
                                    if ([self is_black_color :red_ave :green_ave :blue_ave])
                                    {
                                        // int color_diff = 0;
                                        // if (obj_color_red != -1)    // colors are valid
                                        // {
                                        //     color_diff = (red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue);
                                        // }
                                        
                                        // printf("               red_ave: %d   obj_color_red: %d      green_ave: %d   obj_color_green: %d      blue_ave: %d   obj_color_blue: %d \n",  red_ave, obj_color_red, green_ave, obj_color_green, blue_ave, obj_color_blue);
                                        
                                        // if (color_diff < 120) // 170)
                                        if (true)
                                        {
                                            // Check if the obj frame is fixed:
                                            // int obj_frame_diff = [self compute_object_frame_diff :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                            
                                            //                      if (obj_frame_diff < 40) // 80) // 100) // 150) // 200)
                                            // if (obj_frame_diff < 100)
                                            // if (obj_frame_diff < 100)
                                            if (true)
                                            {
                                                // Identify set of pixels that differ and check if they fit into an octagon; then check if that shape and color appear the marked location in the previous frame:
                                                // [self identify_2d_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                                
                                                // color_score = 100 - ((red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue));
                                                
                                                // score = diff_box - obj_frame_diff;
                                                // score = diff_box - diff_box_curr_pprev;
                                                // score += (red_ave + green_ave + blue_ave) / 8;     // the ball is a light color object
                                                score = 300 - ((red_ave + green_ave + blue_ave) / 8);
                                                
                                                // printf("         diff_box: %d  at x: %d  y: %d   diff_box_curr_pprev: %d   score: %d   color_score: %d  \n",  diff_box, x, y, diff_box_curr_pprev, score, color_score);
                                                // printf("            - red_ave: %d   green_ave: %d   blue_ave: %d \n",  red_ave, green_ave, blue_ave);
                                                
                                                // score += color_score;
                                                
                                                if (score > score_max)
                                                {
                                                    score_max = score;
                                                    pos_x_max = x;
                                                    pos_y_max = y;
                                                    
                                                    red_ave_max = red_ave;
                                                    green_ave_max = green_ave;
                                                    blue_ave_max = blue_ave;
                                                }
                                            }
                                        }
                                    }
                    }
                }
            }
        }
    }
    
    int obj_center = 0;
    // if ((pos_x_max != 0) && (pos_y_max != 0))
    // {
    //     obj_center = [self find_center_of_moving_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :pos_x_max :pos_y_max];
    // }
    
    // int obj_center_x = obj_center / 1000000;
    // int obj_center_y = obj_center % 1000000;

    int obj_center_x = pos_x_max;
    int obj_center_y = pos_y_max;

    printf("         --- object center - x: %d  y: %d \n",  obj_center_x, obj_center_y);
    
    if (obj_center_x != 0) // (sharpness > 1.0f)
    {
        obj_color_red   = red_ave_max;
        obj_color_green = green_ave_max;
        obj_color_blue  = blue_ave_max;
        
        
        // Compute speed:
        // if (    (! (object_action_path_state >= 90))                                              // not past point of no return (otherwise cancel speed computation)
        //     ||  ((fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max))))     // OR moving outwards
        if (true)
        {
            float obj_radius = 13.16f;                    // pixels
            if (ball_radius > 1.0f)
            {
                obj_radius = ball_radius;                 // pixels
            }
            float obj_diameter = 2 * obj_radius;          // pixels
            // float frame_rate = 30;                     // frames / sec
            float frame_rate = video_fps;                 // frames / sec
            float time_per_frame = 1.0f / frame_rate;     // sec
            float ball_diameter = 0.075;                  // meters (baseball diameter)
            float meters_per_pixel = ball_diameter / obj_diameter;   // meters
            
            float delta_x = prev_pos_x_max - pos_x_max;
            float delta_y = prev_pos_y_max - pos_y_max;
            float distance_traveled_in_pixels = 0.0f;
            // if ((prev_pos_x_max != 0) && (prev_pos_y_max != 0))    // if previous position is valid
            if (true)
            {
                distance_traveled_in_pixels = sqrtf(delta_x * delta_x + delta_y * delta_y);
                
                float distance_traveled_in_meters = distance_traveled_in_pixels * meters_per_pixel;
                
                float speed = distance_traveled_in_meters / time_per_frame;    // meters / sec
                ball_speed_mph = speed * 2.2369f;   // convert m/s in mph
                if (ball_speed_mph > 20) { ball_speed_mph = 0.0f; }           // discard implausible speeds
                
                printf("      ~~~ speed: %2.2f   distance_traveled_in_meters: %2.2f   distance_traveled_in_pixels: %2.2f   frame_rate: %2.2f   time_per_frame: %2.2f \n",  speed, distance_traveled_in_meters, distance_traveled_in_pixels, frame_rate, time_per_frame);
                
                
                // Track object_action_path_state:
                // if (    (fabs(delta_x) > (3.0 * fabs(delta_y)))                                       // mostly horizontal movement
                //     &&  (fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))   // moving outwards
                if (true)
                {
                    object_action_path_state = 60;
                    
                    // int large_displacement = img_half_width / (video_fps / 10.0f);
                    // int large_displacement = 15;     // use for super slow motion
                    // if (   (fabs(delta_x) > (large_displacement - 10))                                // moving at certain speed
                    //     && (fabs(delta_x) < (large_displacement + 10)))
                    if (true)
                    {
                        object_action_path_state = 90;                                                // point of no return
                        
                        // if (impact_frame_no == 0)                                                     // impact most likely occurred right before high horizontal velocity is observed
                        // {
                        //     int synch_actor = -16;
                        //     impact_frame_no = frame_no + synch_actor;
                        // }
                        
                        if (ball_speed_mph > max_ball_speed_mph)
                        {
                            max_ball_speed_mph = ball_speed_mph;
                        }
                    }
                }
            }
            else { ball_speed_mph = 0.0f; }
        }
        
        printf("      pos_x_max: %d   pos_y_max: %d   prev_pos_x_max: %d   prev_pos_y_max: %d \n", pos_x_max, pos_y_max, prev_pos_x_max, prev_pos_y_max);
        prev_pos_x_max = pos_x_max;
        prev_pos_y_max = pos_y_max;
    }
    else
    {
        prev_pos_x_max = 0;
        prev_pos_y_max = 0;
        
        ball_speed_mph = 0.0f;
    }
    
    
    
    // [self set_overlay_box :(pos_x_max + (box_width / 2)) :(pos_y_max + (box_height / 2))];                         // Set position of blue box
    [self set_overlay_box :obj_center_x :obj_center_y];                                                               // Set position of blue box
    
    // diff_box_ave = diff_box_acc / diff_box_cnt;                                                                       // the average is approx. 16
    
    // printf("         === frame_no: %d   diff_box_ave: %d \n", frame_no, diff_box_ave);
}




- (void) find_moving_objects__putt:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    int motion_intensity_threshold = 200;
    int motion_intensity = 0;
    
    if (true) // (! activity_started)
    {
        motion_intensity = [self detect_activity :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];    // detect moving objects
        printf("      --- frame_no: %d   motion_intensity: %d   motion_intensity_threshold: %d \n", frame_no, motion_intensity, motion_intensity_threshold);
        if ((frame_no > 4) && (motion_intensity > motion_intensity_threshold))
        {
            activity_started = true;
        }
    }
    
    // if (activity_started)
    if (   (frame_no > 4) && (   (motion_intensity > motion_intensity_threshold)
                              || ((frame_no > impact_frame_no) && (impact_frame_no > 0))))           // don't skip frames after impact
    {
        [self find_moving_shafts__putt__motion_based :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];      // for tracking shaft
        
        [self find_moving_objects__putt__motion_based :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];     // for tracking club head (using club head position computed by find_moving_shafts__putt__motion_based)
        
        if (object_action_path_state < 100)
        {
            [self find_moving_objects__putt__shape_based :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];  // for tracking ball
        }
        new_fps_reduction_factor = 1;
    }
    else
    {
        printf("      --- skipping frame processing --- frame_no: %d \n", frame_no);
        new_fps_reduction_factor = 2;
    }
}




- (int) detect_activity:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    
    //x int arr_length = image_height * bytesPerRow - 2;    // subtract 2 because 1 and 2 is added
    
    int align_shift_x = align_shift[0];     // these are redundant (see img_sect_align)
    int align_shift_y = align_shift[1];
    
    //x int align_shift_x_curr_pprev = align_shift_curr_pprev[0];     // these are redundant (see img_sect_align_curr_pprev)
    //x int align_shift_y_curr_pprev = align_shift_curr_pprev[1];
    
    printf("         - detect_activity - align_shift_x: %d  align_shift_y: %d  prev_pos_x_max: %d  prev_pos_y_max: %d\n",  align_shift_x, align_shift_y, prev_pos_x_max, prev_pos_y_max);
    [self set_overlay_box :0 :0];       // default position of blue box
    
    // Look for isolated areas where the two images differ:
    
    int box_width  = 2; // 30; // 30; // 40;
    int box_height = 2; // 30; // 30; // 40;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int red_ave_max = 0;
    int green_ave_max = 0;
    int blue_ave_max = 0;
    
    int step_size = 8; // 4; // 2;
    
    int diff_box = 0;
    int diff_box_ave = 0;
    long diff_box_acc = 0;
    int diff_box_cnt = 0;
    
    int diff_box_curr_pprev = 0;
    
    // NEED TO MAKE SURE THE align_shift PARAMETERS DON'T LEAD TO INDICES OUT THE IMAGE ARRAYS
    int margin_x = 30; // image_width / 60; // 70;
    int margin_y_top    = 30; // image_height / 60; //  / 2; // 40; // 20;
    int margin_y_bottom = margin_y_top; // 3; //  image_height / 40; // 40; // 20;
    
    int score = 0;
    int score_max = -999999;
    int pos_x_max = 0;
    int pos_y_max = 0;
    
    
    // SHOULD RESTRICT THIS TO APPROX. ball height:
    int search_x_start = margin_x;
    int search_x_end   = (image_width - box_width) - margin_x;
    
    int search_y_start = margin_y_top;
    int search_y_end   = (image_height - box_height) - margin_y_bottom;
    
    
    bool ball_proximity_mode = false;
    
    
    bool subimg_tracking = false;
    //    if (frame_no > 37)    // TEMP FOR TESTING -- switch to clubhead_subimg tracking
    if (   (clubhead_tracking_confidence > 7)
        || ((clubhead_tracking_confidence >= 1) && (ball_proximity_mode)))
    {
        subimg_tracking = true;     // save pixels in rectangle and use for tracking
    }
    
    int box_step_size = 2;
    
    int color_score = 0;
    
    int box_diff_threshold = 20; // 50; // 70; // 80; // 100;
    
    if (true)
    {
        for (int x_loop = search_x_start; x_loop < search_x_end; x_loop += step_size)
        {
            for (int y_loop = search_y_start; y_loop < search_y_end; y_loop += step_size)
            {
                int x = x_loop;
                int y = y_loop;
                
                // Compare prev_img with pprev_img.
                diff_box = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                
                diff_box_acc += diff_box;
                diff_box_cnt++;
                
                if (diff_box > box_diff_threshold)    // x, y position is a candidate for moving object
                {
                    
                    score = diff_box;
                    
                    if (score > score_max)
                    {
                        score_max = score;
                        pos_x_max = x;
                        pos_y_max = y;
                        
                        red_ave_max = red_ave;
                        green_ave_max = green_ave;
                        blue_ave_max = blue_ave;
                    }

                    diff_box_acc += diff_box;
                }
            }
        }
    }
    
    long num_pixels = (long) (image_height * image_width);
    int change_level = (int) ((diff_box_acc * 1000l) / num_pixels); // score;
    printf("         --- detect_activity -- change_level: %d \n", change_level);
    
    return change_level;
}




- (void) find_moving_objects__putt__motion_based:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    // int img_half_width = image_width / 2;
    // int half_height = image_height / 2;
    
    int arr_length = image_height * bytesPerRow - 2;    // subtract 2 because 1 and 2 is added
    
    int align_shift_x = align_shift[0];     // these are redundant (see img_sect_align)
    int align_shift_y = align_shift[1];
    
    int align_shift_x_curr_pprev = align_shift_curr_pprev[0];     // these are redundant (see img_sect_align_curr_pprev)
    int align_shift_y_curr_pprev = align_shift_curr_pprev[1];
    
    printf("         - find_moving_objects__putt__motion_based - align_shift_x: %d  align_shift_y: %d  prev_pos_x_max: %d  prev_pos_y_max: %d\n",  align_shift_x, align_shift_y, prev_pos_x_max, prev_pos_y_max);
    [self set_overlay_box :0 :0];       // default position of blue box
    
    // Look for isolated areas where the two images differ:
    
    int box_width  = 30; // 30; // 40; // 20; // 10; // 20;
    int box_height = 30; // 30; // 40; // 20; // 10; // 20;
    
    size_t pixel_arr_idx = 0;
    int red = 0;
    int green = 0;
    int blue = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int red_ave_max = 0;
    int green_ave_max = 0;
    int blue_ave_max = 0;
    
    int step_size = 8; // 4; // 2;
    
    int diff_box = 0;
    int diff_box_ave = 0;
    int diff_box_acc = 0;
    int diff_box_cnt = 0;
    
    int diff_box_curr_pprev = 0;
    
    // int diff_box_left = 0;
    // int diff_box_right = 0;
    // int diff_box_up = 0;
    // int diff_box_down = 0;
    
    // NEED TO MAKE SURE THE align_shift PARAMETERS DON'T LEAD TO INDICES OUT THE IMAGE ARRAYS
    int margin_x = image_width / 60; // 70;
    int margin_y_top    = image_height / 2; // 40; // 20;
    int margin_y_bottom = image_height / 3; //  image_height / 40; // 40; // 20;
    
    int red_acc = 0;
    int green_acc = 0;
    int blue_acc = 0;
    
    int score = 0;
    int score_max = -999999;
    int pos_x_max = 0;
    int pos_y_max = 0;
    
    
    // SHOULD RESTRICT THIS TO APPROX. ball height:
    int search_x_start = margin_x;
    int search_x_end   = (image_width - box_width) - margin_x;
    
    int search_y_start = margin_y_top;
    int search_y_end   = (image_height - box_height) - margin_y_bottom;
    
    
    // Enforce clubhead motion continuity (and speed up search):
    int prev_box2_delta_x = prev_pos_box2_x_max - pprev_pos_box2_x_max;
    int prev_box2_delta_y = prev_pos_box2_y_max - pprev_pos_box2_y_max;
    
    int pprev_box2_delta_x = pprev_pos_box2_x_max - ppprev_pos_box2_x_max;
    int pprev_box2_delta_y = pprev_pos_box2_y_max - ppprev_pos_box2_y_max;
    
    int ppprev_box2_delta_x = ppprev_pos_box2_x_max - pppprev_pos_box2_x_max;
    int ppprev_box2_delta_y = ppprev_pos_box2_y_max - pppprev_pos_box2_y_max;
    
    int delta_x_continuity_threshold = 20; // 40; // 20; // 10;
    int delta_y_continuity_threshold = 10; // 30; // 20; // 10;
    
    int continuity_tolerance_x = 40; // 10; // 10; // 7; // 20; // 30; // 15; // 20; // 20;
    int continuity_tolerance_y = 20; //  7; // 10; // 7; // 20; // 10; // 20;
    
    printf("         ---ppp--- prev_box2_delta_x: %d   prev_box2_delta_y: %d \n", prev_box2_delta_x, prev_box2_delta_y);
    
    bool ball_proximity_mode = false;
    
    // Narrow the search scope there is a consistent movement from frame to frame:
    if (   (    (true) // (frame_no > 37)    // TEMP FOR TESTING
            &&  (abs( prev_box2_delta_x) < 30)  &&  (abs(prev_box2_delta_x) > 5)
            &&  (abs( prev_box2_delta_y) < 20)  &&  (abs(prev_box2_delta_y) > -10)
            &&  (abs( prev_box2_delta_x -  pprev_box2_delta_x) < delta_x_continuity_threshold)
            &&  (abs( prev_box2_delta_y -  pprev_box2_delta_y) < delta_y_continuity_threshold)
            &&  (abs(pprev_box2_delta_x - ppprev_box2_delta_x) < delta_x_continuity_threshold)
            &&  (abs(pprev_box2_delta_y - ppprev_box2_delta_y) < delta_y_continuity_threshold)
           )
        || (    (clubhead_tracking_confidence > 7)
            &&  (abs(prev_box2_delta_x) > 2)
            &&  ((prev_pos_box2_x_max > 0) && (prev_pos_box2_x_max < movie_frame_width))))           // if the object is out of view reset clubhead_tracking_confidence to zero ("else" condition)
    {
        search_x_start = (prev_pos_box2_x_max + prev_box2_delta_x) - continuity_tolerance_x;
        // search_x_start = max( search_x_start, (prev_pos_box2_x_max + 5) );    // make sure it doesn't come to a stand still
        search_x_end   = (prev_pos_box2_x_max + prev_box2_delta_x) + continuity_tolerance_x;
        
        search_y_start = (prev_pos_box2_y_max + prev_box2_delta_y) - continuity_tolerance_y;
        search_y_end   = (prev_pos_box2_y_max + prev_box2_delta_y) + continuity_tolerance_y;
        
        clubhead_tracking_confidence++;     // use for locking on target
        if (clubhead_tracking_confidence > 14) { clubhead_tracking_confidence = 14; }      // cap clubhead_tracking_confidence at 14
        printf("      -->1-- find_moving_objects__putt__motion_based --- search in continuity mode - clubhead_tracking_confidence: %d \n", clubhead_tracking_confidence);
    }
    else
    {
        clubhead_tracking_confidence = 0;   // the accumulation of clubhead_tracking_confidence points must be consecutive
        
        // When approach in the ball, the club head should be at about the same level as the ball:
        // Use ball location: prev_obj_center_x, prev_obj_center_y
        // If the clubhead x coordinate is close the ball x coorindate, the y coordinates should be about the same:
        int ball_pos_x = prev_obj_center_x;
        int ball_pos_y = prev_obj_center_y;
        float ball_diameter = prev_ball_radius * 2.0f;
        float x_separation = (float) abs(prev_pos_box2_x_max - ball_pos_x);
        if (x_separation < (3.0f * ball_diameter))
        {
            search_y_start = ball_pos_y - 10; // 30;
            search_y_end   = ball_pos_y + 10; // 20;
            ball_proximity_mode = true;
        }
        printf("      -->2-- find_moving_objects__putt__motion_based --- ball_proximity_mode: %d   clubhead_tracking_confidence: %d   ball_pos_x: %d   prev_pos_box2_x_max %d   prev_ball_radius: %5.2f \n", ball_proximity_mode, clubhead_tracking_confidence, ball_pos_x, prev_pos_box2_x_max, prev_ball_radius);
    }
    
    bool subimg_tracking = false;
//    if (frame_no > 37)    // TEMP FOR TESTING -- switch to clubhead_subimg tracking
    if (   (clubhead_tracking_confidence > 7)
        || ((clubhead_tracking_confidence >= 1) && (ball_proximity_mode)))
    {
        subimg_tracking = true;     // save pixels in rectangle and use for tracking
    }
    
    int box_step_size = 2;
    
    int color_score = 0;
    
    int box_diff_threshold = 20; // 50; // 70; // 80; // 100; // 120; // 140; // 200; // 250; // 280;
    

    int obj_center = 0;
    float obj_angle = 0.0f;

    int obj_center_x = 0;
    int obj_center_y = 0;

    if ((subimg_tracking == false) && (club_shaft_is_set == false))
    {
        for (int x_loop = search_x_start; x_loop < search_x_end; x_loop += step_size)
        {
            for (int y_loop = search_y_start; y_loop < search_y_end; y_loop += step_size)
            {
                int x = x_loop;
                int y = y_loop;
                
                // DEBUGGING:
                // x = 545;
                // y = 245;
                
                // Compare prev_img with pprev_img.
                diff_box = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                
                // if (diff_box > 100)   { printf("      --- putt - diff_box: %d \n", diff_box); }
                
                // Make sure the difference is not due to image shift:
                /*
                 if (diff_box > box_diff_threshold)
                 {
                     int diff_box_verify = [self verify_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                     if (diff_box_verify < diff_box)
                     {
                         diff_box = diff_box_verify;
                     }
                 }
                */
                
                diff_box_acc += diff_box;
                diff_box_cnt++;
                
                if (diff_box > box_diff_threshold)    // x, y position is a candidate for moving object
                {
                    //            printf("         --- baseball - diff_box: %d   diff_box_threshold: %d \n",  diff_box, box_diff_threshold);
                    // Compare curr_img with pprev_img (difference should be close to zero).
                    // WE SHOULD USE pix_arr (prev_img) AS REFERENCE AND APPLY align shift TO curr_img (align_shift_prev_curr = alin_shift_prev_pprev minus align_shift_curr_pprev
                    //          diff_box_curr_pprev = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :curr_img :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                    
                    if (true) // (diff_box_curr_pprev < 50) // 50)  // in super slow moation we cannot use this (ball moves to slow)
                    {
                        // Check if neighboring 10x10 boxes show a difference
                        // int box_diff_threshold_2 = box_diff_threshold / 2;
                        // int box_diff_threshold_2 = box_diff_threshold - (box_diff_threshold / 3);
                        // int box_diff_threshold_2 = 0;
                        // int x_left = x - box_width;
                        //x diff_box_left = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                        // diff_box_left = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                        
                        // if (diff_box_left > box_diff_threshold_2)
                        if (true)
                        {
                            // int x_right = x + box_width;
                            // diff_box_right = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_right :y];
                            // diff_box_right = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_right :y];
                            
                            if (true) // (diff_box_right > box_diff_threshold_2)
                            {
                                // int y_up = y - box_height;
                                // diff_box_up = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y_up];
                                // diff_box_up = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y_up];
                                
                                if (true) // (diff_box_up > box_diff_threshold_2)
                                {
                                    // int y_down = y + box_height;
                                    // diff_box_down = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y_down];
                                    // diff_box_down = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y_down];
                                    
                                    if (true) // (diff_box_down > box_diff_threshold_2)
                                    {
                                        // Check color
                                        red_acc = 0;
                                        green_acc = 0;
                                        blue_acc = 0;
                                        int cnt2 = 0;
                                        for (int bx = 0; bx < box_width; bx++)
                                        {
                                            for (int by = 0; by < box_height; by++)
                                            {
                                                pixel_arr_idx = ((y + by) * bytesPerRow) + ((x + bx) * 4);
                                                if (pixel_arr_idx < arr_length)
                                                {
                                                    red   = pix_arr[pixel_arr_idx + 2];
                                                    green = pix_arr[pixel_arr_idx + 1];
                                                    blue  = pix_arr[pixel_arr_idx];
                                                    
                                                    red_acc += red;
                                                    green_acc += green;
                                                    blue_acc += blue;
                                                    
                                                    cnt2++;
                                                }
                                           }
                                        }
                                        if (cnt2 > 0)
                                        {
                                           red_ave   = red_acc / cnt2;
                                           green_ave = green_acc / cnt2;
                                           blue_ave  = blue_acc / cnt2;
                                        }
                                        // if ([self is_yellow:red_ave :green_ave :blue_ave])
                                        // if ([self is_light_color :red_ave :green_ave :blue_ave])
                                        // if ([self is_white_color :red_ave :green_ave :blue_ave])
                                        //                       if ([self is_white_color_putt :red_ave :green_ave :blue_ave])
                                        if (cnt2 > 0)    // valid
                                        {
                                            // printf("      --- putt - passed is_white_color - red_ave: %d  green_ave: %d  blue_ave: %d \n", red_ave, green_ave, blue_ave);
                                            int color_diff = 0;
                                            if (obj_color_red != -1)    // colors are valid
                                            {
                                                color_diff = (red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue);
                                            }
                                            
                                            // printf("               red_ave: %d   obj_color_red: %d      green_ave: %d   obj_color_green: %d      blue_ave: %d   obj_color_blue: %d \n",  red_ave, obj_color_red, green_ave, obj_color_green, blue_ave, obj_color_blue);
                                            
                                            // if (color_diff < 120) // 170)
                                            if (true)
                                            {
                                                // Check if the obj frame is fixed:
                                                int obj_frame_diff = [self compute_object_frame_diff :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                                
                                                // if (obj_frame_diff < 40) // 80) // 100) // 150) // 200)
                                                // if (obj_frame_diff < 150)
                                                //                                if (obj_frame_diff < 180)
                                                if (true)
                                                {
                                                    // Identify set of pixels that differ and check if they fit into an octagon; then check if that shape and color appear the marked location in the previous frame:
                                                    // [self identify_2d_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                                    
                                                    color_score = 100 - ((red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue));
                                                    
                                                    // Check how close this position is to the previous position:
                                                    int displacement_score = 100;
                                                    float displacement_score_weight = 2.0f;
                                                    
                                                    if (frame_no > 10)
                                                    {
                                                        float delta_x = fabs(prev_pos_box2_x_max - x);
                                                        float delta_y = fabs(prev_pos_box2_y_max - y);
                                                        float displacement = sqrt(delta_x * delta_x + delta_y * delta_y);
                                                        displacement_score -= ((int) (displacement * displacement_score_weight));
                                                    }
                                                    
                                                    // int color_score = (red_ave + green_ave + blue_ave) / 4; // 8;     // the ball is a light color object
                                                    
                                                    score = diff_box;
                                                    // score = diff_box - obj_frame_diff;
                                                    // score = diff_box - diff_box_curr_pprev + displacement_score;
                                                    // score = diff_box + displacement_score + color_score;
                                                    
                                                    // printf("         ^v^v^ diff_box: %d  displacement_score: %d  at x: %d  y: %d  obj_frame_diff: %d   diff_box_curr_pprev: %d   score: %d   color_score: %d   color_diff: %d \n",  diff_box, displacement_score, x, y, obj_frame_diff, diff_box_curr_pprev, score, color_score, color_diff);
                                                    //                                 printf("            - red_ave: %d   green_ave: %d   blue_ave: %d \n",  red_ave, green_ave, blue_ave);
                                                    
                                                    // score += color_score;
                                                    
                                                    if (score > score_max)
                                                    {
                                                        score_max = score;
                                                        pos_x_max = x;
                                                        pos_y_max = y;
                                                        
                                                        red_ave_max = red_ave;
                                                        green_ave_max = green_ave;
                                                        blue_ave_max = blue_ave;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if ((pos_x_max != 0) && (pos_y_max != 0))
        {
            obj_center = [self find_center_of_moving_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :pos_x_max :pos_y_max];
            // obj_angle  = [self find_orientation_of_obj :pix_arr :frame_no :obj_center];
        }
        
        obj_center_x = obj_center / 1000000;
        obj_center_y = obj_center % 1000000;
    }
    else if ((subimg_tracking == true) && (club_shaft_is_set == false))
    {
        // Find a match to the image "clubhead_subimg":
        int pix_x_min = 0;
        int pix_y_min = 0;
        int diff_min  = 99999999;
        int diff      = 0;
        
        int step_size_subimg = 2; // 1; // 2;
        
        for (int x_loop = search_x_start; x_loop < search_x_end; x_loop += step_size_subimg)
        {
            for (int y_loop = search_y_start; y_loop < search_y_end; y_loop += step_size_subimg)
            {
                int x = x_loop;
                int y = y_loop;
                
                // Compare the pixels (of pix_arr[]) with the pixels in clubhead_subimg:
                diff = [ self compare_clubhead_subimg :pix_arr :x :y ];
                
                if (diff < diff_min)
                {
                    diff_min = diff;
                    pix_x_min = x;
                    pix_y_min = y;
                    
                    printf("           ---<0>--- clubhead_subimg tracking -- diff_min: %9d   pix_x_min: %4d   pix_y_min: %4d \n",  diff_min, pix_x_min, pix_y_min);
                }
            }
        }
        
        printf("        ---<1>--- clubhead_subimg tracking -- diff_min: %9d   pix_x_min: %4d   pix_y_min: %4d \n",  diff_min, pix_x_min, pix_y_min);
        
        [ self save_clubhead_subimg :pix_arr :pix_x_min :pix_y_min ];       // update the new clubhead_subimg
        
        
        // // DEBUGGING -- compare the new clubhead_subimg with the pix_arr:
        // int diff_debug = [ self compare_clubhead_subimg :pix_arr :pix_x_min :pix_y_min ];         // this should always be zero
        // printf("        ---<2>--- diff_debug: %4d \n", diff_debug);
               
        
        // Determine (stationary) background and set subimg_mask (for the subimg just updated to the current frame).
        // Compare subimg (from this frame (pix_arr)) with the same rectangle from previous frame (prev_pix_arr) (to do: and in next frame (curr_frame)):
        // if (frame_no <= 50)    // testing
        if ((impact_frame_no == 0) || (frame_no < impact_frame_no) || (prev_box2_delta_x > 20))     // stop updating the mask if the velocity drops below threshold
        {
            // printf("         --- calling set_background_mask \n");
            [ self set_clubhead_background_mask :prev_pix_arr :pix_x_min :pix_y_min ];
        }
        
        pos_x_max = pix_x_min;
        pos_y_max = pix_y_min;

        obj_center_x = pix_x_min;
        obj_center_y = pix_y_min;
    }
    else if (club_shaft_is_set == true)
    {
        int x_shift = box2_width_half;      // box center is to the left (for left to right club head motion)
        
        pos_x_max = (int) (0.5 + (club_shaft_end_x - ((double)x_shift)));
        pos_y_max = (int) (0.5 + club_shaft_end_y);
        
        // printf("      putt__motion_based -2- prev_pos_box2_x_max: %d   pos_x_max: %d   club_shaft_end_x: %10.5f   x_shift: %d\n",  prev_pos_box2_x_max, pos_x_max, club_shaft_end_x, x_shift);
        
        obj_center_x = pos_x_max;
        obj_center_y = pos_y_max;
    }
    
    printf("         ---< putt - object center - x: %d  y: %d  obj_angle: %2.2f   clubhead_tracking_confidence: %d   subimg_tracking: %d   club_shaft_is_set: %d   club_shaft_end_x: %5.2f   club_shaft_end_y: %5.2f \n",  obj_center_x, obj_center_y, obj_angle, clubhead_tracking_confidence, subimg_tracking, club_shaft_is_set, club_shaft_end_x, club_shaft_end_y );
    
    if (obj_center_x != 0) // (sharpness > 1.0f)
    {
        obj_color_red   = red_ave_max;
        obj_color_green = green_ave_max;
        obj_color_blue  = blue_ave_max;
        
        printf("         --- putt - red_ave_max: %d  green_ave_max: %d  blue_ave_max: %d \n",  red_ave_max, green_ave_max, blue_ave_max);
        
        // Compute speed:
        // if (   ((! (sport == 30)) || (frame_no > 40))        // temporary for demo (baseball?)   --  DON'T NEED THIS, THIS FUNCTION IS ONLY FOR PUTT
        //     && (    (! (cliubhead_action_path_state >= 90))                                               // not past point of no return (otherwise cancel speed computation)
        //         ||  ((fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))))     // OR moving outwards
        if (true)
        {
            float obj_radius = 25.0f; // 17.0f; // 13.16f;                                   // pixels
            // if (ball_radius > 1.0f) { obj_radius = ball_radius; }                         // pixels
            if (ball_radius_shape_based > 1.0f) { obj_radius = ball_radius_shape_based; }    // in pixels (this is set by find_moving_object__putt_shape_based()
            float obj_diameter = 2 * obj_radius;                                             // pixels
            // float frame_rate = 30;                                                        // frames / sec
            float frame_rate = (float) (video_fps / fps_reduction_factor);                   // frames / sec
            float time_per_frame = 1.0f / frame_rate;                                        // sec
            //x float ball_diameter = 0.075;                                                 // meters (baseball diameter)
            float ball_diameter = 0.047;                                                     // meters -- golf ball diametert 1.68 inches (4,27 cm)
            if (meters_per_pixel == 0.0f)                                                    // Using class variable "meters_per_pixel" (don't overwrite unless it is zero) which has been set in find_moving_objects__putt__shape_based.
            {
                meters_per_pixel = ball_diameter / obj_diameter;                             // meters
            }
            
            float delta_x = (float) (prev_pos_box2_x_max - pos_x_max);
            float delta_y = (float) (prev_pos_box2_y_max - pos_y_max);
            float distance_traveled_in_pixels = 0.0f;
            if ((prev_pos_box2_x_max != 0) && (prev_pos_box2_y_max != 0))    // if previous position is valid
            {
                // distance_traveled_in_pixels = sqrtf(delta_x * delta_x + delta_y * delta_y);
                distance_traveled_in_pixels = fabs(delta_x); // sqrtf(delta_x * delta_x);       // use only horizonal movement for now
                // printf("      putt__motion_based -- prev_pos_box2_x_max: %d   pos_x_max: %d    delta_x: %d \n",  prev_pos_box2_x_max, pos_x_max, delta_x);
                
                float distance_traveled_in_meters = distance_traveled_in_pixels * meters_per_pixel;
                // distance_traveled_in_meters /= ((float) prev_fps_reduction_factor);          // need to adjust distance traveled if fps has been reduced (frames have been skipped) -- this is taken care of by adjustment in time_per_frame
                
                float speed = distance_traveled_in_meters / time_per_frame;    // meters / sec
                float clubhead_speed_mph_inst = speed * 2.2369f;                          // convert m/s in mph
                float clubhead_speed_mph_ave = [ self get_average_clubhead_speed :clubhead_speed_mph_inst ];
                [self update_trail_of_clubhead_speeds :clubhead_speed_mph_ave];
                
                clubhead_speed_mph = clubhead_speed_mph_ave;
                
                if (
                        (clubhead_speed_mph_ave < 8.0f)                                     // check if speed is reasonable
                     && (object_action_path_state < 100)
                   )
                {
                    [ self update_head_speed_arr :frame_no :clubhead_speed_mph_ave ];      // for displaying club head speed graph
                }
                
                float last_ball_speed_mph = [self get_last_ball_speed];
                printf("      putt__motion_based -- frame_no: %d   speed: %2.2f   distance_traveled_in_meters: %2.4f   distance_traveled_in_pixels: %2.2f   frame_rate: %2.2f   time_per_frame: %10.5f   delta_x: %2.2f   delta_y: %2.2f   clubhead_speed_mph_ave: %7.5f   last_ball_speed_mph: %7.5f \n",  frame_no, speed, distance_traveled_in_meters, distance_traveled_in_pixels, frame_rate, time_per_frame, delta_x, delta_y, clubhead_speed_mph_ave, last_ball_speed_mph);
                
    // /*          // THIS CAUSES CRASH -- now fixed
                if ((clubhead_speed_mph_ave < 1.0f) && (last_ball_speed_mph < 1.0f))       // NEED TO USE fps_reduction_factor WHEREEVER WE USE video_fps -- also need to add duplicate entries in "trailing arrays" (e.g., when computing average values)
                     { new_fps_reduction_factor = 2; }
                else { new_fps_reduction_factor = 1; }
    // */
                
                // Track clubhead_action_path_state:
                if (    (fabs(delta_x) > (3.0 * fabs(delta_y))))                                       // mostly horizontal movement
                       //   &&  (fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))   // moving outwards
                {
                    clubhead_action_path_state = 60;
                    
                    // int large_displacement = img_half_width / (video_fps / 10.0f);
                    int large_displacement = 60;                                                      // use for putt (this funcion is for putt only)
                    
                    // if (   (fabs(delta_x) > (large_displacement - 10))                                // moving at certain speed
                    //     && (fabs(delta_x) < (large_displacement + 10)))
                    if (true)
                    {
                        clubhead_action_path_state = 90;                                                // point of no return
                        
                        // if (impact_frame_no == 0)                                                     // impact most likely occurred right before high horizontal velocity is observed
                        // {
                        //     int synch_factor = -1; // -8; // -16;
                        //     impact_frame_no = frame_no + synch_factor;
                        // }
                        
                        if (    (clubhead_speed_mph > max_clubhead_speed_mph)
                          // && (frame_no > 8) && (frame_no < 50)) //  (impact_frame_no - 2))
                             && (clubhead_tracking_confidence > 7))
                        {
                            max_clubhead_speed_mph = clubhead_speed_mph_ave;
                        }
                        
                        if ((impact_frame_no > 4) && (frame_no > impact_frame_no) && (impact_clubhead_speed_mph == 0))
                        {
                            impact_clubhead_speed_mph = smoothed_clubhead_speed_mph_minus_4;     // This is displayed as "Head Speed"
                        }
                    }
                }
            }
            else { clubhead_speed_mph = 0.0f; }
        }
        
        printf("      ~== pos_x_max: %d   pos_y_max: %d   prev_pos_box2_x_max: %d   prev_pos_box2_y_max: %d   meters_per_pixel: %10.5f   clubhead_speed_mph: %6.4f   max_clubhead_speed_mph: %1.4f  impact_frame_no: %d \n", pos_x_max, pos_y_max, prev_pos_box2_x_max, prev_pos_box2_y_max, meters_per_pixel, clubhead_speed_mph, max_clubhead_speed_mph, impact_frame_no);

        pppprev_pos_box2_x_max = ppprev_pos_box2_x_max;
        pppprev_pos_box2_y_max = ppprev_pos_box2_y_max;
        
        ppprev_pos_box2_x_max = pprev_pos_box2_x_max;
        ppprev_pos_box2_y_max = pprev_pos_box2_y_max;
        
        pprev_pos_box2_x_max = prev_pos_box2_x_max;
        pprev_pos_box2_y_max = prev_pos_box2_y_max;
        
        prev_pos_box2_x_max = pos_x_max;
        prev_pos_box2_y_max = pos_y_max;
        
        
        [self save_clubhead_subimg :pix_arr :obj_center_x :obj_center_y];
    }
    else
    {
        prev_pos_box2_x_max = 0;
        prev_pos_box2_y_max = 0;
        
        max_clubhead_speed_mph = 0.0f;
    }
    
    
    //x [self set_overlay_box :(pos_x_max + (box_width / 2)) :(pos_y_max + (box_height / 2))];                         // Set position of red box
    
    // DEBUGGING:
    // obj_center_x = 491;     // frame 10
    // obj_center_y = 241;
    // obj_center_x = 545; //  frame 11
    // obj_center_y = 245;

    [self set_overlay_box2 :obj_center_x :obj_center_y];                                                               // Set position of blue box
    
    /*
    if ((obj_center_x == 0) && (obj_center_y == 0))       // The object location is undefined
    {
        obj_rot_angle  = 0.0f;                            // reset the rotation angle so that the box is straight when the ball it hit
        obj_rot_angle1 = 0.0f;                            // reset the rotation angle so that the box is straight when the ball it hit
        obj_rot_angle2 = 0.0f;                            // reset the rotation angle so that the box is straight when the ball it hit
        delta_rotation_angle = 0.0f;
        // obj_rot_ref_frame = frame_no;
    }
    */

    
    // diff_box_ave = diff_box_acc / diff_box_cnt;                                                                     // the average is approx. 16
    
    // printf("         === frame_no: %d   diff_box_ave: %d \n", frame_no, diff_box_ave);
}




- (void) find_moving_shafts__putt__motion_based:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    // Method:
    // 1. Use blue box to find area with motion (use tracking after shaft has been identified (lock on target))
    // 2. Use subimg mask to identify pixels that change (edges of shaft) (compare current sub-image with previous image and next image)
    // 3. Identify approximate line (matching the shaft) using the top-most and buttom-most (changing) pixels from mask (or linear regression (see http://introcs.cs.princeton.edu/java/97data/LinearRegression.java.html ))
    // 4. Use two parallel lines to find exact orienation of shaft
    // 5. Use extension of this shaft-line to restrict position of blue box representing the club head
    
    
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    // int img_half_width = image_width / 2;
    // int half_height = image_height / 2;
    
    int align_shift_x = align_shift[0];     // these are redundant (see img_sect_align)
    int align_shift_y = align_shift[1];
    
    int align_shift_x_curr_pprev = align_shift_curr_pprev[0];     // these are redundant (see img_sect_align_curr_pprev)
    int align_shift_y_curr_pprev = align_shift_curr_pprev[1];
    
    printf("         - find_moving_shafts__putt__motion_based - align_shift_x: %d  align_shift_y: %d  prev_pos_x_max: %d  prev_pos_y_max: %d\n",  align_shift_x, align_shift_y, prev_pos_x_max, prev_pos_y_max);
    [self set_overlay_box :0 :0];       // default position of blue box
    
    // Look for isolated areas where the two images differ:
    
    int box_width  = 60; // 30; // 30; // 40; // 20; // 10; // 20;
    int box_height = 60; // 30; // 30; // 40; // 20; // 10; // 20;
    
    // size_t pixel_arr_idx = 0;
    // int red = 0;
    // int green = 0;
    // int blue = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    // int red_ave_max = 0;
    // int green_ave_max = 0;
    // int blue_ave_max = 0;
    
    int step_size = 8; // 4; // 2;
    
    int diff_box = 0;
    int diff_box_ave = 0;
    int diff_box_acc = 0;
    int diff_box_cnt = 0;
    
    int diff_box_curr_pprev = 0;
    
    // NEED TO MAKE SURE THE align_shift PARAMETERS DON'T LEAD TO INDICES OUT THE IMAGE ARRAYS
    int margin_x = image_width / 60; // 70;
    int margin_y_top    = image_height / 60; // 30; // 40; // 20;
    int margin_y_bottom = (image_height * 2) / 3; //  image_height / 40; // 40; // 20;
    
    // int red_acc = 0;
    // int green_acc = 0;
    // int blue_acc = 0;
    
    int score = 0;
    int score_max = -999999;
    int pos_x_max = 0;
    int pos_y_max = 0;
    
    
    // SHOULD RESTRICT THIS TO APPROX. ball height:
    int search_x_start = box_width + margin_x;
    int search_x_end   = (image_width - box_width) - margin_x;
    
    int search_y_start = box_width + margin_y_top;
    int search_y_end   = search_y_start + 1; // only search horizontally // (image_height - box_height) - margin_y_bottom; // restrict search to top part of image
    
    printf("         --- find_moving_shafts__putt__motion_based -- search_y_start: %d   search_y_end: %d   box_width: %d   box_height: %d \n", search_y_start, search_y_end, box_width, box_height);
    
    
    // Enforce clubhead motion continuity (and speed up search):
    int prev_shaft_delta_x = prev_shaft_x_max - pprev_shaft_x_max;
    int prev_shaft_delta_y = prev_shaft_y_max - pprev_shaft_y_max;
    
    int pprev_shaft_delta_x = pprev_shaft_x_max - ppprev_shaft_x_max;
    int pprev_shaft_delta_y = pprev_shaft_y_max - ppprev_shaft_y_max;
    
    int ppprev_shaft_delta_x = ppprev_shaft_x_max - pppprev_shaft_x_max;
    int ppprev_shaft_delta_y = ppprev_shaft_y_max - pppprev_shaft_y_max;
    
    int delta_x_continuity_threshold = 20; // 40; // 20; // 10;
    int delta_y_continuity_threshold = 10; // 30; // 20; // 10;
    
    int continuity_tolerance_x = 20; // 40; // 10;
    int continuity_tolerance_y = 20; //  7; // 10;
    
    // printf("         --- find_moving_shafts__putt__motion_based -- prev_box2_delta_x: %d   prev_box2_delta_y: %d \n", prev_shaft_delta_x, prev_shaft_delta_y);
    
    //x bool ball_proximity_mode = false;
    
    // Narrow the search scope if there is a consistent movement from frame to frame:
    if (   (    (true) // (frame_no > 37)    // TEMP FOR TESTING
            &&  (abs( prev_shaft_delta_x) < 30)  &&  (abs(prev_shaft_delta_x) > 1)
            &&  (abs( prev_shaft_delta_y) < 20)  &&  (abs(prev_shaft_delta_y) > -10)
            &&  (abs( prev_shaft_delta_x -  pprev_shaft_delta_x) < delta_x_continuity_threshold)
            &&  (abs( prev_shaft_delta_y -  pprev_shaft_delta_y) < delta_y_continuity_threshold)
            &&  (abs( pprev_shaft_delta_x - ppprev_shaft_delta_x) < delta_x_continuity_threshold)
            &&  (abs( pprev_shaft_delta_y - ppprev_shaft_delta_y) < delta_y_continuity_threshold)
           )
        || (    (club_shaft_tracking_confidence > 7)
      //    &&  (abs(prev_shaft_delta_x) > 2)
            &&  ((prev_shaft_x_max > 0) && (prev_shaft_x_max < movie_frame_width)))           // if the object is out of view reset club_shaft_tracking_confidence to zero ("else" condition)
       )
    {
        search_x_start = (prev_shaft_x_max + prev_shaft_delta_x) - continuity_tolerance_x;
        // search_x_start = max( search_x_start, (prev_pos_box2_x_max + 5) );    // make sure it doesn't come to a stand still
        search_x_end   = (prev_shaft_x_max + prev_shaft_delta_x) + continuity_tolerance_x;
        
        // search_y_start = (prev_pos_box2_y_max + prev_shaft_delta_y) - continuity_tolerance_y;
        // search_y_end   = (prev_pos_box2_y_max + prev_shaftdelta_y) + continuity_tolerance_y;
        
        club_shaft_tracking_confidence++;     // use for locking on target
        if (club_shaft_tracking_confidence > 14) { club_shaft_tracking_confidence = 14; }      // cap clubhead_tracking_confidence at 14
        printf("         --- find_moving_shafts__putt__motion_based -- search in continuity mode - club_shaft_tracking_confidence: %d \n", club_shaft_tracking_confidence);
    }
    else
    {
        club_shaft_tracking_confidence = 0;   // the accumulation of clubhead_tracking_confidence points must be consecutive
    }
    
    
    bool subimg_tracking = false;; // false;
    
    //    if (frame_no > 37)    // TEMP FOR TESTING -- switch to clubhead_subimg tracking
    if  (club_shaft_tracking_confidence > 7)
        // || ((club_shaft_tracking_confidence >= 1) && (ball_proximity_mode)))
    {
        subimg_tracking = true;     // save pixels in rectangle and use for tracking
    }
    
    
    int box_step_size = 2;
    
    int color_score = 0;
    
    int box_diff_threshold = 20; // 50; // 70; // 80; // 100; // 120; // 140; // 200; // 250; // 280;
    
    
    int obj_center = 0;
    float obj_angle = 0.0f;
    
    int obj_center_x = 0;
    int obj_center_y = 0;
    
    if (subimg_tracking == false)
    {
        for (int x_loop = search_x_start; x_loop < search_x_end; x_loop += step_size)
        {
            for (int y_loop = search_y_start; y_loop < search_y_end; y_loop += step_size)
            {
                int x = x_loop;
                int y = y_loop;
                
                // Compare prev_img with pprev_img.
                diff_box = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                // printf("         --- find_moving_shafts__put__motion_based -- diff_box: %d \n", diff_box);
                
                diff_box_acc += diff_box;
                diff_box_cnt++;
                
                if (true) // (diff_box > box_diff_threshold)    // x, y position is a candidate for moving object
                {
                    //            printf("         --- baseball - diff_box: %d   diff_box_threshold: %d \n",  diff_box, box_diff_threshold);
                    // Compare curr_img with pprev_img (difference should be close to zero).
                    // WE SHOULD USE pix_arr (prev_img) AS REFERENCE AND APPLY align shift TO curr_img (align_shift_prev_curr = alin_shift_prev_pprev minus align_shift_curr_pprev
                    //          diff_box_curr_pprev = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :curr_img :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                    
                                                // if (obj_frame_diff < 40) // 80) // 100) // 150) // 200)
                                                // if (obj_frame_diff < 150)
                                                //                                if (obj_frame_diff < 180)
                                                if (true)
                                                {
                                                    // Identify set of pixels that differ and check if they fit into an octagon; then check if that shape and color appear the marked location in the previous frame:
                                                    // [self identify_2d_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                                    
                                                    color_score = 100 - ((red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue));
                                                    
                                                    /*
                                                    // Check how close this position is to the previous position:
                                                    int displacement_score = 100;
                                                    float displacement_score_weight = 2.0f;
                                                    
                                                    if (frame_no > 10)
                                                    {
                                                        float delta_x = fabs(prev_pos_box2_x_max - x);
                                                        float delta_y = fabs(prev_pos_box2_y_max - y);
                                                        float displacement = sqrt(delta_x * delta_x + delta_y * delta_y);
                                                        displacement_score -= ((int) (displacement * displacement_score_weight));
                                                    }
                                                    */
                                                    
                                                    score = diff_box;
                                                    
                                                    if (score > score_max)
                                                    {
                                                        score_max = score;
                                                        pos_x_max = x;
                                                        pos_y_max = y;
                                                    }
                                                }
                }
            }
        }
        
        /*
        if ((pos_x_max != 0) && (pos_y_max != 0))
        {
            obj_center = [self find_center_of_moving_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :pos_x_max :pos_y_max];
            // obj_angle  = [self find_orientation_of_obj :pix_arr :frame_no :obj_center];
        }
        
        obj_center_x = obj_center / 1000000;
        obj_center_y = obj_center % 1000000;
        */
        
        // printf("         --- find_moving_shafts__put__motion_based -- pos_x_max: %d   pos_y_max: %d \n", pos_x_max, pos_y_max);
 
        obj_center_x = pos_x_max + ( box_width / 2 );
        obj_center_y = pos_y_max + ( box_height / 2 );
    }
    else if (subimg_tracking == true)
    {
        // Find a match to the image "club_shaft_subimg":
        int pix_x_min = 0;
        int pix_y_min = 0;
        int diff_min  = 99999999;
        int diff      = 0;
        
        int step_size_subimg = 2; // 1; // 2;
        
        for (int x_loop = search_x_start; x_loop < search_x_end; x_loop += step_size_subimg)
        {
            for (int y_loop = search_y_start; y_loop < search_y_end; y_loop += step_size_subimg)
            {
                int x = x_loop + ( box_width / 2 );;
                int y = y_loop + ( box_height / 2 );
                
                // Compare the pixels (of pix_arr[]) with the pixels in club_shaft_subimg:
                diff = [ self compare_club_shaft_subimg :pix_arr :x :y ];
                
                if (diff < diff_min)
                {
                    diff_min = diff;
                    pix_x_min = x;
                    pix_y_min = y;
                    
                    printf("           ---<0>=== club_shaft_subimg tracking -- diff_min: %9d   pix_x_min: %4d   pix_y_min: %4d \n",  diff_min, pix_x_min, pix_y_min);
                }
            }
        }
        
        printf("        ---<1>=== club_shaft_subimg tracking -- diff_min: %9d   pix_x_min: %4d   pix_y_min: %4d \n",  diff_min, pix_x_min, pix_y_min);

        // [ self save_club_shaft_subimg :pix_arr :pix_x_min :pix_y_min ];       // update the new club_shaft_subimg
        
        // // DEBUGGING -- compare the new clubhead_subimg with the pix_arr:
        // int diff_debug = [ self compare_clubhead_subimg :pix_arr :pix_x_min :pix_y_min ];         // this should always be zero
        // printf("        ---<2>--- diff_debug: %4d \n", diff_debug);
        
        
        // Determine (stationary) background and set subimg_mask (for the subimg just updated to the current frame).
        // Compare subimg (from this frame (pix_arr)) with the same rectangle from previous frame (prev_pix_arr) (to do: and in next frame (curr_frame)):
        // if (frame_no <= 50)    // testing
        // if ((impact_frame_no == 0) || (frame_no < impact_frame_no) || (prev_box2_delta_x > 20))     // stop updating the mask if the velocity drops below threshold
        // {
            // printf("         --- calling set_background_mask \n");
    //    [ self set_club_shaft_background_mask :prev_pix_arr :pix_x_min :pix_y_min ];
        // }
        
        pos_x_max = pix_x_min - ( box_width / 2 );
        pos_y_max = pix_y_min - ( box_height / 2 );
        
        obj_center_x = pix_x_min;
        obj_center_y = pix_y_min;
        // obj_center_x = pos_x_max + ( box_width / 2 );
        // obj_center_y = pos_y_max + ( box_height / 2 );
    }
    
    
    [ self save_club_shaft_subimg         :pix_arr      :obj_center_x :obj_center_y ];       // update the new club_shaft_subimg
    [ self set_club_shaft_background_mask :prev_pix_arr :obj_center_x :obj_center_y ];
    
    [ self set_linear_regression_points ];                                                   // setting  linear_regression_points_x  and  linear_regression_points_y
    [ self compute_linear_regression_line :linear_regression_points_x :linear_regression_points_y :num_linear_regression_points];

    int min_num_points = 100; // 2000
    if ((num_linear_regression_points > min_num_points) || (subimg_tracking))    { club_shaft_found = true; }
    else                                                                         { club_shaft_found = false; obj_center_x = -1000; }   // move overlay drawing out of view if no shaft movement detected
    
    // TODO: improve optimize_shaft_line
    [ self optimize_shaft_line :frame_no :pix_arr ];                                         // use center shaft line and two flanking lines to determine accurate direction and position of shaft (minimize variance in each line)
    
    printf("         ---<2>=== putt - shaft - object center - x: %d  y: %d  obj_angle: %2.2f   club_shaft_tracking_confidence: %d   subimg_tracking: %d   num_linear_regression_points: %d \n",  obj_center_x, obj_center_y, obj_angle, club_shaft_tracking_confidence, subimg_tracking, num_linear_regression_points);
    
    if (obj_center_x != 0) // (sharpness > 1.0f)
    {
        // obj_color_red   = red_ave_max;
        // obj_color_green = green_ave_max;
        // obj_color_blue  = blue_ave_max;
        
        // printf("         --- putt -shaft - red_ave_max: %d  green_ave_max: %d  blue_ave_max: %d \n",  red_ave_max, green_ave_max, blue_ave_max);
        
    /*
        // Compute speed:
        // if (   ((! (sport == 30)) || (frame_no > 40))        // temporary for demo (baseball?)   --  DON'T NEED THIS, THIS FUNCTION IS ONLY FOR PUTT
        //     && (    (! (cliubhead_action_path_state >= 90))                                               // not past point of no return (otherwise cancel speed computation)
        //         ||  ((fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))))     // OR moving outwards
        if (true)
        {
            float obj_radius = 25.0f; // 17.0f; // 13.16f;                                   // pixels
            // if (ball_radius > 1.0f) { obj_radius = ball_radius; }                         // pixels
            if (ball_radius_shape_based > 1.0f) { obj_radius = ball_radius_shape_based; }    // in pixels (this is set by find_moving_object__putt_shape_based()
            float obj_diameter = 2 * obj_radius;                                             // pixels
            // float frame_rate = 30;                                                        // frames / sec
            float frame_rate = (float) (video_fps / fps_reduction_factor);                   // frames / sec
            float time_per_frame = 1.0f / frame_rate;                                        // sec
            //x float ball_diameter = 0.075;                                                 // meters (baseball diameter)
            float ball_diameter = 0.047;                                                     // meters -- golf ball diametert 1.68 inches (4,27 cm)
            if (meters_per_pixel == 0.0f)                                                    // Using class variable "meters_per_pixel" (don't overwrite unless it is zero) which has been set in find_moving_objects__putt__shape_based.
            {
                meters_per_pixel = ball_diameter / obj_diameter;                             // meters
            }
            
            float delta_x = prev_pos_box2_x_max - pos_x_max;
            float delta_y = prev_pos_box2_y_max - pos_y_max;
            float distance_traveled_in_pixels = 0.0f;
            if ((prev_pos_box2_x_max != 0) && (prev_pos_box2_y_max != 0))    // if previous position is valid
            {
                // distance_traveled_in_pixels = sqrtf(delta_x * delta_x + delta_y * delta_y);
                distance_traveled_in_pixels = sqrtf(delta_x * delta_x);       // use only horizonal movement for now
                
                float distance_traveled_in_meters = distance_traveled_in_pixels * meters_per_pixel;
                
                float speed = distance_traveled_in_meters / time_per_frame;    // meters / sec
                float clubhead_speed_mph_inst = speed * 2.2369f;                          // convert m/s in mph
                float clubhead_speed_mph_ave = [ self get_average_clubhead_speed :clubhead_speed_mph_inst ];
                [self update_trail_of_clubhead_speeds :clubhead_speed_mph_ave];
                
                printf("      putt__motion_based -- speed: %2.2f   distance_traveled_in_meters: %2.2f   distance_traveled_in_pixels: %2.2f   frame_rate: %2.2f   time_per_frame: %2.2f   delta_x: %2.2f   delta_y: %2.2f \n",  speed, distance_traveled_in_meters, distance_traveled_in_pixels, frame_rate, time_per_frame, delta_x, delta_y);
                
                
                // Track clubhead_action_path_state:
                if (    (fabs(delta_x) > (3.0 * fabs(delta_y))))                                       // mostly horizontal movement
                    //   &&  (fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))   // moving outwards
                {
                    clubhead_action_path_state = 60;
                    
                    // int large_displacement = img_half_width / (video_fps / 10.0f);
                    int large_displacement = 60;                                                      // use for putt (this funcion is for putt only)
                    
                    // if (   (fabs(delta_x) > (large_displacement - 10))                                // moving at certain speed
                    //     && (fabs(delta_x) < (large_displacement + 10)))
                    if (true)
                    {
                        clubhead_action_path_state = 90;                                                // point of no return
                        
                        // if (impact_frame_no == 0)                                                     // impact most likely occurred right before high horizontal velocity is observed
                        // {
                        //     int synch_factor = -1; // -8; // -16;
                        //     impact_frame_no = frame_no + synch_factor;
                        // }
                        
                        if (    (clubhead_speed_mph > max_clubhead_speed_mph)
                            // && (frame_no > 8) && (frame_no < 50)) //  (impact_frame_no - 2))
                            && (clubhead_tracking_confidence > 7))
                        {
                            max_clubhead_speed_mph = clubhead_speed_mph_ave;
                        }
                        
                        if ((impact_frame_no > 4) && (frame_no > impact_frame_no) && (impact_clubhead_speed_mph == 0))
                        {
                            impact_clubhead_speed_mph = smoothed_clubhead_speed_mph_minus_4;     // This is displayed as "Head Speed" ?
                        }
                    }
                }
            }
            else { clubhead_speed_mph = 0.0f; }
        }
        
        printf("      ~== pos_x_max: %d   pos_y_max: %d   prev_pos_box2_x_max: %d   prev_pos_box2_y_max: %d   meters_per_pixel: %10.5f   clubhead_speed_mph: %6.3f   max_clubhead_speed_mph: %1.1f  impact_frame_no: %d \n", pos_x_max, pos_y_max, prev_pos_box2_x_max, prev_pos_box2_y_max, meters_per_pixel, clubhead_speed_mph, max_clubhead_speed_mph, impact_frame_no);
        
     */
        pppprev_shaft_x_max = ppprev_shaft_x_max;
        pppprev_shaft_y_max = ppprev_shaft_y_max;
        
        ppprev_shaft_x_max = pprev_shaft_x_max;
        ppprev_shaft_y_max = pprev_shaft_y_max;
        
        pprev_shaft_x_max = prev_shaft_x_max;
        pprev_shaft_y_max = prev_shaft_y_max;
        
        prev_shaft_x_max = pos_x_max;
        prev_shaft_y_max = pos_y_max;
     
   //     [self save_clubhead_subimg :pix_arr :obj_center_x :obj_center_y];
    }
    else
    {
        // prev_pos_box2_x_max = 0;
        // prev_pos_box2_y_max = 0;
        
        // max_clubhead_speed_mph = 0.0f;
    }
    
    
    [self set_overlay_box3 :obj_center_x :obj_center_y];                                                               // Set position of green box (club shaft)
    
    /*
     if ((obj_center_x == 0) && (obj_center_y == 0))       // The object location is undefined
     {
     obj_rot_angle  = 0.0f;                            // reset the rotation angle so that the box is straight when the ball it hit
     obj_rot_angle1 = 0.0f;                            // reset the rotation angle so that the box is straight when the ball it hit
     obj_rot_angle2 = 0.0f;                            // reset the rotation angle so that the box is straight when the ball it hit
     delta_rotation_angle = 0.0f;
     // obj_rot_ref_frame = frame_no;
     }
    */
    
    
    // diff_box_ave = diff_box_acc / diff_box_cnt;                                                                       // the average is approx. 16
    
    // printf("         === frame_no: %d   diff_box_ave: %d \n", frame_no, diff_box_ave);
}




- (void) find_moving_objects__putt__shape_based:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    
    // Adjust default values for small images:
    float img_size_factor = movie_frame_size_factor;  //x  ((float)image_width) / 1280.0f;
    printf("      --- img_size_factor: %2.5f \n", img_size_factor);
    
    // Scan through the image (prev_pix_arr) and find white disks (circles).
    // Test each scanned pixel whether it is the center of a circle.
    // First call a function that computes the relative coorindates of a series of points that mark a circle around a point:
    //    Define 2 circles and test if they contain a circle on the image.
    int num_circle_points = 72;   // 1 point for every 5 degrees
    //  float lower_bound_circle_radius = 50.0f; // in pixels
    //  float upper_bound_circle_radius = 80.0f; // in pixels
    //  float lower_bound_circle_radius = 42.0f; // in pixels
    //  float upper_bound_circle_radius = 47.0f; // 60.0f; // in pixels
//    float lower_bound_circle_radius = 43.0f; // in pixels      // carpet video
//    float upper_bound_circle_radius = 47.0f; // in pixels      // carpet video
    float lower_bound_circle_radius = 60.0f * img_size_factor; // in pixels      // carpet video
    float upper_bound_circle_radius = 80.0f * img_size_factor; // in pixels      // carpet video
    
    float * circle_points_lower_bound_x = NULL;
    float * circle_points_lower_bound_y = NULL;
    float * circle_points_upper_bound_x = NULL;
    float * circle_points_upper_bound_y = NULL;
    
    circle_points_lower_bound_x = (float *) calloc(num_circle_points, sizeof(float));       // THESE ALLOCATIONS SHOULD BE DONE OUTSIDE THE LOOP
    circle_points_lower_bound_y = (float *) calloc(num_circle_points, sizeof(float));
    circle_points_upper_bound_x = (float *) calloc(num_circle_points, sizeof(float));
    circle_points_upper_bound_y = (float *) calloc(num_circle_points, sizeof(float));
    
    [self fill_in_circle_points :num_circle_points :lower_bound_circle_radius  :circle_points_lower_bound_x  :circle_points_lower_bound_y];   // overwritten below
    [self fill_in_circle_points :num_circle_points :upper_bound_circle_radius  :circle_points_upper_bound_x  :circle_points_upper_bound_y];
    
    
    int num_blastman1_points = 7;
    float blastman1_radius = 14.0f * img_size_factor;
    
    float * blastman1_points_x = NULL;
    float * blastman1_points_y = NULL;
    
    blastman1_points_x = (float *) calloc(num_blastman1_points, sizeof(float));               // THESE ALLOCATIONS SHOULD BE DONE OUTSIDE THE LOOP
    blastman1_points_y = (float *) calloc(num_blastman1_points, sizeof(float));               // THESE ALLOCATIONS SHOULD BE DONE OUTSIDE THE LOOP

    [self fill_in_blastman_points :num_blastman1_points :blastman1_radius  :blastman1_points_x  :blastman1_points_y];

    
    int margin_x = image_width / 60; // 70;
 //   int margin_y_top = image_height / 3; // 2;
 //   int margin_y_bottom = image_height / 40;
    int margin_y_top = image_height / 3; // 3;
 //   int margin_y_bottom = image_height / 3;
    int margin_y_bottom = image_height / 4;
    
    int score = 0;
    int score_max = -999999;
    float radius_max = 0.0f;
    int pos_x_max = 0;
    int pos_y_max = 0;
    int contrast_cnt_max = 0;
    
    
    int margin = 60 * img_size_factor; // upper_bound_circle_radius
    
    int search_x_start = (margin_x + margin);
    int search_x_end   = (image_width - margin) - margin_x;
    
    int search_y_start = margin_y_top + margin;
    int search_y_end   = (image_height - margin) - margin_y_bottom;
    
    int search_range = 100 * img_size_factor; // 200
    
    if (prev_obj_center_x > 0)
    {
        search_x_start = max(               margin_x, prev_obj_center_x - search_range );
        search_x_end   = min( (image_width - margin), prev_obj_center_x + search_range );
        
        search_y_start = max( (margin_y_top + margin), prev_obj_center_y - search_range );
        search_y_end   = min( (image_height - margin), prev_obj_center_y + search_range );
    }
    
    
    // Enforce ball motion continuity (and speed up search):
    int prev_delta_x = prev_pos_x_max - pprev_pos_x_max;
    int prev_delta_y = prev_pos_y_max - pprev_pos_y_max;
    
    int pprev_delta_x = pprev_pos_x_max - ppprev_pos_x_max;
    int pprev_delta_y = pprev_pos_y_max - ppprev_pos_y_max;
    
    int delta_x_continuity_threshold = 30; // 20; // 10;
    int delta_y_continuity_threshold = 30; // 20; // 10;
    
    int continuity_tolerance_x = 30; //  20; // 20;    // overwritten below
    int continuity_tolerance_y = 10; // 20;            // overwritten below
    
    
    // Scan image:
    int step_size = 4; // 2; // 4; // 8; // 4; // 2;
    int radius_start = lower_bound_circle_radius - 20.0f;
    int radius_end   = lower_bound_circle_radius + 20.0f; // 6.1f;
    if (prev_ball_radius > 0.0f)
    {
        radius_start = prev_ball_radius - 2.1f;
        radius_end   = prev_ball_radius + 3.1f;
    }
    int radius_step_size = 1.0f;
    float radius_gap = 6.0f; // 10.0f; // 20.0f; // 5;
    
    
    // First check if there is no movement:  set position_alignment_theshold to small value (3); if score is good and similar to previous good score continue; otherwise due more extensive search
    int num_phases = 2;
    //x num_phases = 0;    // testing
    
    for (int phase_no = 1; phase_no <= num_phases; phase_no++)
    {
        score_max = -999999;    // reset
        
        if (phase_no == 1) { continuity_tolerance_x =  5;  continuity_tolerance_y = 10; }
   //   else               { continuity_tolerance_x = 40;  continuity_tolerance_y = 16; }
        else               { continuity_tolerance_x = 60;  continuity_tolerance_y = 24; }
        
        
        if (    (prev_pos_x_max > 0)
            &&  (abs(prev_delta_x - pprev_delta_x) < delta_x_continuity_threshold)
            &&  (abs(prev_delta_y - pprev_delta_y) < delta_y_continuity_threshold))
        {
            search_x_start = (prev_pos_x_max + prev_delta_x) - continuity_tolerance_x;
            search_x_end   = (prev_pos_x_max + prev_delta_x) + continuity_tolerance_x;
            
            search_y_start = (prev_pos_y_max + prev_delta_y) - continuity_tolerance_y;
            search_y_end   = (prev_pos_y_max + prev_delta_y) + continuity_tolerance_y;
            
            // printf("         --->>>  enforcing ball motion continuity --   frame_no: %d   search_x_start: %d   search_x_end: %d   search_y_start: %d   search_y_end: %d \n",  frame_no, search_x_start, search_x_end, search_y_start, search_y_end);
        }

        
        for (int radius1 = radius_start; radius1 < radius_end; radius1 += radius_step_size)
        {
            float lower_bound_circle_radius = radius1;
            float upper_bound_circle_radius = lower_bound_circle_radius + radius_gap;
            [self fill_in_circle_points :num_circle_points :lower_bound_circle_radius :circle_points_lower_bound_x :circle_points_lower_bound_y];
            [self fill_in_circle_points :num_circle_points :upper_bound_circle_radius :circle_points_upper_bound_x :circle_points_upper_bound_y];
            
            // printf("         --->-->  find_moving_objects__put__shape_based --   frame_no: %d   radius_start: %d   radius_end: %d   search_x_start: %d   search_x_end: %d   search_y_start: %d   search_y_end: %d \n",  frame_no, radius_start, radius_end, search_x_start, search_x_end, search_y_start, search_y_end);
            
            for (int x_loop = search_x_start;  x_loop < search_x_end;  x_loop += step_size)
            {
                for (int y_loop = search_y_start;  y_loop < search_y_end;  y_loop += step_size)
                {
                    int pixel_x = x_loop;
                    int pixel_y = y_loop;
                    
                    // Evaluate the average intensity of the the smaller circle:
                    // int intensity_small_circle = [self get_average_circle_intensity :pixel_x :pixel_y :pix_arr :num_circle_points :circle_points_lower_bound_x :circle_points_lower_bound_y];    // -- should get average of brightest 10 points
                    // int intensity_large_circle = [self get_average_circle_intensity :pixel_x :pixel_y :pix_arr :num_circle_points :circle_points_upper_bound_x :circle_points_upper_bound_y];    // -- should get average of brightest 10 points
                    int contrast_cnt          = [self get_average_circle_contrast  :pixel_x :pixel_y :pix_arr :num_circle_points :circle_points_lower_bound_x :circle_points_lower_bound_y :circle_points_upper_bound_x :circle_points_upper_bound_y];
                    // int intensity_large_circle = [self get_average_circle_intensity :pixel_x :pixel_y :pix_arr :num_circle_points :circle_points_lower_bound_x :circle_points_upper_bound_y];
                    
                    // score = intensity_small_circle;
                    // score = intensity_small_circle + (100 * intensity_small_circle) / intensity_large_circle;
                    // score = contrast_cnt + (intensity_small_circle / 256);
                    score = contrast_cnt;
                    score += (radius1 / 1);     // give preference to larger balls
                    
                    // printf("         --0-- pixel_x: %d  pixel_y: %d  score: %5d \n",  pixel_x, pixel_y, score);
                    
                    // TODO: If score is above threshold optimize further by adjusting the radii of the small and larger circle (small circle ranges from 40 to 60 pixels):
                    //
                    
                    if (score > score_max)
                    {
                        // printf("         --0-- pixel_x: %d  pixel_y: %d  score_max: %5d  pos_x_max: %d  pos_y_max: %d\n",  pixel_x, pixel_y, score_max, pos_x_max, pos_y_max);
                        score_max = score;
                        radius_max = radius1;
                        pos_x_max = pixel_x;
                        pos_y_max = pixel_y;
                        contrast_cnt_max = contrast_cnt;
                        
                        // Track the top 50 locations:
                        // [self track_top_ball_position :pos_x_max :pos_y_max :score_max];
                    }
                    
                }
            }
            
        }
        
        
        if (score_max > (ball_shape_score - 50))  { break; }   // Good enough - don't need to do more extensive search (phase 2)
    }
    
    ball_shape_score = [self get_ball_shape_score :score_max];

   
    int center_pixel_x = 0;
    int center_pixel_y = 0;
    int radius1        = 0;
    
    [self find_center_of_ball :frame_no :pos_x_max :pos_y_max :radius_max :pix_arr :num_circle_points :circle_points_lower_bound_x :circle_points_lower_bound_y :circle_points_upper_bound_x :circle_points_upper_bound_y  :&center_pixel_x  :&center_pixel_y  :&radius1];
    
    /*
    int obj_center = center_pixel_x * 1000000 + center_pixel_y;
    float obj_angle = 0.0f;
    if ((pos_x_max != 0) && (pos_y_max != 0))
    {
        obj_angle  = [self find_orientation_of_obj :pix_arr :frame_no :obj_center];
    }
    */
    int obj_center_x = center_pixel_x;
    int obj_center_y = center_pixel_y;
    printf("         --2-- frame: %d   obj_center_x: %d  obj_center_y: %d  score_max: %5d  contrast_cnt_max: %5d   pos_x_max: %d  pos_y_max: %d  radius1: %d \n",  frame_no, obj_center_x, obj_center_y, score_max, contrast_cnt_max, pos_x_max, pos_y_max, radius1);
    
    
    if (pos_x_max > (image_width - 100))  { object_action_path_state = 100; }   // end state
    
    // Compute speed:
    if (score_max > 70)     // if score is too low, the ball was probably not detected
    {
        float obj_radius = 52.0f;                                                        // in pixels
        // if (ball_radius > 1.0f)  { obj_radius = ball_radius; }                        // in pixels
        if (ball_radius_shape_based > 1.0f) { obj_radius = ball_radius_shape_based; }    // in pixels
        float obj_diameter = 2 * obj_radius;                                             // in pixels
        float frame_rate = (float) (video_fps / fps_reduction_factor);                   // in frames / sec
        float time_per_frame = 1.0f / frame_rate;                                        // in sec
        float ball_diameter = 0.047;                                                     // in meters -- golf ball diametert 1.68 inches (4,27 cm)
        float ball_weight   = 0.04593;                                                   // 0.04593 kg = 45.93 grams
        meters_per_pixel = ball_diameter / obj_diameter;                           // meters
        
        float delta_x = prev_obj_center_x - obj_center_x;
        float delta_y = prev_obj_center_y - obj_center_y;
        float distance_traveled_in_pixels = 0.0f;
        if ((prev_pos_x_max != 0) && (prev_pos_y_max != 0))    // if previous position is valid
        {
            distance_traveled_in_pixels = sqrtf(delta_x * delta_x + delta_y * delta_y);
            
            float distance_traveled_in_meters = distance_traveled_in_pixels * meters_per_pixel;
            distance_traveled_in_meters /= ((float) prev_fps_reduction_factor);          // need to adjust distance traveled if fps has been reduced (frames have been skipped)
            
            float speed = distance_traveled_in_meters / time_per_frame;    // meters / sec
            float ball_speed_in_mph = speed * 2.2369f;   // convert m/s in mph
            float ball_speed_ave_mph = [self get_average_ball_speed :ball_speed_in_mph];
            
            if (   true // (frame_no > 40)
                // && (ball_speed_in_mph < 20.0f)                                     // check if speed is reasonable
                && (object_action_path_state < 100))
            {
                [ self update_ball_speed_arr :frame_no :ball_speed_ave_mph ];              // for displaying speed graph
                // [ self update_head_speed_arr :frame_no :clubhead_speed_mph ];      // for displaying club head speed graph
            }
            else
            {
                [ self update_ball_speed_arr :frame_no :(-999999.0f) ];            // for displaying speed graph (mark as "not set")
                [ self update_head_speed_arr :frame_no :(-999999.0f) ];            // for displaying head speed graph (mark as "not set")
                [ self update_ball_rpm_arr :(-999999.0f) ];                        // for displaying rpm graph (mark as "not set")
                if (frame_no > 40) { object_action_path_state = 100; }             // 100 means: path tracking terminated
            }
            
            printf("      putt -- speed: %2.2f   distance_traveled_in_meters: %2.2f   distance_traveled_in_pixels: %2.2f   frame_rate: %2.2f   time_per_frame: %2.2f   delta_x: %2.2f   delta_y: %2.2f \n",  speed, distance_traveled_in_meters, distance_traveled_in_pixels, frame_rate, time_per_frame, delta_x, delta_y);
            
            
            // Track object_action_path_state:
            if (object_action_path_state < 100)
            // if (    (true) // (fabs(delta_x) > (3.0 * fabs(delta_y)))                                       // mostly horizontal movement
               //   && (object_action_path_state < 100)
                 // && (ball_speed_in_mph > 0.5f)
                 // && (ball_speed_in_mph < 30.0f)
                 // && (fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))   // moving outwards
            //   )
            {
                object_action_path_state = 60;

                // ball_speed_mph = speed * 2.2369f;   // convert m/s in mph
                ball_speed_mph = ball_speed_ave_mph;   // this is display on the UI dashboard
                
                // int large_displacement = img_half_width / (video_fps / 10.0f);
                int large_displacement = 20; // 60;                                                      // use for putt (this funcion is for putt only)
                printf("         ---&--. delta_x: %5.2f \n", delta_x);
                
                if (   (fabs(delta_x) > (large_displacement - 10))                                // moving at certain speed (detect impact)
                    && (fabs(delta_x) < (large_displacement + 40)))
                {
                    object_action_path_state = 90;                                                // point of no return
                    
                    if (impact_frame_no == 0)                                                     // impact most likely occurred right before high horizontal velocity is observed
                    {
                        int synch_factor = -1; // -8; // -16;
                        impact_frame_no = frame_no + synch_factor;
                        
                        impact_ball_position_x = ((float)obj_center_x * meters_per_pixel);        // in meters
                        impact_ball_position_y = ((float)obj_center_x * meters_per_pixel);        // in meters
                        
                        impact_obj_pos_x = prev_obj_center_x;     // in pixels
                        impact_obj_pos_y = prev_obj_center_y;     // in pixels
                    }
                    
                    // if (ball_speed_in_mph > max_ball_speed_mph)
                    if (ball_speed_ave_mph > max_ball_speed_mph)
                    {
                        max_ball_speed_mph = ball_speed_ave_mph;
                        // Track the last 4 ball speed values and average over these so smooth out fluctuations due detection accuracy limitations:

                        float max_ball_speed_mps = max_ball_speed_mph / 2.2369f;
                        
                        // Compute momentum transfer ("force"):  momentum = mass * velocity = 0.04593 kg * max_ball_speed_mps
                        float max_ball_momentum = ball_weight * max_ball_speed_mps;
                        
                        // Compute force applied to achieve the momentum:
                        float duration = 1.0f;      // assume application duration is 1 sec.
                        float force = max_ball_momentum / duration;
                        force_for_ball_momentum = force;
                        
                        // Compute distance from impact to stand still:    distance = 0.5 * v*v / mu * g     rolling_friction_factor mu = 0.056        g = 9.81
                        float rolling_friction_factor = 0.056;   // for stimp reading of 10
                        float travel_distance = (0.5f * max_ball_speed_mps * max_ball_speed_mps) / (rolling_friction_factor * 9.81);
                        ball_travel_distance = travel_distance;
                        
                        // printf("         ---&-- frame_no: %5d   impact_frame_no: %5d   max_clubhead_speed_mph: %7.2f   max_ball_speed_mph: %7.2f   max_ball_momentum: %7.2f kg*m/s   force: %7.2f   travel_distance: %7.2f meters \n", frame_no, impact_frame_no, max_clubhead_speed_mph, max_ball_speed_mph, max_ball_momentum, force, travel_distance);
                    }
                    
                    if (impact_clubhead_speed_mph > 0.0f)
                    {
                        // impact_ratio = max_ball_speed_mph / impact_clubhead_speed_mph;    // smash factor
                        
                        int ball_speed_sample_offset_240fps = 10;      // for 240 fps
                        int ball_speed_sample_offset = (int) (((float) ball_speed_sample_offset_240fps) / ((float) (video_fps/fps_reduction_factor)));     // adjust for different frame rates (video_fps)
                        if ((impact_frame_no > 4) && (frame_no == (impact_frame_no + 10)))
                        {
                            impact_ratio = ball_speed_ave_mph / impact_clubhead_speed_mph;    // smash factor taken at 10 frames after impact
                        }
                        printf("         ---&--  frame_no: %5d   impact_frame_no: %5d   impact_clubhead_speed_mph: %7.2f   ball_speed_ave_mph: %7.2f \n", frame_no, impact_frame_no, impact_clubhead_speed_mph, ball_speed_ave_mph);
                    }
                }
                
                // Find orientation (rotation) of ball:
                int obj_center = center_pixel_x * 1000000 + center_pixel_y;
                float obj_angle = 0.0f;
                if ((pos_x_max != 0) && (pos_y_max != 0))
                {
                    // obj_angle  = [self find_orientation_of_obj :pix_arr :frame_no :obj_center];                                                                                  // <<<<<<<<<<<<<<<<<<<<<<<<<<<
                    // obj_angle  = [self find_orientation_of_obj_with_blastman :pix_arr :frame_no :obj_center :num_blastman1_points :blastman1_points_x :blastman1_points_y];         // <<<<<<<<<<<<<<<<<<<<<<<<<<< find orientation (use blastman)
                    obj_angle  = [self find_orientation_of_obj_with_pattern :pix_arr :frame_no :obj_center :radius1 :num_blastman1_points :blastman1_points_x :blastman1_points_y];         // <<<<<<<<<<<<<<<<<<<<<<<<<<< find orientation (use blastman) -- THIS IS SLOW ON DEVICE (NEED TO OPTIMIZE)
                }
            }
            else   // Ball travelled out of view
            {
                printf("      -_-_ object_action_path_state: %d \n", object_action_path_state);
                
                pos_x_max = -100;
                pos_y_max = -100;
                obj_center_x = -100;
                obj_center_y = -100;
            }
        }
        else { ball_speed_mph = 0.0f; }
        
        printf("      ~=o center_pixel_x: %d   center_pixel_y: %d   pos_x_max: %d   pos_y_max: %d   prev_pos_x_max: %d   prev_pos_y_max: %d   max_ball_speed_mph: %1.1f   max_clubhead_speed_mph: %1.1f   impact_ratio: %1.1f \n",  center_pixel_x, center_pixel_y, pos_x_max, pos_y_max, prev_pos_x_max, prev_pos_y_max, max_ball_speed_mph, max_clubhead_speed_mph, impact_ratio);
        
        
        ppprev_pos_x_max = pprev_pos_x_max;
        ppprev_pos_y_max = pprev_pos_y_max;
        
        pprev_pos_x_max = prev_pos_x_max;
        pprev_pos_y_max = prev_pos_y_max;
        
        prev_pos_x_max = pos_x_max;
        prev_pos_y_max = pos_y_max;
        
        
        ppprev_obj_center_x = pprev_obj_center_x;
        ppprev_obj_center_y = pprev_obj_center_y;
        
        pprev_obj_center_x = prev_obj_center_x;
        pprev_obj_center_y = prev_obj_center_y;
        
        prev_obj_center_x = obj_center_x;
        prev_obj_center_y = obj_center_y;
        
        
        
        [self set_overlay_circle :obj_center_x :obj_center_y :radius_max];            // Set position of red circle
  //    [self set_overlay_circle :obj_center_x :obj_center_y :lower_bound_circle_radius];            // Set position of red circle
  //    [self set_overlay_circle :obj_center_x :obj_center_y :radius1+10];                              // Set position of red circle (add 10 so that the circle doesn't cover the ball outline)
        //  [self set_overlay_box    :obj_center_x :obj_center_y];                                      // Set position of red box
        
        
        // Position blastman:
        // int blastman1_shift_x = pos_x_max; // 300;
        // int blastman1_shift_y = pos_y_max; // 200;
        // for (int point_no = 0; point_no < num_blastman1_points; point_no++)
        // {
        //     blastman1_points_x[point_no] += (float) blastman1_shift_x;
        //     blastman1_points_y[point_no] += (float) blastman1_shift_y;
        // }
        [self draw_blastman :num_blastman1_points :blastman1_points_x :blastman1_points_y];
    }
    else
    {
        [self set_overlay_circle :-10 :-10 :radius1+10];                             // Remove red circel from view (if ball is not detected)
    }
    
    if (circle_points_lower_bound_x) { free(circle_points_lower_bound_x); }
    if (circle_points_lower_bound_x) { free(circle_points_lower_bound_y); }
    if (circle_points_lower_bound_x) { free(circle_points_upper_bound_x); }
    if (circle_points_lower_bound_x) { free(circle_points_upper_bound_y); }
}




- (void) fill_in_circle_points :(int)num_circle_points :(float)circle_radius1 :(float *)circle_points_x :(float *)circle_points_y
{
    int num_points_quarter_circle = num_circle_points / 4;
    int num_points_half_circle    = num_circle_points / 2;
    
    // Fill in the first quarter of the circle (start at 3 o'clock position going clockwise)
    float angle_increment = (2.0f * M_PI) / num_circle_points;
    float angle_current = 0.0f;
    for (int point_no = 0; point_no < num_points_quarter_circle; point_no++)
    {
        // printf("         angle_current: %5.2f \n", angle_current);
        float x = circle_radius1 * cos(angle_current);
        float y = circle_radius1 * sin(angle_current);
        
        circle_points_x[point_no] = x;
        circle_points_y[point_no] = y;
        
        // Assign (symmetic) points in the second quarter (6 o'clock to 9 o'clock)
        int index = num_points_half_circle - point_no;
        circle_points_x[index] = -x;
        circle_points_y[index] =  y;
        
        // Assign (symmetic) points in the third quarter (9 o'clock to 12 o'clock)
        index = num_points_half_circle + point_no;
        circle_points_x[index] = -x;
        circle_points_y[index] = -y;
        
        // Assign (symmetic) points in the forth quarter (12 o'clock to 3 o'clock)
        index = num_circle_points - point_no;
        if (index < num_circle_points)
        {
           circle_points_x[index] =  x;
           circle_points_y[index] = -y;
        }
        
        angle_current += angle_increment;
    }
    
    // Add the 6 o'clock and 12 o'clock points:
    circle_points_x[num_points_quarter_circle] = 0.0f;
    circle_points_y[num_points_quarter_circle] = circle_radius1;
    
    circle_points_x[num_points_half_circle + num_points_quarter_circle] = 0.0f;
    circle_points_y[num_points_half_circle + num_points_quarter_circle] = -circle_radius1;
    
    
    /*
    // Print out the circle points (for verification):
    for (int point_no = 0; point_no < num_circle_points; point_no++)
    {
        float x = circle_points_x[point_no];
        float y = circle_points_y[point_no];
        
        printf("               ()()() circle_point %5d:  %6.1f  %6.1f \n", point_no, x, y);
    }
    */
}



/*  // Initial version (proportions not correct)
- (void) fill_in_blastman_points :(int)num_blastman1_points :(float)blastman_radius  :(float *)blastman1_points_x  :(float *)blastman1_points_y
{
    // Points:  (1) Head - (2) Left Hand - (3) Chest - (4) Right Hand - (5) Belly - (6) Left Foot - (7) Right Foot (from viewer perspective)
    blastman1_points_x[0] =  0.0f;    // Head
    blastman1_points_y[0] = -1.0f;
    
    // blastman1_points_x[1] = -1.0f;    // Left Hand
    blastman1_points_x[1] = -1.1f;
    // blastman1_points_y[1] =  0.0f;
    blastman1_points_y[1] =  0.2f;
    
    blastman1_points_x[2] =  0.0f;       // Chest (reference)
    blastman1_points_y[2] =  0.0f;
    
    // blastman1_points_x[3] =  1.0f;    // Right Hand
    blastman1_points_x[3] =  1.3f;
    // blastman1_points_y[3] =  0.0f;
    blastman1_points_y[3] = -0.15f;
    
    // blastman1_points_x[4] =  0.0f;    // Belly
    blastman1_points_x[4] =  0.1f;
    // blastman1_points_y[4] =  1.0f;
    blastman1_points_y[4] =  0.8f;
    
    // blastman1_points_x[5] = -1.0f;    // Left Foot
    blastman1_points_x[5] = -0.85f;
    // blastman1_points_y[5] =  2.0f;
    blastman1_points_y[5] =  1.55f;
    
    // blastman1_points_x[6] =  1.0f;    // Right Foot
    blastman1_points_x[6] =  1.0f;
    // blastman1_points_y[6] =  2.0f;
    blastman1_points_y[6] =  1.5f;
    
    for (int point_no = 0; point_no < num_blastman1_points; point_no++)
    {
        blastman1_points_x[point_no] *= blastman_radius;
        blastman1_points_y[point_no] *= blastman_radius;
    }
}
*/


- (void) fill_in_blastman_points :(int)num_blastman1_points :(float)blastman_radius  :(float *)blastman1_points_x  :(float *)blastman1_points_y
{
    // Points:  (1) Head - (2) Left Hand - (3) Chest - (4) Right Hand - (5) Belly - (6) Left Foot - (7) Right Foot (from viewer perspective)
    blastman1_points_x[0] =  0.0f;    // Head
    blastman1_points_y[0] = -1.23f;
    
    // blastman1_points_x[1] = -1.0f;    // Left Hand
    blastman1_points_x[1] = -1.1f;
    blastman1_points_y[1] =  0.10f;
    
    blastman1_points_x[2] =  0.0f;       // Chest (reference)
    blastman1_points_y[2] =  0.0f;
    
    // blastman1_points_x[3] =  1.0f;    // Right Hand
    blastman1_points_x[3] =  1.3f;
    blastman1_points_y[3] = -0.10f;
    
    // blastman1_points_x[4] =  0.0f;    // Belly
    blastman1_points_x[4] =  0.03f;
    blastman1_points_y[4] =  1.25f;
    
    // blastman1_points_x[5] = -1.0f;    // Left Foot
    blastman1_points_x[5] = -1.05f;
    // blastman1_points_y[5] =  1.55f;
    blastman1_points_y[5] =  2.52f;
    
    // blastman1_points_x[6] =  1.0f;    // Right Foot
    blastman1_points_x[6] =  1.39f;
    // blastman1_points_y[6] =  1.5f;
    blastman1_points_y[6] =  2.32f;
    
    for (int point_no = 0; point_no < num_blastman1_points; point_no++)
    {
        blastman1_points_x[point_no] *= blastman_radius;
        blastman1_points_y[point_no] *= blastman_radius;
    }
}




- (int) get_average_circle_intensity :(int)pixel_x :(int)pixel_y :(unsigned char*)pix_arr :(int)num_circle_points :(float *)circle_points_x :(float *)circle_points_y
{
    int red = 0;
    int green = 0;
    int blue = 0;
    
    int red_acc = 0;
    int green_acc = 0;
    int blue_acc = 0;
    
    int gray_acc = 0;
    
    for (int point_no = 0; point_no < num_circle_points; point_no++)
    {
        int point_x = pixel_x + ((int)circle_points_x[point_no]);
        int point_y = pixel_y + ((int)circle_points_y[point_no]);
        
        int pixel_arr_idx = (int) ((point_y * movie_frame_bytes_per_row) + (point_x * 4));
        red   = pix_arr[pixel_arr_idx + 2];
        green = pix_arr[pixel_arr_idx + 1];
        blue  = pix_arr[pixel_arr_idx];
        
        red_acc   += red;
        green_acc += green;
        blue_acc  += blue;
        
        // printf("               --a--  pixel_x: %d    pixel_y: %d    point_x: %d    point_y: %d \n",  pixel_x, pixel_y, point_x, point_y);
    }
    
    gray_acc = (red_acc + green_acc + blue_acc) / 3;
    
    /*
     // TEST:
     gray_acc = 0;
     int gray_ave = 0;
     int num_points = 20;
     for (int point_no = 0; point_no < num_points; point_no++)
     {
     int pixel_x1 = pixel_x + point_no;
     int pixel_arr_idx = (int) ((pixel_y * movie_frame_bytes_per_row) + (pixel_x1  * 4));
     red   = pix_arr[pixel_arr_idx + 2];
     green = pix_arr[pixel_arr_idx + 1];
     blue  = pix_arr[pixel_arr_idx];
     int gray = (red + green + blue) / 3;
     gray_acc += gray;
     }
     gray_ave = gray_acc / num_points;
     return gray_ave;
     */
    
    return gray_acc;
}



/*
 *  Count the number of circle points which show a significant contrast (bright inside, dark outsite).
 */
- (int) get_average_circle_contrast :(int)pixel_x :(int)pixel_y :(unsigned char*)pix_arr :(int)num_circle_points :(float *)small_circle_points_x :(float *)small_circle_points_y :(float *)large_circle_points_x :(float *)large_circle_points_y
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;

    int red1 = 0;
    int green1 = 0;
    int blue1 = 0;
    int gray1 = 0;
    int prev_gray1 = 0;
    
    int red2 = 0;
    int green2 = 0;
    int blue2 = 0;
    int gray2 = 0;
    int prev_gray2 = 0;
    
    int contrast_cnt = 0;
    int contrast_threshold = 30; // 60; // 70; // 90; // 80; // 20; // 30; // 40; // 30; // 20; // 10;
    int continuity_theshold = 30; // 15; // 20;
    
    int blue_points_cnt = 0;
    

    
    for (int point_no = 0; point_no < num_circle_points; point_no++)
    {
        int point_x1 = pixel_x + ((int)small_circle_points_x[point_no]);
        int point_y1 = pixel_y + ((int)small_circle_points_y[point_no]);
        
        int point_x2 = pixel_x + ((int)large_circle_points_x[point_no]);
        int point_y2 = pixel_y + ((int)large_circle_points_y[point_no]);
        
        int pixel_arr_idx2 = (int) ((point_y2 * movie_frame_bytes_per_row) + (point_x2 * 4));
        
        if (   (point_x1 >= 0) && (point_x1 < image_width)
            && (point_y1 >= 0) && (point_y1 < image_height)
            && (point_x2 >= 0) && (point_x2 < image_width)
            && (point_y2 >= 0) && (point_y2 < image_height))
        {
            int pixel_arr_idx1 = (int) ((point_y1 * movie_frame_bytes_per_row) + (point_x1 * 4));
            red1   = pix_arr[pixel_arr_idx1 + 2];
            green1 = pix_arr[pixel_arr_idx1 + 1];
            blue1  = pix_arr[pixel_arr_idx1];
            gray1  = (red1 + green1 + blue1) / 3;     // small circle intensity
            
            red2   = pix_arr[pixel_arr_idx2 + 2];
            green2 = pix_arr[pixel_arr_idx2 + 1];
            blue2  = pix_arr[pixel_arr_idx2];
            gray2  = (red2 + green2 + blue2) / 3;     // large circle intensity
            
            int red_diff   = abs(red2 - red1);
            int green_diff = abs(green2 - green1);
            int blue_diff  = abs(blue2 - blue1);
            int gray_diff  = abs(gray2 - gray1);
            
            // if (gray_diff > contrast_threshold)
            if (   (red_diff   > contrast_threshold)
                || (green_diff > contrast_threshold)
                || (blue_diff  > contrast_threshold))
            {
                contrast_cnt += 2;
                
                if (point_no > 36)     // the upper half of the circle
                {
                    // contrast_cnt += 1;
                    if (gray1 > (gray2 + contrast_threshold)) { contrast_cnt += 1; }   // small circle is brighter than large circle
                }
                
                // if (gray_diff > (contrast_threshold * 2))    // add point for high contrast
                // {
                //     contrast_cnt++;
                // }
                
                /*
                 int this_diff = gray2 - gray1;
                 int prev_diff = prev_gray2 - prev_gray1;
                 
                 if (abs(prev_diff - this_diff) < continuity_theshold)     // give extra points for continuity
                 {
                 contrast_cnt++;
                 }
                 */
                
                /*
                 // Give extra points if the smaller circle is brighter than the larger circle:
                 if (point_no > 36)     // the upper half of the circle
                 {
                 if (gray1 > (gray2 + 90))
                 {
                 contrast_cnt += 2; // 4;
                 }
                 else if (gray1 > (gray2 + 60))
                 {
                 contrast_cnt += 2;
                 }
                 else if (gray1 > (gray2 + 30))
                 {
                 contrast_cnt += 2;
                 }
                 }
                 */
                
                /*
                 // Give extra points for small circle points to be white:
                 if ([self is_white_color_putt2:red1 :green1 :blue1])
                 {
                 contrast_cnt++;
                 }
                 */
                
                //  pos_x_max: 297  pos_y_max: 372
                // if ((pixel_x == 297) && (pixel_y == 372))
                // {
                //     printf("               --a--  pixel_x: %d    pixel_y: %d    point_x1: %d    point_y1: %d     point_x2: %d    point_y2: %d    gray1: %d    gray2: %d \n",  pixel_x, pixel_y, point_x1, point_y1, point_x2, point_y2, gray1, gray2);
                // }
            }
            
            // if ((pixel_x == 913) && (pixel_y == 444))
            // {
            //     printf("         pixel_x: %4d   pixel_y: %4d   point_no: %4d   color: %d %d %d   contrast_cnt: %6d \n", pixel_x, pixel_y, point_no, red1, green1, blue1, contrast_cnt);
            // }
            
            // pos_x_max: 505  pos_y_max: 456
            // pos_x_max: 509  pos_y_max: 456
            // pos_x_max: 517  pos_y_max: 460
            // pos_x_max: 505   pos_y_max: 456
            //            477   pos_y_max: 460
            // if ((pixel_x == 477) && (pixel_y == 460))
            // {
            //     printf("         pixel_x: %4d   pixel_y: %4d   point_no: %4d   color: %d %d %d  gray1: %d  gray2: %d   contrast_cnt: %6d \n", pixel_x, pixel_y, point_no, red1, green1, blue1, gray1, gray2, contrast_cnt);
            // }
            
            
            
            // if ([self is_light_blue_color2:red1 :green1 :blue1])    // penalize small circle points to be blue
            // {
            //     blue_points_cnt++;
            // }
            // if ([self is_light_blue_color:red1 :green1 :blue1])    // penalize small circle points to be blue
            // {
            //     blue_points_cnt++;
            // }
            
            
            //
            // if ([self is_red_color:red1 :green1 :blue1])    // penalize small circle points to be blue
            // {
            //     contrast_cnt -= 200;
            //
            //     // pos_x_max: 913  pos_y_max: 444
            //     // if ((pixel_x == 913) && (pixel_y == 444))
            //     // {
            //     //     printf("         pixel_x: %4d   pixel_y: %4d   point_no: %4d   color: %d %d %d   contrast_cnt: %6d \n", pixel_x, pixel_y, point_no, red1, green1, blue1, contrast_cnt);
            //     // }
            // }
            
            
            /*
             int this_diff = gray2 - gray1;
             int prev_diff = prev_gray2 - prev_gray1;
             
             if (abs(prev_diff - this_diff) < continuity_theshold)     // give extra points for continuity
             {
             contrast_cnt++;
             }
             */
            
            prev_gray1 = gray1;
            prev_gray2 = gray2;
        }
    }
    
    // if (blue_points_cnt > 8) { contrast_cnt -= 50; }
    
    
    return contrast_cnt;
}




- (void) find_center_of_ball :(int)frame_no :(int)start_pixel_x :(int)start_pixel_y :(float)start_circle_radius :(unsigned char*)pix_arr :(int)num_circle_points :(float *)circle_points_lower_bound_x :(float *)circle_points_lower_bound_y :(float *)circle_points_upper_bound_x :(float *)circle_points_upper_bound_y  :(int *)center_pixel_x  :(int *)center_pixel_y  :(int *) center_radius1
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;

    // Find optimal radius and ball center:
//    float radius_start = start_circle_radius - 2.0f;
//    float radius_end   = radius_start        + 2.0f; // 20.0f; // 10; // 20; // 40;    // optimize this by using the same radius as in previous frames
    float radius_start = start_circle_radius - 0.0f;
    float radius_end   = radius_start        + 0.1f; // 20.0f; // 10; // 20; // 40;    // optimize this by using the same radius as in previous frames
    float radius_step_size = 1.0f;
    
    // if ((prev_ball_radius > 0.0f) && (frame_no > 5))    // fix the ball radius (to the previous value)
    // {
    //     radius_start = prev_ball_radius - 2.0f;
    //     radius_end   = prev_ball_radius + 2.0f;
    // }
    
    int pix_search_range = 0; // 30; // 20; // 30;
    int pix_step_size = 2;
    
    float radius_gap = 5; // 6;
    
    int red1 = 0;
    int green1 = 0;
    int blue1 = 0;
    int gray1 = 0;
    
    int red2 = 0;
    int green2 = 0;
    int blue2 = 0;
    int gray2 = 0;
    
    // int contrast_min = 20; // 40; // 30;
    int contrast_threshold = 30; // 60; // 70; // 90; // 80; // 20; // 30; // 40; // 30; // 20; // 10;
    
    int pair_count = 0;
    int pair_cnt_max = -99999;
    int center_x_max = 0;
    int center_y_max = 0;
    float radius1_max = 0;
    
    int search_count = 0;
    
    for (float radius1 = radius_start; radius1 < radius_end; radius1 += radius_step_size)
    {
        float lower_bound_circle_radius = radius1;
        float upper_bound_circle_radius = lower_bound_circle_radius + radius_gap;
        [self fill_in_circle_points :num_circle_points :lower_bound_circle_radius :circle_points_lower_bound_x :circle_points_lower_bound_y];
        [self fill_in_circle_points :num_circle_points :upper_bound_circle_radius :circle_points_upper_bound_x :circle_points_upper_bound_y];
        
        for (int pix_x = (start_pixel_x - pix_search_range);  pix_x <= (start_pixel_x + pix_search_range);  pix_x += pix_step_size)
        {
            for (int pix_y = (start_pixel_y - pix_search_range);  pix_y <= (start_pixel_y + pix_search_range);  pix_y += pix_step_size)
            {
                search_count++;
                pair_count = 0;
                for (int point_no = 0; point_no < num_circle_points; point_no++)
                {
                    int point_x1 = pix_x + ((int)circle_points_lower_bound_x[point_no]);
                    int point_y1 = pix_y + ((int)circle_points_lower_bound_y[point_no]);
                    
                    int point_x2 = pix_x + ((int)circle_points_upper_bound_x[point_no]);
                    int point_y2 = pix_y + ((int)circle_points_upper_bound_y[point_no]);
                    
                    int pixel_arr_idx2 = (int) ((point_y2 * movie_frame_bytes_per_row) + (point_x2 * 4));
                    
                    if (   (point_x1 >= 0) && (point_x1 < image_width)
                        && (point_y1 >= 0) && (point_y1 < image_height)
                        && (point_x2 >= 0) && (point_x2 < image_width)
                        && (point_y2 >= 0) && (point_y2 < image_height))
                    {
                        int pixel_arr_idx1 = (int) ((point_y1 * movie_frame_bytes_per_row) + (point_x1 * 4));
                        red1   = pix_arr[pixel_arr_idx1 + 2];
                        green1 = pix_arr[pixel_arr_idx1 + 1];
                        blue1  = pix_arr[pixel_arr_idx1];
                        gray1  = (red1 + green1 + blue1) / 3;     // small circle intensity
                        
                        red2   = pix_arr[pixel_arr_idx2 + 2];
                        green2 = pix_arr[pixel_arr_idx2 + 1];
                        blue2  = pix_arr[pixel_arr_idx2];
                        gray2  = (red2 + green2 + blue2) / 3;     // large circle intensity
                        
                        int red_diff   = abs(red2 - red1);
                        int green_diff = abs(green2 - green1);
                        int blue_diff  = abs(blue2 - blue1);
                        // int gray_diff  = abs(gray2 - gray1);
                        
                        // if (gray_diff > contrast_threshold)
                        if (   (red_diff   > contrast_threshold)
                            || (green_diff > contrast_threshold)
                            || (blue_diff  > contrast_threshold))
                        {
                            pair_count += 2;
                        }
                    }

                    
                    /*x
                    int small_circle_point_x = pix_x + ((int) circle_points_lower_bound_x[point_no]);
                    int small_circle_point_y = pix_y + ((int) circle_points_lower_bound_y[point_no]);
                    
                    int large_circle_point_x = pix_x + ((int) circle_points_upper_bound_x[point_no]);
                    int large_circle_point_y = pix_y + ((int) circle_points_upper_bound_y[point_no]);
                    
                    int pixel_arr_idx = (int) ((small_circle_point_y * movie_frame_bytes_per_row) + (small_circle_point_x * 4));
                    red1   = pix_arr[pixel_arr_idx + 2];
                    green1 = pix_arr[pixel_arr_idx + 1];
                    blue1  = pix_arr[pixel_arr_idx];
                    gray1  = (red1 + green1 + blue1) / 3;
                    
                    pixel_arr_idx = (int) ((large_circle_point_y * movie_frame_bytes_per_row) + (large_circle_point_x * 4));
                    red2   = pix_arr[pixel_arr_idx + 2];
                    green2 = pix_arr[pixel_arr_idx + 1];
                    blue2  = pix_arr[pixel_arr_idx];
                    gray2  = (red2 + green2 + blue2) / 3;
                    
                    if      (gray1 > (gray2 + (3 * contrast_min)))   { pair_count += 3; }   // give more weight to higher contrast
                    else if (gray1 > (gray2 + (2 * contrast_min)))   { pair_count += 2; }
                    else if (gray1 > (gray2 +      contrast_min))    { pair_count += 1; }
                    x*/
                }
                
                if (pair_count > pair_cnt_max)
                {
                    pair_cnt_max = pair_count;
                    center_x_max = pix_x;
                    center_y_max = pix_y;
                    radius1_max  = radius1;
                    // if (pix_y > 900000)
                    // {
                    //     printf("            --3-- -- pair_cnt_max: %d   center_x_max: %d   center_y_max: %d   radius1_max: %5.2f   pix_x: %d   pix_y: %d \n",  pair_cnt_max, center_x_max, center_y_max, radius1_max, pix_x, pix_y);
                    // }
                }
            }
        }
    }
    
    // ball_radius = radius1_max;
    ball_radius_shape_based = radius1_max;
    
    *center_pixel_x = max(0, center_x_max);                 // return value
    *center_pixel_y = max(0, center_y_max);                 // return value
    *center_radius1 = radius1_max + radius_gap;     // return value -- used for display
    
    // prev_center_of_mass_x = *center_pixel_x;
    // prev_center_of_mass_y = *center_pixel_y;
    
    prev_ball_radius = radius1_max;
    
    printf("            --find_center_of_ball-- center_x_max: %d   center_y_max: %d   start_circle_radius: %5.2f  radius1_max: %5.2f  start_pixel_y: %d   search_count: %d\n", center_x_max, center_y_max, start_circle_radius, radius1_max, start_pixel_y, search_count);
}



- (void) find_moving_objects__full_swing:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    int img_half_width = image_width / 2;
    // int half_height = image_height / 2;
    
    int align_shift_x = align_shift[0];     // these are redundant (see img_sect_align)
    int align_shift_y = align_shift[1];
    
    int align_shift_x_curr_pprev = align_shift_curr_pprev[0];     // these are redundant (see img_sect_align_curr_pprev)
    int align_shift_y_curr_pprev = align_shift_curr_pprev[1];
    
    printf("         - find_moving_objects__putt - align_shift_x: %d  align_shift_y: %d  prev_pos_x_max: %d  prev_pos_y_max: %d\n",  align_shift_x, align_shift_y, prev_pos_x_max, prev_pos_y_max);
    [self set_overlay_box :0 :0];       // default position of blue box
    
    // Look for isolated areas where the two images differ:
    
    int box_width = 10; // 20;
    int box_height = 10; // 20;
    
    size_t pixel_arr_idx = 0;
    int red = 0;
    int green = 0;
    int blue = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int red_ave_max = 0;
    int green_ave_max = 0;
    int blue_ave_max = 0;
    
    int step_size = 2; // 4; // 2;
    if (image_width > 1200) { step_size = 4; }
    
    int diff_box = 0;
    int diff_box_ave = 0;
    int diff_box_acc = 0;
    int diff_box_cnt = 0;
    
    int diff_box_curr_pprev = 0;
    
    // int diff_box_left = 0;
    // int diff_box_right = 0;
    // int diff_box_up = 0;
    // int diff_box_down = 0;
    
    // NEED TO MAKE SURE THE align_shift PARAMETERS DON'T LEAD TO INDICES OUT THE IMAGE ARRAYS
    int margin_x = 20; // image_width / 60; // 70;
    int margin_y_top    = image_height / 3; // 40; // 20;
    int margin_y_bottom = image_height / 40; // 40; // 20;
    
    int red_acc = 0;
    int green_acc = 0;
    int blue_acc = 0;
    
    int score = 0;
    int score_max = -999999;
    int pos_x_max = 0;
    int pos_y_max = 0;
    
    int box_step_size = 2;
    
    int color_score = 0;
    
    int box_diff_threshold = 200; // 200; // 300; // 160; // 200; // 250; // 280;
    
    for (int x_loop = margin_x; x_loop < ((image_width - box_width) - margin_x); x_loop += step_size)
    {
        for (int y_loop = margin_y_top; y_loop < ((image_height - box_height) - margin_y_bottom); y_loop += step_size)
        {
            int x = x_loop;
            int y = y_loop;
            
            // DEBUGGING:
            // x = 545;
            // y = 245;
            
            // Compare prev_img with pprev_img.
            diff_box = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
            
            // if (diff_box > 100)   { printf("      --- putt - diff_box: %d \n", diff_box); }
            
            // Make sure the difference is not due to image shift:
            /*
             if (diff_box > box_diff_threshold)
             {
             int diff_box_verify = [self verify_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
             if (diff_box_verify < diff_box)
             {
             diff_box = diff_box_verify;
             }
             }
             */
            
            diff_box_acc += diff_box;
            diff_box_cnt++;
            
            if (diff_box > box_diff_threshold)    // x, y position is a candidate for moving object
            {
                //            printf("         --- baseball - diff_box: %d   diff_box_threshold: %d \n",  diff_box, box_diff_threshold);
                // Compare curr_img with pprev_img (difference should be close to zero).
                // WE SHOULD USE pix_arr (prev_img) AS REFERENCE AND APPLY align shift TO curr_img (align_shift_prev_curr = alin_shift_prev_pprev minus align_shift_curr_pprev
                //          diff_box_curr_pprev = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :curr_img :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                
                if (true) // (diff_box_curr_pprev < 50) // 50)  // in super slow moation we cannot use this (ball moves to slow)
                {
                    // Check if neighboring 10x10 boxes show a difference
                    // int box_diff_threshold_2 = box_diff_threshold / 2;
                    // int box_diff_threshold_2 = box_diff_threshold - (box_diff_threshold / 3);
                    // int box_diff_threshold_2 = 0;
                    // int x_left = x - box_width;
                    //x diff_box_left = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    // diff_box_left = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    
                    // if (diff_box_left > box_diff_threshold_2)
                    if (true)
                    {
                        // int x_right = x + box_width;
                        // diff_box_right = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_right :y];
                        // diff_box_right = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_right :y];
                        
                        if (true) // (diff_box_right > box_diff_threshold_2)
                        {
                            // int y_up = y - box_height;
                            // diff_box_up = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y_up];
                            // diff_box_up = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y_up];
                            
                            if (true) // (diff_box_up > box_diff_threshold_2)
                            {
                                // int y_down = y + box_height;
                                // diff_box_down = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y_down];
                                // diff_box_down = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y_down];
                                
                                if (true) // (diff_box_down > box_diff_threshold_2)
                                {
                                    // Check color
                                    red_acc = 0;
                                    green_acc = 0;
                                    blue_acc = 0;
                                    int cnt2 = 0;
                                    for (int bx = 0; bx < box_width; bx++)
                                    {
                                        for (int by = 0; by < box_height; by++)
                                        {
                                            pixel_arr_idx = ((y + by) * bytesPerRow) + ((x + bx) * 4);
                                            red   = pix_arr[pixel_arr_idx + 2];
                                            green = pix_arr[pixel_arr_idx + 1];
                                            blue  = pix_arr[pixel_arr_idx];
                                            
                                            red_acc += red;
                                            green_acc += green;
                                            blue_acc += blue;
                                            
                                            cnt2++;
                                        }
                                    }
                                    red_ave   = red_acc / cnt2;
                                    green_ave = green_acc / cnt2;
                                    blue_ave  = blue_acc / cnt2;
                                    // if ([self is_yellow:red_ave :green_ave :blue_ave])
                                    // if ([self is_light_color :red_ave :green_ave :blue_ave])
                                    // if ([self is_white_color :red_ave :green_ave :blue_ave])
                                    if ([self is_white_color_putt :red_ave :green_ave :blue_ave])
                                    // if (true)
                                    {
                                        // printf("      --- putt - passed is_white_color - red_ave: %d  green_ave: %d  blue_ave: %d \n", red_ave, green_ave, blue_ave);
                                        int color_diff = 0;
                                        if (obj_color_red != -1)    // colors are valid
                                        {
                                            color_diff = (red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue);
                                        }
                                        
                                        // printf("               red_ave: %d   obj_color_red: %d      green_ave: %d   obj_color_green: %d      blue_ave: %d   obj_color_blue: %d \n",  red_ave, obj_color_red, green_ave, obj_color_green, blue_ave, obj_color_blue);
                                        
                                        // if (color_diff < 120) // 170)
                                        if (true)
                                        {
                                            // Check if the obj frame is fixed:
                                            int obj_frame_diff = [self compute_object_frame_diff :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                            
                                            // if (obj_frame_diff < 40) // 80) // 100) // 150) // 200)
                                            // if (obj_frame_diff < 150)
                                            if (obj_frame_diff < 180)
                                            // if (true)
                                            {
                                                // Identify set of pixels that differ and check if they fit into an octagon; then check if that shape and color appear the marked location in the previous frame:
                                                // [self identify_2d_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                                
                                                color_score = 100 - ((red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue));
                                                
                                                // Check how close this position is to the previous position:
                                                // int displacement_score = 100;
                                                int direction_consistency_score = 100.0f;
                                                
                                                if (frame_no > 10)
                                                {
                                                    float prev_delta_x = prev_pos_x_max - pprev_pos_x_max;
                                                    float prev_delta_y = prev_pos_y_max - pprev_pos_y_max;
                                                    float delta_x = x - prev_pos_x_max;
                                                    float delta_y = y - prev_pos_y_max;
                                                    
                                                    // This difference vector should be small:
                                                    float diff_x = delta_x - prev_delta_x;
                                                    float diff_y = delta_y - prev_delta_y;
                                                    
                                                    float diff_magnitude = sqrt(diff_x * diff_x + diff_y * diff_y);
                                                    
                                                    // diff_magnitude should be less than 50% of delta_magnitude
                                                    float delta_magnitude = sqrt(delta_x * delta_x + delta_y * delta_y);
                                                    
                                                    float direction_change_threshold = 0.5f * delta_magnitude;
                                                    
                                                    if (diff_magnitude > direction_change_threshold)
                                                    {
                                                        direction_consistency_score = -1000;      // penalize direction change
                                                    }
                                                    
                                                    //x float delta_x = fabs(prev_pos_x_max - x);
                                                    //x float delta_y = fabs(prev_pos_y_max - y);
                                                    //x float displacement = sqrt(delta_x * delta_x + delta_y * delta_y);
                                                    //x displacement_score -= ((int) displacement);
                                                    
                                                    //x if (displacement > 110) { displacement_score = -1000; }   // temp for testing (discount any postion where the displacement is > 110 pixels)
                                                }
                                                
                                                // score = diff_box - obj_frame_diff;
                                                // score = (diff_box - diff_box_curr_pprev) + displacement_score;
                                                score = (diff_box - diff_box_curr_pprev) + direction_consistency_score;
                                                //      score += (red_ave + green_ave + blue_ave) / 8;     // the ball is a light color object
                                                
                                                printf("         diff_box: %d  at x: %d  y: %d  obj_frame_diff: %d   diff_box_curr_pprev: %d   score: %d   color_score: %d   color_diff: %d   direction_consistency_score: %d \n",  diff_box, x, y, obj_frame_diff, diff_box_curr_pprev, score, color_score, color_diff, direction_consistency_score);
                                                printf("            - red_ave: %d   green_ave: %d   blue_ave: %d \n",  red_ave, green_ave, blue_ave);
                                                
                                                // score += color_score;
                                                
                                                if (score > score_max)
                                                {
                                                    score_max = score;
                                                    pos_x_max = x;
                                                    pos_y_max = y;
                                                    
                                                    red_ave_max = red_ave;
                                                    green_ave_max = green_ave;
                                                    blue_ave_max = blue_ave;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    int obj_center = 0;
    float obj_angle = 0.0f;
    if ((pos_x_max != 0) && (pos_y_max != 0))
    {
        obj_center = [self find_center_of_moving_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :pos_x_max :pos_y_max];
        // obj_angle  = [self find_orientation_of_obj :frame_no :obj_center];     // don't rotate the square for full swing
    }
    int obj_center_x = obj_center / 1000000;
    int obj_center_y = obj_center % 1000000;
    printf("         ---< putt - object center - x: %d  y: %d  obj_angle: %2.2f \n",  obj_center_x, obj_center_y, obj_angle);
    
    if (obj_center_x != 0) // (sharpness > 1.0f)
    {
        obj_color_red   = red_ave_max;
        obj_color_green = green_ave_max;
        obj_color_blue  = blue_ave_max;
        
        printf("         --- putt - red_ave_max: %d  green_ave_max: %d  blue_ave_max: %d \n",  red_ave_max, green_ave_max, blue_ave_max);
        
        // Compute speed:
        if (   //x ((! (sport == 30)) || (frame_no > 40))        // temporary for demo (baseball?)   --  DON'T NEED THIS, THIS FUNCTION IS ONLY FOR PUTT
               (    (true) // (! (object_action_path_state >= 90))                                               // not past point of no return (otherwise cancel speed computation)
                ||  (true))) // ((fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))))     // OR moving outwards
        {
            float obj_radius = 8.0f; // 11.0f; // 25.0f; // 17.0f; // 13.16f;                    // pixels
            // if (ball_radius > 1.0f)
            // {
            //     obj_radius = ball_radius;                 // pixels
            // }
            float obj_diameter = 2 * obj_radius;          // pixels
            // float frame_rate = 30;                     // frames / sec
            float frame_rate = (float) (video_fps / fps_reduction_factor);                 // frames / sec
            float time_per_frame = 1.0f / frame_rate;     // sec
            //x float ball_diameter = 0.075;                  // meters (baseball diameter)
            float ball_diameter = 0.047;                      // meters -- golf ball diametert 1.68 inches (4,27 cm)
            float meters_per_pixel = ball_diameter / obj_diameter;   // meters
            
            //x float delta_x = prev_pos_x_max - pos_x_max;
            //x float delta_y = prev_pos_y_max - pos_y_max;
            float prev_delta_x = (float) (prev_pos_x_max - pprev_pos_x_max);
            // float prev_delta_y = prev_pos_y_max - pprev_pos_y_max;
            float delta_x = float(pos_x_max - prev_pos_x_max);
            float delta_y = float(pos_y_max - prev_pos_y_max);
            
            float distance_traveled_in_pixels = 0.0f;
            if ((prev_pos_x_max != 0) && (prev_pos_y_max != 0))    // if previous position is valid
            {
                distance_traveled_in_pixels = sqrtf(delta_x * delta_x + delta_y * delta_y);
                
                float distance_traveled_in_meters = distance_traveled_in_pixels * meters_per_pixel;
                
                float speed = distance_traveled_in_meters / time_per_frame;    // meters / sec
                ball_speed_mph = speed * 2.2369f;   // convert m/s in mph
                
                printf("      full swing -- speed: %2.2f   distance_traveled_in_meters: %2.2f   distance_traveled_in_pixels: %2.2f   frame_rate: %2.2f   time_per_frame: %2.2f   prev_delta_x: %2.2f   delta_x: %2.2f   delta_y: %2.2f \n",  speed, distance_traveled_in_meters, distance_traveled_in_pixels, frame_rate, time_per_frame, prev_delta_x, delta_x, delta_y);
                printf("      fabs(delta_x - prev_delta_x): %2.2f     (0.7f * fabs(prev_delta_x): %2.2f    ( fabs(delta_x - prev_delta_x) < (0.7f * fabs(prev_delta_x))): %d \n",  fabs(delta_x - prev_delta_x),  (0.7f * fabs(prev_delta_x)),  ( fabs(delta_x - prev_delta_x) < (0.7f * fabs(prev_delta_x))));
                
                // Check if there is a large increase in horizontal speed (to determine impact frame):
                float increased_speed = prev_delta_x * 1.3f;
               
                // Track object_action_path_state:
                if (   (true) // (fabs(delta_x) > (3.0 * fabs(delta_y)))                                       // mostly horizontal movement
                    // && (delta_y > 0.0f)                                                                     // ball should move upwards
                    && (ball_speed_mph > 40.0f) // 40.0f)                                                                // require minimum speed
                    && (   (delta_x > increased_speed)                                                         // check for suddon increase in speed
                        || ((impact_frame_no > 0) && (frame_no > impact_frame_no)))                             // unless impact_frame_no is already set and frame_no is past impact
                    && ( fabs(delta_x - prev_delta_x) < (0.9f * fabs(prev_delta_x)))                           // there must no reversal in direction
                      // && (frame_no >= 50)) // 53))                                                               // TEMPORARY HACK (SHOULD USE NEXT FRAME AFTER FIRST UPWARDS MOTION)
                      // &&  (fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))       // moving outwards
                    )
                {
                    object_action_path_state = 60;
                    
                    // int large_displacement = img_half_width / (video_fps / 10.0f);
                    // int large_displacement = 60;                                                      // use for putt (this funcion is for putt only)
                    
                    // if (   (fabs(delta_x) > (large_displacement - 10))                                // moving at certain speed
                    //     && (fabs(delta_x) < (large_displacement + 10)))
                    if (true)
                    {
                        object_action_path_state = 90;                                                // point of no return
                        
                        if ((impact_frame_no > 10) && (frame_no > (impact_frame_no + 1)))             // make sure impact_frame_no is set
                        {
                            if (ball_speed_mph > max_ball_speed_mph)
                            {
                                max_ball_speed_mph = ball_speed_mph;
                            }
                        }
 
                        if (impact_frame_no == 0)                                                     // impact most likely occurred right before high horizontal velocity is observed
                        {
                            int synch_factor = -1; // -5; // -8; // -16;
                            impact_frame_no = frame_no + synch_factor;
                        }
                        
                        if ((max_clubhead_speed_mph > 0) && (impact_frame_no > 0) && (frame_no > impact_frame_no))
                        {
                            impact_ratio = max_ball_speed_mph / max_clubhead_speed_mph;   // smash factor
                        }
                   }
                }
                
                // Determine swing speed (club head speed):
                // printf("      ~}}~~~ frame_no: %d   impact_frame_no: %d   max_ball_speed_mph: %5.2f   max_swing_speed_mph: %5.2f \n", frame_no, impact_frame_no, max_ball_speed_mph, max_swing_speed_mph);
                if (frame_no <= impact_frame_no)   // this is applied to phase 2 only (impact_frame_no is set)
                {
                    clubhead_speed_mph = ball_speed_mph;          // for display as "Head Speed"
                    if (ball_speed_mph > max_swing_speed_mph)
                    {
                        max_swing_speed_mph = ball_speed_mph;
                        max_clubhead_speed_mph = ball_speed_mph;
                    }
                }
            }
            else { ball_speed_mph = 0.0f; }
        }
        
        // printf("      ~}}~ pos_x_max: %d   pos_y_max: %d   prev_pos_x_max: %d   prev_pos_y_max: %d   max_ball_speed_mph: %5.2f   max_swing_speed_mph: %5.2f \n", pos_x_max, pos_y_max, prev_pos_x_max, prev_pos_y_max, max_ball_speed_mph, max_swing_speed_mph);
        pprev_pos_x_max = prev_pos_x_max;
        pprev_pos_y_max = prev_pos_y_max;
        
        prev_pos_x_max = pos_x_max;
        prev_pos_y_max = pos_y_max;
    }
    else
    {
        prev_pos_x_max = 0;
        prev_pos_y_max = 0;
        
        pprev_pos_x_max = 0;
        pprev_pos_y_max = 0;
        
        ball_speed_mph = 0.0f;
    }
    
    
    // DEBUGGING:
    // obj_center_x = 491;     // frame 10
    // obj_center_y = 241;
    // obj_center_x = 545; //  frame 11
    // obj_center_y = 245;
    
    [self set_overlay_box :obj_center_x :obj_center_y];                                                               // Set position of red box
    
    if ((obj_center_x == 0) && (obj_center_y == 0))      // The object location is undefined
    {
        obj_rot_angle  = 0.0f;                            // reset the rotation angle so that the box is straight when the ball it hit
        obj_rot_angle1 = 0.0f;                            // reset the rotation angle so that the box is straight when the ball it hit
        obj_rot_angle2 = 0.0f;                            // reset the rotation angle so that the box is straight when the ball it hit
        delta_rotation_angle = 0.0f;
        // obj_rot_ref_frame = frame_no;
    }
    
    
    diff_box_ave = diff_box_acc / diff_box_cnt;                                                                       // the average is approx. 16
    
    // printf("         === frame_no: %d   diff_box_ave: %d \n", frame_no, diff_box_ave);
}





- (void) find_moving_objects__jumps:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    // int img_half_width = image_width / 2;
    // int half_height = image_height / 2;
    
    int align_shift_x = align_shift[0];     // these are redundant (see img_sect_align)
    int align_shift_y = align_shift[1];
    
    int align_shift_x_curr_pprev = align_shift_curr_pprev[0];     // these are redundant (see img_sect_align_curr_pprev)
    int align_shift_y_curr_pprev = align_shift_curr_pprev[1];
    
    printf("         - find_moving_objects__jumps - align_shift_x: %d  align_shift_y: %d  prev_pos_x_max: %d  prev_pos_y_max: %d\n",  align_shift_x, align_shift_y, prev_pos_x_max, prev_pos_y_max);
    [self set_overlay_box :0 :0];       // default position of blue box
    
    // Look for isolated areas where the two images differ:
    
    int box_width  = 20; // 30; // 40; // 50; // 10; // 20;
    int box_height = 20; // 30; // 40; // 50; // 10; // 20;
    
    size_t pixel_arr_idx = 0;
    int red = 0;
    int green = 0;
    int blue = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int red_ave_max = 0;
    int green_ave_max = 0;
    int blue_ave_max = 0;
    
    int step_size = 4; // 2;
    
    int diff_box = 0;
    // int diff_box_ave = 0;
    // int diff_box_acc = 0;
    // int diff_box_cnt = 0;
    
    int diff_box_curr_pprev = 0;
    
    // int diff_box_left = 0;
    // int diff_box_right = 0;
    // int diff_box_up = 0;
    // int diff_box_down = 0;
    
    // NEED TO MAKE SURE THE align_shift PARAMETERS DON'T LEAD TO INDICES OUT THE IMAGE ARRAYS
    int margin_x = 20; // 50; // 150; //  image_width / 60; // 70;
    int margin_y_top = 50; // 150; // 200; // 20; //  image_height / 40; // 40; // 20;
    int margin_y_bottom = 10;
    
    int red_acc = 0;
    int green_acc = 0;
    int blue_acc = 0;
    
    int score = 0;
    int score_max = -999999;
    int pos_x_max = 0;
    int pos_y_max = 0;
    
    int box_step_size = 2;
    
    int color_score = 0;
    
    int box_diff_threshold = 100; // 80; // 60; // 40; // 50; // 50; // 70; // 300;
    
    float center_of_mass_acc_x = 0.0f;
    float center_of_mass_acc_y = 0.0f;
    int   center_of_mass_cnt = 0;
    float center_of_mass_x = 0.0f;
    float center_of_mass_y = 0.0f;
    
    for (int x = margin_x; x < ((image_width - box_width) - margin_x); x += step_size)
    {
        for (int y = margin_y_top; y < ((image_height - box_height) - margin_y_bottom); y += step_size)
        {
            // Compare prev_img with pprev_img.
            diff_box = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
            
            // diff_box_acc += diff_box;
            // diff_box_cnt++;
            
            if (diff_box > box_diff_threshold)    // x, y position is a candidate for moving object
            // if (true)
            {
                // printf("         diff_box: %d   diff_box_threshold: %d \n", diff_box, box_diff_threshold);
                // Compare curr_img with pprev_img (difference should be close to zero).
                // WE SHOULD USE pix_arr (prev_img) AS REFERENCE AND APPLY align shift TO curr_img (align_shift_prev_curr = alin_shift_prev_pprev minus align_shift_curr_pprev
                // diff_box_curr_pprev = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :curr_img :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                
                if (true) // (diff_box_curr_pprev < 50) // 50)  // in super slow motion we cannot use this (ball moves to slow)
                {
                    // Check if neighboring 10x10 boxes show a difference
                    // int box_diff_threshold_2 = box_diff_threshold / 2;
                    // int box_diff_threshold_2 = box_diff_threshold - (box_diff_threshold / 3);
                    // int box_diff_threshold_2 = 0;
                    // int x_left = x - box_width;
                    //x diff_box_left = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    // diff_box_left = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x_left :y];
                    
                    // if (diff_box_left > box_diff_threshold_2)
                    if (true)
                    {
                        // Check color
                        red_acc = 0;
                        green_acc = 0;
                        blue_acc = 0;
                        int cnt2 = 0;
                        for (int bx = 0; bx < box_width; bx++)
                        {
                            for (int by = 0; by < box_height; by++)
                            {
                                pixel_arr_idx = ((y + by) * bytesPerRow) + ((x + bx) * 4);
                                red   = pix_arr[pixel_arr_idx + 2];
                                green = pix_arr[pixel_arr_idx + 1];
                                blue  = pix_arr[pixel_arr_idx];
                                
                                red_acc += red;
                                green_acc += green;
                                blue_acc += blue;
                                
                                cnt2++;
                            }
                        }
                        red_ave   = red_acc / cnt2;
                        green_ave = green_acc / cnt2;
                        blue_ave  = blue_acc / cnt2;
                        // if ([self is_white_color :red_ave :green_ave :blue_ave])
                        // if ([self is_black_color :red_ave :green_ave :blue_ave])
                        if (true)
                        {
                            // int color_diff = 0;
                            // if (obj_color_red != -1)    // colors are valid
                            // {
                            //     color_diff = (red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue);
                            // }
                            
                            // printf("               red_ave: %d   obj_color_red: %d      green_ave: %d   obj_color_green: %d      blue_ave: %d   obj_color_blue: %d \n",  red_ave, obj_color_red, green_ave, obj_color_green, blue_ave, obj_color_blue);
                            
                            // if (color_diff < 120) // 170)
                            if (true)
                            {
                                // Check if the obj frame is fixed:
                                // int obj_frame_diff = [self compute_object_frame_diff :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                
                                //                      if (obj_frame_diff < 40) // 80) // 100) // 150) // 200)
                                // if (obj_frame_diff < 100)
                                // if (obj_frame_diff < 100)
                                if (true)
                                {
                                    // Identify set of pixels that differ and check if they fit into an octagon; then check if that shape and color appear the marked location in the previous frame:
                                    // [self identify_2d_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :box_width :box_height :box_step_size :box_diff_threshold :x :y];
                                    
                                    // color_score = 100 - ((red_ave - obj_color_red) + (green_ave - obj_color_green) + (blue_ave - obj_color_blue));
                                    
                                    score = diff_box;
                                    // score = diff_box_curr_pprev;
                                    // score = diff_box - obj_frame_diff;
                                    // score = diff_box - diff_box_curr_pprev;
                                    // score += (red_ave + green_ave + blue_ave) / 8;     // the ball is a light color object
                                    // score = 300 - ((red_ave + green_ave + blue_ave) / 8);
                                    
                                    // printf("         diff_box: %d  at x: %d  y: %d   diff_box_curr_pprev: %d   score: %d   color_score: %d  \n",  diff_box, x, y, diff_box_curr_pprev, score, color_score);
                                    // printf("            - red_ave: %d   green_ave: %d   blue_ave: %d \n",  red_ave, green_ave, blue_ave);
                                    
                                    // score += color_score;
                                    
                                    if (score > score_max)
                                    {
                                        score_max = score;
                                        pos_x_max = x;
                                        pos_y_max = y;
                                        
                                        red_ave_max = red_ave;
                                        green_ave_max = green_ave;
                                        blue_ave_max = blue_ave;
                                    }
                                    
                                    float dist_from_prev_center_of_mass = 0.0f;
                                    float center_of_mass_dist_max = 100; // 60; // 80; // 100; // 60; // 80.0f; // 100.0f;
                                    if (prev_center_of_mass_x != 0.0f)
                                    {
                                        // printf("      @@@---@@@ prev_center_of_mass_x: %5.2f   prev_center_of_mass_y: %5.2f  \n", prev_center_of_mass_x, prev_center_of_mass_y);
                                        // Remove outliers by omitting spots that are far from the previous center of mass
                                        float center_of_mass_delta_x = prev_center_of_mass_x - ((float)x);
                                        float center_of_mass_delta_y = prev_center_of_mass_y - ((float)y);
                                        dist_from_prev_center_of_mass = sqrtf( center_of_mass_delta_x * center_of_mass_delta_x + center_of_mass_delta_y * center_of_mass_delta_y );
                                        // printf("      @@@---@@@ dist_from_prev_center_of_mass: %5.2f   center_of_mass_delta_x: %5.2f   center_of_mass_delta_y: %5.2f   prev_center_of_mass_x\n", dist_from_prev_center_of_mass, center_of_mass_delta_x, center_of_mass_delta_y);
                                    }
                                    if (dist_from_prev_center_of_mass < center_of_mass_dist_max)
                                    {
                                        center_of_mass_acc_x += (float) x;
                                        center_of_mass_acc_y += (float) y;
                                        center_of_mass_cnt++;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    int obj_center = 0;
    // if ((pos_x_max != 0) && (pos_y_max != 0))
    // {
    //     obj_center = [self find_center_of_moving_obj :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x :align_shift_y :img_sect_align :align_shift_x_curr_pprev :align_shift_y_curr_pprev :img_sect_align_curr_pprev :box_width :box_height :box_step_size :box_diff_threshold :pos_x_max :pos_y_max];
    // }
    
    // int obj_center_x = obj_center / 1000000;
    // int obj_center_y = obj_center % 1000000;
    
    if (center_of_mass_cnt > 0)
    {
       center_of_mass_x = center_of_mass_acc_x / ((float) center_of_mass_cnt);
       center_of_mass_y = center_of_mass_acc_y / ((float) center_of_mass_cnt);
    }
    
    // int obj_center_x = pos_x_max;
    // int obj_center_y = pos_y_max;
    int obj_center_x = center_of_mass_x;
    int obj_center_y = center_of_mass_y;
    
    printf("         --- object center - x: %d  y: %d   center_of_mass_cnt: %d   prev_center_of_mass_x: %5.0f   prev_center_of_mass_y: %5.0f \n",  obj_center_x, obj_center_y, center_of_mass_cnt, prev_center_of_mass_x, prev_center_of_mass_y);
    
    prev_center_of_mass_x = center_of_mass_x;
    prev_center_of_mass_y = center_of_mass_y;
    
    if (obj_center_x != 0) // (sharpness > 1.0f)
    {
        obj_color_red   = red_ave_max;
        obj_color_green = green_ave_max;
        obj_color_blue  = blue_ave_max;
        
        
        // Compute speed:
        // if (    (! (object_action_path_state >= 90))                                              // not past point of no return (otherwise cancel speed computation)
        //     ||  ((fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max))))     // OR moving outwards
        if (true)
        {
            float obj_radius = 13.16f;                    // pixels
            if (ball_radius > 1.0f)
            {
                obj_radius = ball_radius;                 // pixels
            }
            float obj_diameter = 2 * obj_radius;          // pixels
            // float frame_rate = 30;                     // frames / sec
            float frame_rate = (float)video_fps;                 // frames / sec
            float time_per_frame = 1.0f / frame_rate;     // sec
            float ball_diameter = 0.075;                  // meters (baseball diameter)
            float meters_per_pixel = ball_diameter / obj_diameter;   // meters
            
            float delta_x = prev_pos_x_max - pos_x_max;
            float delta_y = prev_pos_y_max - pos_y_max;
            float distance_traveled_in_pixels = 0.0f;
            // if ((prev_pos_x_max != 0) && (prev_pos_y_max != 0))    // if previous position is valid
            if (true)
            {
                distance_traveled_in_pixels = sqrtf(delta_x * delta_x + delta_y * delta_y);
                
                float distance_traveled_in_meters = distance_traveled_in_pixels * meters_per_pixel;
                
                float speed = distance_traveled_in_meters / time_per_frame;    // meters / sec
                ball_speed_mph = speed * 2.2369f;   // convert m/s in mph
                if (ball_speed_mph > 20) { ball_speed_mph = 0.0f; }           // discard implausible speeds
                
                printf("      ~~~ speed: %2.2f   distance_traveled_in_meters: %2.2f   distance_traveled_in_pixels: %2.2f   frame_rate: %2.2f   time_per_frame: %2.2f \n",  speed, distance_traveled_in_meters, distance_traveled_in_pixels, frame_rate, time_per_frame);
                
                
                // Track object_action_path_state:
                // if (    (fabs(delta_x) > (3.0 * fabs(delta_y)))                                       // mostly horizontal movement
                //     &&  (fabs(img_half_width - prev_pos_x_max) < fabs(img_half_width - pos_x_max)))   // moving outwards
                if (true)
                {
                    object_action_path_state = 60;
                    
                    // int large_displacement = img_half_width / (video_fps / 10.0f);
                    // int large_displacement = 15;     // use for super slow motion
                    // if (   (fabs(delta_x) > (large_displacement - 10))                                // moving at certain speed
                    //     && (fabs(delta_x) < (large_displacement + 10)))
                    if (true)
                    {
                        object_action_path_state = 90;                                                // point of no return
                        
                        // if (impact_frame_no == 0)                                                     // impact most likely occurred right before high horizontal velocity is observed
                        // {
                        //     int synch_actor = -16;
                        //     impact_frame_no = frame_no + synch_actor;
                        // }
                        
                        if (ball_speed_mph > max_ball_speed_mph)
                        {
                            max_ball_speed_mph = ball_speed_mph;
                        }
                    }
                }
            }
            else { ball_speed_mph = 0.0f; }
        }
        
        printf("      pos_x_max: %d   pos_y_max: %d   prev_pos_x_max: %d   prev_pos_y_max: %d \n", pos_x_max, pos_y_max, prev_pos_x_max, prev_pos_y_max);
        prev_pos_x_max = pos_x_max;
        prev_pos_y_max = pos_y_max;
    }
    else
    {
        prev_pos_x_max = 0;
        prev_pos_y_max = 0;
        
        ball_speed_mph = 0.0f;
    }
    
    
    
    // [self set_overlay_box :(pos_x_max + (box_width / 2)) :(pos_y_max + (box_height / 2))];                         // Set position of blue box
    [self set_overlay_box :obj_center_x :obj_center_y];                                                               // Set position of blue box
    
    // diff_box_ave = diff_box_acc / diff_box_cnt;                                                                       // the average is approx. 16
    
    // printf("         === frame_no: %d   diff_box_ave: %d \n", frame_no, diff_box_ave);
}




- (void) find_interesting_events:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev
{
    if (! activity_started)
    {
        int motion_intensity = [self detect_activity :frame_no :bytesPerRow :pprev_img :prev_img :align_shift :align_shift_curr_pprev :img_sect_align :img_sect_align_curr_pprev];    // detect moving objects
        // printf("      motion_intensity, %d \n",  motion_intensity);
        if (num_valid_motion_intensity_values < motion_intensity_arr_length)
        {
            motion_intensity_arr[num_valid_motion_intensity_values++] = motion_intensity;
        }
        int motion_intensity_threshold = 200;
        // if ((frame_no > 4) && (motion_intensity > motion_intensity_threshold))
        // {
        //     activity_started = true;
        // }
    }
}



- (void) print_motion_intensity_arr
{
    for (int frame_no = 0; frame_no < num_valid_motion_intensity_values; frame_no++)
    {
        printf("      frame_no, %d,  motion_intensity, %d \n",  frame_no, motion_intensity_arr[frame_no]);
    }
}



- (int) find_center_of_moving_obj:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int)align_shift_x :(int)align_shift_y :(signed char *)img_sect_align
                                 :(int)align_shift_x_curr_pprev :(int)align_shift_y_curr_pprev :(signed char *)img_sect_align_curr_pprev :(int)box_width :(int)box_height :(int)box_step_size :(int)box_diff_threshold :(int)x :(int)y
{
    int image_height = movie_frame_height;
    
    int obj_center_coords = 0;
    
    int pixel_diff_threshold_pprev = 80; // 70;    // for tennis
    int pixel_diff_threshold_curr = 80;
    if (sport == 20)   // ice hockey
    {
        pixel_diff_threshold_pprev = 35; // 40; // 40; // 70;
        pixel_diff_threshold_curr  = 35;
    }
    if (sport == 50)  // putt
    {
        pixel_diff_threshold_pprev  = 80; // 50; // 35;
        pixel_diff_threshold_curr  = 1; // 35;
    }
    
    int red0 = 0;
    int green0 = 0;
    int blue0 = 0;
    
    int red1 = 0;
    int green1 = 0;
    int blue1 = 0;
    
    int red2 = 0;
    int green2 = 0;
    int blue2 = 0;
    
    // Determine the set of pixels that show a difference between the current image and both: the previous image and the next image:
    
    int box_width2 = 50;    // use larger box that completely includes obj
    int box_height2 = box_width2;
    if (sport == 20)        // ice hockey
    {
        box_width2 = 200; // 160; // 100; // 120; // 100;
        box_height2 = 50;
    }
    else if (sport == 50)        // ice hockey
    {
        box_width2  = 50;
        box_height2 = 50;
    }
    
    int box_radius_increase_x = (box_width2 - box_width) / 2;
    int box_radius_increase_y = (box_height2 - box_height) / 2;
    int x2 = x - box_radius_increase_x;    // scan larger box
    int y2 = y - box_radius_increase_y;    // scan larger box
    
    int pixel_diff_prev_pprev = 0;
    int pixel_diff_prev_curr  = 0;
    
    int arr_length = image_height * bytesPerRow - 2;    // subtract 2 because 1 and 2 is added
    
    int center_pos_x_acc = 0;
    int center_pos_y_acc = 0;
    int center_pos_x = 0;
    int center_pos_y = 0;

    int cnt2 = 0;
    int cnt3 = 0;
    
    int pixel_arr_idx = 0;
    int prev_pixel_arr_idx = 0;
    int curr_img_idx = 0;

    for (int bx = 0; bx < box_width2; bx++)
    {
        for (int by = 0; by < box_height2; by++)
        {
            // Compute shift of curr_img relative to prev_img (pix_arr):
            //      align_shift_prev_curr = align_shift_prev_pprev minus align_shift_curr_pprev
            //      align_shift_prev_pprev = align_shift_x/y
            //      align_shift_curr_pprev = align_shift_curr_pprev_x/y
            int align_shift_prev_curr_x = align_shift_x - align_shift_x_curr_pprev;
            int align_shift_prev_curr_y = align_shift_y - align_shift_y_curr_pprev;
            curr_img_idx = (((y2 + align_shift_prev_curr_y) + by) * bytesPerRow) + (((x2 + align_shift_prev_curr_x) + bx) * 4);
            if ((curr_img_idx >= 0) && (curr_img_idx < arr_length))
            {
                red0   = curr_img[curr_img_idx + 2];
                green0 = curr_img[curr_img_idx + 1];
                blue0  = curr_img[curr_img_idx];
                
                pixel_arr_idx = ((y2 + by) * bytesPerRow) + ((x2 + bx) * 4);
                if ((pixel_arr_idx >= 0) && (pixel_arr_idx < arr_length))
                {
                    red1   = pix_arr[pixel_arr_idx + 2];
                    green1 = pix_arr[pixel_arr_idx + 1];
                    blue1  = pix_arr[pixel_arr_idx];
                    
                    prev_pixel_arr_idx = (((y2 + align_shift_y) + by) * bytesPerRow) + (((x2 + align_shift_x) + bx) * 4);
                    
                    if ((prev_pixel_arr_idx >= 0) && (prev_pixel_arr_idx < arr_length))
                    {
                        red2   = prev_pix_arr[prev_pixel_arr_idx + 2];
                        green2 = prev_pix_arr[prev_pixel_arr_idx + 1];
                        blue2  = prev_pix_arr[prev_pixel_arr_idx];
                        
                        pixel_diff_prev_pprev = abs(red1 - red2) + abs(green1 - green2) + abs(blue1 - blue2);
                        pixel_diff_prev_curr  = abs(red1 - red0) + abs(green1 - green0) + abs(blue1 - blue0);
                        
                        // There should be a difference between pix_arr (prev_img) and the image immediately preceeding and following it.
                        if (   (pixel_diff_prev_pprev > pixel_diff_threshold_pprev)       // difference between prev_img (pix_arr) and pprev_img (prev_pix_arr)
                            && (pixel_diff_prev_curr  > pixel_diff_threshold_curr))      // difference between prev_img (pix_arr) and curr_img
                        {
                            center_pos_x_acc += x2 + bx;
                            center_pos_y_acc += y2 + by;
                            
                            cnt2++;
                        }
                        else { cnt3++; }
                    }
                }
            }
        }
    }
    
    if (cnt2 > 0)
    {
        center_pos_x = center_pos_x_acc / cnt2;
        center_pos_y = center_pos_y_acc / cnt2;
    }
    
    
    
    // Compute object radius (area of circle equals pi squared times radius):
    float obj_radius = sqrtf( ((float)cnt2) / 3.14159f );   // use M_PI
    
    // printf("         --= object center - x: %d  y: %d    number of differing pixels: %d    number of similar pixels: %d    obj_radius: %2.2f \n",  center_pos_x, center_pos_y, cnt2, cnt3, obj_radius);
    
    
    
    // Compute object sharpness (check how many pixels with difference are inside the circle) - also compute color:
    int cnt4 = 0;
    int cnt5 = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int red_acc = 0;
    int green_acc = 0;
    int blue_acc = 0;
    
    float obj_rad_squared = (obj_radius * obj_radius) + 2;   // add 2 to account for fuzzy image
    for (int bx = 0; bx < box_width2; bx++)
    {
        for (int by = 0; by < box_height2; by++)
        {
            // Compute shift of curr_img relative to prev_img (pix_arr):
            //      align_shift_prev_curr = align_shift_prev_pprev minus align_shift_curr_pprev
            //      align_shift_prev_pprev = align_shift_x/y
            //      align_shift_curr_pprev = align_shift_curr_pprev_x/y
            int align_shift_prev_curr_x = align_shift_x - align_shift_x_curr_pprev;
            int align_shift_prev_curr_y = align_shift_y - align_shift_y_curr_pprev;
            curr_img_idx = (int) ((((y2 + align_shift_prev_curr_y) + by) * bytesPerRow) + (((x2 + align_shift_prev_curr_x) + bx) * 4));
            
            if ((curr_img_idx >= 0) && (curr_img_idx < arr_length))
            {
                red0   = curr_img[curr_img_idx + 2];
                green0 = curr_img[curr_img_idx + 1];
                blue0  = curr_img[curr_img_idx];
                
                pixel_arr_idx = (int) (((y2 + by) * bytesPerRow) + ((x2 + bx) * 4));
                
                if ((pixel_arr_idx >= 0) && (curr_img_idx < arr_length))
                {
                    red1   = pix_arr[pixel_arr_idx + 2];
                    green1 = pix_arr[pixel_arr_idx + 1];
                    blue1  = pix_arr[pixel_arr_idx];
                    
                    prev_pixel_arr_idx = (int) ((((y2 + align_shift_y) + by) * bytesPerRow) + (((x2 + align_shift_x) + bx) * 4));
                    
                    if ((prev_pixel_arr_idx >= 0) && (prev_pixel_arr_idx < arr_length))
                    {
                        red2   = prev_pix_arr[prev_pixel_arr_idx + 2];
                        green2 = prev_pix_arr[prev_pixel_arr_idx + 1];
                        blue2  = prev_pix_arr[prev_pixel_arr_idx];
                        
                        pixel_diff_prev_pprev = abs(red1 - red2) + abs(green1 - green2) + abs(blue1 - blue2);
                        pixel_diff_prev_curr  = abs(red1 - red0) + abs(green1 - green0) + abs(blue1 - blue0);
                        
                        // There should be a difference between pix_arr (prev_img) and the image immediately preceeding and folling it.
                        if (   (pixel_diff_prev_pprev > pixel_diff_threshold_pprev)       // difference between prev_img (pix_arr) and pprev_img (prev_pix_arr)
                            && (pixel_diff_prev_curr  > pixel_diff_threshold_curr))      // difference between prev_img (pix_arr) and curr_img
                        {
                            int delta_x = (x2 + bx) - center_pos_x;
                            int delta_y = (y2 + by) - center_pos_y;
                            
                            float dist = delta_x * delta_x + delta_y * delta_y;
                            
                            if (dist < obj_rad_squared)
                            {
                                red_acc   += red1;
                                green_acc += green1;
                                blue_acc  += blue1;
                                cnt4++;
                            }
                            else { cnt5++; }
                        }
                    }
                }
            }
        }
    }
    
    float sharpness = -1.0f;
    if (cnt5 > 0)
    {
        sharpness = ((float)cnt4) / ((float)cnt5);
    }
    
    if (cnt4 > 0)
    {
        red_ave   = red_acc   / cnt4;
        green_ave = green_acc / cnt4;
        blue_ave  = blue_acc  / cnt4;
    }

    printf("         --- object center - x: %d  y: %d    number of differing pixels: %d    number of similar pixels: %d    obj_radius: %2.2f   pixels_inside: %d   pixels_outside: %d   sharpness: %2.2f \n",  center_pos_x, center_pos_y, cnt2, cnt3, obj_radius, cnt4, cnt5, sharpness);
    printf("         --- object color - red, green, blue: %d, %d, %d \n",  red_ave, green_ave, blue_ave);
    
    
    float sharpness_threshold = 0.8f;    // 1.0f   // tennis
    if (    (sport == 20)                // ice hockey
        ||  (sport == 30)                // baseball
        ||  (sport == 40)                // trampoline
        ||  (sport == 50)
       )
    {
        sharpness_threshold = -2.0f;     // disabling this condition for now
    }
    
    if (sharpness >= sharpness_threshold)
    {
        obj_center_coords = center_pos_x * 1000000 + center_pos_y;
        
        // obj_color_red   = red_ave;
        // obj_color_green = green_ave;
        // obj_color_blue  = blue_ave;
    }
    
    if (sharpness > 6) // 10)       // SHOULD USE THE MAXIMUM SHARPNESS ABOVE THIS THRESHOLD
    {
        ball_radius = obj_radius;   // this is only correct for fast moving objects
    }

    return obj_center_coords;
}




- (float) find_orientation_of_obj :(unsigned char*)pix_arr :(int)frame_no :(int)obj_center
{
    float angle = 0.0f;
    float prev_ball_rotation_angle  = obj_rot_angle;
    float prev_ball_rotation_angle1 = obj_rot_angle1;   // primary ball rotation angle
    float prev_ball_rotation_angle2 = obj_rot_angle2;   // secondary ball rotation angle
    float prev_delta_rotation_angle1 = delta_rotation_angle;
    
    
    /*
    // This section is temporary until to ball orientation is properly computed:
    // if (frame_no >= 18)
    if (frame_no >= obj_rot_ref_frame)
    {
        // float rot_angle1 = (float) frame_no;   // temporary for testing
        float delta_rotation = 1.9f;
        if (obj_rot_ref_frame == 18)     // This demo 1
        {
            if      (frame_no == obj_rot_ref_frame + 0) { delta_rotation = 0.50f; }
            else if (frame_no == obj_rot_ref_frame + 1) { delta_rotation = 1.80f; }
            else if (frame_no == obj_rot_ref_frame + 2) { delta_rotation = 1.90f; }
            else if (frame_no == obj_rot_ref_frame + 3) { delta_rotation = 1.91f; }
            else if (frame_no == obj_rot_ref_frame + 4) { delta_rotation = 1.89f; }
            else if (frame_no == obj_rot_ref_frame + 5) { delta_rotation = 1.905f; }
            else if (frame_no == obj_rot_ref_frame + 6) { delta_rotation = 1.895f; }
        }
        else if (obj_rot_ref_frame == 35)    // This is demo 2
        {
            if      (frame_no == obj_rot_ref_frame + 0) { delta_rotation = 0.30f; }
            else if (frame_no == obj_rot_ref_frame + 1) { delta_rotation = 0.79f; }
            else if (frame_no == obj_rot_ref_frame + 2) { delta_rotation = 1.75f; }
            else if (frame_no == obj_rot_ref_frame + 3) { delta_rotation = 1.69f; }
            else if (frame_no == obj_rot_ref_frame + 4) { delta_rotation = 1.76f; }
            else if (frame_no == obj_rot_ref_frame + 5) { delta_rotation = 1.81f; }
            else if (frame_no == obj_rot_ref_frame + 6) { delta_rotation = 1.82f; }
        }
        
        float rot_angle1 = prev_ball_rotation_angle + delta_rotation;
        [_draw_field2 set_rotation_angle:rot_angle1];
        
        float delta_rotation_angle = rot_angle1 - prev_ball_rotation_angle;
        float time_per_frame = 1.0f / video_fps;
        ball_rpm = (int) (((delta_rotation_angle / 3.14159f) / time_per_frame) * 60.0f);    // multiply by 60 to get from seconds to minutes
        
        if (ball_rpm > max_ball_rpm) { max_ball_rpm = ball_rpm; }
        
        printf("      --- obj_rot_ref_frame: %d  prev_ball_rotation_angle: %5.2f  delta_rotation_angle: %5.2f  ball_rpm: %d \n",  obj_rot_ref_frame, prev_ball_rotation_angle, delta_rotation_angle, ball_rpm);
        obj_rot_angle = rot_angle1;    // overwritten below
    }
    */
    
    
    // Detect orientation of ball (assuming there is a black line drawn on the ball):
    //    Use center of ball to focus on a minimal rectanglar area that includes the ball.
    //    Search for a black line (drawn as marker on the ball).
    //       - Project 3 parallel lines (center line should be darker than the neighboring two lines.
    //       - Determine the darkness of each half of each line separately to ensure it is a line (both halfs a each line need to be consistent).
    //    Use the rotation angles of one of the two demos above as a guide: search for rotation angles that are close to the expected rotation angles (as seen in the two demos).
    
    int obj_center_x = obj_center / 1000000;
    int obj_center_y = obj_center % 1000000;
    printf("         -<>- putt - compute ball orientation - object center - x: %d  y: %d  ball_radius: %2.2f \n",  obj_center_x, obj_center_y, ball_radius);

    float pi = 3.14159;  // use M_PI
   
    /*
    // Define the three projection lines (examining each orientation):
    float angle_step_size = pi / 80.0f;
    for (float orientation_angle = 0.0f;  orientation_angle < pi;  orientation_angle += angle_step_size)
    {
        // printf("              orientation_angle: %5.2f \n", orientation_angle);
        // Define line through center at given angle (angle starts at horizontal line and increases clockwise):
        // Define vector from center to end point:
        
        // cos(alpha) = half_line_x / ball_radius
        // sin(alpha) = half_line_y / ball_radius
        float half_line1_x = cosf(orientation_angle) * ball_radius;
        float half_line1_y = sinf(orientation_angle) * ball_radius;
        // This line is defined by the two points: (object_center_x, object_center_y) and (half_line1_x, half_line1_y)
        
        // The opposite line:
        float half_line2_x = -half_line1_x;
        float half_line2_y = -half_line2_y;
        // This line is defined by the two points: (object_center_x, object_center_y) and (half_line2_x, half_line2_y)
        
        // Now find pixels on these two half lines:
        // If slope is within 45 degrees of horizontal, walk one pixel to the left on each iteration;
        // if slope is within 45 degrees of vertical, walk one pixel up on each iteration.
    }
    */
    
    
    // Find line segments on the ball (use this to match orientation to next frame by rotating ball suitably):
    // Explore each pixel and each orientation (0 to 180 degrees) (draw a line from each pixel with each orientation and check if there is line on the ball).
    // Scan a rectangle around the center of the ball:
    float scan_radius = 10.0f; // 20.0f;    // in pixels
    if (ball_radius > 36) // 40)
       { scan_radius = ball_radius / 2; }
    float scan_x_step_size = 1.0f;
    float scan_y_step_size = 1.0f;
    float angle_step_size = pi / 40.0f; // 4.0f; // 80.0f;
    float object_center_x = (float) obj_center_x;
    float object_center_y = (float) obj_center_y;
    
    float line_score_max1 = -999999;
    float line_center_max1_x = 0.0f;
    float line_center_max1_y = 0.0f;
    float orientation_angle_max1 = 0.0f;
    
    float line_score_max2 = -999999;
    float line_center_max2_x = 0.0f;
    float line_center_max2_y = 0.0f;
    float orientation_angle_max2 = 0.0f;
    
    float line_length = 40.0f; // 20.0f;   // in pixels (ball radius is about 20 pixels)
 //   if (ball_radius > 40) { line_length = ball_radius / 4;  scan_x_step_size = 2.0f;  scan_y_step_size = 2.0f;  }
    for (float point_x = -scan_radius; point_x <= scan_radius; point_x += scan_x_step_size)
    {
        for (float point_y = -scan_radius; point_y <= scan_radius; point_y += scan_y_step_size)
        {
            for (float orientation_angle = 0.0f;  orientation_angle < pi;  orientation_angle += angle_step_size)
            {
                float line_score = [self evaluate_line :line_length :pix_arr :object_center_x :object_center_y :point_x :point_y :orientation_angle];
                
                if (line_score > line_score_max1)
                {
                    if (    (((fabs)(orientation_angle - orientation_angle_max1)) > 1.0f)   // second line must have significantly different angle
                        &&  (((fabs)((orientation_angle - pi) - orientation_angle_max1)) > 1.0f)
                        &&  (((fabs)((orientation_angle_max1 - pi) - orientation_angle)) > 1.0f))
                    {
                        line_score_max2 = line_score_max1;
                        line_center_max2_x = line_center_max1_x;
                        line_center_max2_y = line_center_max1_y;
                        orientation_angle_max2 = orientation_angle_max1;
                    }
                    
                    line_score_max1 = line_score;
                    line_center_max1_x = point_x;
                    line_center_max1_y = point_y;
                    orientation_angle_max1 = orientation_angle;
                }
                else if (line_score > line_score_max2)
                {
                    if (    (((fabs)(orientation_angle - orientation_angle_max1)) > 1.0f)   // second line must have significantly different angle
                        &&  (((fabs)((orientation_angle - pi) - orientation_angle_max1)) > 1.0f)
                        &&  (((fabs)((orientation_angle_max1 - pi) - orientation_angle)) > 1.0f))
                    {
                        line_score_max2 = line_score;
                        line_center_max2_x = point_x;
                        line_center_max2_y = point_y;
                        orientation_angle_max2 = orientation_angle;
                    }
                }
                // printf("            -<>- putt - debug - point_x: %2.2f  point_y: %2.2f  line_score: %2.2f  line_score_max: %2.2f  line_center_max_x: %2.2f  line_center_max_y: %2.2f  orientation_angle_max: %2.2f \n",  point_x, point_y, line_score, line_score_max, line_center_max_x, line_center_max_y, orientation_angle_max);
            }
        }
    }
    
    printf("         -<>- putt - strongest line - line_score_max: %2.2f   line_center_max_x: %2.2f   line_center_max_y: %2.2f    orientation_angle_max1: %2.2f deg   orientation_angle_max2: %2.2f deg \n",  line_score_max1, line_center_max1_x, line_center_max1_y, [self to_deg :orientation_angle_max1], [self to_deg :orientation_angle_max2]);
    
    
    // Compute start and end point of first line (market with red/magenta dots):
    
    float line_length_half = line_length / 2.0f;
    float delta1_x = line_length_half * cosf(orientation_angle_max1);
    float delta1_y = line_length_half * sinf(orientation_angle_max1);
    
    float start_point1_x = object_center_x + ( line_center_max1_x - delta1_x );
    float start_point1_y = object_center_y + ( line_center_max1_y - delta1_y );
    
    float end_point1_x = object_center_x + ( line_center_max1_x + delta1_x );
    float end_point1_y = object_center_y + ( line_center_max1_y + delta1_y );
    
    float start_point1_x_scaled = start_point1_x * video_scale_factor_x;
    float start_point1_y_scaled = start_point1_y * video_scale_factor_y;
    
    float end_point1_x_scaled = end_point1_x * video_scale_factor_x;
    float end_point1_y_scaled = end_point1_y * video_scale_factor_y;
    
    // printf("         -<>- putt - set_marker_line1 - start_point1_x_scaled: %2.2f  start_point1_y_scaled: %2.2f  end_point1_x_scaled: %2.2f  end_point1_y_scaled: %2.2f \n",  start_point1_x_scaled, start_point1_y_scaled, end_point1_x_scaled, end_point1_y_scaled);
    [self.draw_field2 set_marker_line1 :start_point1_x_scaled :start_point1_y_scaled :end_point1_x_scaled :end_point1_y_scaled];

    
    
    // Compute start and end point of second line (marked with blue dots):
    
    float delta2_x = line_length_half * cosf(orientation_angle_max2);
    float delta2_y = line_length_half * sinf(orientation_angle_max2);
    
    float start_point2_x = object_center_x + ( line_center_max2_x - delta2_x );
    float start_point2_y = object_center_y + ( line_center_max2_y - delta2_y );
    
    float end_point2_x = object_center_x + ( line_center_max2_x + delta2_x );
    float end_point2_y = object_center_y + ( line_center_max2_y + delta2_y );
    
    float start_point2_x_scaled = start_point2_x * video_scale_factor_x;
    float start_point2_y_scaled = start_point2_y * video_scale_factor_y;
    
    float end_point2_x_scaled = end_point2_x * video_scale_factor_x;
    float end_point2_y_scaled = end_point2_y * video_scale_factor_y;
    
    // printf("         -<>- putt - set_marker_line2 - start_point2_x_scaled: %2.2f  start_point2_y_scaled: %2.2f  end_point2_x_scaled: %2.2f  end_point2_y_scaled: %2.2f \n",  start_point2_x_scaled, start_point2_y_scaled, end_point2_x_scaled, end_point2_y_scaled);
    [self.draw_field2 set_marker_line2 :start_point2_x_scaled :start_point2_y_scaled :end_point2_x_scaled :end_point2_y_scaled];
    
    
    
    // Identify the line that corresponds to the previous primary orientation angle:
    //    Apply default rotation to prev_obj_rot_angle1, then check which of the two new angles is closest to the previous obj_rot_angle1 (after applying default rotation):
    float default_rotation                        = prev_delta_rotation_angle1;
    float rotated_prev_obj_rot_angle1             = prev_ball_rotation_angle1 + default_rotation;
    
    float prev_marker_line_offset_angle = marker_line_offset_angle;
    float rotated_prev_obj_rot_angle1_with_offset = rotated_prev_obj_rot_angle1 + prev_marker_line_offset_angle;
    printf("         -<>-   prev_marker_line_offset_angle: %5.2f deg    rotated_prev_obj_rot_angle1: %5.2f deg  rotated_prev_obj_rot_angle1_with_offset: %5.2f deg \n", [self to_deg :prev_marker_line_offset_angle], [self to_deg :rotated_prev_obj_rot_angle1], [self to_deg :rotated_prev_obj_rot_angle1_with_offset]);
    
    float orientation_angle_max1_adjusted = orientation_angle_max1;
    float orientation_angle_max2_adjusted = orientation_angle_max2;
    // float angle_diff1 = [self angle_diff_mod_180 :rotated_prev_obj_rot_angle1 :orientation_angle_max1  :&orientation_angle_max1_adjusted];
    // float angle_diff2 = [self angle_diff_mod_180 :rotated_prev_obj_rot_angle1 :orientation_angle_max2  :&orientation_angle_max2_adjusted];
    float angle_diff1 = [self angle_diff_mod_180 :rotated_prev_obj_rot_angle1_with_offset :orientation_angle_max1  :&orientation_angle_max1_adjusted];    // adjust by +/- 180 deg to be in synch with (accumulative) object rotation
    float angle_diff2 = [self angle_diff_mod_180 :rotated_prev_obj_rot_angle1_with_offset :orientation_angle_max2  :&orientation_angle_max2_adjusted];
    
    float angle_diff_min = min(fabs(angle_diff1), fabs(angle_diff2));
    float angle_alignment_threshold = 0.3f; // 0.4f
    
    
    /*
    // Check if we should switch back to the primary marker line (as reference):
    if (angle_diff_min >= angle_alignment_threshold)
    {
        float angle_diff1_tmp = [self angle_diff_mod_180 :rotated_prev_obj_rot_angle1 :orientation_angle_max1  :&orientation_angle_max1_adjusted];
        float angle_diff2_tmp = [self angle_diff_mod_180 :rotated_prev_obj_rot_angle1 :orientation_angle_max2  :&orientation_angle_max2_adjusted];
        
        float angle_diff_min_temp = min(fabs(angle_diff1_tmp), fabs(angle_diff2_tmp));
        
        if (angle_diff_min_temp < angle_alignment_threshold)
        {
            marker_line_offset_angle = 0.0f;    // switch back to tracking primary marker line
            prev_marker_line_offset_angle = 0.0f;    // reset
            rotated_prev_obj_rot_angle1_with_offset = rotated_prev_obj_rot_angle1;   // reset
            
            angle_diff1 = angle_diff1_tmp;
            angle_diff2 = angle_diff2_tmp;
            
            angle_diff_min = angle_diff_min_temp;
        }
    }
    */
    
    
    if (angle_diff_min < angle_alignment_threshold) // 0.4f)     // Don't make adjustment if expected orientation is too fare off the detected orientation.
    {
        int primary_marker_line_id = 1;     // 1 = line1; 2 = line2
        if (fabs(angle_diff2) < fabs(angle_diff1))
        {
            primary_marker_line_id = 2;     // Switch the lines to match the marker lines from the previous image.
        }
        
        // if (marker_line_offset_angle != 0.0f)    // Using angle offset means we are referencing the secondary marker line; so we need to flip primary_marker_line_id.
        // {
        //     if (primary_marker_line_id == 1) { primary_marker_line_id = 2; } else { primary_marker_line_id = 1; }
        // }
        
        // Now determine obj_rot_angle1 (the orientation of the primary marker line).
        if (primary_marker_line_id == 1)
        {
            obj_rot_angle1 = orientation_angle_max1_adjusted;
            obj_rot_angle2 = orientation_angle_max2_adjusted;
            float obj_rot_angle1_minus_offset = obj_rot_angle1 - prev_marker_line_offset_angle;
            printf("         -<>-   Primary marker line is stronger than secondary marker line.   obj_rot_angle1: %5.2f deg    marker_line_offset_angle: %5.2f deg    obj_rot_angle1_minus_offset: %5.2f deg      orientation_angle_max2: %5.2f deg   orientation_angle_max1: %5.2f deg \n", [self to_deg :obj_rot_angle1], [self to_deg :marker_line_offset_angle], [self to_deg :obj_rot_angle1_minus_offset], [self to_deg :orientation_angle_max2], [self to_deg :orientation_angle_max1]);
        }
        else // This means, the primary marker line has become weaker than the secondary marker line
        {
            obj_rot_angle1 = orientation_angle_max2_adjusted;
            obj_rot_angle2 = orientation_angle_max1_adjusted;
            
            // If the primary marker line has become weaker than the secondary marker line, use the secondary marker line as reference (that is, define an "offset angle"):
            // Define the angle between the primary marker line (which defines the object orientation) and the secondary marker line:
            if (marker_line_offset_angle == 0.0f)    // if it's not zero, we are already in "offset mode"
            {
                // marker_line_offset_angle = orientation_angle_max2 - orientation_angle_max1;
                marker_line_offset_angle = orientation_angle_max1 - orientation_angle_max2;       // orientation_angle_max1 is the stronger line (not necessarily the primary marker line)
            }
            // In the next iteration add this offset to the "rotated_prev_obj_rot_angle1" when search for a parallel line; then subtract this offset when setting "obj_rot_angle1".
        
            printf("         -<>-   Primary marker line is weaker than secondary marker line.  obj_rot_angle1: %5.2f deg    marker_line_offset_angle: %5.2f deg   orientation_angle_max2: %5.2f deg   orientation_angle_max1: %5.2f deg \n", [self to_deg :obj_rot_angle1], [self to_deg :marker_line_offset_angle], [self to_deg :orientation_angle_max2], [self to_deg :orientation_angle_max1]);
        }
    }
    else
    {
        // obj_rot_angle1 = rotated_prev_obj_rot_angle1;   // used dead reckoning if there is no matching line
        obj_rot_angle1 = rotated_prev_obj_rot_angle1_with_offset;   // used dead reckoning if there is no matching line
        printf("         -<>-   Unable to match expect orientatation to a marker line -- using rotation dead reckoning. \n");
    }

    obj_rot_angle1 -= prev_marker_line_offset_angle;      // remove the offset added above
    delta_rotation_angle = obj_rot_angle1 - prev_ball_rotation_angle1;

    printf("         -<>-   orientation_angle_max1: %5.2f deg   orientation_angle_max2: %5.2f deg   prev_ball_rotation_angle1: %5.2f deg   prev_delta_rotation_angle1: %5.2f deg   rotated_prev_obj_rot_angle1: %5.2f deg   angle_diff1: %5.2f deg   angle_diff2: %5.2f deg   obj_rot_angle1: %5.2f deg   obj_rot_angle2: %5.2f deg   delta_rotation_angle: %5.2f deg \n",  [self to_deg :orientation_angle_max1], [self to_deg :orientation_angle_max2], [self to_deg :prev_ball_rotation_angle1], [self to_deg :prev_delta_rotation_angle1], [self to_deg :rotated_prev_obj_rot_angle1], [self to_deg :angle_diff1], [self to_deg :angle_diff2], [self to_deg :obj_rot_angle1], [self to_deg :obj_rot_angle2], [self to_deg :delta_rotation_angle]);
    
    obj_rot_angle = obj_rot_angle1;                       // This defines the orietation (clockwise rotation from 3 o'clock orientation)
    
    [_draw_field2 set_rotation_angle :obj_rot_angle1];    // set the orientation of the red box
    // if (frame_no == 37) { [_draw_field2 set_rotation_angle :M_PI]; } // TEMP FOR TESING
    
    
    float time_per_frame = 1.0f / ((float) (video_fps / fps_reduction_factor));   // in seconds
    int ball_rpm_curr = (int) (((delta_rotation_angle / 3.14159f) / time_per_frame) * 60.0f);    // multiply by 60 to get from seconds to minutes
    
    // Track the last 8 rpm values and average over these so smooth out quick rotation due detection accuracy limitations:
    int ball_rpm_ave = [self get_average_ball_rpm :ball_rpm_curr];
    ball_rpm = ball_rpm_ave;                                                                   // ball_rpm this is displayed in UI
    
    if (frame_no > 8)
    {
        // if (ball_rpm > max_ball_rpm) { max_ball_rpm = ball_rpm; }                           // ball_rpm and max_ball_rpm are displayed in UI
        if (ball_rpm_ave > max_ball_rpm) { max_ball_rpm = ball_rpm_ave; }                      // ball_rpm and max_ball_rpm are displayed in UI
    }
    
    return angle;    // not used
}




- (float) find_orientation_of_obj_with_blastman :(unsigned char*)pix_arr :(int)frame_no :(int)obj_center :(int)num_blastman1_points :(float *)blastman1_points_x :(float *)blastman1_points_y
{
    float angle = 0.0f;
    // float prev_ball_rotation_angle  = obj_rot_angle;
    float prev_ball_rotation_angle1 = obj_rot_angle1;   // primary ball rotation angle
    // float prev_ball_rotation_angle2 = obj_rot_angle2;   // secondary ball rotation angle
    float prev_delta_rotation_angle1 = delta_rotation_angle;
    
    // float prev_chest_point_offset_x = blastman_points_x[2];
    // float prev_chest_point_offset_y = blastman_points_y[2];
    
    // Detect orientation of ball (assuming there is a black blastman drawn on the ball):
    //    Use center of ball to focus on a minimal rectanglar area that includes the ball.
    //    Search for a black blastman (drawn as marker on the ball).
    //       - For each blastman point compare the center pixel with the pixel on a small circle around it.
    
    int obj_center_x = obj_center / 1000000;
    int obj_center_y = obj_center % 1000000;
    printf("         -<>- putt - compute ball orientation using blastman - object center - x: %d  y: %d  ball_radius: %2.2f \n",  obj_center_x, obj_center_y, ball_radius);
    
    float pi = 3.14159;  // use M_PI
    
    
    // Find blastman on the ball (use this to match orientation to next frame by rotating ball suitably):
    // Explore each pixel and each orientation (0 to 180 degrees) (draw the blastman at each pixel (rotated by some degrees) and check if it matches the image).
    // Scan a rectangle around the center of the ball:
    float scan_radius = 20.0f; // 15.0f; // 20.0f;    // in pixels
    float scan_radius_x_start = -scan_radius;
    float scan_radius_x_end   =  scan_radius;
    float scan_radius_y_start = -scan_radius;
    float scan_radius_y_end   =  scan_radius;
    // if (ball_radius > 36) // 40)
    //    { scan_radius = ball_radius / 2; }
    float scan_x_step_size = 1.0f; // 0.5f; // 1.0f;
    float scan_y_step_size = 1.0f; // 1.0f;
    float angle_step_size =  (3.0f / 180) * pi; // (4.0f / 180) * pi; // 4 degrees // pi / 180.0f; //  pi / 80.0f; //  pi / 40.0f; // 4.0f; // 80.0f;
    float object_center_x = (float) obj_center_x;
    float object_center_y = (float) obj_center_y;
    
    float line_score_max1 = -999999;
    float line_center_max1_x = 0.0f;
    float line_center_max1_y = 0.0f;
    float orientation_angle_max1 = 0.0f;
    
    // float line_score_max2 = -999999;
    // float line_center_max2_x = 0.0f;
    // float line_center_max2_y = 0.0f;
    // float orientation_angle_max2 = 0.0f;
    
    
    // Determine the expected rotation (default rotation):
    float default_rotation                        = prev_delta_rotation_angle1;
    float rotated_prev_obj_rot_angle1             = prev_ball_rotation_angle1 + default_rotation;
    float angle_alignment_threshold               = 0.2f; // 0.3f; // 0.4f
    float position_alignment_theshold             = 12.0f; //  8.0f; // 4.0f;        // overwritten below
    
    float prev_marker_line_offset_angle = marker_line_offset_angle;
    float rotated_prev_obj_rot_angle1_with_offset = rotated_prev_obj_rot_angle1 + prev_marker_line_offset_angle;
    printf("         -<>-   prev_marker_line_offset_angle: %5.2f deg    rotated_prev_obj_rot_angle1: %5.2f deg  rotated_prev_obj_rot_angle1_with_offset: %5.2f deg \n", [self to_deg :prev_marker_line_offset_angle], [self to_deg :rotated_prev_obj_rot_angle1], [self to_deg :rotated_prev_obj_rot_angle1_with_offset]);

   
    float orientation_angle_start = 0.0f;
    float orientation_angle_end   = pi;
    
    float blastman1_radius = 14.0f; // 12.0f;   // in pixels (ball radius is about 20 pixels)

    // USE CONTINUITY CONDITION TO IMPROVE EFFICIENCY
    
    // First check if there is no movement:  set position_alignment_theshold to small value (3); if score is good and similar to previous good score continue; otherwise due more extensive search
    int num_phases = 2;
    
    for (int phase_no = 1; phase_no <= num_phases; phase_no++)
    {
        line_score_max1 = -999999;    // reset
        
        if (phase_no == 1) { position_alignment_theshold =  3.0f; }
        else               { position_alignment_theshold = 12.0f; }
        
        if (frame_no > 5) // 6)   // replace this by condition that checks if there is a continous motion
        {
            orientation_angle_start = rotated_prev_obj_rot_angle1 - angle_alignment_threshold;
            orientation_angle_end   = rotated_prev_obj_rot_angle1 + angle_alignment_threshold;
            
            scan_radius_x_start     = prev_chest_point_offset_x - position_alignment_theshold;
            scan_radius_x_end       = prev_chest_point_offset_x + position_alignment_theshold;
            
            scan_radius_y_start     = prev_chest_point_offset_y - position_alignment_theshold;
            scan_radius_y_end       = prev_chest_point_offset_y + position_alignment_theshold;
        }
        
        
        for (float point_x = scan_radius_x_start; point_x <= scan_radius_x_end; point_x += scan_x_step_size)
        {
            for (float point_y = scan_radius_y_start; point_y <= scan_radius_y_end; point_y += scan_y_step_size)
            {
                for (float orientation_angle = orientation_angle_start;  orientation_angle < orientation_angle_end;  orientation_angle += angle_step_size)
                {
                    [self fill_in_blastman_points :num_blastman1_points :blastman1_radius  :blastman1_points_x  :blastman1_points_y];     // reset blastman points
                    
                    // float point_y = 0.0f;  float point_x = 0.0f;  float orientation_angle = 0.7f; // TEMP FOR TESTING
                    float blastman_score1 = [self evaluate_blastman :blastman1_radius :num_blastman1_points :blastman1_points_x :blastman1_points_y :pix_arr :object_center_x :object_center_y :point_x :point_y :orientation_angle];
                    
                    if (blastman_score1 > line_score_max1)
                    {
                        line_score_max1 = blastman_score1;
                        line_center_max1_x = point_x;
                        line_center_max1_y = point_y;
                        orientation_angle_max1 = orientation_angle;
                        // printf("            -<>- putt - debug - point_x: %2.2f  point_y: %2.2f  line_score: %2.2f  blastman_score1: %2.2f  line_center_max1_x: %2.2f  line_center_max1_y: %2.2f  orientation_angle_max1: %2.2f deg \n",  point_x, point_y, blastman_score, blastman_score1, line_center_max1_x, line_center_max1_y, [self to_deg :orientation_angle_max1]);
                    }
                    // printf("            -<>- putt - debug - point_x: %2.2f  point_y: %2.2f  line_score: %2.2f  blastman_score1: %2.2f  line_center_max1_x: %2.2f  line_center_max1_y: %2.2f  orientation_angle_max1: %2.2f deg \n",  point_x, point_y, blastman_score1, blastman_score1, line_center_max1_x, line_center_max1_y, [self to_deg :orientation_angle_max1]);
                }
            }
        }
        
        if (line_score_max1 > (blastman_score - 30))  { break; }   // Good enought - don't need to do more extensive search (phase 2)
    }
    
    blastman_score = [self get_blastman_score :line_score_max1];
    
    printf("         -<>- putt - strongest blastman - line_score_max1: %2.2f   blastman_score: %2.2f   line_center_max1_x: %2.2f   line_center_max1_y: %2.2f    orientation_angle_max1: %2.2f deg \n",  line_score_max1, blastman_score, line_center_max1_x, line_center_max1_y, [self to_deg :orientation_angle_max1]);
    
    
    // Set the blastman position and orientation according to the best fit computed above (line_center_max1_x, line_center_max1_y, orientation_angle_max1)
    {
        [self fill_in_blastman_points :num_blastman1_points :blastman1_radius  :blastman1_points_x  :blastman1_points_y];     // reset blastman points
        
        // Apply search shift:
        for (int point_no = 0; point_no < num_blastman1_points; point_no++)
        {
            blastman1_points_x[point_no] += object_center_x + line_center_max1_x;
            blastman1_points_y[point_no] += object_center_y + line_center_max1_y;
        }
        
        // Rotate the blastman by "orientation_angle" (chest point is center of rotation).
        // Shift to origin - rotate - shift back to position:
        
        float chest_point_x = blastman1_points_x[2];
        float chest_point_y = blastman1_points_y[2];
        
        for (int point_no = 0; point_no < num_blastman1_points; point_no++)
        {
            blastman1_points_x[point_no] -= chest_point_x;
            blastman1_points_y[point_no] -= chest_point_y;
            
            [self rotate_point_around_origin :&(blastman1_points_x[point_no]) :&(blastman1_points_y[point_no]) :orientation_angle_max1];
            
            blastman1_points_x[point_no] += chest_point_x;
            blastman1_points_y[point_no] += chest_point_y;
        }
        
        prev_chest_point_offset_x = line_center_max1_x;
        prev_chest_point_offset_y = line_center_max1_y;
    }

    
    
    float orientation_angle_max1_adjusted = orientation_angle_max1;
    // float orientation_angle_max2_adjusted = orientation_angle_max2;
    // float angle_diff1 = [self angle_diff_mod_180 :rotated_prev_obj_rot_angle1 :orientation_angle_max1  :&orientation_angle_max1_adjusted];
    // float angle_diff2 = [self angle_diff_mod_180 :rotated_prev_obj_rot_angle1 :orientation_angle_max2  :&orientation_angle_max2_adjusted];
    float angle_diff1 = [self angle_diff_mod_180 :rotated_prev_obj_rot_angle1_with_offset :orientation_angle_max1  :&orientation_angle_max1_adjusted];    // adjust by +/- 180 deg to be in synch with (accumulative) object rotation
    // float angle_diff2 = [self angle_diff_mod_180 :rotated_prev_obj_rot_angle1_with_offset :orientation_angle_max2  :&orientation_angle_max2_adjusted];
    
    // float angle_diff_min = min(fabs(angle_diff1), fabs(angle_diff2));
    
    

    // Compute rotation (compared to previous frame):
    
    if (true) // (angle_diff1 < angle_alignment_threshold) // 0.4f)     // Don't make adjustment if expected orientation is too far off the detected orientation.
    {
        // int primary_marker_line_id = 1;     // 1 = line1; 2 = line2
        // if (fabs(angle_diff2) < fabs(angle_diff1))
        // {
        //     primary_marker_line_id = 2;     // Switch the lines to match the marker lines from the previous image.
        // }
        
        // if (marker_line_offset_angle != 0.0f)    // Using angle offset means we are referencing the secondary marker line; so we need to flip primary_marker_line_id.
        // {
        //     if (primary_marker_line_id == 1) { primary_marker_line_id = 2; } else { primary_marker_line_id = 1; }
        // }
        
        // Now determine obj_rot_angle1 (the orientation of the primary marker line).
        if (true) // (primary_marker_line_id == 1)
        {
            obj_rot_angle1 = orientation_angle_max1_adjusted;
            // obj_rot_angle2 = orientation_angle_max2_adjusted;
            float obj_rot_angle1_minus_offset = obj_rot_angle1 - prev_marker_line_offset_angle;
            printf("         -<>-   obj_rot_angle1: %5.2f deg    marker_line_offset_angle: %5.2f deg    obj_rot_angle1_minus_offset: %5.2f deg      orientation_angle_max1: %5.2f deg \n", [self to_deg :obj_rot_angle1], [self to_deg :marker_line_offset_angle], [self to_deg :obj_rot_angle1_minus_offset], [self to_deg :orientation_angle_max1]);
        }
        // else // This means, the primary marker line has become weaker than the secondary marker line
        // {
        //     obj_rot_angle1 = orientation_angle_max2_adjusted;
        //     obj_rot_angle2 = orientation_angle_max1_adjusted;
        //
        //     // If the primary marker line has become weaker than the secondary marker line, use the secondary marker line as reference (that is, define an "offset angle"):
        //     // Define the angle between the primary marker line (which defines the object orientation) and the secondary marker line:
        //     if (marker_line_offset_angle == 0.0f)    // if it's not zero, we are already in "offset mode"
        //     {
        //         // marker_line_offset_angle = orientation_angle_max2 - orientation_angle_max1;
        //         marker_line_offset_angle = orientation_angle_max1 - orientation_angle_max2;       // orientation_angle_max1 is the stronger line (not necessarily the primary marker line)
        //     }
        //     // In the next iteration add this offset to the "rotated_prev_obj_rot_angle1" when search for a parallel line; then subtract this offset when setting "obj_rot_angle1".
        //
        //     printf("         -<>-   Primary marker line is weaker than secondary marker line.  obj_rot_angle1: %5.2f deg    marker_line_offset_angle: %5.2f deg   orientation_angle_max2: %5.2f deg   orientation_angle_max1: %5.2f deg \n", [self to_deg :obj_rot_angle1], [self to_deg :marker_line_offset_angle], [self to_deg :orientation_angle_max2], [self to_deg :orientation_angle_max1]);
        // }
    }
    else
    {
        // obj_rot_angle1 = rotated_prev_obj_rot_angle1;   // used dead reckoning if there is no matching line
        obj_rot_angle1 = rotated_prev_obj_rot_angle1_with_offset;   // used dead reckoning if there is no matching line
        printf("         -<>-   Unable to match expect orientatation to a marker line -- using rotation dead reckoning. \n");
    }
    
    obj_rot_angle1 -= prev_marker_line_offset_angle;      // remove the offset added above
    delta_rotation_angle = obj_rot_angle1 - prev_ball_rotation_angle1;
    
    printf("         -<>-   orientation_angle_max1: %5.2f deg   prev_ball_rotation_angle1: %5.2f deg   prev_delta_rotation_angle1: %5.2f deg   rotated_prev_obj_rot_angle1: %5.2f deg   angle_diff1: %5.2f deg   obj_rot_angle1: %5.2f deg   obj_rot_angle2: %5.2f deg   delta_rotation_angle: %5.2f deg \n",  [self to_deg :orientation_angle_max1], [self to_deg :prev_ball_rotation_angle1], [self to_deg :prev_delta_rotation_angle1], [self to_deg :rotated_prev_obj_rot_angle1], [self to_deg :angle_diff1], [self to_deg :obj_rot_angle1], [self to_deg :obj_rot_angle2], [self to_deg :delta_rotation_angle]);
    
    obj_rot_angle = obj_rot_angle1;                       // This defines the orietation (clockwise rotation from 3 o'clock orientation)
    
    [_draw_field2 set_rotation_angle :obj_rot_angle1];    // set the orientation of the red box
    // if (frame_no == 37) { [_draw_field2 set_rotation_angle :M_PI]; } // TEMP FOR TESING
    
    
    
    float time_per_frame = 1.0f / ((float) (video_fps/fps_reduction_factor));   // in seconds
    int ball_rpm_curr = (int) (((delta_rotation_angle / 3.14159f) / time_per_frame) * 60.0f);    // multiply by 60 to get from seconds to minutes
    
    if (frame_no > 8)
    {
        // Track the last 8 rpm values and average over these to smooth out quick rotation due detection accuracy limitations:
        int ball_rpm_ave = [self get_average_ball_rpm :ball_rpm_curr];
        ball_rpm = ball_rpm_ave;                                                                   // ball_rpm this is displayed in UI
        
        // if (ball_rpm > max_ball_rpm) { max_ball_rpm = ball_rpm; }                           // ball_rpm and max_ball_rpm are displayed in UI
        if (ball_rpm_ave > max_ball_rpm) { max_ball_rpm = ball_rpm_ave; }                      // ball_rpm and max_ball_rpm are displayed in UI

        if (true) // (frame_no > 40)
        {
            [self update_ball_rpm_arr :ball_rpm];
        }
        
        if ((frame_no > 16) && (ball_rpm_ave > 150) && (skid_end_frame_no == 0))
        {
            skid_end_frame_no = frame_no;
        }
        
        ball_orientation = obj_rot_angle1 * 57.2957795f;      // Convert to degrees
        
        // When the ball rotated 90 degress compute distance traveled since impact:
        if ((ball_orientation > 87.0f) && (ninety_degree_point == 0.0f))
        {
            float delta_x_since_impact = ((float)object_center_x * meters_per_pixel) - impact_ball_position_x;
            float delta_y_since_impact = ((float)object_center_y * meters_per_pixel) - impact_ball_position_y;
            ninety_degree_point = sqrt(delta_x_since_impact * delta_x_since_impact + delta_y_since_impact * delta_y_since_impact) * 39.3701f;   // convert to inches
            
            ninety_deg_obj_pos_x = (float) obj_center_x;
            ninety_deg_obj_pos_y = (float) obj_center_y;
        }
    }

    return angle;    // not used
    
}




- (float) find_orientation_of_obj_with_pattern :(unsigned char*)pix_arr :(int)frame_no :(int)obj_center :(int)radius1 :(int)num_blastman1_points :(float *)blastman1_points_x :(float *)blastman1_points_y
{
    float angle = 0.0f;
    
    int obj_center_x = obj_center / 1000000;
    int obj_center_y = obj_center % 1000000;
    printf("         -<o>- putt - compute ball orientation using pattern - object center - x: %d  y: %d  ball_radius: %2.2f \n",  obj_center_x, obj_center_y, ball_radius);

    float blastman1_radius = 14.0f; // 12.0f;   // in pixels (ball radius is about 20 pixels) --- this determines the bastman size on the overlay display

    float object_center_x = (float) obj_center_x;
    float object_center_y = (float) obj_center_y;

    float line_center_max1_x = 0.0f;
    float line_center_max1_y = 0.0f;
    float rotation_angle_max1 = 0.0f;
    
    float blast_man_rotation_angle = 0.0f;
    float line_graph_rotation_angle = 0.0f;       // is this used?

    unsigned char * curr_ball_box_subimg = nullptr;
    unsigned char * prev_ball_box_subimg = nullptr;

    float prev_ball_rotation_angle1 = 0.0f;   // primary ball rotation angle
    float prev_delta_rotation_angle1 = 0.0f;
    float rotated_prev_obj_rot_angle1 = 0.0f; // prev_ball_rotation_angle1 is the angle between the reference subimg and the rotation on the previous frame


    bool ball_image_changed = false; // false;   // for efficiency
    // if (frame_no > 210) { ball_image_changed = true; }  // testing
    if ((frame_no >= impact_frame_no) && (impact_frame_no > 0))  { ball_image_changed = true; }  // testing
    if (ball_image_changed)
    {
        
        //
        // Equalize the ball image (remove shadow, show only lines, etc.):
        //
        
        int alpha1 =   0;
        int red1   =   0;
        int green1 = 255;
        int blue1  =   0;
        // int alpha = 0;
        float dist_squared = 0.0f;
        float radius_squared = radius1 * radius1;
        
        int red = 0;
        int green = 0;
        int blue = 0;
        
        float red_scale   = 0.5f;    // overwritten below
        float green_scale = 0.5f;
        float blue_scale  = 0.5f;
        
        float refence_intensity_red   = 130;    // normalize the ball image to this intensity
        float refence_intensity_green = 130;    // normalize the ball image to this intensity
        float refence_intensity_blue  = 130;    // normalize the ball image to this intensity
        
        float ave_intensity_red = 0.0f;
        float ave_intensity_green = 0.0f;
        float ave_intensity_blue = 0.0f;
        int intensity_count = 0;
        
        int bytes_per_row2 = ball_box_width * 4;
        
        
        float curr_ball_rotation_angle = 0.0f;
        float prev_ball_rotation_angle = 0.0f;
        if (ball_box_subimg_swap == 1)
        {
            curr_ball_box_subimg = ball_box_subimg1;
            prev_ball_box_subimg = ball_box_subimg2;
            curr_ball_rotation_angle = ball_rotation_angle_at_subimg1;
            prev_ball_rotation_angle = ball_rotation_angle_at_subimg2;
        }
        else // ball_box_subimg_swap == 2
        {
            curr_ball_box_subimg = ball_box_subimg2;
            prev_ball_box_subimg = ball_box_subimg1;
            curr_ball_rotation_angle = ball_rotation_angle_at_subimg2;
            prev_ball_rotation_angle = ball_rotation_angle_at_subimg1;
        }
        for (int i = 0; i < ball_box_subimg_arr_length; i++) { curr_ball_box_subimg[i] = 0; }   // reset the subimg being updated
        
        int pixel_arr_idx = 0;
        int arr_length = movie_frame_height * movie_frame_bytes_per_row - 2;
        
        // Make the ball a binary image
        for (int pix_x = obj_center_x - radius1;  pix_x <= obj_center_x + radius1;  pix_x++)
        {
            for (int pix_y = obj_center_y - radius1;  pix_y <= obj_center_y + radius1;  pix_y++)
            {
                dist_squared = (pix_x - obj_center_x) * (pix_x - obj_center_x) + (pix_y - obj_center_y) * (pix_y - obj_center_y);
                if (dist_squared < radius_squared)
                {
                    ave_intensity_red = 0.0f;   // reset
                    ave_intensity_green = 0.0f;
                    ave_intensity_blue = 0.0f;
                    
                    intensity_count = 0;        // reset
                    
                    // For each pixel compute the avage intensity of the area around it:
                    int area_range = 16; // 8; // 4; // 20;
                    for (int pix2_x = pix_x - area_range;  pix2_x <= pix_x + area_range;  pix2_x += 2)
                    {
                        for (int pix2_y = pix_y - area_range;  pix2_y <= pix_y + area_range;  pix2_y += 2)
                        {
                            pixel_arr_idx = pix2_y * movie_frame_bytes_per_row + pix2_x * 4;
                            
                            if ((pixel_arr_idx >= 0) && (pixel_arr_idx < arr_length))
                            {
                                red   = (int) pix_arr[pixel_arr_idx + 2];
                                green = (int) pix_arr[pixel_arr_idx + 1];
                                blue  = (int) pix_arr[pixel_arr_idx];
                                
                                ave_intensity_red   += ((float)red);
                                ave_intensity_green += ((float)green);
                                ave_intensity_blue  += ((float)blue);
                                
                                intensity_count++;
                            }
                        }
                    }
                    if (intensity_count > 0)
                    {
                        ave_intensity_red   = ave_intensity_red   / ((float)intensity_count);
                        ave_intensity_green = ave_intensity_green / ((float)intensity_count);
                        ave_intensity_blue  = ave_intensity_blue  / ((float)intensity_count);
                        
                        red_scale   = ((float)refence_intensity_red)   / ((float)ave_intensity_red);
                        green_scale = ((float)refence_intensity_green) / ((float)ave_intensity_green);
                        blue_scale  = ((float)refence_intensity_blue)  / ((float)ave_intensity_blue);
                        
                        // printf("            -**-**-  ave_intensity_red: %5.2f  ave_intensity_green: %5.2f  ave_intensity_blue: %5.2f  red_scale: %5.2f  green_scale: %5.2f  blue_scale: %5.2f \n",  ave_intensity_red, ave_intensity_green, ave_intensity_blue,  red_scale,  green_scale,  blue_scale);
                        
                        
                        // Adjust the pixel intensities (copy to ball_box_subimg1):
                        size_t pixel_arr_idx = pix_y * movie_frame_bytes_per_row + pix_x * 4;
                        
                        // Adjust coordinates to refer to the upper left corner as the origin (so the pixels can be stored in ball_box_subimg1):
                        int ball_box_origin_x = obj_center_x - radius1;
                        int ball_box_origin_y = obj_center_y - radius1;
                        
                        size_t pixel_arr_idx2 = (pix_y - ball_box_origin_y) * bytes_per_row2 + (pix_x - ball_box_origin_x) * 4;
                        
                        alpha1 = pix_arr[pixel_arr_idx + 3];
                        red1   = pix_arr[pixel_arr_idx + 2];
                        green1 = pix_arr[pixel_arr_idx + 1];
                        blue1  = pix_arr[pixel_arr_idx];
                        
                        // pix_arr[pixel_arr_idx + 2] = (char)red1;
                        // pix_arr[pixel_arr_idx + 1] = (char)green1;
                        // pix_arr[pixel_arr_idx]     = (char)blue1;
                        // pix_arr[pixel_arr_idx + 2] = (char)(((float)red1)   * red_scale);
                        // pix_arr[pixel_arr_idx + 1] = (char)(((float)green1) * green_scale);
                        // pix_arr[pixel_arr_idx]     = (char)(((float)blue1)  * blue_scale);
                        if ((pixel_arr_idx2 + 2) < ball_box_subimg_arr_length)
                        {
                            curr_ball_box_subimg[pixel_arr_idx2 + 3] = alpha1;
                            curr_ball_box_subimg[pixel_arr_idx2 + 2] = (char)(((float)red1)   * red_scale);     // equalizing
                            curr_ball_box_subimg[pixel_arr_idx2 + 1] = (char)(((float)green1) * green_scale);   // equalizing
                            curr_ball_box_subimg[pixel_arr_idx2]     = (char)(((float)blue1)  * blue_scale);    // equalizing
                            
                            
                            // Mark the darkest pixels (using dark blue):
                            int darkness_threshold = 110; // 80;
                            if (   (curr_ball_box_subimg[pixel_arr_idx2 + 2] < darkness_threshold)
                                && (curr_ball_box_subimg[pixel_arr_idx2 + 1] < darkness_threshold)
                                && (curr_ball_box_subimg[pixel_arr_idx2]     < darkness_threshold))
                            {
                                // ball_box_subimg1[pixel_arr_idx2 + 3] = 0;
                                curr_ball_box_subimg[pixel_arr_idx2 + 2] = (char)0;
                                curr_ball_box_subimg[pixel_arr_idx2 + 1] = (char)0;
                                curr_ball_box_subimg[pixel_arr_idx2]     = (char)255;
                            }
                            else // make the other pixels white
                            {
                                // ball_box_subimg1[pixel_arr_idx2 + 3] = alpha1;
                                curr_ball_box_subimg[pixel_arr_idx2 + 2] = 255;
                                curr_ball_box_subimg[pixel_arr_idx2 + 1] = 255;
                                curr_ball_box_subimg[pixel_arr_idx2]     = 255;
                            }
                            
                        }
                    }
                }
            }
        }
        
        /*
         // Copy ball_box_subimg1 back to current image (for display/diagnostics):   (THIS INTERFERS WITH TRYING TO DETECT no motion AS IT CHANGES THE IMAGE)
         for (int pix_x = obj_center_x - radius1;  pix_x <= obj_center_x + radius1;  pix_x++)
         {
             for (int pix_y = obj_center_y - radius1;  pix_y <= obj_center_y + radius1;  pix_y++)
             {
                 int pixel_arr_idx = pix_y * movie_frame_bytes_per_row + pix_x * 4;
         
                 int ball_box_origin_x = obj_center_x - radius1;
                 int ball_box_origin_y = obj_center_y - radius1;
                 int pixel_arr_idx2 = (pix_y - ball_box_origin_y) * bytes_per_row2 + (pix_x - ball_box_origin_x) * 4;
         
                 if ((pixel_arr_idx >= 0) && (pixel_arr_idx < arr_length))
                 {
                     alpha1 = curr_ball_box_subimg[pixel_arr_idx2 + 3];
                     red1   = curr_ball_box_subimg[pixel_arr_idx2 + 2];
                     green1 = curr_ball_box_subimg[pixel_arr_idx2 + 1];
                     blue1  = curr_ball_box_subimg[pixel_arr_idx2];
         
                  // alpha1 = prev_ball_box_subimg[pixel_arr_idx2 + 3];   // debugging
                  // red1   = prev_ball_box_subimg[pixel_arr_idx2 + 2];   // debugging
                  // green1 = prev_ball_box_subimg[pixel_arr_idx2 + 1];   // debugging
                  // blue1  = prev_ball_box_subimg[pixel_arr_idx2];
         
                     if ((red1 > 0) || (green1 > 0) || (blue1 > 0))     // completely black pixels designate "masked out" (not part of the ball)
                     {
                         pix_arr[pixel_arr_idx + 3] = alpha1;
                         pix_arr[pixel_arr_idx + 2] = red1;
                         pix_arr[pixel_arr_idx + 1] = green1;
                         pix_arr[pixel_arr_idx]     = blue1;
                     }
                 }
             }
         }
        */
        
        
        
        //
        // Save a reference ball image
        //
        
        unsigned char * ref_ball_box_subimg = ball_box_subimg0;
        if ((frame_no < 20) || (reference_ball_image_is_set < 3))
        {
            for (int byte_no = 0; byte_no < ball_box_subimg_arr_length; byte_no++) { ref_ball_box_subimg[byte_no] = curr_ball_box_subimg[byte_no]; }
            reference_ball_image_is_set++;
        }
        
        // Rebase the ref_ball_box_subimg if (frame_no - impact_frame_no) == 16:    (the image pattern slowly changes; so the reference subimg needs to be "re-based"
        int num_frames_since_impact = frame_no - impact_frame_no;
        if (num_frames_since_impact == 15) // 20) // 16) // 10)
        {
            for (int byte_no = 0; byte_no < ball_box_subimg_arr_length; byte_no++) { ref_ball_box_subimg[byte_no] = prev_ball_box_subimg[byte_no]; }
            ball_rotation_angle_at_subimg0 = prev_ball_rotation_angle;
            prev_chest_point_offset_x = 0.0f;   // after re-basing the ref ball imag, the accumulated shift needs to be reset also (to zero)
            prev_chest_point_offset_y = 0.0f;
        }
        float ref_ball_rotation_angle = ball_rotation_angle_at_subimg0;
        
        
        
        //
        // Now compare "prev_ball_box_subimg" with "curr_ball_box_subimg" (or "ref_ball_box_subimg") (check how much "prev_ball_box_subimg" needs to be rotated to match "curr_ball_box_subimg"
        //
        
        // Define a rectangle around the center of the ball that is used to apply rotation and match with curr_ball_box_subimg:
        int rotation_rect_radius = radius1 / 2;    // define half the width of the rectangle being rotated and compared
        
        // Rotate and shift each pixel (maybe only the marked (dark) pixels for efficiency)
        
        // float pi = 3.14159;  // use M_PI
        
        prev_ball_rotation_angle1 = obj_rot_angle1;   // primary ball rotation angle
        prev_delta_rotation_angle1 = delta_rotation_angle;
        
        float scan_radius = 4.0f; // 0.0f; // 20.0f; // 15.0f; // 20.0f;    // in pixels
        float scan_radius_x_start = -scan_radius;
        float scan_radius_x_end   =  scan_radius;
        float scan_radius_y_start = -scan_radius;
        float scan_radius_y_end   =  scan_radius;
        
        float scan_x_step_size = 2.0f; // 1.0f; // 0.5f; // 1.0f;
        float scan_y_step_size = 2.0f; // 1.0f;
        
        float line_score_max1 = -999999;
        
        // Determine the expected rotation (default rotation):
        float default_rotation                        = prev_delta_rotation_angle1;
        //  float rotated_prev_obj_rot_angle1             = prev_ball_rotation_angle1 + default_rotation;
        rotated_prev_obj_rot_angle1             = (prev_ball_rotation_angle1 + default_rotation) - ref_ball_rotation_angle;    // prev_ball_rotation_angle1 is the angle between the reference subimg and the rotation on the previous frame
        float angle_alignment_threshold               = 0.2f; // 0.3f; // 0.4f
        float position_alignment_theshold             = 12.0f; //  8.0f; // 4.0f;        // overwritten below
        
        float rotation_angle_start = -0.3f;  // 0.0f;
        float rotation_angle_end   =  0.6f;  // pi;
        float angle_step_size      =  0.02f; // (3.0f / 180) * pi; // (4.0f / 180) * pi; // 4 degrees // pi / 180.0f; //  pi / 80.0f; //  pi / 40.0f; // 4.0f; // 80.0f;
        
        float pattern_score1 = -999999.9f;
        
        // First check if there is no movement:  set position_alignment_theshold to small value (3); if score is good and similar to previous good score continue; otherwise due more extensive search
        int num_phases = 2; // 1; // 2;
        // num_phases = 1;   // testing
        
        for (int phase_no = 2; phase_no <= num_phases; phase_no++)
        {
            line_score_max1 = -999999;    // reset
            
            //     if (phase_no == 1) { position_alignment_theshold =  3.0f; }
            //     else               { position_alignment_theshold = 12.0f; }
            if      (phase_no == 1) { position_alignment_theshold =  2.0f;  angle_alignment_threshold = 0.00001f; }  // not currently used
            else if (phase_no == 2) { position_alignment_theshold =  4.0f;  angle_alignment_threshold = 0.2f; }
            else                    { position_alignment_theshold = 12.0f;  angle_alignment_threshold = 0.2f;  }     // not currently used
            
            
            if (frame_no > 5) // 6)   // replace this by condition that checks if there is a continous motion
            {
                rotation_angle_start = rotated_prev_obj_rot_angle1 - angle_alignment_threshold;
                rotation_angle_end   = rotated_prev_obj_rot_angle1 + angle_alignment_threshold;
                
                scan_radius_x_start  = prev_chest_point_offset_x - position_alignment_theshold;      // "chest point" refers to the chest point of the blast man, which is placed at the center of the ball initially
                scan_radius_x_end    = prev_chest_point_offset_x + position_alignment_theshold;
                
                scan_radius_y_start  = prev_chest_point_offset_y - position_alignment_theshold;
                scan_radius_y_end    = prev_chest_point_offset_y + position_alignment_theshold;
            }
            
            
            
            for (double rotation_angle = rotation_angle_start;  rotation_angle < rotation_angle_end;  rotation_angle += angle_step_size)
                // for (float rotation_angle = rotation_angle_start;  rotation_angle < rotation_angle_end;  rotation_angle += angle_step_size)
            {
                bool rotation_change = true;
                // if (frame_no > 40) { rotation_change = false; }
                if (rotation_change)              // for efficiency -- this does not work
                {
                    // Perform rotation once - use for each x,y position explored...
                    // Apply rotation_angle to prev_ball_box_subimg (ref_ball_box_subimg) and store the result in "prev_ball_box_subimg_rotated"
                    int pix_count = 0;
                    int rect_start_x = (obj_center_x - rotation_rect_radius) - (obj_center_x - radius1);   // The larger square is the reference system
                    int rect_end_x   = (obj_center_x + rotation_rect_radius) - (obj_center_x - radius1);
                    int rect_start_y = (obj_center_y - rotation_rect_radius) - (obj_center_y - radius1);
                    int rect_end_y   = (obj_center_y + rotation_rect_radius) - (obj_center_y - radius1);
                    for (int pix_x = rect_start_x;  pix_x < rect_end_x;  pix_x++)
                    {
                        for (int pix_y = rect_start_y;  pix_y < rect_end_y;  pix_y++)
                        {
                            double pix_x_rot = (double)pix_x;          // point to be rotated
                            double pix_y_rot = (double)pix_y;
                            // float pix_x_rot = (float)pix_x;          // point to be rotated
                            // float pix_y_rot = (float)pix_y;
                            pix_x_rot -= (double) radius1;        // coordinates relative to ball center (rectangle is center at ball center)
                            pix_y_rot -= (double) radius1;
                            // pix_x_rot -= (float) radius1;        // coordinates relative to ball center (rectangle is center at ball center)
                            // pix_y_rot -= (float) radius1;
                            
                            [self rotate_point_around_origin_d :&(pix_x_rot) :&(pix_y_rot) :rotation_angle];
                            
                            pix_x_rot += (double) radius1;                 // change back to coordinate system with origin at upper left corner of ball_box_subimg
                            pix_y_rot += (double) radius1;
                            // pix_x_rot += (float) radius1;                 // change back to coordinate system with origin at upper left corner of ball_box_subimg
                            // pix_y_rot += (float) radius1;
                            
                            int idx = pix_count * 2;
                            if (idx < prev_ball_box_subimg_rotated_arr_length)
                            {
                                prev_ball_box_subimg_rotated[idx]     = pix_x_rot;
                                prev_ball_box_subimg_rotated[idx + 1] = pix_y_rot;
                            }
                            pix_count++;
                        }
                    }
                }
                
                for (float point_x = scan_radius_x_start;  point_x <= scan_radius_x_end;  point_x += scan_x_step_size)
                {
                    for (float point_y = scan_radius_y_start;  point_y <= scan_radius_y_end;  point_y += scan_y_step_size)
                    {
                        pattern_score1 = [self evaluate_pattern :rotation_rect_radius :point_x :point_y :obj_center_x :obj_center_y :radius1];     // compare the rotated prev_ball_box_subimg (prev_ball_box_subimg_rotated) with the curr_ball_box_subimg
                        // printf("        ---.  rotation_angle: %5.2f   pattern_score1: %5.2f \n", [self to_deg :rotation_angle], pattern_score1);
                        
                        if (pattern_score1 > line_score_max1)
                        {
                            line_score_max1 = pattern_score1;
                            line_center_max1_x = point_x;
                            line_center_max1_y = point_y;
                            rotation_angle_max1 = rotation_angle;
                            // printf("            -<>- putt - debug - point_x: %2.2f  point_y: %2.2f  line_score: %2.2f  blastman_score1: %2.2f  line_center_max1_x: %2.2f  line_center_max1_y: %2.2f  orientation_angle_max1: %2.2f deg \n",  point_x, point_y, blastman_score, blastman_score1, line_center_max1_x, line_center_max1_y, [self to_deg :orientation_angle_max1]);
                        }
                        // printf("            -<>- putt - debug - point_x: %2.2f  point_y: %2.2f  line_score: %2.2f  blastman_score1: %2.2f  line_center_max1_x: %2.2f  line_center_max1_y: %2.2f  orientation_angle_max1: %2.2f deg \n",  point_x, point_y, blastman_score1, blastman_score1, line_center_max1_x, line_center_max1_y, [self to_deg :orientation_angle_max1]);
                    }
                }
            }
            
            // if (line_score_max1 > 900)  { break; }   // 800 // Good enough - don't need to do more extensive search (phase 2)   // this measure needs to be normalized so that it works with other patterns
        }
        
        
        float delta_rotation_angle_max1 = rotation_angle_max1 - prev_delta_rotation_angle1;    // use this when comparing current subimage with previous subimage (instead of with initial subimg)
        // delta_rotation_angle = delta_rotation_angle_max1;
        // ball_rotation_angle_acc += delta_rotation_angle_max1;
        
        rotation_angle_max1 += ref_ball_rotation_angle;   // add reference angle so that rotation_angle_max1 is the complete rotation angle (from start of rotation)
        blast_man_rotation_angle = rotation_angle_max1;
        line_graph_rotation_angle = obj_rot_angle1;       // is this used?
        
        // float blast_man_rotation_angle = ball_rotation_angle_acc; // rotation_angle_max1;
        // float line_graph_rotation_angle = blast_man_rotation_angle; // obj_rot_angle1

        
        printf("         -<>-.   putt - strongest pattern match - ball_box_subimg_swap: %d   line_score_max1: %2.2f   line_center_max1_x: %2.2f   line_center_max1_y: %2.2f    rotation_angle_max1: %2.2f deg \n",  ball_box_subimg_swap, line_score_max1, line_center_max1_x, line_center_max1_y, [self to_deg :rotation_angle_max1]);

    }
 
    
    // Set the blastman position and orientation according to the best fit computed above (line_center_max1_x, line_center_max1_y, orientation_angle_max1)
    {
        [self fill_in_blastman_points :num_blastman1_points :blastman1_radius  :blastman1_points_x  :blastman1_points_y];     // reset blastman points
        
        // Apply search shift:
        for (int point_no = 0; point_no < num_blastman1_points; point_no++)
        {
            blastman1_points_x[point_no] += object_center_x + line_center_max1_x;
            blastman1_points_y[point_no] += object_center_y + line_center_max1_y;
        }
        
        // Rotate the blastman by "orientation_angle" (chest point is center of rotation).
        // Shift to origin - rotate - shift back to position:
        
        float chest_point_x = blastman1_points_x[2];
        float chest_point_y = blastman1_points_y[2];
        
        for (int point_no = 0; point_no < num_blastman1_points; point_no++)
        {
            blastman1_points_x[point_no] -= chest_point_x;
            blastman1_points_y[point_no] -= chest_point_y;
            
            [self rotate_point_around_origin :&(blastman1_points_x[point_no]) :&(blastman1_points_y[point_no]) :blast_man_rotation_angle];
            
            blastman1_points_x[point_no] += chest_point_x;
            blastman1_points_y[point_no] += chest_point_y;
        }
        
        prev_chest_point_offset_x = line_center_max1_x;
        prev_chest_point_offset_y = line_center_max1_y;
    }
    

    // obj_rot_angle += rotation_angle_max1;      // obj_rot_angle is the orientation (cumulative angle)
    obj_rot_angle  = rotation_angle_max1;      // obj_rot_angle is the orientation (relative to ref_ball_box_subimg)
    obj_rot_angle1 = obj_rot_angle;
    delta_rotation_angle = obj_rot_angle1 - prev_ball_rotation_angle1;
    
    printf("         -<>-.   orientation_angle_max1: %5.2f deg   prev_ball_rotation_angle1: %5.2f deg   prev_delta_rotation_angle1: %5.2f deg   rotated_prev_obj_rot_angle1: %5.2f deg   obj_rot_angle1: %5.2f deg   obj_rot_angle2: %5.2f deg   delta_rotation_angle: %5.2f deg \n",  [self to_deg :rotation_angle_max1], [self to_deg :prev_ball_rotation_angle1], [self to_deg :prev_delta_rotation_angle1], [self to_deg :rotated_prev_obj_rot_angle1], [self to_deg :obj_rot_angle1], [self to_deg :obj_rot_angle2], [self to_deg :delta_rotation_angle]);
    
    obj_rot_angle = obj_rot_angle1;                       // This defines the orietation (clockwise rotation from 3 o'clock orientation)
    
    [_draw_field2 set_rotation_angle :line_graph_rotation_angle];    // set the orientation of the red box
    // if (frame_no == 37) { [_draw_field2 set_rotation_angle :M_PI]; } // TEMP FOR TESING
    
    
    
    float time_per_frame = 1.0f / ((float) (video_fps/fps_reduction_factor));   // in seconds
    int ball_rpm_curr = (int) (((delta_rotation_angle / 3.14159f) / time_per_frame) * 60.0f);    // multiply by 60 to get from seconds to minutes
    
    if (frame_no > 8)
    {
        // Track the last 8 rpm values and average over these to smooth out quick rotation due detection accuracy limitations:
        int ball_rpm_ave = [self get_average_ball_rpm :ball_rpm_curr];
        ball_rpm = ball_rpm_ave;                                                                   // ball_rpm this is displayed in UI
        
        // if (ball_rpm > max_ball_rpm) { max_ball_rpm = ball_rpm; }                           // ball_rpm and max_ball_rpm are displayed in UI
        if (ball_rpm_ave > max_ball_rpm) { max_ball_rpm = ball_rpm_ave; }                      // ball_rpm and max_ball_rpm are displayed in UI
        
        if (true) // (frame_no > 40)
        {
            [self update_ball_rpm_arr :ball_rpm];
        }
        
        if ((frame_no > 16) && (ball_rpm_ave > 150) && (skid_end_frame_no == 0))
        {
            skid_end_frame_no = frame_no;
        }
        
        ball_orientation = line_graph_rotation_angle * 57.2957795f;      // Convert to degrees
        
        // When the ball rotated 90 degress compute distance traveled since impact:
        if ((ball_orientation > 87.0f) && (ninety_degree_point == 0.0f))
        {
            float delta_x_since_impact = ((float)object_center_x * meters_per_pixel) - impact_ball_position_x;
            float delta_y_since_impact = ((float)object_center_y * meters_per_pixel) - impact_ball_position_y;
            ninety_degree_point = sqrt(delta_x_since_impact * delta_x_since_impact + delta_y_since_impact * delta_y_since_impact) * 39.3701f;   // convert to inches
            
            ninety_deg_obj_pos_x = (float) obj_center_x;
            ninety_deg_obj_pos_y = (float) obj_center_y;
        }
    }

    
    // This may not be currently used:
    if (ball_image_changed)
    {
        if (ball_box_subimg_swap == 1)
        {
            // save to ball_box_subimg1:
            for (int byte_no = 0; byte_no < ball_box_subimg_arr_length; byte_no++) { ball_box_subimg1[byte_no] = curr_ball_box_subimg[byte_no]; }
            ball_box_subimg_swap = 2;
            ball_rotation_angle_at_subimg1 = obj_rot_angle;
        }
        else
        {
            // save to ball_box_subimg2:
            for (int byte_no = 0; byte_no < ball_box_subimg_arr_length; byte_no++) { ball_box_subimg2[byte_no] = curr_ball_box_subimg[byte_no]; }
            ball_box_subimg_swap = 1;
            ball_rotation_angle_at_subimg2 = obj_rot_angle;
        }
    }


    return angle;   // not used
}



- (float) angle_diff_mod_180 :(float)ref_angle :(float)angle1  :(float *)angle_max_adjusted
{
    float pi = 3.14159;  // use M_PI
    float large_angle_threshold = pi / 2.0f; // 4.0f; // 8.0f;
    float angle_diff = 0.0f;
    
    angle_diff = ref_angle - angle1;
    
    if (fabs(angle_diff) > large_angle_threshold)
    {
        *angle_max_adjusted = angle1 - pi;
        angle_diff = ref_angle - *angle_max_adjusted;    // try subtraction 180 degress (Pi)
        
        if (fabs(angle_diff ) > large_angle_threshold)   // if it is still large subtract another 180 degress (Pi)  --- THIS NEEDS TO BE GENERALIZED TO WORK FOR MULTIPLE ROTATIONS
        {
            *angle_max_adjusted -= pi;
            angle_diff = ref_angle - *angle_max_adjusted;
        }
        
        
        // If it is still not a small angle, try the other rotation direction:
        if (fabs(angle_diff) > large_angle_threshold)    // try adding 180 degress (Pi)
        {
            *angle_max_adjusted = angle1 + pi;
            angle_diff = ref_angle - *angle_max_adjusted;
        }
        
        if (fabs(angle_diff ) > large_angle_threshold)   // if it is still large add another 180 degress (Pi)    --- THIS NEEDS TO BE GENERALIZED TO WORK FOR MULTIPLE ROTATIONS
        {
            *angle_max_adjusted += pi;
            angle_diff = ref_angle - *angle_max_adjusted;
        }
    }
    
    return angle_diff;
}



- (float) evaluate_line :(int)line_length :(unsigned char*)pix_arr :(float)object_center_x :(float)object_center_y :(float)point_x :(float)point_y :(float)angle
{
    float line_length_half = line_length / 2.0f;
    float flank_distance = 3.0f; // 2.0f;
    float score = 0;
    
    // Draw line centered on object_center:
    //    cos alpha = delta_x / line_length_half
    //    sin alpha = delta_y / line_length_half
    // alpha is the angle between the 3 o'clock orientation and line going downward.
    float delta_x = line_length_half * cosf(angle);
    float delta_y = line_length_half * sinf(angle);
    
    float start_point_x = object_center_x + ( point_x - delta_x );
    float start_point_y = object_center_y + ( point_y - delta_y );
    
    float end_point_x = object_center_x + ( point_x + delta_x );
    float end_point_y = object_center_y + ( point_y + delta_y );
    
    // Travers the line:
    float step_size = 1.0f;   // in pixels
    // if (ball_radius > 40) { step_size = 2.0f; }
    
    float vector_x = end_point_x - start_point_x;
    float vector_y = end_point_y - start_point_y;
    
    int num_steps = (int) (line_length / step_size);
    
    float vector_increment_x = vector_x / ((float) num_steps);
    float vector_increment_y = vector_y / ((float) num_steps);
    
    float vector_length = sqrt(vector_x * vector_x  +  vector_y * vector_y);
    float unit_vector_x = vector_x / vector_length;
    float unit_vector_y = vector_y / vector_length;
    
    float left_orthogonal_unit_vector_x =  unit_vector_y;
    float left_orthogonal_unit_vector_y = -unit_vector_x;
    
    float right_orthogonal_unit_vector_x = -unit_vector_y;
    float right_orthogonal_unit_vector_y =  unit_vector_x;
    
    for (int step_no = 0; step_no < num_steps; step_no++)   // traversing the line
    {
        float point_x = start_point_x + ((float) step_no) * vector_increment_x;
        float point_y = start_point_y + ((float) step_no) * vector_increment_y;
        
        // Get intensity value at this point and the 2 flanking points:
        float intensity_center = [ self get_weighted_pixel_intensity :(unsigned char*)pix_arr :point_x :point_y ];
        
        
        // Get intensity at left flanking pixel:
        float left_flank_point_x = point_x + (flank_distance * left_orthogonal_unit_vector_x);
        float left_flank_point_y = point_y + (flank_distance * left_orthogonal_unit_vector_y);
        
        float intensity_left = [ self get_weighted_pixel_intensity :(unsigned char*)pix_arr :left_flank_point_x :left_flank_point_y ];
        
        
        // Get intensity at left flanking pixel:
        float right_flank_point_x = point_x + (flank_distance * right_orthogonal_unit_vector_x);
        float right_flank_point_y = point_y + (flank_distance * right_orthogonal_unit_vector_y);
        
        float intensity_right = [ self get_weighted_pixel_intensity :pix_arr :right_flank_point_x :right_flank_point_y ];
        
        // Now evaluate if the center pixel is darker than the flanking pixels (as evidence that this is part of a line)
        if ((intensity_left > intensity_center) && (intensity_right > intensity_center))
        {
            score += 1.0f;
        }
    }
    
    // printf("            -<>- putt - debug2 -
    
    return score;
}



- (float) evaluate_blastman :(int)blastman_radius :(int)num_blastman1_points :(float *)blastman1_points_x :(float *)blastman1_points_y :(unsigned char*)pix_arr :(float)object_center_x :(float)object_center_y :(float)point_x :(float)point_y :(float)orientation_angle
{
    float flank_distance = 6.0f; // 5.0f; // 4.0f; // 1.9f; // 1.7f; // 1.5f; // 1.0f; // 2.0f; // 2.0f;
    float score = 0;

    
    // Apply search shift:
    for (int point_no = 0; point_no < num_blastman1_points; point_no++)
    {
        blastman1_points_x[point_no] += object_center_x + point_x;
        blastman1_points_y[point_no] += object_center_y + point_y;
    }
    
    
    // Rotate the blastman by "orientation_angle" (chest point is center of rotation).
       // Shift to origin - rotate - shift back to position:
    
    float chest_point_x = blastman1_points_x[2];
    float chest_point_y = blastman1_points_y[2];
    
    for (int point_no = 0; point_no < num_blastman1_points; point_no++)
    // for (int point_no = 0; point_no <= 4; point_no++)
    {
        blastman1_points_x[point_no] -= chest_point_x;
        blastman1_points_y[point_no] -= chest_point_y;
        
        [self rotate_point_around_origin :&(blastman1_points_x[point_no]) :&(blastman1_points_y[point_no]) :orientation_angle];
        
        blastman1_points_x[point_no] += chest_point_x;
        blastman1_points_y[point_no] += chest_point_y;
    }
    
    
    // For each blastman point check if there is a point on the image (get "point_score" and accumulate the point_scores in "total_point_score"); Check 8 pixels (about 3 pixels from the center) around the center of each point.
    for (int point_no = 0; point_no < num_blastman1_points; point_no++)
    {
        float point1_x = blastman1_points_x[point_no];
        float point1_y = blastman1_points_y[point_no];
        
        float score1 = [self evaluate_blastman_point :point1_x :point1_y :flank_distance :pix_arr];
        
        score += score1;
    }

    
    // printf("      --- evaluate_blastman - score: %5.2f \n", score);
    return score;
}



- (float) evaluate_blastman_point :(float)point_x :(float)point_y :(float)flank_distance :(unsigned char*)pix_arr
{
    float score = 0;
    float min_intensity_diff = 3.0f; // 6.0f; // 10.0f; // 30.0f; // 40.0f; // 20.0f;
    
    // float core_intensity = [ self get_weighted_pixel_intensity :pix_arr :point_x :point_y ];
    // float core_intensity = [ self get_pixel_intensity :pix_arr :point_x :point_y ];
    float core_intensity = 0.0f;
    int cnt = 0;
    for (int pix_x = -3; pix_x <= 3; pix_x++)
    {
        for (int pix_y = -3; pix_y <= 3; pix_y++)
        {
            core_intensity += [ self get_pixel_intensity :pix_arr :(point_x + pix_x) :(point_y + pix_y) ];
            cnt++;
        }
    }
    core_intensity = core_intensity / ((float) cnt);
    
    
    // Travers a sqare around the center to evaluate intensity dropoff:
    int radius = (int) flank_distance;
    
    /*
    int horizontal_line1_y = point_y - radius;
    int horizontal_line2_y = point_y + radius;
    for (int horizontal_line_x = (point_x - radius); horizontal_line_x <= (point_x + radius); horizontal_line_x++)
    {
        score = [self update_score :pix_arr :core_intensity :horizontal_line_x :horizontal_line1_y :min_intensity_diff :score];
        score = [self update_score :pix_arr :core_intensity :horizontal_line_x :horizontal_line2_y :min_intensity_diff :score];
    }
     */
    
    int vertical_line1_x = point_x - radius;
    int vertical_line2_x = point_x + radius;
    for (int vertical_line_y = (point_y - radius); vertical_line_y <= (point_y + radius); vertical_line_y++)
    {
        score = [self update_score :pix_arr :core_intensity :vertical_line1_x :vertical_line_y :min_intensity_diff :score];
        score = [self update_score :pix_arr :core_intensity :vertical_line2_x :vertical_line_y :min_intensity_diff :score];   // previous score is passed as argument
    }
    
    /*
    // Read the intensity of 8 pixels around the center (center pixel would be the dimmest):
    
    float out_point_x = point_x - flank_distance;
    float out_point_y = point_y;
    score = [self update_score :pix_arr :core_intensity :out_point_x :out_point_y :min_intensity_diff :score];
    
    out_point_x = point_x - flank_distance;
    out_point_y = point_y - flank_distance;
    score = [self update_score :pix_arr :core_intensity :out_point_x :out_point_y :min_intensity_diff :score];
    
    out_point_x = point_x;
    out_point_y = point_y - flank_distance;
    score = [self update_score :pix_arr :core_intensity :out_point_x :out_point_y :min_intensity_diff :score];

    out_point_x = point_x + flank_distance;
    out_point_y = point_y - flank_distance;
    score = [self update_score :pix_arr :core_intensity :out_point_x :out_point_y :min_intensity_diff :score];
    
    out_point_x = point_x + flank_distance;
    out_point_y = point_y;
    score = [self update_score :pix_arr :core_intensity :out_point_x :out_point_y :min_intensity_diff :score];
    
    out_point_x = point_x + flank_distance;
    out_point_y = point_y + flank_distance;
    score = [self update_score :pix_arr :core_intensity :out_point_x :out_point_y :min_intensity_diff :score];
    
    out_point_x = point_x;
    out_point_y = point_y + flank_distance;
    score = [self update_score :pix_arr :core_intensity :out_point_x :out_point_y :min_intensity_diff :score];
    
    out_point_x = point_x - flank_distance;
    out_point_y = point_y + flank_distance;
    score = [self update_score :pix_arr :core_intensity :out_point_x :out_point_y :min_intensity_diff :score];
    */
    
    return score;
}



- (float) evaluate_pattern :(int)rotation_rect_radius :(float)shift_x :(float)shift_y :(int)obj_center_x :(int)obj_center_y :(int)radius1
{
    float score = 0;
    
    int bytes_per_row2 = ball_box_width * 4;
    
    int arr_length = movie_frame_height * movie_frame_bytes_per_row;
    
    
    unsigned char * ref_ball_box_subimg = ball_box_subimg0;    // fixed pattern from start of swing (not updated)
    unsigned char * curr_ball_box_subimg = nullptr;
    unsigned char * prev_ball_box_subimg = nullptr;
    if (ball_box_subimg_swap == 1)
    {
        curr_ball_box_subimg = ball_box_subimg1;
        prev_ball_box_subimg = ball_box_subimg2;
    }
    else // ball_box_subimg_swap == 2
    {
        curr_ball_box_subimg = ball_box_subimg2;
        prev_ball_box_subimg = ball_box_subimg1;
    }
    
    
    int pix_count = 0;
    int rect_start_x = (obj_center_x - rotation_rect_radius) - (obj_center_x - radius1);   // The larger square is the reference system
    int rect_end_x   = (obj_center_x + rotation_rect_radius) - (obj_center_x - radius1);
    int rect_start_y = (obj_center_y - rotation_rect_radius) - (obj_center_y - radius1);
    int rect_end_y   = (obj_center_y + rotation_rect_radius) - (obj_center_y - radius1);
    for (int pix_x = rect_start_x;  pix_x < rect_end_x;  pix_x++)
    {
        for (int pix_y = rect_start_y;  pix_y < rect_end_y;  pix_y++)
        {
            size_t pixel_arr_idx1 = pix_y * bytes_per_row2 + pix_x * 4;
          //  int red1   = prev_ball_box_subimg[pixel_arr_idx1 + 2];
          //  int green1 = prev_ball_box_subimg[pixel_arr_idx1 + 1];
          //  int blue1  = prev_ball_box_subimg[pixel_arr_idx1];
            int red1   = ref_ball_box_subimg[pixel_arr_idx1 + 2];
            int green1 = ref_ball_box_subimg[pixel_arr_idx1 + 1];
            int blue1  = ref_ball_box_subimg[pixel_arr_idx1];
            
            // Apply the rotation stored in "prev_ball_box_subimg_rotated" to "curr_ball_box_subimg" (so that a pixel in prev_ball_box_subimg is matched to the point where it would be rotated to in curr_ball_box_subimg
            int idx2 = pix_count * 2;
            if (idx2 < prev_ball_box_subimg_rotated_arr_length)
            {
                int pix_x_rot = (int) ( 0.5 + prev_ball_box_subimg_rotated[idx2] );
                int pix_y_rot = (int) ( 0.5 + prev_ball_box_subimg_rotated[idx2 + 1] );
                
                // size_t pixel_arr_idx2 = pix_y_rot * bytes_per_row2 + pix_x_rot * 4;
                int pixel_arr_idx2 = (pix_y_rot + shift_y) * bytes_per_row2 + (pix_x_rot + shift_x) * 4;
                
                if ((pixel_arr_idx2 >= 0) && (pixel_arr_idx2 < arr_length))
                {
                    int red2   = curr_ball_box_subimg[pixel_arr_idx2 + 2];
                    int green2 = curr_ball_box_subimg[pixel_arr_idx2 + 1];
                    int blue2  = curr_ball_box_subimg[pixel_arr_idx2];
                    
                    // TODO: If the rotation is correct the intensities should match (red1 == red2; green1 == green2; blue1 = blue2)...
                    
                    if ((red1 == 0) && (green1 == 0) && (blue1 == 255))      // only consider pixel that were set blue in the current image
                    {
                        if ((red1 == red2) && (green1 == green2) && (blue1 == blue2))
                        {
                            score += 1;
                        }
                    }
                }
            }
            
            // if (pix_count < 10)
            // {
            //     printf("                  ---.*  pix_count: %d   pix_x: %d   pix_y: %d   pix_x_rot: %d   pix_x_rot: %d   pix_y_rot: %d \n",  pix_count, pix_x, pix_y, pix_x_rot, pix_y_rot);
            // }
            
            pix_count++;
        }
    }

    
    // printf("        --- evaluate_pattern - score: %5.2f \n", score);
    return score;
}



- (float) update_score :(unsigned char*)pix_arr :(float)core_intensity :(float)out_point_x :(float)out_point_y :(float)min_intensity_diff :(float)score_curr
{
    float score = 0.0f;
    
    // out_intensity = [ self get_weighted_pixel_intensity :pix_arr :out_point_x :out_point_y ];
    float out_intensity = [ self get_pixel_intensity :pix_arr :out_point_x :out_point_y ];
    
    // if (out_intensity > (core_intensity + min_intensity_diff))  { score++; }
    
    float intensity_diff = out_intensity - core_intensity;
    
    // score = score_curr + intensity_diff;
    if      (intensity_diff > (3.0f * min_intensity_diff)) { score = score_curr + 3.0f; }
    else if (intensity_diff > (2.0f * min_intensity_diff)) { score = score_curr + 2.0f; }
    else if (intensity_diff >         min_intensity_diff)  { score = score_curr + 1.0f; }
    else if (intensity_diff < (3.0f * -min_intensity_diff))  { score = score_curr - 3.0f; }
    else if (intensity_diff < (2.0f * -min_intensity_diff))  { score = score_curr - 2.0f; }
    else if (intensity_diff <         -min_intensity_diff)   { score = score_curr - 1.0f; }
    
    return score;
}



- (void) update_ball_speed_arr :(int)frame_no :(float)ball_speed_in_mph
{
    ball_speed_arr[ball_speed_arr_start_idx] = ball_speed_in_mph;
    ball_speed_arr_start_idx++;
    if (ball_speed_arr_start_idx == ball_speed_arr_length) { ball_speed_arr_start_idx = 0; }   // circular array
    
    head_speed_arr_start_idx++;          // keep the 2 arrays in synch (ball_speed_arr_start_idx has already been incremented)
    if (head_speed_arr_start_idx == head_speed_arr_length) { head_speed_arr_start_idx = 0; }         // circular array
    
    ball_rpm_arr_start_idx++;            // keep the 2 arrays in synch (ball_speed_arr_start_idx has already been incremented)
    if (ball_rpm_arr_start_idx == ball_rpm_arr_length) { ball_rpm_arr_start_idx = 0; }         // circular array
    
    [ _draw_field_graph set_ball_speed_graph_start_idx :frame_no :ball_speed_arr_start_idx ];
    
    if (impact_frame_no != 0)
    {
        // ball_speed_arr_impact_frame_no = ball_speed_arr_start_idx;
        [ _draw_field_graph set_ball_speed_arr_impact_frame_no :(ball_speed_arr_start_idx - 2) ];     // subtract 2 to adjust for various index base values
    }
}


- (void) update_head_speed_arr :(int)frame_no :(float)head_speed_in_mph
{
    int idx = head_speed_arr_start_idx - 1;
    if (idx < 0) {idx = head_speed_arr_length - 1; }
    head_speed_arr[idx] = head_speed_in_mph;        // ball_rpm_arr_start_idx has already been incremented in "update_ball_speed_arr"
    // head_speed_arr_start_idx++;
    // if (head_speed_arr_start_idx == head_speed_arr_length) { head_speed_arr_start_idx = 0; }   // circular array
    
    // [ _draw_field_graph set_head_speed_graph_start_idx :frame_no :head_speed_arr_start_idx ];
}



- (float) get_last_ball_speed
{
    int idx = ball_speed_arr_start_idx - 1;
    if (idx < 0) { idx = ball_speed_arr_length - 1; }
    float ball_speed_in_mph = ball_speed_arr[idx];
    return ball_speed_in_mph;
}



- (void) update_ball_rpm_arr :(float)ball_rpm1
{
    // ball_rpm_arr_start_idx = ball_speed_arr_start_idx - 1;    // keep the 2 arrays in synch (ball_speed_arr_start_idx has already been incremented)
    int idx = ball_rpm_arr_start_idx - 1;
    if (idx < 0) { idx = ball_rpm_arr_length - 1; }         // circular array
    ball_rpm_arr[idx] = ball_rpm1;        // ball_rpm_arr_start_idx has already been incremented in "update_ball_speed_arr"
    // ball_rpm_arr[ball_rpm_arr_start_idx] = ball_rpm1;
    // ball_rpm_arr_start_idx++;
    // if (ball_rpm_arr_start_idx == ball_rpm_arr_length) { ball_rpm_arr_start_idx = 0; }         // circular array
}



- (void) rotate_point_around_origin :(float *) pt_x :(float *) pt_y :(float) angle
{
    // *pt_x += 3;
    float pt_x_new = cosf(angle) * *pt_x - sinf(angle) * *pt_y;
    float pt_y_new = sinf(angle) * *pt_x + cosf(angle) * *pt_y;
    
    *pt_x = pt_x_new;
    *pt_y = pt_y_new;
}


- (void) rotate_point_around_origin_d :(double *) pt_x :(double *) pt_y :(double) angle
{
    // *pt_x += 3;
    double pt_x_new = cosf(angle) * *pt_x - sinf(angle) * *pt_y;
    double pt_y_new = sinf(angle) * *pt_x + cosf(angle) * *pt_y;
    
    *pt_x = pt_x_new;
    *pt_y = pt_y_new;
}



- (float) get_average_ball_speed :(float)ball_speed_new
{
    ball_speed_4 = ball_speed_3;
    ball_speed_3 = ball_speed_2;
    ball_speed_2 = ball_speed_1;
    ball_speed_1 = ball_speed_new;
    
    // float average_ball_speed = (ball_speed_4 + ball_speed_3 + ball_speed_2 + ball_speed_1) / 4.0f;
    // float average_ball_speed = (ball_speed_3 + ball_speed_2 + ball_speed_1) / 3.0f;
    float average_ball_speed = (ball_speed_2 + ball_speed_1) / 2.0f;
    
    return average_ball_speed;
}



- (float) get_average_clubhead_speed :(float)clubhead_speed
{
    clubhead_speed_mph_minus_4 = clubhead_speed_mph_minus_3;
    clubhead_speed_mph_minus_3 = clubhead_speed_mph_minus_2;
    clubhead_speed_mph_minus_2 = clubhead_speed_mph_minus_1;
    clubhead_speed_mph_minus_1 = clubhead_speed;
    
    float average_clubhead_speed = (clubhead_speed_mph_minus_3 + clubhead_speed_mph_minus_2 + clubhead_speed_mph_minus_1) / 3.0f;
    // float average_clubhead_speed = (clubhead_speed_mph_minus_1) / 1.0f;
    
    return average_clubhead_speed;
}



- (void) update_trail_of_shaft_lines :(double)slope :(double)offset
{
    shaft_line_slope_minus_10 = shaft_line_slope_minus_9;
    shaft_line_slope_minus_9 = shaft_line_slope_minus_8;
    shaft_line_slope_minus_8 = shaft_line_slope_minus_7;
    shaft_line_slope_minus_7 = shaft_line_slope_minus_6;
    shaft_line_slope_minus_6 = shaft_line_slope_minus_5;
    shaft_line_slope_minus_5 = shaft_line_slope_minus_4;
    shaft_line_slope_minus_4 = shaft_line_slope_minus_3;
    shaft_line_slope_minus_3 = shaft_line_slope_minus_2;
    shaft_line_slope_minus_2 = shaft_line_slope_minus_1;
    shaft_line_slope_minus_1 = slope;
    
    shaft_line_offset_minus_10 = shaft_line_offset_minus_9;
    shaft_line_offset_minus_9 = shaft_line_offset_minus_8;
    shaft_line_offset_minus_8 = shaft_line_offset_minus_7;
    shaft_line_offset_minus_7 = shaft_line_offset_minus_6;
    shaft_line_offset_minus_6 = shaft_line_offset_minus_5;
    shaft_line_offset_minus_5 = shaft_line_offset_minus_4;
    shaft_line_offset_minus_4 = shaft_line_offset_minus_3;
    shaft_line_offset_minus_3 = shaft_line_offset_minus_2;
    shaft_line_offset_minus_2 = shaft_line_offset_minus_1;
    shaft_line_offset_minus_1 = offset;
}



- (void) update_trail_of_clubhead_speeds :(float)clubhead_speed_mph_ave
{
    smoothed_clubhead_speed_mph_minus_4 = smoothed_clubhead_speed_mph_minus_3;
    smoothed_clubhead_speed_mph_minus_3 = smoothed_clubhead_speed_mph_minus_2;
    smoothed_clubhead_speed_mph_minus_2 = smoothed_clubhead_speed_mph_minus_1;
    smoothed_clubhead_speed_mph_minus_1 = clubhead_speed_mph_ave;
}


- (int) get_average_ball_rpm :(int)ball_rpm1
{
    ball_rpm_minus_8 = ball_rpm_minus_7;
    ball_rpm_minus_7 = ball_rpm_minus_6;
    ball_rpm_minus_6 = ball_rpm_minus_5;
    ball_rpm_minus_5 = ball_rpm_minus_4;
    ball_rpm_minus_4 = ball_rpm_minus_3;
    ball_rpm_minus_3 = ball_rpm_minus_2;
    ball_rpm_minus_2 = ball_rpm_minus_1;
    ball_rpm_minus_1 = ball_rpm1;
    
    int average_ball_rpm = (ball_rpm_minus_8 + ball_rpm_minus_7 + ball_rpm_minus_6 + ball_rpm_minus_5 + ball_rpm_minus_4 + ball_rpm_minus_3 + ball_rpm_minus_2 + ball_rpm_minus_1) / 8;
    
    // printf("      --- ball_rpm_minus_8, 7, 6, 5, 4, 3, 2, 1: %d %d %d %d %d %d %d %d \n", ball_rpm_minus_8, ball_rpm_minus_7, ball_rpm_minus_6, ball_rpm_minus_5, ball_rpm_minus_4, ball_rpm_minus_3, ball_rpm_minus_2, ball_rpm_minus_1);
    
    return average_ball_rpm;
}


- (float) get_ball_shape_score :(float)score
{
    ball_shape_score_minus_5 = ball_shape_score_minus_4;
    ball_shape_score_minus_4 = ball_shape_score_minus_3;
    ball_shape_score_minus_3 = ball_shape_score_minus_2;
    ball_shape_score_minus_2 = ball_shape_score_minus_1;
    ball_shape_score_minus_1 = score;
    
    float average_ball_shape_score = (ball_shape_score_minus_5 + ball_shape_score_minus_4 + ball_shape_score_minus_3 + ball_shape_score_minus_2 + ball_shape_score_minus_1) / 5.0f;
    
    return average_ball_shape_score;
}


- (float) get_blastman_score :(float)score
{
    blastman_score_minus_5 = blastman_score_minus_4;
    blastman_score_minus_4 = blastman_score_minus_3;
    blastman_score_minus_3 = blastman_score_minus_2;
    blastman_score_minus_2 = blastman_score_minus_1;
    blastman_score_minus_1 = score;
    
    float average_blastman_score = (blastman_score_minus_5 + blastman_score_minus_4 + blastman_score_minus_3 + blastman_score_minus_2 + blastman_score_minus_1) / 5.0f;
    
    return average_blastman_score;
}



-(void) track_top_ball_position :(int)pos_x_max :(int)pos_y_max :(int)score_max
{
    // Use:       int * top_n_ball_positions;
    //            int max_num_ball_positions;

    // Add new position into sorted array:
    
}



- (float) get_pixel_intensity :(unsigned char*)pix_arr :(float)point_x :(float)point_y
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    
    float intensity = 0.0f;
    int pixel1_x = (int) point_x;
    int pixel1_y = (int) point_y;
    
    if ((pixel1_x < image_width ) && (pixel1_y < image_height))
    {
        int bytes_per_row = movie_frame_bytes_per_row;
        int pixel_arr_idx = (pixel1_y * bytes_per_row) + ((pixel1_x + 1) * 4);
        
        int red2   = pix_arr[pixel_arr_idx + 2];
        int green2 = pix_arr[pixel_arr_idx + 1];
        int blue2  = pix_arr[pixel_arr_idx];
        int pixel_intensity2 = (red2 + green2 + blue2) / 3;
        
        intensity = (float)pixel_intensity2;
    }
    
    return intensity;
}



- (float) get_weighted_pixel_intensity :(unsigned char*)pix_arr :(float)point_x :(float) point_y
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    int bytes_per_row = movie_frame_bytes_per_row;
    
    //x float intensity1 = 0.0f;
    
    // Compute the distance from each of the 4 neighboring pixels and weigh their intensity accordingly:
    int pixel1_x = (int) point_x;
    int pixel1_y = (int) point_y;
    int pixel1_arr_idx = (pixel1_y * bytes_per_row) + (pixel1_x * 4);
    int red1   = pix_arr[pixel1_arr_idx + 2];
    int green1 = pix_arr[pixel1_arr_idx + 1];
    int blue1  = pix_arr[pixel1_arr_idx];
    int pixel_intensity1 = (red1 + green1 + blue1) / 3;
    int pixel_intensity = pixel_intensity1;   // will be overwritten below
    
    // Now include a portion of the pixel to the right:
    float portion_right = 0.0f;
    int pixel_intensity2 = 0;
    if (pixel1_x < (image_width - 1))
    {
        int pixel2_arr_idx = (pixel1_y * bytes_per_row) + ((pixel1_x + 1) * 4);   // pixel to the right
        int red2   = pix_arr[pixel2_arr_idx + 2];
        int green2 = pix_arr[pixel2_arr_idx + 1];
        int blue2  = pix_arr[pixel2_arr_idx];
        pixel_intensity2 = (red2 + green2 + blue2) / 3;
        
        portion_right = point_x - ((float) pixel1_x);   // include this fraction from the right pixel (and remove it from the first pixel)
        pixel_intensity += ((pixel_intensity2 * portion_right) - (pixel_intensity1 * portion_right));
    }
    
    // Now include a portion of the pixels below:
    float portion_below = 0.0f;
    if (pixel1_y < (image_height - 1))
    {
        int pixel3_arr_idx = ((pixel1_y + 1) * bytes_per_row) + (pixel1_x * 4);   // pixel below
        int red3   = pix_arr[pixel3_arr_idx + 2];
        int green3 = pix_arr[pixel3_arr_idx + 1];
        int blue3  = pix_arr[pixel3_arr_idx];
        int pixel_intensity3 = (red3 + green3 + blue3) / 3;
        
        portion_below = point_y - ((float) pixel1_y);   // include this faction from the pixel below (and remove it from the first pixel)
        float portion_below_only = portion_below * (1.0f - portion_right);
        float portion_below_right = portion_below * portion_right;
        
        pixel_intensity += ((pixel_intensity3 * portion_below_only) - (pixel_intensity1 * portion_below_only));   // add part of pixel 3 and remove same size part from pixel 1
        
        
        int pixel4_arr_idx = ((pixel1_y + 1) * bytes_per_row) + ((pixel1_x + 1) * 4);   // pixel below
        int red4   = pix_arr[pixel4_arr_idx + 2];
        int green4 = pix_arr[pixel4_arr_idx + 1];
        int blue4  = pix_arr[pixel4_arr_idx];
        int pixel_intensity4 = (red4 + green4 + blue4) / 3;
        
        pixel_intensity += ((pixel_intensity4 * portion_below_right) - (pixel_intensity2 * portion_below_right));   // add part of pixel 4 and remove same size part from pixel 2
    }
    
    return pixel_intensity;
}


- (int) get_diff_in_box1:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int)align_shift_x :(int)align_shift_y :(int)box_width :(int)box_height :(int)box_step_size :(int)box_diff_threshold :(int)x :(int)y
{
    // int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    // int half_width = image_width / 2;

    int red_diff_acc = 0;
    int green_diff_acc = 0;
    int blue_diff_acc = 0;
    
    int red1 = 0;
    int green1 = 0;
    int blue1 = 0;
    
    int red2 = 0;
    int green2 = 0;
    int blue2 = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int diff_box = 0;
    
    int pixel_arr_idx = 0;
    int prev_pixel_arr_idx = 0;
    
    int arr_length = image_height * bytesPerRow - 2;    // subtract 2 because 1 and 2 is added
    
    int cnt = 0;
    for (int bx = 0; bx < box_width; bx += box_step_size)
    {
        for (int by = 0; by < box_height; by += box_step_size)
        {
            pixel_arr_idx = ((y + by) * bytesPerRow) + ((x + bx) * 4);
            if (pixel_arr_idx < movie_frame_num_pixels)
            {
                red1   = pix_arr[pixel_arr_idx + 2];
                green1 = pix_arr[pixel_arr_idx + 1];
                blue1  = pix_arr[pixel_arr_idx];
                
                prev_pixel_arr_idx = (((y + align_shift_y) + by) * bytesPerRow) + (((x + align_shift_x) + bx) * 4);
                
                if ((prev_pixel_arr_idx >= 0) && (prev_pixel_arr_idx < arr_length))
                {
                    red2   = prev_pix_arr[prev_pixel_arr_idx + 2];
                    green2 = prev_pix_arr[prev_pixel_arr_idx + 1];
                    blue2  = prev_pix_arr[prev_pixel_arr_idx];
                    
                    red_diff_acc   += abs(red1 - red2);
                    green_diff_acc += abs(green1 - green2);
                    blue_diff_acc  += abs(blue1 - blue2);
                    
                    cnt++;
                }
            }
        }
   }
    
    if (cnt > 0)
    {
        red_ave = red_diff_acc / cnt;
        green_ave = green_diff_acc / cnt;
        blue_ave = blue_diff_acc / cnt;
        
        diff_box = red_ave + green_ave + blue_ave;
    }
    
    return diff_box;
}



// Using img_sect_align instead of aligh_shift_x and align_shift_y
- (int) get_diff_in_box2:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int)align_shift_x :(int)align_shift_y :(signed char *)img_sect_align :(int)box_width :(int)box_height :(int)box_step_size :(int)box_diff_threshold :(int)x :(int)y
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    

    // Compute the index into the matrix "img_sect_align":
    int col_width = image_width / img_sect_align_num_cols;
    int row_height = image_height / img_sect_align_num_rows;
    int col1 = x / col_width;
    int row1 = y / row_height;
    int idx1 = (row1 * img_sect_align_num_cols) + col1;
    int align_shift_x2 = img_sect_align[idx1 * 2];
    int align_shift_y2 = img_sect_align[idx1 * 2 + 1];
    
    
    // int half_width = image_width / 2;
    
    int red_diff_acc = 0;
    int green_diff_acc = 0;
    int blue_diff_acc = 0;
    
    int red1 = 0;
    int green1 = 0;
    int blue1 = 0;
    
    int red2 = 0;
    int green2 = 0;
    int blue2 = 0;
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int diff_box = 0;
    
    int pixel_arr_idx = 0;
    int prev_pixel_arr_idx = 0;
    
    int arr_length = image_height * bytesPerRow - 2;    // subtract 2 because 1 and 2 is added
    
    int cnt = 0;      // count the number of pixels inside the image
    for (int bx = 0; bx < box_width; bx += box_step_size)
    {
        for (int by = 0; by < box_height; by += box_step_size)
        {
            // printf("      --- x: %d  bx: %d  y: %d  by: %d \n",  x, bx, y, by);
            pixel_arr_idx = (int) ((y + by) * bytesPerRow) + ((x + bx) * 4);
            if ((pixel_arr_idx >= 0) && (pixel_arr_idx < arr_length))
            {
                red1   = pix_arr[pixel_arr_idx + 2];
                green1 = pix_arr[pixel_arr_idx + 1];
                blue1  = pix_arr[pixel_arr_idx];
            }
            
            // prev_pixel_arr_idx = (((y + align_shift_y) + by) * bytesPerRow) + (((x + align_shift_x) + bx) * 4);
            prev_pixel_arr_idx = (int) (((y + align_shift_y2) + by) * bytesPerRow) + (((x + align_shift_x2) + bx) * 4);
            
            if ((prev_pixel_arr_idx >= 0) && (prev_pixel_arr_idx < arr_length))
            {
                red2   = prev_pix_arr[prev_pixel_arr_idx + 2];
                green2 = prev_pix_arr[prev_pixel_arr_idx + 1];
                blue2  = prev_pix_arr[prev_pixel_arr_idx];
                
                red_diff_acc   += abs(red1 - red2);
                green_diff_acc += abs(green1 - green2);
                blue_diff_acc  += abs(blue1 - blue2);
                
                cnt++;
            }
        }
    }
    
    if (cnt == 0)    // this means the box is outside the image
    {
        printf("               img_sect_align matrix: \n");
        for (int img_sect_col = 0; img_sect_col < img_sect_align_num_cols; img_sect_col++)
        {
            for (int img_sect_row = 0; img_sect_row < img_sect_align_num_rows; img_sect_row++)
            {
                int idx = img_sect_row * img_sect_align_num_cols + img_sect_col;
                int shift_x2 = img_sect_align[idx * 2];
                int shift_y2 = img_sect_align[idx * 2 + 1];
                printf("                  row: %d  col: %d  shift_x: %d  shift_y: %d: \n", img_sect_row, img_sect_col, shift_x2, shift_y2);
            }
        }
    }
    
    if (cnt > 0)
    {
        red_ave   = red_diff_acc   / cnt;
        green_ave = green_diff_acc / cnt;
        blue_ave  = blue_diff_acc  / cnt;
    }
    
    diff_box = red_ave + green_ave + blue_ave;
    
    return diff_box;
}




- (int) verify_diff_in_box:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int)align_shift_x :(int)align_shift_y :(int)box_width :(int)box_height :(int)box_step_size :(int)box_diff_threshold :(int)x :(int)y
{
    // Minimize the difference to make sure the difference is not due image shift (apply additional shift to previous image)
    
    int diff_box_min = 999999999;
    int diff_box3 = 0;
    
    int shift_range2 = 1; // 2; // 3;
    for (int shift_x2 = -shift_range2; shift_x2 <= shift_range2; shift_x2++)
    {
        for (int shift_y2 = -shift_range2; shift_y2 <= shift_range2; shift_y2++)
        {
            int align_shift_x2 = align_shift_x + shift_x2;
            int align_shift_y2 = align_shift_y + shift_y2;
            
            diff_box3 = [self get_diff_in_box1 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x2 :align_shift_y2 :box_width :box_height :box_step_size :box_diff_threshold :x :y];
            
            if (diff_box3 < diff_box_min)
            {
                diff_box_min = diff_box3;
            }
        }
    }
    
    return diff_box_min;
}


- (int) compute_object_frame_diff:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int)align_shift_x :(int)align_shift_y :(signed char *)img_sect_align :(int)box_width :(int)box_height :(int)box_step_size :(int)box_diff_threshold :(int)x :(int)y
{
    // The obj-frame is separated by a 10 pixel gap. It is 10 pixel wide and forms a square round the 10x10 pix object
    
    // Minimize the object frame difference (apply additional shift to previous image)
    
    int diff_boxes_min = 999999999;
    
    int shift_range2 = 0; // 1; // 2; // 3;
    for (int shift_x2 = -shift_range2; shift_x2 <= shift_range2; shift_x2++)
    {
        for (int shift_y2 = -shift_range2; shift_y2 <= shift_range2; shift_y2++)
        {
            int align_shift_x2 = align_shift_x + shift_x2;
            int align_shift_y2 = align_shift_y + shift_y2;
            
            // Top bar
            // int new_x = x - 40;
            int new_x = x - 30;
            // int new_y = y - 40;
            int new_y = y - 30;
            int new_box_width = 90;    // CORRECT THIS
            int new_box_height = 10;
            
            int diff_box1 = 0;
            if ((new_y >= 0) && (new_y <= movie_frame_height))
            {
  //             diff_box1 = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x2 :align_shift_y2 :new_box_width :new_box_height :box_step_size :box_diff_threshold :new_x :new_y];
            }
            
            // Bottom bar
            // new_y = y + 40;
            new_y = y + 30;
            
            int diff_box2 = 0;
            if ((new_y >= 0) && (new_y <= movie_frame_height))
            {
                // diff_box2 = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x2 :align_shift_y2 :new_box_width :new_box_height :box_step_size :box_diff_threshold :new_x :new_y];
                diff_box2 = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x2 :align_shift_y2 :img_sect_align :new_box_width :new_box_height :box_step_size :box_diff_threshold :new_x :new_y];
            }
            
            // Left bar
            new_y = y - 30;
            new_box_width = 10;
            new_box_height = 70;       // CORRECT THIS
            
            int diff_box3 = 0;
            if ((new_y >= 0) && (new_y <= movie_frame_height))
            {
                // diff_box3 = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x2 :align_shift_y2 :new_box_width :new_box_height :box_step_size :box_diff_threshold :new_x :new_y];
                diff_box3 = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x2 :align_shift_y2 :img_sect_align :new_box_width :new_box_height :box_step_size :box_diff_threshold :new_x :new_y];
            }
            
            // Right bar
            // new_x = x + 40;
            new_x = x + 30;
            
            int diff_box4 = 0;
            if ((new_y >= 0) && (new_y <= movie_frame_height))
            {
                // diff_box4 = [self get_diff_in_box :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x2 :align_shift_y2 :new_box_width :new_box_height :box_step_size :box_diff_threshold :new_x :new_y];
                diff_box4 = [self get_diff_in_box2 :frame_no :bytesPerRow :prev_pix_arr :pix_arr :align_shift_x2 :align_shift_y2 :img_sect_align :new_box_width :new_box_height :box_step_size :box_diff_threshold :new_x :new_y];
            }
            
            int diff_boxes = diff_box1 + diff_box2 + diff_box3 + diff_box4;
            
            if (diff_boxes < diff_boxes_min) { diff_boxes_min = diff_boxes; }
        }
    }
    
    return diff_boxes_min;
}


- (void) save_clubhead_subimg :(unsigned char*)pix_arr :(int)obj_center_x :(int)obj_center_y
{
    int x_start = obj_center_x - box2_width_half;
    int x_end   = obj_center_x + box2_width_half;
    int y_start = obj_center_y - box2_height_half;
    int y_end   = obj_center_y + box2_height_half;
    
    
    if (   (x_start >= 0) && (x_end < movie_frame_width)
        && (y_start >= 0) && (y_end < movie_frame_height))
    {
        int pixel_arr_idx = 0;
        unsigned char red = 0;
        unsigned char green = 0;
        unsigned char blue = 0;
        int bytesPerRow = movie_frame_bytes_per_row;
        int subimg_idx = 0;
        for (int x = x_start;  x < x_end;  x++)
        {
            for (int y = y_start;  y < y_end;  y++)
            {
                pixel_arr_idx = (y * bytesPerRow) + (x * 4);
                red   = pix_arr[pixel_arr_idx + 2];
                green = pix_arr[pixel_arr_idx + 1];
                blue  = pix_arr[pixel_arr_idx];
                
                clubhead_subimg[subimg_idx]     = red;
                clubhead_subimg[subimg_idx + 1] = green;
                clubhead_subimg[subimg_idx + 2] = blue;
                
                /*
                // ------ DEBUGGING:
                red_subimg   = clubhead_subimg[subimg_idx];
                green_subimg = clubhead_subimg[subimg_idx + 1];
                blue_subimg  = clubhead_subimg[subimg_idx + 2];
                
                diff_red   = abs(red - red_subimg);
                diff_green = abs(green - green_subimg);
                diff_blue  = abs(blue - blue_subimg);
                
                if (diff_red   > diff_threshold) { diff++; }
                if (diff_green > diff_threshold) { diff++; }
                if (diff_blue  > diff_threshold) { diff++; }
                // ------ END DEBUGGING
                */
                
                subimg_idx += 3;
            }
        }
    }
    
    
    /*
    // DEBUGGING:    -- should see a difference    (diff should be zero)
     
     unsigned char red_subimg = 0;       // for debugging
     unsigned char green_subimg = 0;     // for debugging
     unsigned char blue_subimg = 0;      // for debugging
     int diff_threshold = 30;
     int diff_red = 0;
     int diff_green = 0;
     int diff_blue = 0;
     int diff = 0;
     
    int mask_pix_on_cnt = 0;     // for debugging
    int mask_pix_off_cnt = 0;    // for debugging
    
    int pixel_arr_idx = 0;
    unsigned char red = 0;
    unsigned char green = 0;
    unsigned char blue = 0;
    // unsigned char red_subimg = 0;
    // unsigned char green_subimg = 0;
    // unsigned char blue_subimg = 0;
    int subimg_idx = 0;
    int subimg_mask_idx = 0;
    int mask_value = 0;
    for (int x = x_start;  x < x_end;  x++)
    {
        for (int y = y_start;  y < y_end;  y++)
        {
            mask_value = clubhead_subimg_mask[subimg_mask_idx];     // 1 = masked out;  0 = not masked
            subimg_mask_idx++;
            
            if (mask_value == 0)
            {
                pixel_arr_idx = (y * movie_frame_bytes_per_row) + (x * 4);
                red   = pix_arr[pixel_arr_idx + 2];
                green = pix_arr[pixel_arr_idx + 1];
                blue  = pix_arr[pixel_arr_idx];
                
                red_subimg   = clubhead_subimg[subimg_idx];
                green_subimg = clubhead_subimg[subimg_idx + 1];
                blue_subimg  = clubhead_subimg[subimg_idx + 2];
                
                diff_red   = abs(red - red_subimg);
                diff_green = abs(green - green_subimg);
                diff_blue  = abs(blue - blue_subimg);
                
                if (diff_red   > diff_threshold) { diff++; }
                if (diff_green > diff_threshold) { diff++; }
                if (diff_blue  > diff_threshold) { diff++; }
                
                mask_pix_off_cnt++;
            }
            else
            {
                mask_pix_on_cnt++;
            }
            
            subimg_idx += 3;
        }
    }

    
    printf("        ---<4>---  debugging save_clubhead_subimg -- diff: %4d    mask_pix_on_cnt: %d   mask_pix_off_cnt: %d   mask_pix_total_cnt: %d \n", diff,  mask_pix_on_cnt, mask_pix_off_cnt, (mask_pix_on_cnt + mask_pix_off_cnt));
    */
}



- (void) save_club_shaft_subimg :(unsigned char*)pix_arr :(int)obj_center_x :(int)obj_center_y
{
    int x_start = obj_center_x - box3_width_half;
    int x_end   = obj_center_x + box3_width_half;
    int y_start = obj_center_y - box3_height_half;
    int y_end   = obj_center_y + box3_height_half;
    
    
    if (   (x_start >= 0) && (x_end < movie_frame_width)
        && (y_start >= 0) && (y_end < movie_frame_height))
    {
        int pixel_arr_idx = 0;
        unsigned char red = 0;
        unsigned char green = 0;
        unsigned char blue = 0;
        int bytesPerRow = movie_frame_bytes_per_row;
        int subimg_idx = 0;
        for (int x = x_start;  x < x_end;  x++)
        {
            for (int y = y_start;  y < y_end;  y++)
            {
                pixel_arr_idx = (y * bytesPerRow) + (x * 4);
                red   = pix_arr[pixel_arr_idx + 2];
                green = pix_arr[pixel_arr_idx + 1];
                blue  = pix_arr[pixel_arr_idx];
                
                club_shaft_subimg[subimg_idx]     = red;
                club_shaft_subimg[subimg_idx + 1] = green;
                club_shaft_subimg[subimg_idx + 2] = blue;
                
                subimg_idx += 3;
            }
        }
    }
}



- (int) compare_clubhead_subimg :(unsigned char*)pix_arr :(int)obj_center_x :(int)obj_center_y
{
    int diff = 0;
    
    int x_start = obj_center_x - box2_width_half;
    int x_end   = obj_center_x + box2_width_half;
    int y_start = obj_center_y - box2_height_half;
    int y_end   = obj_center_y + box2_height_half;
    
    int mask_pix_on_cnt = 0;     // for debugging
    int mask_pix_off_cnt = 0;    // for debugging
    
    if (   (x_start >= 0) && (x_end < movie_frame_width)
        && (y_start >= 0) && (y_end < movie_frame_height))
    {
        int pixel_arr_idx = 0;
        unsigned char red = 0;
        unsigned char green = 0;
        unsigned char blue = 0;
        unsigned char red_subimg = 0;
        unsigned char green_subimg = 0;
        unsigned char blue_subimg = 0;
        int bytesPerRow = movie_frame_bytes_per_row;
        int subimg_idx = 0;
        int subimg_mask_idx = 0;
        int mask_value = 0;
        int diff_threshold = 30;
        int diff_red = 0;
        int diff_green = 0;
        int diff_blue = 0;
        for (int x = x_start;  x < x_end;  x++)
        {
            for (int y = y_start;  y < y_end;  y++)
            {
                mask_value = clubhead_subimg_mask[subimg_mask_idx];     // 1 = masked out;  0 = not masked
                subimg_mask_idx++;
                
                if (mask_value == 0)
                {
                    pixel_arr_idx = (y * bytesPerRow) + (x * 4);
                    red   = pix_arr[pixel_arr_idx + 2];
                    green = pix_arr[pixel_arr_idx + 1];
                    blue  = pix_arr[pixel_arr_idx];
                    
                    red_subimg   = clubhead_subimg[subimg_idx];
                    green_subimg = clubhead_subimg[subimg_idx + 1];
                    blue_subimg  = clubhead_subimg[subimg_idx + 2];
                    
                    diff_red   = abs(red - red_subimg);
                    diff_green = abs(green - green_subimg);
                    diff_blue  = abs(blue - blue_subimg);
                    
                    if (diff_red   > diff_threshold) { diff++; }
                    if (diff_green > diff_threshold) { diff++; }
                    if (diff_blue  > diff_threshold) { diff++; }
                    
                    mask_pix_off_cnt++;
                }
                else
                {
                    mask_pix_on_cnt++;
                }
                
                subimg_idx += 3;
            }
        }
    }

    // printf("            ---M2---  mask_pix_on_cnt: %d   mask_pix_off_cnt: %d   mask_pix_total_cnt: %d \n",  mask_pix_on_cnt, mask_pix_off_cnt, (mask_pix_on_cnt + mask_pix_off_cnt));

    return diff;
}



- (int) compare_club_shaft_subimg :(unsigned char*)pix_arr :(int)obj_center_x :(int)obj_center_y
{
    int diff = 0;
    
    int x_start = obj_center_x - box2_width_half;
    int x_end   = obj_center_x + box2_width_half;
    int y_start = obj_center_y - box2_height_half;
    int y_end   = obj_center_y + box2_height_half;
    
    int mask_pix_on_cnt = 0;     // for debugging
    int mask_pix_off_cnt = 0;    // for debugging
    
    if (   (x_start >= 0) && (x_end < movie_frame_width)
        && (y_start >= 0) && (y_end < movie_frame_height))
    {
        int pixel_arr_idx = 0;
        unsigned char red = 0;
        unsigned char green = 0;
        unsigned char blue = 0;
        unsigned char red_subimg = 0;
        unsigned char green_subimg = 0;
        unsigned char blue_subimg = 0;
        int bytesPerRow = movie_frame_bytes_per_row;
        int subimg_idx = 0;
        int subimg_mask_idx = 0;
        int mask_value = 0;
        int diff_threshold = 30;
        int diff_red = 0;
        int diff_green = 0;
        int diff_blue = 0;
        for (int x = x_start;  x < x_end;  x++)
        {
            for (int y = y_start;  y < y_end;  y++)
            {
                mask_value = club_shaft_subimg_mask[subimg_mask_idx];     // 1 = masked out;  0 = not masked
                subimg_mask_idx++;
                
                if (mask_value == 0)
                {
                    pixel_arr_idx = (y * bytesPerRow) + (x * 4);
                    red   = pix_arr[pixel_arr_idx + 2];
                    green = pix_arr[pixel_arr_idx + 1];
                    blue  = pix_arr[pixel_arr_idx];
                    
                    red_subimg   = club_shaft_subimg[subimg_idx];
                    green_subimg = club_shaft_subimg[subimg_idx + 1];
                    blue_subimg  = club_shaft_subimg[subimg_idx + 2];
                    
                    diff_red   = abs(red - red_subimg);
                    diff_green = abs(green - green_subimg);
                    diff_blue  = abs(blue - blue_subimg);
                    
                    if (diff_red   > diff_threshold) { diff++; }
                    if (diff_green > diff_threshold) { diff++; }
                    if (diff_blue  > diff_threshold) { diff++; }
                    
                    mask_pix_off_cnt++;
                }
                else
                {
                    mask_pix_on_cnt++;
                }
                
                subimg_idx += 3;
            }
        }
    }
    
    // printf("            ---M2---  mask_pix_on_cnt: %d   mask_pix_off_cnt: %d   mask_pix_total_cnt: %d \n",  mask_pix_on_cnt, mask_pix_off_cnt, (mask_pix_on_cnt + mask_pix_off_cnt));
    
    return diff;
}



- (void) set_clubhead_background_mask :(unsigned char*)prev_pix_arr :(int)obj_center_x :(int)obj_center_y
{
    // This function compares the "current" image (pix_arr (copied to clubhead_subimg)) with previous image (prev_pix_arr). If there is little difference in a pixel, mask it out.
    // It also compares the "current" image with the next image (curr_img). If there is little change, mask it out (logic OR with privous mask value).
    
    int diff_threshold = 4; // 6; // 10; // 20; // 30;

    int x_start = obj_center_x - box2_width_half;
    int x_end   = obj_center_x + box2_width_half;
    int y_start = obj_center_y - box2_height_half;
    int y_end   = obj_center_y + box2_height_half;
    
    int mask_pix_on_cnt = 0;     // for debugging
    int mask_pix_off_cnt = 0;    // for debugging
    
    if (   (x_start >= 0) && (x_end < movie_frame_width)
        && (y_start >= 0) && (y_end < movie_frame_height))
    {
        int pixel_arr_idx = 0;
        unsigned char   red = 0;
        unsigned char green = 0;
        unsigned char  blue = 0;
        unsigned char   red_subimg = 0;
        unsigned char green_subimg = 0;
        unsigned char  blue_subimg = 0;
        unsigned char   red_next_img = 0;
        unsigned char green_next_img = 0;
        unsigned char  blue_next_img = 0;
        int bytesPerRow = movie_frame_bytes_per_row;
        int subimg_idx = 0;
        int subimg_mask_idx = 0;
        int diff_red   = 0;
        int diff_green = 0;
        int diff_blue  = 0;
        int diff_red_next   = 0;
        int diff_green_next = 0;
        int diff_blue_next  = 0;
        for (int x = x_start;  x < x_end;  x++)
        {
            for (int y = y_start;  y < y_end;  y++)
            {
                pixel_arr_idx = (y * bytesPerRow) + (x * 4);
                
                red   = prev_pix_arr[pixel_arr_idx + 2];            // previous image
                green = prev_pix_arr[pixel_arr_idx + 1];
                blue  = prev_pix_arr[pixel_arr_idx];
                
                red_next_img   = curr_img[pixel_arr_idx + 2];       // next image (curr_img)
                green_next_img = curr_img[pixel_arr_idx + 1];
                blue_next_img  = curr_img[pixel_arr_idx];
                
                red_subimg   = clubhead_subimg[subimg_idx];         // "current" image
                green_subimg = clubhead_subimg[subimg_idx + 1];
                blue_subimg  = clubhead_subimg[subimg_idx + 2];
                subimg_idx += 3;
                
                diff_red   = abs(red - red_subimg);
                diff_green = abs(green - green_subimg);
                diff_blue  = abs(blue - blue_subimg);
                
                diff_red_next   = abs(red_subimg   - red_next_img);
                diff_green_next = abs(green_subimg - green_next_img);
                diff_blue_next  = abs(blue_subimg  - blue_next_img);
                
                if (    (true) && ((diff_red > diff_threshold) || (diff_green > diff_threshold) || (diff_blue > diff_threshold))
                    &&  (true) && ((diff_red_next > diff_threshold) || (diff_green_next > diff_threshold) || (diff_blue_next > diff_threshold))
                   )
                {
                    clubhead_subimg_mask[subimg_mask_idx] = 0;     // 0 means change in pixel value
                    mask_pix_on_cnt++;
                }
                else
                {
                    clubhead_subimg_mask[subimg_mask_idx] = 1;     // mask out stationary background (we don't want to match stationary background patterns)
                    mask_pix_off_cnt++;
                }
                
                // if (y == obj_center_y)    // debugging
                // {
                //     printf("            ---M1a---  clubhead_subimg_mask -- x: %4d   y: %4d   clubhead_subimg_mask[ %4d ]: %d   diff_red: %4d   diff_green: %4d   diff_blue: %4d  \n",  x, y, subimg_mask_idx, clubhead_subimg_mask[subimg_mask_idx], diff_red, diff_green, diff_blue);
                // }
                
                subimg_mask_idx++;
            }
        }
    }
    
    printf("         ---M1---  mask_pix_on_cnt: %d   mask_pix_off_cnt: %d   mask_pix_total_cnt: %d \n",  mask_pix_on_cnt, mask_pix_off_cnt, (mask_pix_on_cnt + mask_pix_off_cnt));
}



- (void) set_club_shaft_background_mask :(unsigned char*)prev_pix_arr :(int)obj_center_x :(int)obj_center_y
{
    // This function compares the "current" image (pix_arr (copied to clubhead_subimg)) with previous image (prev_pix_arr). If there is little difference in a pixel, mask it out.
    // It also compares the "current" image with the next image (curr_img). If there is little change, mask it out (logic OR with privous mask value).
    
    int diff_threshold = 20; // 12; // 8; // 4; // 6; // 10; // 20; // 30;
    
    int x_start = obj_center_x - box3_width_half;
    int x_end   = obj_center_x + box3_width_half;
    int y_start = obj_center_y - box3_height_half;
    int y_end   = obj_center_y + box3_height_half;
    
    int mask_pix_on_cnt = 0;     // for debugging
    int mask_pix_off_cnt = 0;    // for debugging
    
    if (   (x_start >= 0) && (x_end < movie_frame_width)
        && (y_start >= 0) && (y_end < movie_frame_height))
    {
        int pixel_arr_idx = 0;
        unsigned char   red = 0;
        unsigned char green = 0;
        unsigned char  blue = 0;
        unsigned char   red_subimg = 0;
        unsigned char green_subimg = 0;
        unsigned char  blue_subimg = 0;
        unsigned char   red_next_img = 0;
        unsigned char green_next_img = 0;
        unsigned char  blue_next_img = 0;
        int bytesPerRow = movie_frame_bytes_per_row;
        int subimg_idx = 0;
        int subimg_mask_idx = 0;
        int diff_red   = 0;
        int diff_green = 0;
        int diff_blue  = 0;
        int diff_red_next   = 0;
        int diff_green_next = 0;
        int diff_blue_next  = 0;
        for (int x = x_start;  x < x_end;  x++)
        {
            for (int y = y_start;  y < y_end;  y++)
            {
                pixel_arr_idx = (y * bytesPerRow) + (x * 4);
                
                red   = prev_pix_arr[pixel_arr_idx + 2];            // previous image
                green = prev_pix_arr[pixel_arr_idx + 1];
                blue  = prev_pix_arr[pixel_arr_idx];
                
                red_next_img   = curr_img[pixel_arr_idx + 2];       // next image (curr_img)
                green_next_img = curr_img[pixel_arr_idx + 1];
                blue_next_img  = curr_img[pixel_arr_idx];
                
                red_subimg   = club_shaft_subimg[subimg_idx];         // "current" image
                green_subimg = club_shaft_subimg[subimg_idx + 1];
                blue_subimg  = club_shaft_subimg[subimg_idx + 2];
                subimg_idx += 3;
                
                diff_red   = abs(red - red_subimg);
                diff_green = abs(green - green_subimg);
                diff_blue  = abs(blue - blue_subimg);
                
                diff_red_next   = abs(red_subimg   - red_next_img);
                diff_green_next = abs(green_subimg - green_next_img);
                diff_blue_next  = abs(blue_subimg  - blue_next_img);
                
                if (    ((diff_red > diff_threshold) || (diff_green > diff_threshold) || (diff_blue > diff_threshold))
                    &&  ((diff_red_next > diff_threshold) || (diff_green_next > diff_threshold) || (diff_blue_next > diff_threshold))
                    )
                {
                    club_shaft_subimg_mask[subimg_mask_idx] = 0;     // 0 means change in pixel value
                    mask_pix_on_cnt++;
                }
                else
                {
                    club_shaft_subimg_mask[subimg_mask_idx] = 1;     // mask out stationary background (we don't want to match stationary background patterns)
                    mask_pix_off_cnt++;
                }
                
                // if (y == obj_center_y)    // debugging
                // {
                //     printf("            ---M1a---  clubhead_subimg_mask -- x: %4d   y: %4d   clubhead_subimg_mask[ %4d ]: %d   diff_red: %4d   diff_green: %4d   diff_blue: %4d  \n",  x, y, subimg_mask_idx, clubhead_subimg_mask[subimg_mask_idx], diff_red, diff_green, diff_blue);
                // }
                
                subimg_mask_idx++;
            }
        }
    }
    
    // printf("         ---CSM---  mask_pix_on_cnt: %d   mask_pix_off_cnt: %d   mask_pix_total_cnt: %d \n",  mask_pix_on_cnt, mask_pix_off_cnt, (mask_pix_on_cnt + mask_pix_off_cnt));
}



-(void) set_linear_regression_points
{
    
    // First reduce all varying pixels on each row to one pixel (average pixel position or "centroid"):
    int box_width  = box3_width_half * 2;
    int box_height = box3_height_half * 2;
    int num_points = 0;
    int * row_for_centering_shaft = (int *)calloc(box_width,sizeof(int));
    for (int row_no = 0; row_no < box_height; row_no++)
    {
        // Remove outliers:
        
        for (int col_no = 0; col_no < box_width; col_no++)
        {
            int pix_no = (box_height * col_no) + row_no;
            int mask_value = club_shaft_subimg_mask[pix_no];
            
            row_for_centering_shaft[ col_no ] = mask_value;     // copy row of pixels
        }
        
        [self remove_outliers_from_row :(&row_for_centering_shaft) :box_width :3];         // <<<<<<<<<<<<<<<< Phase 1 outlier removal
        [self remove_outliers_from_row :(&row_for_centering_shaft) :box_width :2];         // <<<<<<<<<<<<<<<< Phase 2 outlier removal
        
        
        // Copy row back to club_shaft_subimg_mask (for visual diagnostics):
        for (int col_no = 0; col_no < box_width; col_no++)
        {
            int pix_no = (box_height * col_no) + row_no;
            int mask_value2 = row_for_centering_shaft[ col_no ];     // copy row of pixels
            club_shaft_subimg_mask[pix_no] = mask_value2;
        }
        
        
        // Compute average y-position of remaining pixels:

        int col_ave = 0;
        int col_acc = 0;
        int col_cnt = 0;
        for (int col_no = 0; col_no < box_width; col_no++)
        {
            int mask_value = row_for_centering_shaft[col_no];
            
            if (mask_value == 0)    // not masked out
            {
                col_acc += col_no;
                col_cnt++;
            }
        }
 
        if (col_cnt > 0)
        {
            col_ave = (int) (0.5f + ((float) col_acc) / ((float) col_cnt));
            linear_regression_points_x[num_points] = row_no;    // x,y switch (col,row switch) is intentional!
            linear_regression_points_y[num_points] = col_ave;
            num_points++;
            // printf("         --- set_linear_regression_points -- row_no: %d   col_ave: %d \n",  row_no, col_ave);
        }
        
    }
    num_linear_regression_points = num_points;
    
    free(row_for_centering_shaft);
    

    
    /*
    int num_points = 0;
    for (int pix_no = 0; pix_no < club_shaft_subimg_mask_arr_length; pix_no++)
    {
        // subimg dimensions:  box3_width_half * 2, box3_height_half * 2
        // subimg is filled one column at a time.
        int box_height = box3_height_half * 2;
        int pix_x = pix_no / box_height;
        int pix_y = pix_no - (pix_x * box_height);
        int mask_value = club_shaft_subimg_mask[pix_no];
        if (mask_value == 0)       // not masked out
        {
            // linear_regression_points_x[num_points] = pix_x;
            // linear_regression_points_y[num_points] = pix_y;
            
            // Use the y direction (downwards) as x-axis and the x-direction (right) as y-axis (for linear regression purposes).
            // This way the vertical direction is computed accurately by the linear regression function (otherwise the slope would be infinite for vertical).
            linear_regression_points_x[num_points] = pix_y;    // x,y switch is intentional!
            linear_regression_points_y[num_points] = pix_x;
            num_points++;
        }
    }
    num_linear_regression_points = num_points;
    */
}



-(void)remove_outliers_from_row :(int * *)row_for_centering_shaft :(int)box_width :(int)max_dist_factor;
{
    // Compute average:
    
    int col_ave = 0;
    int col_acc = 0;
    int col_cnt = 0;
    for (int col_no = 0; col_no < box_width; col_no++)
    {
        int mask_value = (*row_for_centering_shaft)[col_no];
        
        if (mask_value == 0)    // not masked out
        {
            col_acc += col_no;
            col_cnt++;
        }
    }
    
    if (col_cnt > 0)
    {
        col_ave = (int) (0.5f + ((float) col_acc) / ((float) col_cnt));
    }
    
    
    // Compute standard deviation:
    
    int diff_acc = 0;
    int diff_ave = 0;
    int diff_cnt = 0;
    for (int col_no = 0; col_no < box_width; col_no++)
    {
        int mask_value = (*row_for_centering_shaft)[col_no];
        
        if (mask_value == 0)    // not masked out
        {
            int diff = abs(col_ave - col_no);
            diff_acc += diff;
            diff_cnt++;
        }
    }
    
    if (diff_cnt > 0)
    {
        diff_ave = (int) (0.5f + ((float) diff_acc) / ((float) diff_cnt));   // std dev
    }
    
    // printf("         --- --- --- remove_outliers_from_row -- diff_ave: %d \n", diff_ave);

    
    // Remove pixels that lie out more than 3 times the standard deviation
    
    for (int col_no = 0; col_no < box_width; col_no++)
    {
        int mask_value = (*row_for_centering_shaft)[col_no];
        
        if (mask_value == 0)    // not masked out
        {
            int diff = abs(col_ave - col_no);
            if (diff > (diff_ave * max_dist_factor))
            {
                (*row_for_centering_shaft)[col_no] = 1;   // filter it out
            }
        }
    }
}



-(void) compute_linear_regression_line :(int *)points_x :(int *)points_y :(int)num_linear_regression_points1
{
    if (num_linear_regression_points1 > 10)
    {
        int n = 0;
        
        // first pass: read in data, compute xbar and ybar
        double sumx = 0.0, sumy = 0.0, sumx2 = 0.0;
        //x while(!StdIn.isEmpty()) {
        for (int point_no = 0; point_no < num_linear_regression_points1; point_no++)
        {
            sumx  += points_x[n];
            sumx2 += points_x[n] * points_x[n];
            sumy  += points_y[n];
            n++;
        }
        
        double xbar = sumx / ((double)n);
        double ybar = sumy / ((double)n);
        
        // second pass: compute summary statistics
        double xxbar = 0.0, yybar = 0.0, xybar = 0.0;
        for (int i = 0; i < n; i++) {
            xxbar += (points_x[i] - xbar) * (points_x[i] - xbar);
            yybar += (points_y[i] - ybar) * (points_y[i] - ybar);
            xybar += (points_x[i] - xbar) * (points_y[i] - ybar);
        }
        double beta1 = xybar / xxbar;
        double beta0 = ybar - beta1 * xbar;
        
        // print results
        printf("            Linear regression line:  y = %5.2f * x + %5.2f \n", beta1, beta0);
        
        // analyze results
        int df = n - 2;
        double rss = 0.0;      // residual sum of squares
        double ssr = 0.0;      // regression sum of squares
        for (int i = 0; i < n; i++) {
            double fit = beta1 * points_x[i] + beta0;
            rss += (fit - points_y[i]) * (fit - points_y[i]);
            ssr += (fit - ybar) * (fit - ybar);
        }
        double R2    = ssr / yybar;
        double svar  = rss / df;
        double svar1 = svar / xxbar;
        double svar0 = svar/n + xbar*xbar*svar1;
        printf("            R^2                 = %5.2f \n", R2);
        printf("            std error of beta_1 = %5.2f \n" , sqrt(svar1));
        printf("            std error of beta_0 = %5.2f \n", sqrt(svar0));
        svar0 = svar * sumx2 / (n * xxbar);
        printf("            std error of beta_0 = %5.2f \n", sqrt(svar0));
        
        printf("            SSTO = %5.2f \n" , yybar);
        printf("            SSE  = %5.2f \n" , rss);
        printf("            SSR  = %5.2f \n" , ssr);
        
        linear_regression_line_slope  = beta1;
        linear_regression_line_offset = beta0;
    }
}


- (void) compute_intersection_of_circle_with_line :(double)x_pivot :(double)y_pivot :(double)shaft_length :(double)line_slope :(double)line_offset  :(double *)club_head2_x  :(double *)club_head2_y
{
    // line y = mx + c and the circle (x−p)^2 + (y−q)^2 = r^2
    // (m^2 + 1) x^2 + 2(mc − mq − p)x + (q^2 − r^2 + p^2 − 2cq + c^2) = 0
    
    double m = line_slope;
    double c = line_offset;
    
    double p = x_pivot;
    double q = y_pivot;
    double r = shaft_length;
    
    double A = m * m + 1;
    double B = 2 * (m * c - m * q - p);
    double C = (q * q - r * r + p * p - 2 * c * q + c * c);
    
    double root_arg = B * B - 4 * A * C;
    
    if ((root_arg >= 0.0) && (A != 0.0))
    {
       // double x = (-B + sqrt( B * B - 4 * A * C )) / ( 2 * A );
       double x = (-B + sqrt( root_arg )) / ( 2 * A );
       double y = m * x + c;
    
       *club_head2_x = x;
       *club_head2_y = y;
    }
}


- (void) compute_intersection_of_two_lines :(double)line1_slope :(double)line1_offset :(double)line2_slope :(double)line2_offset  :(double *)intersect_point_x  :(double *)intersect_point_y
{
    double offset_diff = line2_offset - line1_offset;
    double slope_diff  = line1_slope - line2_slope;
    *intersect_point_x = 100000.0;   // in case denominator is zero
    if (slope_diff != 0.0)
    {
       *intersect_point_x = offset_diff / slope_diff;
    }
    *intersect_point_y = line1_slope * *intersect_point_x + line1_offset;
    
    printf("            --- compute_intersection_of_two_lines (in 90 deg rotated coorindate system) -- line1_slope: %5.2f   line1_offset: %5.2f   line2_slope: %5.2f   line2_offset: %5.2f   intersect_point_x: %5.2f   intersect_point_y: %5.2f \n", line1_slope, line1_offset, line2_slope, line2_offset, *intersect_point_x, *intersect_point_y);
}


//
// Determine orientation of shaft line that minimizes the variance along the line.
//
-(void) optimize_shaft_line :(int)frame_no :(unsigned char*)pix_arr
{
    // Shaft line is defined by:
    //    double linear_regression_line_slope;     // Note: linear regression coordinate system is rotated 90 deg to the right
    //    double linear_regression_line_offset;    // y-offset
    //    Anchor point: shift_box3_x, shift_box3_y
    
    // Slightly modify the slope to determine slope with mininum variance:
    double line_length = 120; // 60; // 30; // 40; // 80.0; // TODO: try 60   // This should be computed using distance to ball.
    // double range = 0.020;
    // double step  = 0.00025;
    
    double range = 0.0;      // TEMP FOR TESTING
 //   double range = 0.060; // 0.120;
    double step  = 0.00025;
    
    double start_slope = linear_regression_line_slope - range;
    double end_slope   = linear_regression_line_slope + range;
    
    int anchor_point_x = shift_box3_x - box3_width_half;
    int anchor_point_y = shift_box3_y - box3_height_half;
    
    // double ave_diff1 = 0.0;
    double high_diff_count = 0;
    // double ave_diff2 = 0.0;
    double ave_diff_total = 0.0f;
    double ave_diff_min = 9999999999.0f;
    double slope_min = 0.0;
    
    /*
    // double offset_x_range = 0.0; // TEMP FOR TESTING
    double offset_x_range = 4.0; // 16.0;
    double offset_x_start = linear_regression_line_offset - offset_x_range;
    double offset_x_end   = linear_regression_line_offset + offset_x_range;
    
    double offset_x_min = 0;
    
    for (double offset_x = offset_x_start; offset_x <= offset_x_end; offset_x += 2.0)
    {
        for (double slope1 = start_slope; slope1 <= end_slope; slope1 += step)
        {
            // ave_diff1 = [ self compute_line_variance :pix_arr :slope1 :linear_regression_line_offset :shift_box3_x :shift_box3_y :line_length ];
            high_diff_count = [ self compute_shaft_line_score :frame_no :pix_arr :slope1 :offset_x :anchor_point_x :anchor_point_y :line_length ];    // shift_box3_x/y is the center of the box
            
            // Scan line a few pixels to the right:
            // int right_flank_x = shift_box3_x + 5;
            // ave_diff2 = [ self compute_line_variance :pix_arr :slope1 :linear_regression_line_offset :right_flank_x :shift_box3_y :line_length ];
            
            // ave_diff_total = ave_diff1 + ave_diff2;
            ave_diff_total = high_diff_count;
            // printf("            ---1- optimize_shaft_line --  slope1: %10.6f  ave_diff1: %5.2f \n", slope1, ave_diff1);
            
            if (ave_diff_total < ave_diff_min)
            {
                ave_diff_min = ave_diff_total;
                slope_min = slope1;
                offset_x_min = offset_x;
            }
        }
    }
    
    printf("            ---1--- optimize_shaft_line --  frame_no: %3d  slope_min: %10.6f  ave_diff_min: %5.2f   linear_regression_line_offset: %5.2f   offset_x_min: %5.2f \n", frame_no, slope_min, ave_diff_min, linear_regression_line_offset, offset_x_min);
    */
    
    // TODO: Alternatively use "club_shaft_subimg_mask" to find one or both edges of the shaft:
    double offset_x_range = 0.0f; // 20.0; // 16.0;
    double offset_x_step  = 4.0;
    double offset_x_start = linear_regression_line_offset - offset_x_range;
    double offset_x_end   = linear_regression_line_offset + offset_x_range;
    double offset_x_min = 0;
    for (double offset_x = offset_x_start; offset_x <= offset_x_end; offset_x += offset_x_step)
    {
        for (double slope1 = start_slope; slope1 <= end_slope; slope1 += step)
        {
            high_diff_count = [ self compute_shaft_edge_line_score :frame_no :pix_arr :slope1 :offset_x :anchor_point_x :anchor_point_y :line_length ];    // shift_box3_x/y is the center of the box
            
            ave_diff_total = high_diff_count;
            // printf("            ---2- optimize_shaft_line --  slope1: %10.6f  ave_diff1: %5.2f \n", slope1, ave_diff1);
            
            if (ave_diff_total < ave_diff_min)
            {
                ave_diff_min = ave_diff_total;
                slope_min = slope1;
                offset_x_min = offset_x;
            }
        }
    }
    
    printf("            ---0--- optimize_shaft_line --  frame_no: %3d  slope_min: %10.6f  ave_diff_min: %5.2f   linear_regression_line_offset: %5.2f   offset_x_min: %5.2f \n", frame_no, slope_min, ave_diff_min, linear_regression_line_offset, offset_x_min);
    
    
    
    // Adjust the orientation of the shaft line:
    linear_regression_line_slope = slope_min;
    linear_regression_line_offset = offset_x_min;
    
    
    // Now compute the shaft length (swing radius) (assuming the pivot is right above the ball):
    //    If       y = ax + b    is the shaft line for the rotated coordinate system (origin is upper left corner of box3), we know the y coordinate (y_ball_rot) of the pivot point (the horizontal component of the golf ball).
    //    So       y_ball_rot = ax + b            (y_ball_rot is known, x is unknown) (y_ball_rot = "y coordinate of ball in rotated coordinate system (rotated 90 deg right))
    //    So       x = (y_ball_rot - b) / a       (x = x_pivot_rot)
    //    So rotating the coordinate system back we have:
    //    x_pivot = y_ball_rot
    //    y_pivot = (y_ball_rot - b) / a
    //    So the shaft swing circle radius (shaft length) is:   radius = y_ball - y_pivot
    //    Now we can compute the club head position by adding a vector of length radius to the pivot.
    
    double x_origin = shift_box3_x - box3_width_half;      // origin of coorindate system rotated 90 deg clock wise
    double y_origin = shift_box3_y - box3_height_half;
    
    double x_golf_ball = circle_shift_x;
    double y_golf_ball = circle_shift_y;
    
    double y_ball_rot = x_golf_ball - x_origin;       // known quantity
    
    double x_pivot_rot = (y_ball_rot - linear_regression_line_offset) / linear_regression_line_slope;
    
    double x_pivot = x_origin + y_ball_rot;
    double y_pivot = y_origin + x_pivot_rot;
    
    double offset_x_min__img_ref = offset_x_min + x_origin;
    [ self update_trail_of_shaft_lines :slope_min :offset_x_min__img_ref ];    // used by compute_pivot_from_shaft_lines
    
    double shaft_length = y_golf_ball - y_pivot;
    
    double club_head_x = 0.0;
    double club_head_y = 0.0;
    
    if (   (x_golf_ball < 0)                                            // ball moved out of view (so we cannot use the ball for computing pivot and shaft length)
        || ((impact_frame_no > 0) && (frame_no > impact_frame_no)))     // don't use ball position after impact (since ball moves after impact)
    {
        x_pivot = prev_shaft_x_pivot;     // x,y_pivot is fixed from now on
        y_pivot = prev_shaft_y_pivot;
        
        double x_pivot_rot2 = y_pivot - y_origin;
        double y_pivot_rot2 = x_pivot - x_origin;
        
        shaft_length = prev_shaft_length;
        
        // Compute the club head position as the intersection of circle around pivot with shaft line...
        double club_head2_x_rot = 0.0;
        double club_head2_y_rot = 0.0;
        [ self compute_intersection_of_circle_with_line :x_pivot_rot2 :y_pivot_rot2 :shaft_length :linear_regression_line_slope :linear_regression_line_offset  :&club_head2_x_rot  :&club_head2_y_rot ];
        
        club_head_x = x_origin + club_head2_y_rot;
        club_head_y = y_origin + club_head2_x_rot;
        
        printf("            ---1--- optimize_shaft_line --  frame_no: %3d   origin: %5.2f,%5.2f   golf_ball: %5.2f,%5.2f   y_ball_rot: %5.2f   x_pivot_rot: %5.2f   pivot: %5.2f,%5.2f   prev_shaft_x,y_pivot: %5.2f,%5.2f   shaft_length: %5.2f   club_head2_x,y_rot:  %5.2f,%5.2f   club_head: %5.2f,%5.2f \n",  frame_no, x_origin, y_origin, x_golf_ball, y_golf_ball,  y_ball_rot, x_pivot_rot, x_pivot, y_pivot, prev_shaft_x_pivot, prev_shaft_y_pivot, shaft_length, club_head2_x_rot, club_head2_y_rot, club_head_x, club_head_y);
    }
    else   // before impact
    {
        double x_shaft_vector = linear_regression_line_slope;
        double y_shaft_vector = 1.0;
        
        double shaft_vector_length = sqrt(x_shaft_vector * x_shaft_vector + y_shaft_vector * y_shaft_vector);
        
        double x_shaft_vector_normalized = x_shaft_vector / shaft_vector_length;
        double y_shaft_vector_normalized = y_shaft_vector / shaft_vector_length;
        
        club_head_x = x_pivot + (shaft_length * x_shaft_vector_normalized);
        club_head_y = y_pivot + (shaft_length * y_shaft_vector_normalized);
        
        printf("            ---2--- optimize_shaft_line --  frame_no: %3d   origin: %5.2f,%5.2f   golf_ball: %5.2f,%5.2f   y_ball_rot: %5.2f   x_pivot_rot: %5.2f   pivot: %5.2f,%5.2f   prev_shaft_x,y_pivot: %5.2f,%5.2f   shaft_length: %5.2f   shaft_vector_normalized:  %5.2f,%5.2f   club_head: %5.2f,%5.2f \n",  frame_no, x_origin, y_origin, x_golf_ball, y_golf_ball,  y_ball_rot, x_pivot_rot, x_pivot, y_pivot, prev_shaft_x_pivot, prev_shaft_y_pivot, shaft_length, x_shaft_vector_normalized, y_shaft_vector_normalized, club_head_x, club_head_y);

        // Compute pivot by computing the intersection of the shaft line at two different time points (e.g., impact frame and 10 frames prior):
        [ self compute_pivot_from_shaft_lines :x_origin :y_origin  :&x_pivot  :&y_pivot ];    // x,y_pivot is saved in prev_shaft_x,y_pivot and used in subsequent frames (after impact)
        shaft_length = y_golf_ball - y_pivot;                                                 // shaft_length is saved in prev_shaft_length and used in subsequent frames (after impact)
        printf("            ---3--- optimize_shaft_line --  frame_no: %3d   origin: %5.2f,%5.2f   golf_ball: %5.2f,%5.2f   y_ball_rot: %5.2f   x_pivot_rot: %5.2f   pivot: %5.2f,%5.2f   prev_shaft_x,y_pivot: %5.2f,%5.2f   shaft_length: %5.2f \n",  frame_no, x_origin, y_origin, x_golf_ball, y_golf_ball,  y_ball_rot, x_pivot_rot, x_pivot, y_pivot, prev_shaft_x_pivot, prev_shaft_y_pivot, shaft_length);
    }
    

    // Set the blue box (club head tracking):
    /*
    int x_shift = box2_width_half;      // box center is to the left (for left to right club head motion)
    
    int pos_x_head = (int) (0.5 + (club_shaft_end_x - x_shift));
    int pos_y_head = (int) (0.5 + club_shaft_end_y);

    [ self set_overlay_box2 :pos_x_head :pos_y_head];                                                               // Set position of blue box
    // [ self set_overlay_box2 :((int)(0.5 + club_head_x)) :((int)(0.5 + club_head_y)) ];
    */
    club_shaft_end_x = club_head_x;      // //x not currently used
    club_shaft_end_y = club_head_y;      // //x not currently used
    club_shaft_is_set = true;            // //x not currently used
    
    
    prev_shaft_x_pivot = x_pivot;
    prev_shaft_y_pivot = y_pivot;
    prev_shaft_length = shaft_length;
}



-(void) compute_pivot_from_shaft_lines :(double)x_origin :(double)y_origin  :(double *)x_pivot  :(double *)y_pivot
{
    //x [ self update_trail_of_shaft_lines :shaft_line_slope1 :shaft_line_offset1 ];
    
    // Compute intersection of two lines:     line 1:  shaft_line_slope_minus_1, shaft_line_offset_minus_1     line 2:  shaft_line_slope_minus_10, shaft_line_offset_minus_10
    double intersect_point_x_rot = 0.0;
    double intersect_point_y_rot = 0.0;
    
    double ref_shaft_line_slope = shaft_line_slope_minus_10;
    double ref_shaft_line_offset = shaft_line_offset_minus_10;
    // Make sure shaft_line_slope_minus_10 and shaft_line_offset_minus_10 are set:
    if ((shaft_line_slope_minus_10 == 0.0) && (shaft_line_offset_minus_10 == 0.0))
    {
        ref_shaft_line_slope = shaft_line_slope_minus_6;
        ref_shaft_line_offset = shaft_line_offset_minus_6;
    }
    [self compute_intersection_of_two_lines :shaft_line_slope_minus_1 :shaft_line_offset_minus_1 :ref_shaft_line_slope :ref_shaft_line_offset :&intersect_point_x_rot :&intersect_point_y_rot ];
    
    // Compute the non-rotated intersection point coorindates:
    *x_pivot = intersect_point_y_rot; // x_origin is already included since we need "global" coordinates when computing intersection of two shaft lines
    *y_pivot = intersect_point_x_rot + y_origin;
}



-(double) compute_shaft_line_score :(int)frame_no :(unsigned char*)pix_arr :(double)slope :(double)line_offset :(int)anchor_point_x :(int)anchor_point_y :(double)line_length
{
    // General approach:
    //    There should high variance across the shaft (profile) and low variance along the shaft.
    //    Add more lines along the shaft (between the center line and the two flanking lines).
    //    Opimize the width of the profile (the flank distance parameter).
    
    //
    // First compute averages:
    //
    
    int cnt = 0;
    
    int red1 = 0;
    int green1 = 0;
    int blue1 = 0;
    
    int red2 = 0;
    int green2 = 0;
    int blue2 = 0;
    
    int red3 = 0;
    int green3 = 0;
    int blue3 = 0;
    
    int prev_red1 = 0;
    int prev_green1 = 0;
    int prev_blue1 = 0;
    
    int prev_red2 = 0;
    int prev_green2 = 0;
    int prev_blue2 = 0;
    
    int prev_red3 = 0;
    int prev_green3 = 0;
    int prev_blue3 = 0;
    
    // Travers the line through a sequence of points by repeatedly attaching a vector of specified length to the start of the line:
    
    double vector_length = 20.0f; // 10.0; // 1.0; // 2.0;  // pixels
    double vector_x = slope;
    double vector_y = 1.0;
    
    double curr_point_x = ((double)anchor_point_x) + line_offset;
    double curr_point_y =  (double)anchor_point_y;
    
    double next_point_x = 0;
    double next_point_y = 0;
    
    double next_right_flank_point_x = 0;
    double next_right_flank_point_y = 0;
    
    double next_left_flank_point_x = 0;
    double next_left_flank_point_y = 0;
    
    int num_steps = (int) (line_length / vector_length);
    
    
    // Compute the difference between the intensities of the first points of the line and right flanking line:
    int flanking_dist = 5; // 3; // 4; // 5;
    
    int pixel1_x = anchor_point_x + line_offset;
    int pixel1_y = anchor_point_y;
    
    int pixel_arr_idx1 = (int) ((pixel1_y * movie_frame_bytes_per_row) + (pixel1_x * 4));
    int red_center_line    = pix_arr[pixel_arr_idx1 + 2];
    int green_center_line  = pix_arr[pixel_arr_idx1 + 1];
    int blue_center_line   = pix_arr[pixel_arr_idx1];
    
    
    int pixel2_x = anchor_point_x + line_offset + flanking_dist;     // should go perpendicar to center line
    int pixel2_y = anchor_point_y;
    
    pixel_arr_idx1 = (int) ((pixel2_y * movie_frame_bytes_per_row) + (pixel2_x * 4));
    int red_right_flank   = pix_arr[pixel_arr_idx1 + 2];
    int green_right_flank = pix_arr[pixel_arr_idx1 + 1];
    int blue_right_flank  = pix_arr[pixel_arr_idx1];
    
    
    int pixel3_x = anchor_point_x + line_offset - flanking_dist;     // should go perpendicar to center line
    int pixel3_y = anchor_point_y;
    
    pixel_arr_idx1 = (int) ((pixel3_y * movie_frame_bytes_per_row) + (pixel3_x * 4));
    int red_left_flank   = pix_arr[pixel_arr_idx1 + 2];
    int green_left_flank = pix_arr[pixel_arr_idx1 + 1];
    int blue_left_flank  = pix_arr[pixel_arr_idx1];
    
    
    int right_red_diff_ref   = red_right_flank   - red_center_line;
    int right_green_diff_ref = green_right_flank - green_center_line;
    int right_blue_diff_ref  = blue_right_flank  - blue_center_line;
    
    int left_red_diff_ref   = red_left_flank   - red_center_line;
    int left_green_diff_ref = green_left_flank - green_center_line;
    int left_blue_diff_ref  = blue_left_flank  - blue_center_line;
    
    
    int red_diff1   = 0;
    int green_diff1 = 0;
    int blue_diff1  = 0;
    
    int red_diff2   = 0;
    int green_diff2 = 0;
    int blue_diff2  = 0;

    
    /*
    int line_profile_threshold = 30; // 30; // 40; // 50;    // Require a difference between the center line and the flanking lines
    if (   ((right_red_diff_ref < line_profile_threshold) && (right_green_diff_ref < line_profile_threshold) && (right_blue_diff_ref < line_profile_threshold))
        && ((left_red_diff_ref  < line_profile_threshold) && (left_green_diff_ref  < line_profile_threshold) && (left_blue_diff_ref  < line_profile_threshold)))
    {
        return 999999.0;    // fail
    }
    */
    
    
    /*
     // For debugging: scan 100 pixels from left to right
     if (frame_no == 15)
     {
         int start_test_x = (anchor_point_x + line_offset) - 50;
         int end_test_x   = (anchor_point_x + line_offset) + 50;
         int test_pix_y = anchor_point_y;
         for (int test_pix_x = start_test_x; test_pix_x < end_test_x; test_pix_x++)
         {
             pixel_arr_idx1 = (int) ((test_pix_y * movie_frame_bytes_per_row) + (test_pix_x * 4));
             int red_test   = pix_arr[pixel_arr_idx1 + 2];
             int green_test = pix_arr[pixel_arr_idx1 + 1];
             int blue_test  = pix_arr[pixel_arr_idx1];
             printf("            ---   --- compute_line_score -- frame_no: %4d   test_pix_x: %5d   test_pix_y: %5d   red_test: %5d   green_test: %5d   blue_test: %5d \n",  frame_no, test_pix_x, test_pix_y, red_test, green_test, blue_test);
         }
     }
    */
    
    
    // Compute the differences from the reference differences and count the number of pixel-pairs that have a difference above a threshold:
    int threshold = 15; // 20; // 30; // 20; // 10; // 5;
    int intensity_diff_acc = 0;
    
    prev_red1 = red_center_line;
    prev_green1 = green_center_line;
    prev_blue1 = blue_center_line;
    
    prev_red2 = red_right_flank;
    prev_green2 = green_right_flank;
    prev_blue2 = blue_right_flank;
    
    prev_red3 = red_left_flank;
    prev_green3 = green_left_flank;
    prev_blue3 = blue_left_flank;
    
    
    int profile_strength = 0;         // profile strength corresponds to variance of the shaft cross section

    cnt = 0;
    
    curr_point_x = anchor_point_x + line_offset;       // Go back to start of line
    curr_point_y = anchor_point_y;                    //
    
    for (int step_no = 0; step_no < num_steps; step_no++)
    {
        next_point_x = curr_point_x + (vector_length * vector_x);
        next_point_y = curr_point_y + (vector_length * vector_y);
        
        next_right_flank_point_x = next_point_x + flanking_dist;      // should go perpendicular to center line
        next_right_flank_point_y = next_point_y;
        
        next_left_flank_point_x = next_point_x - flanking_dist;      // should go perpendicular to center line
        next_left_flank_point_y = next_point_y;
        
        int pixel_x = (int) (0.5 + next_point_x);
        int pixel_y = (int) (0.5 + next_point_y);
        int pixel_arr_idx1 = (int) ((pixel_y * movie_frame_bytes_per_row) + (pixel_x * 4));
        red1   = pix_arr[pixel_arr_idx1 + 2];
        green1 = pix_arr[pixel_arr_idx1 + 1];
        blue1  = pix_arr[pixel_arr_idx1];
        
        pixel_x = (int) (0.5 + next_right_flank_point_x);
        pixel_y = (int) (0.5 + next_right_flank_point_y);
        pixel_arr_idx1 = (int) ((pixel_y * movie_frame_bytes_per_row) + (pixel_x * 4));
        red2   = pix_arr[pixel_arr_idx1 + 2];
        green2 = pix_arr[pixel_arr_idx1 + 1];
        blue2  = pix_arr[pixel_arr_idx1];
        
        pixel_x = (int) (0.5 + next_left_flank_point_x);
        pixel_y = (int) (0.5 + next_left_flank_point_y);
        pixel_arr_idx1 = (int) ((pixel_y * movie_frame_bytes_per_row) + (pixel_x * 4));
        red3   = pix_arr[pixel_arr_idx1 + 2];
        green3 = pix_arr[pixel_arr_idx1 + 1];
        blue3  = pix_arr[pixel_arr_idx1];
        
        
        intensity_diff_acc += abs(prev_red1 - red1);         // center
        intensity_diff_acc += abs(prev_green1 - green1);
        intensity_diff_acc += abs(prev_blue1 - blue1);
        
        intensity_diff_acc += abs(prev_red2 - red2);         // right flank
        intensity_diff_acc += abs(prev_green2 - green2);
        intensity_diff_acc += abs(prev_blue2 - blue2);
        
        intensity_diff_acc += abs(prev_red3 - red3);         // left flank
        intensity_diff_acc += abs(prev_green3 - green3);
        intensity_diff_acc += abs(prev_blue3 - blue3);
        
        
        // Also require that "profile" is similar to the that at the first point (subtract points if not similar):

        red_diff1   = red2 - red1;       // diff with right flank
        green_diff1 = green2 - green1;
        blue_diff1  = blue2 - blue1;
        
        red_diff2   = red3 - red1;       // diff with left flank
        green_diff2 = green3 - green1;
        blue_diff2  = blue3 - blue1;
        
        int profile_diff = 0;
        profile_diff += abs(red_diff2   - left_red_diff_ref);
        profile_diff += abs(green_diff2 - left_green_diff_ref);
        profile_diff += abs(blue_diff2  - left_blue_diff_ref);
        profile_diff += abs(red_diff1   - right_red_diff_ref);
        profile_diff += abs(green_diff1 - right_green_diff_ref);
        profile_diff += abs(blue_diff1  - right_blue_diff_ref);
        
        float weight1 = 0.2f;
        intensity_diff_acc += ((float) profile_diff) * weight1;     // add profile_diff to the penalty intensity_diff_acc

        
        // Reward difference between center line and flanking lines (recognizing "lines"):
        profile_strength -= (abs(red_diff1) + abs(green_diff1) + abs(blue_diff1) + abs(red_diff2) + abs(green_diff2) + abs(blue_diff2));
        float weight2 = 0.2f;
        intensity_diff_acc += ((float) profile_strength) * weight2;
  
        
        cnt++;
        
        curr_point_x = next_point_x;
        curr_point_y = next_point_y;
        
        prev_red1 = red1;
        prev_green1 = green1;
        prev_blue1 = blue1;
        
        prev_red2 = red2;
        prev_green2 = green2;
        prev_blue2 = blue2;
        
        prev_red3 = red3;
        prev_green3 = green3;
        prev_blue3 = blue3;
    }
    
    /*
    // Reward difference between center line and flanking lines (recognizing "lines"):
    profile_strength += right_red_diff_ref + right_green_diff_ref + right_green_diff_ref + left_red_diff_ref + left_red_diff_ref + left_green_diff_ref + left_blue_diff_ref;
    profile_strength *= num_steps;     // give similar weight as the other factors
    float weight3 = 0.2f;
    profile_strength *= weight3;
    intensity_diff_acc += profile_strength;
    */
    
    return ((double) intensity_diff_acc);
}



/*
-(double) compute_shaft_line_score :(int)frame_no :(unsigned char*)pix_arr :(double)slope :(double)line_offset :(int)anchor_point_x :(int)anchor_point_y :(double)line_length
{
    // Compute average red/green/blue values along the line.
    // Then compute the differences between the colors at each point from these averages.
    
    //
    // First compute averages:
    //
    
    int cnt = 0;
    
    int red1 = 0;
    int green1 = 0;
    int blue1 = 0;
    
    int red2 = 0;
    int green2 = 0;
    int blue2 = 0;
    
    int red3 = 0;
    int green3 = 0;
    int blue3 = 0;
    
    // Travers the line through a sequence of points by repeatedly attaching a vector of specified length to the start of the line:
    
    double vector_length = 1.0; // 2.0;  // pixels
    double vector_x = slope;
    double vector_y = 1.0;
    
    double curr_point_x = ((double)anchor_point_x) + line_offset;
    double curr_point_y =  (double)anchor_point_y;
    
    double next_point_x = 0;
    double next_point_y = 0;
    
    double next_right_flank_point_x = 0;
    double next_right_flank_point_y = 0;
    
    double next_left_flank_point_x = 0;
    double next_left_flank_point_y = 0;
    
    int num_steps = (int) (line_length / vector_length);
    
    
    // Compute the difference between the intensities of the first points of the line and right flanking line:
    int flanking_dist = 10; // 3; // 4; // 5;
    
    int pixel1_x = anchor_point_x + line_offset;
    int pixel1_y = anchor_point_y;
    
    int pixel_arr_idx1 = (int) ((pixel1_y * movie_frame_bytes_per_row) + (pixel1_x * 4));
    int red_center_line    = pix_arr[pixel_arr_idx1 + 2];
    int green_center_line  = pix_arr[pixel_arr_idx1 + 1];
    int blue_center_line   = pix_arr[pixel_arr_idx1];
    
    
    int pixel2_x = anchor_point_x + line_offset + flanking_dist;     // should go perpendicar to center line
    int pixel2_y = anchor_point_y;
    
    pixel_arr_idx1 = (int) ((pixel2_y * movie_frame_bytes_per_row) + (pixel2_x * 4));
    int red_right_flank   = pix_arr[pixel_arr_idx1 + 2];
    int green_right_flank = pix_arr[pixel_arr_idx1 + 1];
    int blue_right_flank  = pix_arr[pixel_arr_idx1];
    
    
    int pixel3_x = anchor_point_x + line_offset - flanking_dist;     // should go perpendicar to center line
    int pixel3_y = anchor_point_y;
    
    pixel_arr_idx1 = (int) ((pixel3_y * movie_frame_bytes_per_row) + (pixel3_x * 4));
    int red_left_flank   = pix_arr[pixel_arr_idx1 + 2];
    int green_left_flank = pix_arr[pixel_arr_idx1 + 1];
    int blue_left_flank  = pix_arr[pixel_arr_idx1];
    
    
    int right_red_diff_ref   = red_right_flank   - red_center_line;
    int right_green_diff_ref = green_right_flank - green_center_line;
    int right_blue_diff_ref  = blue_right_flank  - blue_center_line;
    
    int left_red_diff_ref   = red_left_flank   - red_center_line;
    int left_green_diff_ref = green_left_flank - green_center_line;
    int left_blue_diff_ref  = blue_left_flank  - blue_center_line;
    
    
    
    int line_profile_threshold = 30; // 30; // 40; // 50;    // Require a difference between the center line and the flanking lines
    if (   ((right_red_diff_ref < line_profile_threshold) && (right_green_diff_ref < line_profile_threshold) && (right_blue_diff_ref < line_profile_threshold))
        && ((left_red_diff_ref  < line_profile_threshold) && (left_green_diff_ref  < line_profile_threshold) && (left_blue_diff_ref  < line_profile_threshold)))
    {
        return 999999.0;    // fail
    }
    
    
    /*
    // For debugging: scan 100 pixels from left to right
    if (frame_no == 15)
    {
        int start_test_x = (anchor_point_x + line_offset) - 50;
        int end_test_x   = (anchor_point_x + line_offset) + 50;
        int test_pix_y = anchor_point_y;
        for (int test_pix_x = start_test_x; test_pix_x < end_test_x; test_pix_x++)
        {
            pixel_arr_idx1 = (int) ((test_pix_y * movie_frame_bytes_per_row) + (test_pix_x * 4));
            int red_test   = pix_arr[pixel_arr_idx1 + 2];
            int green_test = pix_arr[pixel_arr_idx1 + 1];
            int blue_test  = pix_arr[pixel_arr_idx1];
            printf("            ---   --- compute_line_score -- frame_no: %4d   test_pix_x: %5d   test_pix_y: %5d   red_test: %5d   green_test: %5d   blue_test: %5d \n",  frame_no, test_pix_x, test_pix_y, red_test, green_test, blue_test);
        }
    }
    * /
    
    
    // Compute the differences from the reference differences and count the number of pixel-pairs that have a difference above a threshold:
    int threshold = 15; // 20; // 30; // 20; // 10; // 5;
    int left_pairs_above_threshold_count = 0;
    int right_pairs_above_threshold_count = 0;
    int pairs_above_threshold_count = 0;
    
    int red_diff1   = 0;
    int green_diff1 = 0;
    int blue_diff1  = 0;
    
    int red_diff2   = 0;
    int green_diff2 = 0;
    int blue_diff2  = 0;
    
    cnt = 0;
    
    curr_point_x = anchor_point_x + line_offset;       // Go back to start of line
    curr_point_y = anchor_point_y;                    //
    
    for (int step_no = 0; step_no < num_steps; step_no++)
    {
        next_point_x = curr_point_x + (vector_length * vector_x);
        next_point_y = curr_point_y + (vector_length * vector_y);
        
        next_right_flank_point_x = next_point_x + flanking_dist;      // should go perpendicular to center line
        next_right_flank_point_y = next_point_y;
        
        next_left_flank_point_x = next_point_x - flanking_dist;      // should go perpendicular to center line
        next_left_flank_point_y = next_point_y;
        
        int pixel_x = (int) (0.5 + next_point_x);
        int pixel_y = (int) (0.5 + next_point_y);
        int pixel_arr_idx1 = (int) ((pixel_y * movie_frame_bytes_per_row) + (pixel_x * 4));
        red1   = pix_arr[pixel_arr_idx1 + 2];
        green1 = pix_arr[pixel_arr_idx1 + 1];
        blue1  = pix_arr[pixel_arr_idx1];
        
        pixel_x = (int) (0.5 + next_right_flank_point_x);
        pixel_y = (int) (0.5 + next_right_flank_point_y);
        pixel_arr_idx1 = (int) ((pixel_y * movie_frame_bytes_per_row) + (pixel_x * 4));
        red2   = pix_arr[pixel_arr_idx1 + 2];
        green2 = pix_arr[pixel_arr_idx1 + 1];
        blue2  = pix_arr[pixel_arr_idx1];
        
        pixel_x = (int) (0.5 + next_left_flank_point_x);
        pixel_y = (int) (0.5 + next_left_flank_point_y);
        pixel_arr_idx1 = (int) ((pixel_y * movie_frame_bytes_per_row) + (pixel_x * 4));
        red3   = pix_arr[pixel_arr_idx1 + 2];
        green3 = pix_arr[pixel_arr_idx1 + 1];
        blue3  = pix_arr[pixel_arr_idx1];
        
        red_diff1   = red2 - red1;       // diff with right flank
        green_diff1 = green2 - green1;
        blue_diff1  = blue2 - blue1;
        
        red_diff2   = red3 - red1;       // diff with left flank
        green_diff2 = green3 - green1;
        blue_diff2  = blue3 - blue1;
        
        // red_diff = red_diff1 + red_diff2;
        // green_diff = green_diff1 + green_diff2;
        // blue_diff = blue_diff1 + blue_diff2;
        
        // if (frame_no == 15)
        // {
        //    printf("            --- compute_line_score --   slope: %10.5f  step_no: %5d  left/right red_diff: %5d / %5d  left/right_red_diff_ref: %5d / %5d   left/right green_diff: %5d / %5d  left/right_green_diff_ref: %5d / %5d   left/right blue_diff: %5d / %5d  left/right_blue_diff_ref: %5d / %5d \n",  slope, step_no, red_diff2, red_diff1, left_red_diff_ref, right_red_diff_ref, green_diff2, green_diff1, left_green_diff_ref, right_green_diff_ref, blue_diff2, blue_diff1, left_blue_diff_ref, right_blue_diff_ref);
        // }
        
        if ((abs(red_diff2 - left_red_diff_ref)  > threshold) || (abs(green_diff2 - left_green_diff_ref)  > threshold) || (abs(blue_diff2 - left_blue_diff_ref)  > threshold))
        {
            left_pairs_above_threshold_count++;
        }
        
        if ((abs(red_diff1 - right_red_diff_ref) > threshold) || (abs(green_diff1 - right_green_diff_ref) > threshold) || (abs(blue_diff1 - right_blue_diff_ref) > threshold))
        {
            right_pairs_above_threshold_count++;
        }
        
        cnt++;
        
        curr_point_x = next_point_x;
        curr_point_y = next_point_y;
    }
    
    // pairs_above_threshold_count = min( left_pairs_above_threshold_count, right_pairs_above_threshold_count );
    pairs_above_threshold_count = left_pairs_above_threshold_count + right_pairs_above_threshold_count;
    
    return ((double) pairs_above_threshold_count);
}
*/


/*
-(double) compute_line_variance :(unsigned char*)pix_arr :(double)slope :(double)line_offset :(int)anchor_point_x :(int)anchor_point_y :(double)line_length
{
    // Compute average red/green/blue values along the line.
    // Then compute the differences between the colors at each point from these averages.
    
    //
    // First compute averages:
    //
    
    int red_ave = 0;
    int green_ave = 0;
    int blue_ave = 0;
    
    int red_acc = 0;
    int green_acc = 0;
    int blue_acc = 0;
    
    int cnt = 0;
    
    int red1 = 0;
    int green1 = 0;
    int blue1 = 0;
    
    // Travers the line through a sequence of points by repeatedly attaching a vector of specified length to the start of the line:
    
    double vector_length = 1.0; // 2.0;  // pixels
    double vector_x = slope;
    double vector_y = 1.0;
    
    double curr_point_x = ((double)anchor_point_x) + line_offset;
    double curr_point_y =  (double)anchor_point_y;
    
    double next_point_x = 0;
    double next_point_y = 0;

    int num_steps = (int) (line_length / vector_length);
    
    /*
    for (int step_no = 0; step_no < num_steps; step_no++)
    {
        next_point_x = curr_point_x + (vector_length * vector_x);
        next_point_y = curr_point_y + (vector_length * vector_y);
        
        int pixel_x = (int) (0.5 + next_point_x);
        int pixel_y = (int) (0.5 + next_point_y);
        int pixel_arr_idx1 = (int) ((pixel_y * movie_frame_bytes_per_row) + (pixel_x * 4));
        red1   = pix_arr[pixel_arr_idx1 + 2];
        green1 = pix_arr[pixel_arr_idx1 + 1];
        blue1  = pix_arr[pixel_arr_idx1];

        red_acc += red1;
        green_acc += green1;
        blue_acc += blue1;
        
        cnt++;
        
        curr_point_x = next_point_x;
        curr_point_y = next_point_y;
    }
    
    red_ave = red_acc / cnt;
    green_ave = green_acc / cnt;
    blue_ave = blue_acc / cnt;
    * /
    
    // Instead of using the average use the intensities of the first point:
    int pixel1_x = anchor_point_x + line_offset;
    int pixel1_y = anchor_point_y;

    int pixel_arr_idx1 = (int) ((pixel1_x * movie_frame_bytes_per_row) + (pixel1_y * 4));
    red_ave   = pix_arr[pixel_arr_idx1 + 2];
    green_ave = pix_arr[pixel_arr_idx1 + 1];
    blue_ave  = pix_arr[pixel_arr_idx1];

    
    //
    // Then compute variances:
    //
    
    int red_diff_acc = 0;
    int green_diff_acc = 0;
    int blue_diff_acc = 0;
    
    cnt = 0;
    
    curr_point_x = anchor_point_x + line_offset;       // Go back to start of line
    curr_point_y = anchor_point_y;                    //
    
    for (int step_no = 0; step_no < num_steps; step_no++)
    {
        next_point_x = curr_point_x + (vector_length * vector_x);
        next_point_y = curr_point_y + (vector_length * vector_y);
        
        int pixel_x = (int) (0.5 + next_point_x);
        int pixel_y = (int) (0.5 + next_point_y);
        int pixel_arr_idx1 = (int) ((pixel_y * movie_frame_bytes_per_row) + (pixel_x * 4));
        red1   = pix_arr[pixel_arr_idx1 + 2];
        green1 = pix_arr[pixel_arr_idx1 + 1];
        blue1  = pix_arr[pixel_arr_idx1];
        
        red_diff_acc += abs(red1 - red_ave);
        green_diff_acc += abs(green1 - green_ave);
        blue_diff_acc += abs(blue1 - blue_ave);
        
        cnt++;
        
        curr_point_x = next_point_x;
        curr_point_y = next_point_y;
    }
    
    double red_ave_diff   = ((double)red_diff_acc) / ((double)cnt);
    double green_ave_diff = ((double)green_diff_acc) / ((double)cnt);
    double blue_ave_diff  = ((double)blue_diff_acc) / ((double)cnt);
    
    double ave_diff = (red_ave_diff + green_ave_diff + blue_ave_diff) / 3;
    
    return ave_diff;
}
*/


/*
static float get_distance_from_line(float x1, float y1,
                                    float curr_center_x, float curr_center_y,
                                    float prev_center_x, float prev_center_y)
{
    // curr_center_x/y and prev_center_x/y form a line.
    // Compute the distance of x1/y1 from that line.
    // This is equivalent to computing the height of a triangle.
    // Use Heron's formula to compute the area of the triangle from the lengths of the sides:
    
    float distance = 0.0f;
    
    float delta2_x = curr_center_x - x1;
    float delta2_y = curr_center_y - y1;
    float length_side_b = (float) Math.sqrt((delta2_x * delta2_x) + (delta2_y * delta2_y));
    
    if (prev_center_x < 0)
    {
        distance = length_side_b;
    }
    else
    {
        float delta1_x = prev_center_x - x1;
        float delta1_y = prev_center_y - y1;
        float length_side_a = (float) Math.sqrt((delta1_x * delta1_x) + (delta1_y * delta1_y));
        
        float delta3_x = prev_center_x - curr_center_x;
        float delta3_y = prev_center_y - curr_center_y;
        float length_side_c = (float) Math.sqrt((delta3_x * delta3_x) + (delta3_y * delta3_y));
        
        float s = (length_side_a + length_side_b + length_side_c) / 2.0f;
        float area = (float) Math.sqrt(s * (s - length_side_a) * (s - length_side_b) * (s - length_side_c));
        
        float height = 2.0f * (area / length_side_c);
        distance = height;
    }
    
    return distance;
}
*/




-(double) compute_shaft_edge_line_score :(int)frame_no :(unsigned char*)pix_arr :(double)slope :(double)line_offset :(int)anchor_point_x :(int)anchor_point_y :(double)line_length
{
    double diff = 0.0;
    
    return diff;
}



- (void) rotate_image_180 :(size_t)bytesPerRow :(unsigned char*)pix_arr
{
    int image_width = movie_frame_width;
    int image_height = movie_frame_height;
    int pixel_arr_idx = 0;
    
    int x_swap = 0;
    int y_swap = 0;
    int pixel_arr_swap_idx = 0;
    
    int alpha1 = 0;
    int red1   = 0;
    int green1 = 0;
    int blue1  = 0;
    
    int image_height_half = image_height / 2;
    for (int y = 0; y < image_height_half; y++)
    {
        for (int x = 0; x < image_width; x++)
        {
            pixel_arr_idx = (int)(y * bytesPerRow) + (x * 4);
            
            alpha1 = pix_arr[pixel_arr_idx + 3];
            red1   = pix_arr[pixel_arr_idx + 2];
            green1 = pix_arr[pixel_arr_idx + 1];
            blue1  = pix_arr[pixel_arr_idx];

            
            x_swap = (image_width - 1) - x;
            y_swap = (image_height - 1) - y;
            pixel_arr_swap_idx = (int)(y_swap * bytesPerRow) + (x_swap * 4);
            
            pix_arr[pixel_arr_idx + 0] = pix_arr[pixel_arr_swap_idx + 0];
            pix_arr[pixel_arr_idx + 1] = pix_arr[pixel_arr_swap_idx + 1];
            pix_arr[pixel_arr_idx + 2] = pix_arr[pixel_arr_swap_idx + 2];
            pix_arr[pixel_arr_idx + 3] = pix_arr[pixel_arr_swap_idx + 3];
            
            pix_arr[pixel_arr_swap_idx + 0] = blue1;
            pix_arr[pixel_arr_swap_idx + 1] = green1;
            pix_arr[pixel_arr_swap_idx + 2] = red1;
            pix_arr[pixel_arr_swap_idx + 3] = alpha1;
        }
    }
}


- (float) to_deg :(float) rad
{
    return rad * 180 / M_PI;
}



// Testing:

-(void) print {
    printf( "   %i/%i \n", numerator, denominator );
}

-(void) setNumerator: (int) n {
    numerator = n;
}

-(void) setDenominator: (int) d {
    denominator = d;
}

-(int) denominator {
    return denominator;
}

-(int) numerator {
    return numerator;
}



#pragma mark Regression Test

+ (void) set_regression_test :(bool)bool1
{
    regression_test_switch = bool1;
}

+ (bool) get_regression_test
{
    return regression_test_switch;
}

- (void) regression_test
{
    printf("   --- VDMViewController - Regression Test\n");
    
    [self blast_video_synch__regression_test];
}



// void blast_video_synch__regression_test_test()
// {
//     // PARegressionTest* rtest = [PARegressionTest alloc].init;
//     VDMRegressionTest* rtest = [VDMRegressionTest alloc].init;
// }


- (void) blast_video_synch__regression_test
// void blast_video_synch__regression_test()
{
    int num_regression_test_cases = 8; // 9; // 8; // 4;
    int read_or_write_metrics_files =  0; // 0; //  1;           // 0 = read (and compare), 1 = write
    // [self system_sound: 16];
    
    if (production_mode)
    {
        [self.draw_field2 turn_clubhead_subimg_mask_off];
    }
    
    [ _draw_field2 turn_text_display_off ];
    if (sport == 50) { [ _draw_field2 turn_text_display_on  ]; }      // Turn text display on for Putt
    
    shift_box2_x = -100;     // remove blue box from view
    shift_box2_y = -100;
    
    shift_box3_x = -100;     // remove green box from view
    shift_box3_y = -100;
    
    // First make sure previous video is terminated (cancelled):
    video_cnt++;
    printf("                  -1- blast_video_synch__regression_test - movie_flow: %d   movie_is_running: %d   video_cnt: %d   sport: %d \n", movie_flow, movie_is_running, video_cnt, sport);
    
    
    // Testing threading:
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
        //Background Thread
        
        std::string activity_name1 = "unspecified";
        if      ( sport == 10 ) { activity_name1 = "Tennis"; }
        else if ( sport == 20 ) { activity_name1 = "Ice Hockey"; }
        else if ( sport == 30 ) { activity_name1 = "Baseball"; }
        else if ( sport == 50 ) { activity_name1 = "Golf Putt"; }
        
        
        // RegressionTestResult * results = new RegressionTestResult[num_regression_test_cases];
        RegressionTestResult * results = (RegressionTestResult *)calloc( num_regression_test_cases, sizeof(RegressionTestResult) );
        
        // Use "dictionary" instead of array of structs for "results":
        NSMutableDictionary *metrics_dict1            = [NSMutableDictionary dictionary];
        NSMutableDictionary *activity_metrics = [NSMutableDictionary dictionary];
        
        [metrics_dict1 setObject:activity_metrics forKey:@"Activity Metrics"];    // dict1 contains only one key-value pair
        
        int num_activities = 1;
        NSString *num_activities_ns = [NSString stringWithFormat:@"%d", num_activities];
        [activity_metrics setObject:num_activities_ns forKey:@"Number of activities"];
        
        NSMutableArray *activities = [NSMutableArray array];
        [activity_metrics setObject:activities forKey:@"Activities"];
        
        NSMutableDictionary *activity = [NSMutableDictionary dictionary];
        int activity_no = 0;      // there is only activity for now
        activities[activity_no] = activity;

        std::string activity_name = activity_name1;
        NSString *activity_name_ns = [NSString stringWithFormat:@"%s", activity_name.c_str()];
        
        [activity setObject:activity_name_ns forKey:@"Activity name"];
        
        int num_summary_metrics = 0;
        NSString *num_summary_metrics_ns = [NSString stringWithFormat:@"%d", num_summary_metrics];
        [activity setObject:num_summary_metrics_ns forKey:@"Number of summary metrics"];
        
        NSMutableArray *summary_metrics = [NSMutableArray array];        // leave this empty, there are no summary metrics for now
        [activity setObject:summary_metrics forKey:@"Summary metrics"];
        
        int num_actions = 1;     // there is only one action for now
        NSString *num_actions_ns = [NSString stringWithFormat:@"%d", num_actions];
        [activity setObject:num_actions_ns forKey:@"Number of actions"];
        
        NSMutableArray *actions = [NSMutableArray array];
        [activity setObject:actions forKey:@"Actions"];
        
        NSMutableDictionary *action = [NSMutableDictionary dictionary];
        int action_no = 0;     // there is only one action for now
        actions[action_no] = action;
        
        std::string action_name = "Swing";      // need to differentiate here
        NSString *action_name_ns = [NSString stringWithFormat:@"%s", action_name.c_str()];
        
        [action setObject:action_name_ns forKey:@"Action name"];
        
        // int num_metrics = 2;    // for now
        // NSString *num_metrics_ns = [NSString stringWithFormat:@"%d", num_metrics];
        // [action setObject:num_metrics_ns forKey:@"Number of metrics"];
        
        NSMutableArray *metrics = [NSMutableArray array];
        [action setObject:metrics forKey:@"Metrics"];
        


        
        
        printf("   -1r- In new thread --- \n");
        
        if (movie_is_running)
        {
            while (movie_is_running) // (movie_flow != 10)                             // wait until previous video is cancelled (runs in seperate thread) - it should set movie_flow to 10 when it is cancelled
            {
                movie_flow = 9;                                                        // 9 means the previous video is requested to terminate
                [NSThread sleepForTimeInterval:0.1];
                printf("                  -2- blast_video_synch - movie_flow: %d   movie_is_running: %d \n", movie_flow, movie_is_running);
            }
        }
        
        printf("   -2r- In new thread --- \n");
        
        movie_flow = 1;             // initialize to regular playing mode - may want to use condition: if (movie_flow != 0)  (starting in step by step mode)
        movie_is_running = 1;
        
        NSDate *methodStart = [NSDate date];
        
        
        [NSThread sleepForTimeInterval:0.2];    // give 0.2 sec. for garbage collection before starting new movie?
        
        printf("   Running separate thread.\n");
        self.output_label.text = [NSString stringWithFormat:@"   test_count: %d \n", test_count++];
        
        max_ball_speed_mph      = 0.0f;
        max_clubhead_speed_mph  = 0.0f;
        impact_clubhead_speed_mph = 0.0f;
        max_swing_speed_mph     = 0.0f;
        impact_frame_no         = 0;              // initialize
        impact_ball_position_x  = 0.0f;
        impact_ball_position_y  = 0.0f;
        down_sampling_factor    = 1;              // reset
        fps_reduction_factor    = 1;              // reset
        
        impact_obj_pos_x = -100;                  // keep out of view
        impact_obj_pos_y = -100;                  // keep out of view
        
        ninety_deg_obj_pos_x = -100;              // keep out of view
        ninety_deg_obj_pos_y = -100;              // keep out of view
        
        prev_obj_center_x = 0.0f;                 // reset
        prev_obj_center_y = 0.0f;                 // reset
        
        prev_ball_radius = 0.0f;                  // reset
        
        
        // PARegressionTest* rtest;
        VDMRegressionTest* rtest = [VDMRegressionTest alloc].init;
        
        NSMutableArray *regression_test_report = [NSMutableArray array];
        rtest.messages = regression_test_report;
        rtest.num_files_int = 0;
        rtest.num_metric_matches = 0;
        rtest.num_metric_differences = 0;
        rtest.num_files_without_diff = 0;
        rtest.num_files_with_diff = 0;
        rtest.num_missing_expected_metrics_files = 0;
        rtest.num_jumps = 0;
        rtest.num_freefalls = 0;
        rtest.num_sprints = 0;
        rtest.num_interesting_actions = 0;
        
        
        int phase = 1;
        
        // /*
        for (int case_no = 0; case_no < num_regression_test_cases; case_no++)
        {
            printf("   ---------------*--- case_no: %5d\n", case_no);
            
            switch (case_no)
            {
                case 0: [self set_demo_b1];  break;     // baseball
                case 1: [self set_demo_t2];  break;     // tennis serve
                case 2: [self set_demo_h1];  break;     // ice hockey
                case 3: [self set_demo_h2];  break;     // ice hockey
                case 4: [self set_demo_t1];  break;     // tennis serve
                case 5: [self set_demo_g1];  break;     // golf swing
                case 6: [self set_demo_g4];  break;     // golf putt
                case 7: [self set_demo_putt_s1_trimmed];     break;     // golf putt
            //  case 8: [self set_demo_putt_s1_full];        break;     // golf putt
                case 8: [self set_demo_putt_s2_trimmed];     break;     // golf putt
                    
                    
            }
            
            // select_video_button.enabled = FALSE;
            // [select_video_button setTitle:video_label forState:UIControlStateNormal];
            dispatch_async(dispatch_get_main_queue(), ^(void){                //Run UI Updates
                [select_video_button setTitle:video_label forState:UIControlStateNormal];
                [select_video_button setNeedsDisplay];
                [select_video_button layoutIfNeeded];
            });
            // select_video_button.enabled = TRUE;
            
            [NSThread sleepForTimeInterval:1.0];
            
            [self process_movie :phase];
            
            [NSThread sleepForTimeInterval:1.0];
            
            
            results[case_no].impact_frame = impact_frame_no;
            results[case_no].max_ball_speed   = max_ball_speed_mph;
            
            
            
            // First metric (impact frame no):
            
            int metric_no = 0;
            NSMutableDictionary *metric1 = [NSMutableDictionary dictionary];
            metrics[metric_no] = metric1;
            // [metrics addObject:metric1];    // as alternative to previous line to ensure memory allocation?
            
            std::string metric_name1 = "Impact Frame";
            NSString *metric_name_ns1 = [NSString stringWithFormat:@"%s", metric_name1.c_str()];
            
            NSString * metric_value_ns = [NSString stringWithFormat:@"%d", impact_frame_no];
            
            std::string metric_unit1  = "";
            NSString *metric_unit_ns1 = [NSString stringWithFormat:@"%s", metric_unit1.c_str()];
            
            int metric_order_position1 = 1;
            NSString *metric_order_position_ns1 = [NSString stringWithFormat:@"%d", metric_order_position1];
            
            NSArray *metric_val1 = [NSArray arrayWithObjects:metric_value_ns, metric_unit_ns1, metric_order_position_ns1, nil];
            
            [metric1 setObject:metric_val1 forKey:metric_name_ns1];
            
            
            // Second metric (max ball speed):
            
            metric_no++;
            NSMutableDictionary *metric2 = [NSMutableDictionary dictionary];
            metrics[metric_no] = metric2;
            
            std::string metric_name2 = "Max Ball Speed";
            NSString *metric_name_ns2 = [NSString stringWithFormat:@"%s", metric_name2.c_str()];
            
            NSString * metric_value_ns2 = [NSString stringWithFormat:@"%f", max_ball_speed_mph];
            
            std::string metric_unit2  = "mph";
            NSString *metric_unit_ns2 = [NSString stringWithFormat:@"%s", metric_unit2.c_str()];
            
            int metric_order_position2 = 2;
            NSString *metric_order_position_ns2 = [NSString stringWithFormat:@"%d", metric_order_position2];
            
            NSArray *metric_val2 = [NSArray arrayWithObjects:metric_value_ns2, metric_unit_ns2, metric_order_position_ns2, nil];
            
            [metric2 setObject:metric_val2 forKey:metric_name_ns2];
            
            
            // Third metric (max ball rpm):
            
            metric_no++;
            NSMutableDictionary *metric3 = [NSMutableDictionary dictionary];
            metrics[metric_no] = metric3;
            
            std::string metric_name3 = "Max Ball RPM";
            NSString *metric_name_ns3 = [NSString stringWithFormat:@"%s", metric_name3.c_str()];
            
            NSString * metric_value_ns3 = [NSString stringWithFormat:@"%d", max_ball_rpm];
            
            std::string metric_unit3  = "";
            NSString *metric_unit_ns3 = [NSString stringWithFormat:@"%s", metric_unit3.c_str()];
            
            int metric_order_position3 = 3;
            NSString *metric_order_position_ns3 = [NSString stringWithFormat:@"%d", metric_order_position3];
            
            NSArray *metric_val3 = [NSArray arrayWithObjects:metric_value_ns3, metric_unit_ns3, metric_order_position_ns3, nil];
            
            [metric3 setObject:metric_val3 forKey:metric_name_ns3];
            

            int num_metrics = metric_no + 1;    // for now
            NSString *num_metrics_ns = [NSString stringWithFormat:@"%d", num_metrics];
            // printf("   ---nm--- num_metrics: %d\n", num_metrics);
            [action setObject:num_metrics_ns forKey:@"Number of metrics"];
            log_print([NSString stringWithFormat:@"   ---nm--- num_metrics_ns:  %@ \n", num_metrics_ns]);

            
            // Write out metrics file:
            if (read_or_write_metrics_files == 1)
            {
                NSString * file_ns = thePath;
                // write_metrics_to_file(file_ns, results);
                [self write_metrics_to_file :case_no :file_ns :results[case_no] :metrics_dict1];
            }
            else   // read (expected) metrics from file and compare with current metrics
            {
                NSString * file_ns = thePath;
                read_metrics_from_file(file_ns, metrics_dict1, rtest);
            }
            
        }
        // */
        
        /*
        // TESTING:
        if (regression_test_switch)
        {
            [self set_demo_t1];
            [self process_movie :phase];
            
            [NSThread sleepForTimeInterval:1.0];
            [self set_demo_t2];
            [self process_movie :phase];
            
            [NSThread sleepForTimeInterval:1.0];
            [self set_demo_h1];
            [self process_movie :phase];
            
            [NSThread sleepForTimeInterval:1.0];
            [self set_demo_h2];
            [self process_movie :phase];
            
            [NSThread sleepForTimeInterval:1.0];
            [self set_demo_b1];
            [self process_movie :phase];
        }
        */
        
        
        // Print out regression test results;
        printf("   --- regression test results:\n");
        for (int case_no = 0; case_no < num_regression_test_cases; case_no++)
        {
            printf("         case: %5d   impact_frame: %5d   max_ball_speed: %8.2f \n",  case_no,  results[case_no].impact_frame,  results[case_no].max_ball_speed);
        }

        
        // if (! (movie_flow == 10))    // if movie was not cancelled
        // {
        //     [self system_sound: 1];
        // }
        
        /*x
        // [NSThread sleepForTimeInterval:0.4];    // give 0.4 sec. for garbage collection before starting new movie?
        if (! regression_test_switch)              // don't run phase 2 in regression test mode
        {
            movie_flow = 0;                         // pause so that user can review the data and graphs
            while (movie_flow == 0)
            {
                [NSThread sleepForTimeInterval:0.1];
            }
            
            if (! (movie_flow == 10))    // if movie was not cancelled
            {
                phase = 2;
                [self process_movie :phase];                                            // <<<<<<<<<<<<<  process movie to show video in synch with sensor graph
            }
        }
        x*/
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            
            [self.output_label setNeedsDisplay];
        });
        
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"   ---r--- ExecutionTime = %f", executionTime);
        
        bool pass_flag_metrics = print_regression_test_report(rtest);
        
        // if (! (movie_flow == 10))    // if movie was not cancelled
        // {
        //     [self talk];
        // }
        
        movie_is_running = 0;
        regression_test_status = 1;    // 1 means: video is finished
        
        printf("      === End of dispatch_async in blast_video_synch__regression_test() \n");
        
        
        if (results) { free( results ); }
        // delete [] results;

    });
    
    printf("   === End of blast_video_synch__regression_test() \n");
    
}



/**
 *  Write metrics to file in JSON format (into the directory where the source csv file is)
 */
// - (void) write_metrics_to_file :(NSString *)file_ns :(RegressionTestResult *)results
- (void) write_metrics_to_file :(int)case_no :(NSString *)file_ns :(RegressionTestResult)result1 :(NSMutableDictionary *)metrics_dict1
{
    NSString * stem = [file_ns stringByDeletingPathExtension];
    NSString * suffix = @"_metrics";
    NSString *file2_ns = [NSString stringWithFormat:@"%@%@.txt", stem, suffix];
    const char * file_spec1 = [file2_ns UTF8String];
    printf("\n   --- Writing metrics to file: %s \n", file_spec1);
    
    
    std::string activity_name1 = "unspecified";
    if      ( sport == 10 ) { activity_name1 = "Tennis"; }
    else if ( sport == 20 ) { activity_name1 = "Ice Hockey"; }
    else if ( sport == 30 ) { activity_name1 = "Baseball"; }
    else if ( sport == 50 ) { activity_name1 = "Golf Putt"; }
    
    int num_actions = 1;
    std::string action_name = "Swing";
    int num_metrics = 2;
    
    
    // Access the dictionary "metrics_dict1":
    NSDictionary *activity_metrics_current = [metrics_dict1 objectForKey:@"Activity Metrics"];
    NSNumber *num_activities_current = [activity_metrics_current objectForKey:@"Number of activities"];
    printf("   -r- num_activities (current):  %d \n", [num_activities_current intValue]);
    NSArray *activities_current = [activity_metrics_current objectForKey:@"Activities"];
    int num_activities = (int)[activities_current count];
    
    int activity_no = 0;
    NSDictionary *activity_current = activities_current[activity_no];
    NSString *activity_current_name = [activity_current objectForKey:@"Activity name"];
    log_print([NSString stringWithFormat:@"      -r- activity_current_name:  %@ \n", activity_current_name]);

    NSNumber *num_actions_current  = [activity_current objectForKey:@"Number of actions"];
    log_print([NSString stringWithFormat:@"      -r- num_actions_current:  %@ \n", num_actions_current]);
    
    NSArray *actions_current  = [activity_current objectForKey:@"Actions"];

    
    
    std::ofstream file_stream;
    file_stream.open(file_spec1);
    
    
    file_stream << "{ " << std::endl;
    file_stream << "   \"Activity Metrics\": " << std::endl;
    file_stream << "   { " << std::endl;
    file_stream << "      \"Number of activities\": " << "\"" << "1" << "\"," << std::endl;
    
    file_stream << "      \"Activities\": " << std::endl;
    file_stream << "      [" << std::endl;
    
    
    file_stream << "         { " << std::endl;
    
    file_stream << "            \"Activity name\": "     << "\"" << activity_name1 << "\"," << std::endl;
    file_stream << "            \"Number of summary metrics\": "     << "\"" << "0" << "\"," << std::endl;
    
    file_stream << "            \"Summary metrics\": " << std::endl;
    file_stream << "            [ " << std::endl;
    
    file_stream << "            ]," << std::endl;
    
    
    file_stream << "            \"Number of actions\": " << "\"" << num_actions << "\","<< std::endl;
    
    file_stream << "            \"Actions\": " << std::endl;
    file_stream << "            [" << std::endl;
    
    for (int action_no = 0; action_no < num_actions; action_no++)
    {
        NSDictionary *action_current = actions_current[action_no];
        NSString *action_name_current = [action_current objectForKey:@"Action name"];
        log_print([NSString stringWithFormat:@"         -r- action_name_current: %@ \n", action_name_current]);
        const char *action_name1 = [action_name_current UTF8String];
        
        NSNumber *num_metrics_current = [action_current objectForKey:@"Number of metrics"];
        int num_metrics = num_metrics_current.intValue;
        log_print([NSString stringWithFormat:@"         -r- num_metrics_current:  %@ \n", num_metrics_current]);
        
        NSArray *metrics_current  = [action_current  objectForKey:@"Metrics"];
        
        file_stream << "               { " << std::endl;
        
        file_stream << "                  \"Action name\": "       << "\"" << action_name1 << "\"," << std::endl;
        file_stream << "                  \"Number of metrics\": " << "\"" << num_metrics << "\"," << std::endl;
        
        file_stream << "                  \"Metrics\": " << std::endl;
        file_stream << "                  [ " << std::endl;
        
        for (int metric_no = 0; metric_no < num_metrics; metric_no++)
        {
            NSString *metric_name_current;
            NSString *value_current;
            NSString *unit_current;
            
            NSDictionary *metric_current  = metrics_current[metric_no];
            for (NSString *key1 in metric_current)        // currently there is only 1 key-value pair per metric
            {
                metric_name_current = key1;
                    
                NSArray *metric_value_current = metric_current[key1];
                value_current = metric_value_current[0];     // number
                unit_current  = metric_value_current[1];     // unit
                    
                log_print([NSString stringWithFormat:@"            -r- metric_name_current:  %@: %@ %@ \n", metric_name_current, value_current, unit_current]);
            }
                
            const char *metric_name1 = [metric_name_current UTF8String];
            const char *value_current1 = [value_current UTF8String];
            const char *unit_current1 = [unit_current UTF8String];
            
            
            file_stream << "                     " << "{ \"" << metric_name1 << "\"" << ": [ ";
            file_stream << "\"" << value_current1 << "\"";
            file_stream << ", " << "\"" << unit_current1 << "\"" << " ] }";
            file_stream << ",";
            file_stream << std::endl;
        }
        
        /*x
        file_stream << "                     " << "{ \"" << "Impact Frame" << "\"" << ": [ ";
        file_stream << "\"" << result1.impact_frame << "\"";
        file_stream << ", " << "\"" << "" << "\"" << " ] }";
        file_stream << ",";
        file_stream << std::endl;
        
        file_stream << "                     " << "{ \"" << "Max Ball Speed" << "\"" << ": [ ";
        file_stream << "\"" << result1.max_ball_speed << "\"";
        file_stream << ", " << "\"" << "mph" << "\"" << " ] }";
        file_stream << std::endl;
        
        x*/
        
        file_stream << "                  ]" << std::endl;
        
        file_stream << "               }";
        if ((action_no + 1) < num_actions) { file_stream << ", "; }
        file_stream << std::endl;
    }
    
    file_stream << "            ]" << std::endl;

    file_stream << "         }" << std::endl;   // end of activity

    
    file_stream << "      ]" << std::endl;
    file_stream << "   } " << std::endl;
    file_stream << "} " << std::endl;
    
    file_stream.close();
}




/**
 *  Read metrics from file in JSON format (from the directory where the source csv file is)
 */
void read_metrics_from_file(NSString *file_ns, NSDictionary *metrics, VDMRegressionTest *rtest)
{
    // HelmetMetrics::ActivityMetrics *am1 = &metrics_regression_test->activity_metrics;
    // GenericMotionMetrics::ActivityMetrics *am1 = &metrics->activity_metrics;
    
    NSUInteger file_spec_length = [file_ns length];
    // NSUInteger idx1 = file_spec_length - 4;
    // NSString * stem = [file_ns substringToIndex:idx1];
    NSString * stem = [file_ns stringByDeletingPathExtension];
    NSString * suffix = @"_metrics";
    NSString *file2_ns = [NSString stringWithFormat:@"%@%@.txt", stem, suffix];
    const char * file_spec1 = [file2_ns UTF8String];
    printf("\n   --- Reading metrics from file: %s \n", file_spec1);
    
    /*
     NSString *jsonPath = [[NSBundle mainBundle] pathForResource:file2_ns
     ofType:@"json"];
     NSData *data = [NSData dataWithContentsOfFile:jsonPath];
     NSError *error = nil;
     id json = [NSJSONSerialization JSONObjectWithData:data
     options:kNilOptions
     error:&error];
     NSLog(@"JSON: %@", json);
     */
    
    NSError *error = nil;
    NSString *jsonPath = file2_ns;
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    
    if (data == nil)
    {
        log_print([NSString stringWithFormat:@"   ###------------------- File not found: %@ --------------------###\n", file2_ns]);
        rtest.num_missing_expected_metrics_files++;
    }
    else
    {
        NSDictionary *expected_metrics = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:NSJSONReadingMutableLeaves
                                          error:&error];
        
        // id json = [NSJSONSerialization JSONObjectWithData:data
        //                                           options:kNilOptions
        //                                             error:&error];
        
        // NSLog(@"JSON: %@", json);
        
        // NSString *string2_ns = [NSString stringWithFormat:@"%@", json];
        // const char * string2 = [string2_ns UTF8String];
        // DBPrint("   @@@ JSON object @@@ %s \n", string2);
        
        
        compare_activity_metrics(expected_metrics, metrics, file_ns, rtest);
    }
}



void compare_activity_metrics(NSDictionary *expected_metrics, NSDictionary *metrics_dict, NSString *file_ns, VDMRegressionTest *rtest)
{
    // TODO: Only show file name (omit path) for now:
    NSString* file_name_only = [file_ns lastPathComponent];
    NSString* file_spec = file_name_only; // file_ns;
    // file_ns = file_name_only;
    
    //x NSDictionary *metrics_dict = convert_helmetmetrics_to_dictionary(&metrics->activity_metrics);                               // Convert HelmetMetrics to NSDictionary
    
    // NSString *dict_string = [NSString stringWithFormat:@"%@", metrics_dict];
    // log_print(@"\n      @-- Converting HelmetMetrics to Dictionary:\n");
    // log_print(dict_string);
    // log_print(@"\n      @-- Done converting HelmetMetrics to Dictionary \n\n");
    
    
    NSDictionary *activities_metrics_dict = [expected_metrics objectForKey:@"Activity Metrics"];
    NSNumber *num_activities = [activities_metrics_dict objectForKey:@"Number of activities"];
    log_print([NSString stringWithFormat:@"   -r- num_activities (expected): %@ \n", num_activities]);
    NSArray *activities_expected = [activities_metrics_dict objectForKey:@"Activities"];
    
    NSDictionary *activity_metrics_current = [metrics_dict objectForKey:@"Activity Metrics"];
    NSNumber *num_activities_current = [activity_metrics_current objectForKey:@"Number of activities"];
    log_print([NSString stringWithFormat:@"   -r- num_activities (current):  %@ \n", num_activities_current]);
    NSArray *activities_current = [activity_metrics_current objectForKey:@"Activities"];
    
    
    /*
     NSArray *activities = [activities_metrics_dict objectForKey:@"Activities"];
     for (NSDictionary *activity in activities)
     {
     NSString *activity_name = [activity objectForKey:@"Activity name"];
     NSString *str2 = [NSString stringWithFormat:@"      -r- activity_name: %@ \n", activity_name];
     log_print(str2);
     
     NSNumber *num_actions = [activity objectForKey:@"Number of actions"];
     log_print([NSString stringWithFormat:@"      -r- num_actions: %@ \n", num_actions]);
     
     NSArray *actions = [activity objectForKey:@"Actions"];
     
     for (NSDictionary *action in actions)
     {
     NSString *action_name = [action objectForKey:@"Action name"];
     log_print([NSString stringWithFormat:@"         -r- action_name: %@ \n", action_name]);
     
     NSNumber *num_metrics = [action objectForKey:@"Number of metrics"];
     log_print([NSString stringWithFormat:@"         -r- num_metrics: %@ \n", num_metrics]);
     
     NSArray *metrics = [action objectForKey:@"Metrics"];
     
     for (NSDictionary *metric in metrics)
     {
     for (NSString *key1 in metric)        // currently there is only 1 key-value pair per metric
     {
     NSString *metric_name = key1;
     
     NSArray *metric_value = metric[key1];
     NSString *value = metric_value[0];     // number
     NSString *unit  = metric_value[1];     // unit
     
     log_print([NSString stringWithFormat:@"            -r- metric_name: %@: %@ %@ \n", metric_name, value, unit]);
     }
     }
     }
     }
     */
    
    int num_mismatches_in_this_file = 0;
    
    for (int activity_no = 0; activity_no < num_activities.intValue; activity_no++)
    {
        NSDictionary *activity_expected = activities_expected[activity_no];
        NSString *activity_expected_name = [activity_expected objectForKey:@"Activity name"];
        log_print([NSString stringWithFormat:@"      -r- activity_expected_name: %@   num_activities: %d \n", activity_expected_name, num_activities.intValue]);
        
        if (activity_no < [activities_current count])
        {
            NSDictionary *activity_current = activities_current[activity_no];
            NSString *activity_current_name = [activity_current objectForKey:@"Activity name"];
            log_print([NSString stringWithFormat:@"      -r- activity_current_name:  %@ \n", activity_current_name]);
            
            
            
            // ----------------- Compare summary metrics:
            
            NSNumber *num_summary_metrics_expected = [activity_expected objectForKey:@"Number of summary metrics"];
            log_print([NSString stringWithFormat:@"      -r- num_summary_metrics_expected: %@ \n", num_summary_metrics_expected]);
            
            NSNumber *num_summary_metrics_current  = [activity_current objectForKey:@"Number of summary metrics"];
            log_print([NSString stringWithFormat:@"      -r- num_summary_metrics_current:  %@ \n", num_summary_metrics_current]);
            
            
            NSArray *sum_metrics_expected = [activity_expected objectForKey:@"Summary metrics"];
            NSArray *sum_metrics_current  = [activity_current  objectForKey:@"Summary metrics"];
            
            for (int metric_no = 0; metric_no < num_summary_metrics_expected.intValue; metric_no++)
            {
                NSString *summary_metric_name_expected;
                NSString *value_expected;
                NSString *unit_expected;
                
                NSDictionary *metric_expected = sum_metrics_expected[metric_no];
                for (NSString *key1 in metric_expected)            // currently there is only 1 key-value pair per metric
                {
                    summary_metric_name_expected = key1;
                    
                    NSArray *metric_value_expected = metric_expected[key1];
                    value_expected = metric_value_expected[0];     // number
                    unit_expected  = metric_value_expected[1];     // unit
                    
                    log_print([NSString stringWithFormat:@"            -r- summary_metric_name_expected: %@: %@ %@ \n", summary_metric_name_expected, value_expected, unit_expected]);
                }
                
                
                NSString *summary_metric_name_current;
                NSString *value_current;
                NSString *unit_current;
                
                if (metric_no < [sum_metrics_current count])
                {
                    NSDictionary *metric_current  = sum_metrics_current[metric_no];
                    for (NSString *key1 in metric_current)        // currently there is only 1 key-value pair per metric
                    {
                        summary_metric_name_current = key1;
                        
                        NSArray *metric_value_current = metric_current[key1];
                        value_current = metric_value_current[0];     // number
                        unit_current  = metric_value_current[1];     // unit
                        
                        log_print([NSString stringWithFormat:@"            -r- summary_metric_name_current:  %@: %@ %@ \n", summary_metric_name_current, value_current, unit_current]);
                    }
                    
                    
                    // Compare the expected and curent metric values:
                    // Compare numerically:
                    float val_expected = value_expected.floatValue;
                    float val_current  = value_current.floatValue;
                    // float tolerance = fabs(val_expected) * 0.2f;     // 20 percent tolerance
                    float tolerance = fabs(val_expected) * 0.02f;     // 2 percent tolerance
                    if ((fabs(val_expected - val_current)) > tolerance)
                    {
                        NSString *regression_test_msg = [NSString stringWithFormat:@"               -r-!!!  values are different - metric %@ - expected: %5.2f  current: %5.2f !!!                       file: %@ \n",  summary_metric_name_expected, val_expected, val_current, file_spec];
                        log_print(regression_test_msg);
                        [rtest.messages addObject:regression_test_msg];
                        rtest.num_metric_differences++;
                        num_mismatches_in_this_file++;
                    }
                    else
                    {
                        rtest.num_metric_matches++;
                    }
                }
                else
                {
                    const char* missing_metric_name = [summary_metric_name_expected UTF8String];
                    log_print([NSString stringWithFormat:@"               -r-!!! Missing summary metric: %s \n", missing_metric_name]);
                    num_mismatches_in_this_file++;
                }
            }
            
            // ------------------- End of summary metrics comparison.
            
            
            
            NSNumber *num_actions_expected = [activity_expected objectForKey:@"Number of actions"];
            log_print([NSString stringWithFormat:@"      -r- num_actions_expected: %@ \n", num_actions_expected]);
            
            NSNumber *num_actions_current  = [activity_current objectForKey:@"Number of actions"];
            log_print([NSString stringWithFormat:@"      -r- num_actions_current:  %@ \n", num_actions_current]);
            
            // if ([num_actions_current isEqualToNumber:num_actions_expected]) //   //num_actions_expected])
            if (num_actions_expected.intValue != num_actions_current.intValue)
            {
                NSString *regression_test_msg = [NSString stringWithFormat:@"               -r-!!!  %@ number of actions are different - expected: %d  current: %d !!!                       file: %@ \n",  activity_current_name, num_actions_expected.intValue, num_actions_current.intValue, file_spec];
                log_print(regression_test_msg);
                [rtest.messages addObject:regression_test_msg];
                rtest.num_metric_differences++;
                num_mismatches_in_this_file++;
            }
            
            
            NSArray *actions_expected = [activity_expected objectForKey:@"Actions"];
            NSArray *actions_current  = [activity_current objectForKey:@"Actions"];
            
            for (int action_no = 0; action_no < num_actions_expected.intValue; action_no++)
            {
                NSDictionary *action_expected = actions_expected[action_no];
                NSString *action_name_expected = [action_expected objectForKey:@"Action name"];
                log_print([NSString stringWithFormat:@"         -r- action_name_expected: %@ \n", action_name_expected]);
                
                if (action_no < [actions_current count])
                {
                    NSDictionary *action_current  = actions_current[action_no];
                    NSString *action_name_current = [action_current objectForKey:@"Action name"];
                    log_print([NSString stringWithFormat:@"         -r- action_name_current:  %@ \n", action_name_current]);
                    
                    /*
                    // Count number of jumps, free falls, sprints, etc.:
                    if ([action_name_current isEqualToString:[NSString stringWithFormat:@"%s", ACTION__JUMP.c_str()]])        { rtest.num_jumps++; }
                    if ([action_name_current isEqualToString:[NSString stringWithFormat:@"%s", ACTION__UP_JUMP.c_str()]])     { rtest.num_up_jumps++; }
                    if ([action_name_current isEqualToString:[NSString stringWithFormat:@"%s", ACTION__DOWN_JUMP.c_str()]])   { rtest.num_down_jumps++; }
                    if ([action_name_current isEqualToString:[NSString stringWithFormat:@"%s", ACTION__FREE_FALL.c_str()]])   { rtest.num_freefalls++; }
                    if ([action_name_current isEqualToString:[NSString stringWithFormat:@"%s", ACTION__SPRINT.c_str()]])      { rtest.num_sprints++; }
                    if ([action_name_current isEqualToString:[NSString stringWithFormat:@"%s", ACTION__INTERESTING.c_str()]]) { rtest.num_interesting_actions++; }
                    */
                    
                    NSNumber *num_metrics_expected = [action_expected objectForKey:@"Number of metrics"];
                    log_print([NSString stringWithFormat:@"         -r- num_metrics_expected: %@ \n", num_metrics_expected]);
                    
                    NSNumber *num_metrics_current = [action_current objectForKey:@"Number of metrics"];
                    log_print([NSString stringWithFormat:@"         -r- num_metrics_current:  %@ \n", num_metrics_current]);
                    
                    
                    NSArray *metrics_expected = [action_expected objectForKey:@"Metrics"];
                    NSArray *metrics_current  = [action_current  objectForKey:@"Metrics"];
                    
                    for (int metric_no = 0; metric_no < num_metrics_expected.intValue; metric_no++)
                    {
                        NSString *metric_name_expected;
                        NSString *value_expected;
                        NSString *unit_expected;
                        
                        NSDictionary *metric_expected = metrics_expected[metric_no];
                        for (NSString *key1 in metric_expected)        // currently there is only 1 key-value pair per metric
                        {
                            metric_name_expected = key1;
                            
                            NSArray *metric_value_expected = metric_expected[key1];
                            value_expected = metric_value_expected[0];     // number
                            unit_expected  = metric_value_expected[1];     // unit
                            
                            log_print([NSString stringWithFormat:@"            -r- metric_name_expected: %@: %@ %@ \n", metric_name_expected, value_expected, unit_expected]);
                        }
                        
                        
                        NSString *metric_name_current;
                        NSString *value_current;
                        NSString *unit_current;
                        
                        if (metric_no < [metrics_current count])
                        {
                            NSDictionary *metric_current  = metrics_current[metric_no];
                            for (NSString *key1 in metric_current)        // currently there is only 1 key-value pair per metric
                            {
                                metric_name_current = key1;
                                
                                NSArray *metric_value_current = metric_current[key1];
                                value_current = metric_value_current[0];     // number
                                unit_current  = metric_value_current[1];     // unit
                                
                                log_print([NSString stringWithFormat:@"            -r- metric_name_current:  %@: %@ %@ \n", metric_name_current, value_current, unit_current]);
                            }
                            
                            
                            // Compare the expected and current metric values:
                            // NSComparisonResult is_different = [value_expected compare:value_current];
                            // if (! (is_different == 0))
                            // {
                            //     log_print(@"               -r-!!! values are different !!! \n");
                            // }
                            
                            // Compare numerically:
                            float val_expected = value_expected.floatValue;
                            float val_current  = value_current.floatValue;
                            float tolerance = fabs(val_expected) * 0.02f;     // 2 percent tolerance
                            if ((fabs(val_expected - val_current)) > tolerance)
                            {
                                NSString *regression_test_msg = [NSString stringWithFormat:@"               -r-!!!  values are different - metric %40s - expected: %10.2f  current: %10.2f !!!                       file: %@ \n",  [metric_name_expected UTF8String], val_expected, val_current, file_spec];
                                log_print(regression_test_msg);
                                [rtest.messages addObject:regression_test_msg];
                                rtest.num_metric_differences++;
                                num_mismatches_in_this_file++;
                            }
                            else
                            {
                                rtest.num_metric_matches++;
                            }
                            
                            // Testing: trying to convert a string that does not represent a number results in a zero:
                            // if ([value_expected compare:@"right"] == 0)
                            // {
                            //     log_print([NSString stringWithFormat:@"                  numeric ... val_expected: %f   val_current: %f \n", val_expected, val_current]);
                            // }
                        }
                        else
                        {
                            const char* missing_metric_name = [metric_name_expected UTF8String];
                            log_print([NSString stringWithFormat:@"               -r-!!! Missing metric: %s \n", missing_metric_name]);
                            num_mismatches_in_this_file++;
                        }
                    }
                }
                else
                {
                    const char* missing_action_expected_name = [action_name_expected UTF8String];
                    log_print([NSString stringWithFormat:@"      -r-!!! Missing action: %s \n", missing_action_expected_name]);
                    num_mismatches_in_this_file++;
                }
            }
        }
        else
        {
            const char* missing_activity_expected_name = [activity_expected_name UTF8String];
            log_print([NSString stringWithFormat:@"      -r-!!! Missing activity: %s \n", missing_activity_expected_name]);
            num_mismatches_in_this_file++;
        }
        
    }
    
    if (num_mismatches_in_this_file > 0)
    {
        rtest.num_files_with_diff++;
    }
    else
    {
        rtest.num_files_without_diff++;
    }
}




bool print_regression_test_report(VDMRegressionTest *rtest)
{
    // int debug_output_level_hold = debug_output_level;
    // debug_output_level = 10;
    
    log_print(@"\n--------------- regression test report ----------------------------------------------\n");
    log_print(@"|\n");
    // NSInteger *num_files_ns = rtest.num_files;
    // long* num_files_int = num_files_ns;
    // long num2 = (* num_files_int);
    
    int num_files = rtest.num_files_int;
    log_print([NSString stringWithFormat:@"|   Number of input files:          %6.1d \n", num_files]);
    
    int num_metric_matches = rtest.num_metric_matches;
    log_print([NSString stringWithFormat:@"|   Number of metrics matches:      %6.1d  ", num_metric_matches]);
    
    int num_metric_differences = rtest.num_metric_differences;
    log_print([NSString stringWithFormat:@"    Number of metrics differences:  %6.1d \n", num_metric_differences]);
    
    int num_files_without_diff = rtest.num_files_without_diff;
    log_print([NSString stringWithFormat:@"|   Number of files without diffs:  %6.1d  ", num_files_without_diff]);
    
    int num_files_with_diff = rtest.num_files_with_diff;
    log_print([NSString stringWithFormat:@"    Number of files with diffs:     %6.1d \n", num_files_with_diff]);
    
    int num_missing_expected_metrics_files = rtest.num_missing_expected_metrics_files;
    log_print([NSString stringWithFormat:@"|   Missing expected metrics files: %6.1d \n", num_missing_expected_metrics_files]);
    
    log_print(@"|\n");
    int num_jumps__expected               = 2043; //  877; //  705; // 693;
    int num_up_jumps__expected            =   38;
    int num_down_jumps__expected          =   12;
    int num_freefalls__expected           =  892; //  912; //  500; // 347;
    int num_sprints__expected             =  526; //  199; //  183; // 165;
    int num_interesting_actions__expected = 4100; // 2730; // 1046; // 880;
    int total_num_actions__expected       = num_jumps__expected + num_up_jumps__expected + num_down_jumps__expected + num_freefalls__expected + num_sprints__expected + num_interesting_actions__expected;
    
    int total_number_of_actions = rtest.num_jumps + rtest.num_up_jumps + rtest.num_down_jumps + rtest.num_freefalls + rtest.num_sprints + rtest.num_interesting_actions;
    
    int num_jumps__diff               = num_jumps__expected               - rtest.num_jumps;
    int num_up_jumps__diff            = num_up_jumps__expected            - rtest.num_up_jumps;
    int num_down_jumps__diff          = num_down_jumps__expected          - rtest.num_down_jumps;
    int num_freefalls__diff           = num_freefalls__expected           - rtest.num_freefalls;
    int num_sprints__diff             = num_sprints__expected             - rtest.num_sprints;
    int num_interesting_actions__diff = num_interesting_actions__expected - rtest.num_interesting_actions;
    int total_num_actions_diff        = total_num_actions__expected       - total_number_of_actions;
    
    float num_jumps__percent_diff               = (100.0f * ((float)num_jumps__diff))               / ((float) num_jumps__expected);
    float num_up_jumps__percent_diff            = (100.0f * ((float)num_up_jumps__diff))            / ((float) num_up_jumps__expected);
    float num_down_jumps__percent_diff          = (100.0f * ((float)num_down_jumps__diff))          / ((float) num_down_jumps__expected);
    float num_freefalls__percent_diff           = (100.0f * ((float)num_freefalls__diff))           / ((float) num_freefalls__expected);
    float num_sprints__percent_diff             = (100.0f * ((float)num_sprints__diff))             / ((float) num_sprints__expected);
    float num_interesting_actions__percent_diff = (100.0f * ((float)num_interesting_actions__diff)) / ((float) num_interesting_actions__expected);
    float total_num_actions__percent_diff       = (100.0f * ((float)total_num_actions_diff))        / ((float) total_num_actions__expected);
    
    log_print([NSString stringWithFormat:@"|   Number of jumps:                %6.1d (expected %5.1d)  diff: %5d (%6.1f %%) \n", rtest.num_jumps, num_jumps__expected, num_jumps__diff, num_jumps__percent_diff]);
    log_print([NSString stringWithFormat:@"|   Number of up-jumps:             %6.1d (expected %5.1d)  diff: %5d (%6.1f %%) \n", rtest.num_up_jumps, num_up_jumps__expected, num_up_jumps__diff, num_up_jumps__percent_diff]);
    log_print([NSString stringWithFormat:@"|   Number of down-jumps:           %6.1d (expected %5.1d)  diff: %5d (%6.1f %%) \n", rtest.num_down_jumps, num_down_jumps__expected, num_down_jumps__diff, num_down_jumps__percent_diff]);
    log_print([NSString stringWithFormat:@"|   Number of free falls:           %6.1d (expected %5.1d)  diff: %5d (%6.1f %%) \n", rtest.num_freefalls, num_freefalls__expected, num_freefalls__diff, num_freefalls__percent_diff]);
    log_print([NSString stringWithFormat:@"|   Number of sprints:              %6.1d (expected %5.1d)  diff: %5d (%6.1f %%) \n", rtest.num_sprints, num_sprints__expected, num_sprints__diff, num_sprints__percent_diff]);
    log_print([NSString stringWithFormat:@"|   Number of interesting actions:  %6.1d (expected %5.1d)  diff: %5d (%6.1f %%) \n", rtest.num_interesting_actions, num_interesting_actions__expected, num_interesting_actions__diff, num_interesting_actions__percent_diff]);
    log_print(@"|\n");
    log_print([NSString stringWithFormat:@"|   Total number of actions:        %6.1d (expected %5.1d)  diff: %5d (%6.1f %%) \n", total_number_of_actions, total_num_actions__expected, total_num_actions_diff, total_num_actions__percent_diff]);
    
    // if (rtest.num_jumps               != num_jumps__expected)               { log_print(@"|   ### Discrepancy in number of jumps \n"); }
    // if (rtest.num_freefalls           != num_freefalls__expected)           { log_print(@"|   ### Discrepancy in number of free falls \n"); }
    // if (rtest.num_sprints             != num_sprints__expected)             { log_print(@"|   ### Discrepancy in number of sprints \n"); }
    // if (rtest.num_interesting_actions != num_interesting_actions__expected) { log_print(@"|   ### Discrepancy in number of interesting actions \n"); }
    
    log_print(@"|\n");
    
    for (NSString *line1 in rtest.messages)
    {
        log_print(line1);
    }
    log_print(@"|\n");
    log_print(@"------------ end of regression test report ------------------------------------------\n\n");
    
    // debug_output_level = debug_output_level_hold;
    
    if (num_files_with_diff == 0) { return true; }
    return false;
}



void log_print(NSString *str_ns)
{
    // if (debug_output_level > 0)
    // {
        const char *str = [str_ns UTF8String];
        printf("%s", str);
    // }
}



#pragma mark Memory management

- (void)viewDidUnload {
    // self.imageView = nil;
    self.customLayer = nil;
    // self.prevLayer = nil;
}

- (void)dealloc {
    // [self.captureSession release];
    // [super dealloc];
    
    if (ball_speed_arr) { free(ball_speed_arr); }
    if (head_speed_arr) { free(head_speed_arr); }
    if (ball_rpm_arr)   { free(ball_rpm_arr); }
    
    if (motion_intensity_arr) { free(motion_intensity_arr); }
    
    if (blastman_points_x) { free(blastman_points_x); }
    if (blastman_points_y) { free(blastman_points_y); }
    
    if (top_n_ball_positions) { free(top_n_ball_positions); }

    if (clubhead_subimg) { free(clubhead_subimg); }
    if (clubhead_subimg_mask) { free(clubhead_subimg_mask); }
    if (club_shaft_subimg_mask) { free(club_shaft_subimg_mask); }
    
    if (linear_regression_points_x) { free(linear_regression_points_x); }
    if (linear_regression_points_y) { free(linear_regression_points_y); }
    
    if (ball_box_subimg0) { free(ball_box_subimg0); }
    if (ball_box_subimg1) { free(ball_box_subimg1); }
    if (ball_box_subimg2) { free(ball_box_subimg2); }
    
    if (prev_ball_box_subimg_rotated) { free(prev_ball_box_subimg_rotated); }
}



@end
