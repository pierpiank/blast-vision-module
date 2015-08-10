//
//  VDMViewController.h
//  VidM01
//
//  Created by Juergen Haas on 3/1/14.
//  Copyright (c) 2014 Blast. All rights reserved.
//

#import <UIKit/UIKit.h>

// #import <Foundation/Foundation.h>


#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#import <MobileCoreServices/UTCoreTypes.h>    // using MediaPlayer.framework
#import <MediaPlayer/MediaPlayer.h>           // using MediaPlayer.framework
#import <MobileCoreServices/MobileCoreServices.h>   // using MobileCoreServices.framework


#import "VDMDrawView.h"
#import "VDMDrawView2.h"

#import "VDMSettingsViewController.h"

#import <opencv2/highgui/cap_ios.h>
// using namespace cv;

// Class variable:
static bool regression_test_switch;    // turn regression test on and off
static int  regression_test_status;    // track whether a video is currently being processed

@interface VDMViewController : UIViewController <CvVideoCameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
// @interface VDMViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
// UITextFieldDelegate is used to implement function that makes the keyboard go away when pressing the return button
{
    bool production_mode;    // turn off debugging/development features
    int sport;    // 10: tennis   20: ice hockey
    int rotation_blastman_mode;     // 1 = use blastman for detection orientation
    NSString * thePath;
    NSString * video_label;
    bool path_is_set;
    bool activity_started;
    int reference_ball_image_is_set;
    int max_num_frames;
    
    int * motion_intensity_arr;
    int num_valid_motion_intensity_values;
    int motion_intensity_arr_length;
    
    int numerator;
    int denominator;
    int test_count;
    int movie_frame_width;
    int movie_frame_height;
    int movie_frame_num_pixels;
    float movie_frame_size_factor;
    int movie_frame_bytes_per_row;
    // UIImage * video_display_image;
    
    int shift_x;  // draw posiiton of red box
    int shift_y;
    int box_width_half;
    int box_height_half;
    
    int shift_box2_x;  // draw posiiton of blue box (club head)
    int shift_box2_y;
    int box2_width_half;
    int box2_height_half;
    
    int shift_box3_x;  // draw posiiton of green box (center of box) (club shaft)
    int shift_box3_y;  // draw position of green box (center of box)
    int box3_width_half;
    int box3_height_half;
    
    double club_shaft_end_x;
    double club_shaft_end_y;
    bool club_shaft_is_set;
    bool club_shaft_found;
    
    double prev_shaft_x_pivot;
    double prev_shaft_y_pivot;
    double prev_shaft_length;
    
    int clubhead_subimg_arr_length;
    unsigned char * clubhead_subimg;   // store [red,green,blue] -- dim: 3 * (box2_width_half * 2) * (box2_height_half * 2)
    
    int clubhead_subimg_mask_arr_length;
    int * clubhead_subimg_mask;
    
    int * linear_regression_points_x;
    int * linear_regression_points_y;
    int num_linear_regression_points;
    
    double linear_regression_line_slope;     // Note: linear regression coordinate system is rotated 90 deg to the right
    double linear_regression_line_offset;    // y-offset
    
    int club_shaft_subimg_arr_length;
    unsigned char * club_shaft_subimg;   // store [red,green,blue] -- dim: 3 * (box2_width_half * 2) * (box2_height_half * 2)
    
    int club_shaft_subimg_mask_arr_length;
    int * club_shaft_subimg_mask;
    
    
    // Allocate sub-image for equalizing the ball image (for pattern detection and rotation tracking):
    int ball_box_width;
    int ball_box_height;
    int ball_box_subimg_arr_length;
    unsigned char * ball_box_subimg0;  // store [red,green,blue] -- dim: 4 * ball_box_width * ball_box_height  -- store stationary image of ball
    unsigned char * ball_box_subimg1;  // store [red,green,blue] -- dim: 4 * ball_box_width * ball_box_height
    unsigned char * ball_box_subimg2;  // store [red,green,blue] -- dim: 4 * ball_box_width * ball_box_height
    int ball_box_subimg_swap;          // 1 = ball_box_subimg1 is loaded    2 = ball_box_subimg2 is loaded
    float ball_rotation_angle_at_subimg0;  // ball rotation angle corresponding to ball_box_subimg0
    float ball_rotation_angle_at_subimg1;  // ball rotation angle corresponding to ball_box_subimg1
    float ball_rotation_angle_at_subimg2;  // ball rotation angle corresponding to ball_box_subimg2
    float ball_rotation_angle_acc;

    int prev_ball_box_subimg_rotated_arr_length;
    double * prev_ball_box_subimg_rotated;    // holds the x,y coordinates of each rotated pixel of ball_box_subimg -- dim: 2 * ball_box_width * ball_box_height
    

    int circle_shift_x;   // draw position of red circle (golf ball)
    int circle_shift_y;
    float circle_radius;
    
    int num_blastman_points;
    float * blastman_points_x;
    float * blastman_points_y;
    
    float prev_chest_point_offset_x;
    float prev_chest_point_offset_y;
    
    int img_sect_align_num_rows;
    int img_sect_align_num_cols;
    
    float video_scale_factor_x;
    float video_scale_factor_y;
    
    unsigned char* curr_img;   // = pix_arr
    unsigned char* prev_img;
    unsigned char* display_img;   // to be in synch with the image overlay (red square) 
    unsigned char* pprev_img;
    
    unsigned char* * pix_arr_arr;     // trail of images
    int pix_arr_arr_length;
    int pix_arr_arr_ptr;
    
    
    int prev_pos_x_max;  // for ball speed computation
    int prev_pos_y_max;
    
    int pprev_pos_x_max;  // for ball direction computation
    int pprev_pos_y_max;
    
    int ppprev_pos_x_max;  // // for continuity constraint
    int ppprev_pos_y_max;
    
    
    int prev_obj_center_x;  // for ball speed computation
    int prev_obj_center_y;
    
    int pprev_obj_center_x;  // for ball direction computation
    int pprev_obj_center_y;
    
    int ppprev_obj_center_x;  // // for continuity constraint
    int ppprev_obj_center_y;
    
    
    int prev_pos_box2_x_max;  // for clubhead speed computation
    int prev_pos_box2_y_max;
    
    int pprev_pos_box2_x_max;  // for clubhead direction computation
    int pprev_pos_box2_y_max;
    
    int ppprev_pos_box2_x_max;  // for continuity constraint
    int ppprev_pos_box2_y_max;
    
    int pppprev_pos_box2_x_max;  // for continuity constraint
    int pppprev_pos_box2_y_max;
    
    
    int prev_shaft_x_max;  // for club shaft speed computation
    int prev_shaft_y_max;
    
    int pprev_shaft_x_max;  // for continuity constraint
    int pprev_shaft_y_max;
    
    int ppprev_shaft_x_max;  // for continuity constraint
    int ppprev_shaft_y_max;
    
    int pppprev_shaft_x_max;  // for continuity constraint
    int pppprev_shaft_y_max;
  
    
    float prev_ball_radius;
    
    float prev_center_of_mass_x;
    float prev_center_of_mass_y;
    
    int obj_color_red;
    int obj_color_green;
    int obj_color_blue;
    
    float ball_radius_shape_based;   // in pixels
    float ball_radius;   // in pixels
    float ball_speed_mph;
    float max_ball_speed_mph;
    
    double shaft_line_slope;
    double shaft_line_slope_minus_1;
    double shaft_line_slope_minus_2;
    double shaft_line_slope_minus_3;
    double shaft_line_slope_minus_4;
    double shaft_line_slope_minus_5;
    double shaft_line_slope_minus_6;
    double shaft_line_slope_minus_7;
    double shaft_line_slope_minus_8;
    double shaft_line_slope_minus_9;
    double shaft_line_slope_minus_10;
    
    double shaft_line_offset;
    double shaft_line_offset_minus_1;
    double shaft_line_offset_minus_2;
    double shaft_line_offset_minus_3;
    double shaft_line_offset_minus_4;
    double shaft_line_offset_minus_5;
    double shaft_line_offset_minus_6;
    double shaft_line_offset_minus_7;
    double shaft_line_offset_minus_8;
    double shaft_line_offset_minus_9;
    double shaft_line_offset_minus_10;
    
    float clubhead_speed_mph;
    float clubhead_speed_mph_minus_1;
    float clubhead_speed_mph_minus_2;
    float clubhead_speed_mph_minus_3;
    float clubhead_speed_mph_minus_4;
    
    float max_clubhead_speed_mph;
    float impact_clubhead_speed_mph;
    float impact_ratio;  // "smash factor"
    float max_swing_speed_mph;
    
    float smoothed_clubhead_speed_mph;
    float smoothed_clubhead_speed_mph_minus_1;
    float smoothed_clubhead_speed_mph_minus_2;
    float smoothed_clubhead_speed_mph_minus_3;
    float smoothed_clubhead_speed_mph_minus_4;

    float ball_speed;
    float ball_speed_1;
    float ball_speed_2;
    float ball_speed_3;
    float ball_speed_4;
    
    int ball_rpm;
    int ball_rpm_minus_1;
    int ball_rpm_minus_2;
    int ball_rpm_minus_3;
    int ball_rpm_minus_4;
    int ball_rpm_minus_5;
    int ball_rpm_minus_6;
    int ball_rpm_minus_7;
    int ball_rpm_minus_8;
    int max_ball_rpm;
    
    float ball_shape_score;   // average
    float ball_shape_score_minus_1;
    float ball_shape_score_minus_2;
    float ball_shape_score_minus_3;
    float ball_shape_score_minus_4;
    float ball_shape_score_minus_5;
    
    float blastman_score;    // average
    float blastman_score_minus_1;
    float blastman_score_minus_2;
    float blastman_score_minus_3;
    float blastman_score_minus_4;
    float blastman_score_minus_5;
    
    float obj_rot_angle;
    float obj_rot_angle1;   // primary marker line
    float obj_rot_angle2;   // secondary marker line
    float delta_rotation_angle;  // change in rotation angle of primary marker line
    float marker_line_offset_angle;   // difference between primary marker line angle and secondary marker line angle
    
    float * ball_speed_arr;   // series of ball speeds used for displaying speed graph
    int ball_speed_arr_length;
    int ball_speed_arr_start_idx;
    
    float * head_speed_arr;   // series of club head speeds used for displaying speed graph
    int head_speed_arr_length;
    int head_speed_arr_start_idx;
    
    float * ball_rpm_arr;     // series of ball rpms used for displaying rpm graph
    int ball_rpm_arr_length;
    int ball_rpm_arr_start_idx;
    // int ball_speed_arr_impact_frame_no;
    
    int * top_n_ball_positions;
    int max_num_ball_positions;
    
    int graph_display_state;
    int mask_display_state;
    
    float ball_orientation;      // in degrees
    float ninety_degree_point;   // in inches
    
    float force_for_ball_momentum;
    float ball_travel_distance;
    
    float meters_per_pixel;
    int obj_rot_ref_frame;
    int impact_frame_no;
    int skid_end_frame_no;
    int roll_end_frame_no;
    float impact_ball_position_x;    // in meters
    float impact_ball_position_y;    // in meters
    float impact_obj_pos_x;          // in pixels  -- corresponds to shift_y
    float impact_obj_pos_y;          // in pixels  -- corresponds to shift_y
    float ninety_deg_obj_pos_x;      // in pixels  -- corresponds to shift_y
    float ninety_deg_obj_pos_y;      // in pixels  -- corresponds to shift_y
    // int synch_offset;   // in video frames (synchronizes the sensor graph slider with the video)
    int movie_flow;
    int movie_is_running;
    
    int video_fps;
    int video_fps_override;
    int image_orientation;
    int video_cnt;
    int down_sampling_factor;
    int new_fps_reduction_factor;    // to be used from next frame on
    int prev_fps_reduction_factor;
    int fps_reduction_factor;
    int demo_id;
    
    NSURL * video_url;
    
    int object_action_path_state;     // 0 = start; 50 = impact; 60 = horizontal movement; 90 = point of no return; 100 = completed
    int clubhead_action_path_state;   // 0 = start; 50 = impact; 60 = horizontal movement; 90 = point of no return; 100 = completed
    int clubhead_tracking_confidence;
    int club_shaft_tracking_confidence;
    
    int pix_arr_ptr;     // points to the oldest pix_arr (0 = prev1_pix_arr; 1 = prev2_pix_arr)
    UIImageView *image_field1;
    CALayer *_customLayer;
    
    // UIImage * video_display_image;
    
    // IBOutlet UIPickerView *pickerView;    // sport selection scene
    // NSArray *pickerViewArray;             // sport selection scene
    
    AVSpeechSynthesizer* mySynthesizer;
    
    IBOutlet UIButton* select_video_button;    // linked to button "Video File" by dragging the dot to the left of the line to button in InterfaceBuilder

}


