//
//  VDMDrawView.h
//  VidM01
//
//  Created by Juergen Haas on 4/11/14.
//  Copyright (c) 2014 Blast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDMDrawView : UIView
{
    bool text_display_on;

    float rotation_angle;
    int offset_x;           // red box
    int offset_y;
    
    int box_width_half;     // red box
    int box_height_half;
    
    int impact_offset_x;    // ghost of ball at impact
    int impact_offset_y;
    
    int ninety_deg_offset_x;   // ghost of ball at ninety deg
    int ninety_deg_offset_y;
    
    int box2_offset_y;      // blue box marking clubhead
    int box2_offset_x;
    
    int box3_offset_y;      // green box marking club shaft
    int box3_offset_x;
    
    int box2_width_half;    // blue box for clubhead
    int box2_height_half;
    
    int box3_width_half;    // green box for club shaft
    int box3_height_half;
    
    int box2_width_half_orig;    // blue box for clubhead (unscaled)
    int box2_height_half_orig;
    
    int box3_width_half_orig;    // green box for clubhead (unscaled)
    int box3_height_half_orig;
    
    double shaft_line_slope;     // Note: linear regression coordinate system is rotated 90 deg to the right
    double shaft_line_offset;    // y-offset (in linear regression coorindate system)
    
    int marker_line1_x1;
    int marker_line1_y1;
    int marker_line1_x2;
    int marker_line1_y2;
    
    int marker_line2_x1;
    int marker_line2_y1;
    int marker_line2_x2;
    int marker_line2_y2;
    
    float marker_circle_radius1;
    int marker_circle_offset_x;
    int marker_circle_offset_y;
    
    int num_blastman_points;
    float * blast_man_points_x;
    float * blast_man_points_y;
    
    float ball_orientation;
    float ninety_degree_point;
    int display_fps;
    
    float force_for_ball_momentum;
    float ball_travel_distance;
    
    bool clubhead_subimg_mask_on;
    int * clubhead_subimg_mask;
    int clubhead_subimg_arr_length;
    
    bool club_shaft_subimg_mask_on;
    int * club_shaft_subimg_mask;
    int club_shaft_subimg_arr_length;
    
    float * video_scale_factor_x;
    float * video_scale_factor_y;
}

-(void) set_offset_x: (int) n;
-(int) get_offset_x;

-(void) set_offset_y: (int) n;
-(int) get_offset_y;

-(void) set_impact_ghost :(int)x :(int)y;

-(void) set_ninety_deg_ghost :(int)x :(int)y;

-(void) set_box2_offset_x: (int) n;
-(void) set_box2_offset_y: (int) n;

-(void) set_box3_offset_x: (int) n;
-(void) set_box3_offset_y: (int) n;

-(void) set_box_width: (int) n;
-(int) get_box_width;

-(void) set_box_height: (int) n;
-(int) get_box_height;

-(void) set_box2_width: (int) n;
-(void) set_box2_height: (int) n;

-(void) set_box3_width: (int) n;
-(void) set_box3_height: (int) n;

-(void) set_rotation_angle: (float) n;
-(float) get_rotation_angle;

-(void) set_marker_line1 :(int)x1 :(int)y1 :(int)x2 :(int)y2;
-(void) set_marker_line2 :(int)x1 :(int)y1 :(int)x2 :(int)y2;

-(void) set_marker_circle_radius1 :(float)radius;
-(void) set_marker_circle_offset_x: (int) x;
-(void) set_marker_circle_offset_y: (int) y;

-(void) init_blastman :(int)num_points;
-(void) free_blastman;

-(void) set_blastman_points :(int)num_blastman_points :(float *)blastman_points_x :(float *)blastman_points_y :(float)video_scale_factor_x :(float)video_scale_factor_y;

-(void) set_force_and_distance_etc :(float)force :(float) distance :(float)orientation :(float) ninety_deg_point :(int)display_fps1;

-(void) turn_text_display_on;
-(void) turn_text_display_off;

-(void) set_clubhead_subimg_mask :(int *)mask :(int)length :(int)box_width_orig :(int)box_height_org :(float *)scale_factor_x :(float *)scale_factor_y;
-(void) set_club_shaft_subimg_mask :(int *)mask :(int)length :(int)box_width_orig :(int)box_height_org :(float *)scale_factor_x :(float *)scale_factor_y;

-(void) turn_clubhead_subimg_mask_on;
-(void) turn_clubhead_subimg_mask_off;

- (void) set_shaft_line :(double)slope :(double)offset;

@end