@property (strong, nonatomic) IBOutlet VDMDrawView *draw_field2;
@property (strong, nonatomic) IBOutlet VDMDrawView2 *draw_field_graph;

@property (strong, nonatomic) IBOutlet UIView *draw_field1;   // not used

@property (strong, nonatomic) IBOutlet UIImageView *image_field1;    // video
@property (strong, nonatomic) IBOutlet UIImageView *sensor_data_graph;

@property (strong, nonatomic) IBOutlet UITextField *text_field1;

@property (strong, nonatomic) IBOutlet UILabel *output_label;

@property (strong, nonatomic) IBOutlet UILabel *ball_speed;
@property (strong, nonatomic) IBOutlet UILabel *max_ball_speed_label;
@property (strong, nonatomic) IBOutlet UILabel *impact_frame_no_label;
@property (strong, nonatomic) IBOutlet UILabel *rpm_label;
@property (strong, nonatomic) IBOutlet UILabel *max_rpm_label;
@property (strong, nonatomic) IBOutlet UILabel *impact_ratio;
@property (strong, nonatomic) IBOutlet UILabel *head_speed_label;

@property (strong, nonatomic) IBOutlet UITextField *text_field2;

@property (nonatomic, retain) CvVideoCamera* videoCamera;

@property (nonatomic, retain) AVAssetReader* movieReader;

// The CALayer we use to display the CGImageRef generated from the imageBuffer
@property (nonatomic, retain) CALayer *customLayer;

@property (strong, nonatomic) VDMSettingsViewController *settings_view_controller;   // to create inheritance (to access sport_picker_index)!?

// @property (nonatomic, retain) NSArray *pickerViewArray;      // sport selection scene
// -(IBAction)selectedRow;                                      // sport selection scene


- (IBAction)start_button1:(id)sender;

- (IBAction)button1:(id)sender;

- (IBAction)button2:(id)sender;

- (IBAction)frame_step:(id)sender;
- (IBAction)frame_continue:(id)sender;

- (IBAction)demo_t1:(id)sender;
- (IBAction)demo_t2:(id)sender;
- (IBAction)demo_h1:(id)sender;
- (IBAction)demo_h2:(id)sender;
- (IBAction)demo_b1:(id)sender;
- (IBAction)demo_p1:(id)sender;
- (IBAction)demo_g1:(id)sender;
- (IBAction)demo_g2:(id)sender;
- (IBAction)select_video:(id)sender;

- (IBAction)exit_button:(id)sender;

// - (void)process_video:(int)mode;





- (void) default_video;
- (void) run_demo_t1;
- (void) run_demo_t2;
- (void) run_demo_h1;
- (void) run_demo_h2;
- (void) run_demo_b1;
- (void) run_demo_p1;
- (void) process_video_test;
- (void) blast_video_synch;
- (void) process_movie :(int)phase;
- (void) talk;
- (void) say_phrase :(NSString*)phrase;
- (void) system_sound :(int)index;
- (void) readMovie:(NSURL *)url;
- (void) readNextMovieFrame:(int)frame_no :(unsigned char*)prev0_pix_arr :(unsigned char*)prev1_pix_arr :(unsigned char*)prev2_pix_arr :(signed char*)img_sect_align :(signed char*)img_sect_align_curr_pprev;
- (void) search_for_feature:(size_t)width :(size_t)height :(size_t)bytesPerRow :(unsigned char*)pixel;
- (void) search_for_yellow_square:(size_t)width :(size_t)height :(size_t)bytesPerRow :(unsigned char*)pixel;
- (void) set_overlay_box :(int)shift_x :(int)shift_y;
- (bool) is_yellow:(int)red :(int)green :(int)blue;
- (bool) is_light_color:(int)red :(int)green :(int)blue;
- (void) copy_to_prev_pix_arr:(unsigned char*)pix_arr :(unsigned char*)prev_pix_arr;
- (void) align_images:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)pix_arr :(unsigned char*)prev_pix_arr  :(int *)align_shift  :(signed char*)img_sect_align;
- (void) align_img_section: (int)frame_no :(size_t)bytesPerRow :(int)center_align_x :(int)center_align_y :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr  :(signed char*)img_sect_align  :(int)row :(int)col :(int)row_height :(int)col_width;
- (int) image_diff:(size_t)bytesPerRow :(int)shift_x :(int)shift_y :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr;

- (void) find_moving_objects__tennis:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev;
- (void) find_moving_objects__ice_hockey:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char*) img_sect_align;
- (void) find_moving_objects__baseball:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char*) img_sect_align;
- (void) find_moving_objects__trampoline:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char*) img_sect_align;

- (void) find_moving_objects__putt:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char*) img_sect_align;
- (void) find_moving_objects__putt__motion_based:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char*) img_sect_align;
- (void) find_moving_shafts__putt__motion_based:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char *)img_sect_align :(signed char *)img_sect_align_curr_pprev;
- (void) find_moving_objects__putt__shape_based:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char*) img_sect_align;
- (void) fill_in_circle_points :(int)num_circle_points :(float)circle_radius :(float *)circle_points_lower_bound_x :(float *)circle_points_lower_bound_y;
- (void) fill_in_blastman_points :(int)num_blastman_points :(float)blastman_radius  :(float *)blastman_points_x  :(float *)blastman_points_y;
- (int) get_average_circle_intensity :(int)pixel_x :(int)pixel_y :(unsigned char*)pix_arr :(int)num_circle_points :(float *)circle_points_lower_bound_x :(float *)circle_points_lower_bound_y;
- (int) get_average_circle_contrast :(int)pixel_x :(int)pixel_y :(unsigned char*)pix_arr :(int)num_circle_points :(float *)small_circle_points_x :(float *)small_circle_points_y :(float *)large_circle_points_x :(float *)large_circle_points_y;
- (void) find_center_of_ball :(int)frame_no :(int)start_pixel_x :(int)start_pixel_y :(float)start_circle_radius :(unsigned char*)pix_arr :(int)num_circle_points :(float *)circle_points_lower_bound_x :(float *)circle_points_lower_bound_y :(float *)circle_points_upper_bounds_x :(float *)circle_points_upper_bound_y  :(int *)center_pixel_x  :(int *)center_pixel_y  :(int *) radius1;
- (void) find_moving_objects__full_swing:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char*) img_sect_align;
- (void) find_moving_objects__jumps:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int *)align_shift :(int *)align_shift_curr_pprev :(signed char*) img_sect_align;

- (float) get_average_ball_speed :(float)ball_speed;
- (float) get_average_clubhead_speed :(float)clubhead_speed;
- (void) update_trail_of_clubhead_speeds :(float)clubhead_speed_mph_ave;
- (int) get_average_ball_rpm :(int)ball_rpm;
- (float) get_blastman_score :(float)score;
- (float) get_pixel_intensity :(unsigned char*)pix_arr :(float)point_x :(float)point_y;
- (float) get_weighted_pixel_intensity :(unsigned char*)pix_arr :(float)point_x :(float) point_y;
- (int) get_diff_in_box1:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int)align_shift_x :(int)align_shift_y :(int)box_width :(int)box_height :(int)box_step_size :(int)box_diff_threshold :(int)x :(int)y;
- (int) get_diff_in_box2:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int)align_shift_x :(int)align_shift_y :(signed char *)img_sect_align :(int)box_width :(int)box_height :(int)box_step_size :(int)box_diff_threshold :(int)x :(int)y;
- (int) verify_diff_in_box:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int)align_shift_x :(int)align_shift_y :(int)box_width :(int)box_height :(int)box_step_size :(int)box_diff_threshold :(int)x :(int)y;
- (int) compute_object_frame_diff:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int)align_shift_x :(int)align_shift_y :(signed char *)img_sect_align :(int)box_width :(int)box_height :(int)box_step_size :(int)box_diff_threshold :(int)x :(int)y;
- (int) find_center_of_moving_obj:(int)frame_no :(size_t)bytesPerRow :(unsigned char*)prev_pix_arr :(unsigned char*)pix_arr :(int)align_shift_x :(int)align_shift_y :(signed char *)img_sect_align
                                 :(int)align_shift_x_curr_pprev :(int)align_shift_y_curr_pprev :(signed char *)img_sect_align_curr_pprev :(int)box_width :(int)box_height :(int)box_step_size :(int)box_diff_threshold :(int)x :(int)y;

- (float) find_orientation_of_obj :(unsigned char*)pix_arr :(int)frame_no :(int)obj_center;
- (float) find_orientation_of_obj_with_blastman :(unsigned char*)pix_arr :(int)frame_no :(int)obj_center :(int)num_blastman1_points :(float *)blastman1_points_x :(float *)blastman1_points_y;
- (float) angle_diff_mod_180 :(float)ref_angle :(float)angle1  :(float *)angle_max_adjusted;
- (float) evaluate_line :(int)line_length :(unsigned char*)pix_arr :(float)object_center_x :(float)object_center_y :(float)pix_x :(float)pix_y :(float)angle;
- (float) evaluate_blastman :(int)blastman_radius :(int)num_blastman1_points :(float *)blastman1_points_x :(float *)blastman1_points_y :(unsigned char*)pix_arr :(float)object_center_x :(float)object_center_y :(float)point_x :(float)point_y :(float)orientation_angle;
- (float) evaluate_blastman_point :(float)point_x :(float)point_y :(float)flank_distance :(unsigned char*)pix_arr;
- (float) update_score :(unsigned char*)pix_arr :(float)core_intensity :(float)out_point_x :(float)out_point_y :(float)min_intensity_diff :(float)score_curr;
- (void) update_ball_speed_arr :(int)frame_no :(float)ball_speed_in_mph;
- (void) update_head_speed_arr :(int)frame_no :(float)ball_speed_in_mph;
- (float) get_last_ball_speed;

- (void) save_clubhead_subimg :(unsigned char*)pix_arr :(int)obj_center_x :(int)obj_center_y;
- (int) compare_clubhead_subimg :(unsigned char*)pix_arr :(int)obj_center_x :(int)obj_center_y;
- (void) set_clubhead_background_mask :(unsigned char*)prev_pix_arr :(int)obj_center_x :(int)obj_center_y;
- (void) set_club_shaft_background_mask :(unsigned char*)prev_pix_arr :(int)obj_center_x :(int)obj_center_y;

- (void) rotate_point_around_origin :(float *) pt_x :(float *) pt_y :(float) rotation_angle;
- (void) rotate_image_180 :(size_t) bytesPerRow :(unsigned char*)pix_arr;

- (float) to_deg :(float)rad;

// Testing:
-(void) print;
-(void) setNumerator: (int) n;
-(void) setDenominator: (int) d;
-(int) numerator;
-(int) denominator;
// -(int) test_count;

// Regression test:
+ (void) set_regression_test :(bool)bool1;
+ (bool) get_regression_test;
- (void) regression_test;


typedef struct
{
    int impact_frame;
    float max_ball_speed;
    
} RegressionTestResult;

- (void) blast_video_synch__regression_test;
// - (void) write_metrics_to_file :(NSString *)file_ns :(RegressionTestResult *)results;
- (void) write_metrics_to_file :(int)case_no :(NSString *)file_ns :(RegressionTestResult)results1 :(NSMutableDictionary *)metrics_dict1;

@end



/*
@interface PARegressionTest : NSObject {
    NSInteger* num_files;
}

@property (nonatomic, assign) int num_files_int;
@property (nonatomic, assign) int num_metric_matches;
@property (nonatomic, assign) int num_metric_differences;
@property (nonatomic, assign) int num_files_without_diff;
@property (nonatomic, assign) int num_files_with_diff;
@property (nonatomic, assign) int num_missing_expected_metrics_files;

@property (nonatomic, assign) int num_jumps;               // count "Jump"s
@property (nonatomic, assign) int num_up_jumps;            // count "Up-Jump"s
@property (nonatomic, assign) int num_down_jumps;          // count "Down-Jump"s
@property (nonatomic, assign) int num_freefalls;           // count "Free Fall"s
@property (nonatomic, assign) int num_sprints;             // count "Sprint"s
@property (nonatomic, assign) int num_interesting_actions; // count "Interesting Actions"s

@property NSMutableArray* messages;

@end


@implementation PARegressionTest

@synthesize num_files_int, num_metric_matches, num_metric_differences, num_files_without_diff, num_files_with_diff, messages;

- (void) dealloc {
    // [num_files release];
    // [num_successes release];
    // [num_failure release];
    // [messages release];
    // [super release];
}

@end
*/

