//
//  VDMDrawView2.h
//  VidM01
//
//  Created by Juergen Haas on 5/17/14.
//  Copyright (c) 2014 Blast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDMDrawView2 : UIView
{
    int offset_x;
    int offset_y;
    
    float slider_accel;
    float slider_accel_scaling;    // to adapt to with of graph
    
    int box_width_half;
    int box_height_half;
    
    int x_slide_offset;
    int synch_offset;
    
    
    bool graph_display_on;
    
    bool ball_speed_graph_on;
    float * ball_speed_graph;
    int ball_speed_graph_length;
    int ball_speed_graph_start_idx;
    bool ball_speed_graph_is_filled;
    bool ball_speed_graph_is_updated;
    int ball_speed_arr_impact_frame_no;
    
    bool head_speed_graph_on;
    float * head_speed_graph;
    int head_speed_graph_length;
    int head_speed_graph_start_idx;
    bool head_speed_graph_is_filled;
    bool head_speed_graph_is_updated;
    int head_speed_arr_impact_frame_no;

    bool ball_rpm_graph_on;
    float * ball_rpm_graph;
    int ball_rpm_graph_length;
    int ball_rpm_graph_start_idx;
    
    int frame;
    int impact_frame;
    int skid_end_frame;
    int roll_end_frame;
    
    int impact_marker_line_draw_pos_x;
}

-(void) set_offset_x: (int) n;
-(int) get_offset_x;

-(void) set_offset_y: (int) n;
-(int) get_offset_y;

-(void) set_box_width: (int) n;
-(int) get_box_width;

-(void) set_box_height: (int) n;
-(int) get_box_height;

-(void) set_x_slide_offset: (int) n;
-(int) get_x_slide_offset;

-(void) set_synch_offset: (int) n;
-(int) get_synch_offset;

-(void) set_slider_accel: (float) n;
-(float) get_slider_accel;

-(void) set_slider_accel_scaling: (float) n;
-(float) get_slider_accel_scaling;

-(void) set_ball_speed_graph :(float *)n :(int)length :(int)start;
-(void) set_head_speed_graph :(float *)n :(int)length :(int)start;
-(void) set_ball_speed_graph_start_idx :(int)frame_no :(int)start;
-(void) set_head_speed_graph_start_idx :(int)frame_no :(int)start;
-(void) set_ball_speed_arr_impact_frame_no :(int)frame_no;
-(void) set_head_speed_arr_impact_frame_no :(int)frame_no;
-(void) set_ball_speed_graph_is_filled :(bool)b;
-(void) set_head_speed_graph_is_filled :(bool)b;

-(void) turn_head_speed_graph_on;
-(void) turn_head_speed_graph_off;

-(void) turn_ball_speed_graph_on;
-(void) turn_ball_speed_graph_off;

-(void) set_ball_rpm_graph :(float *)n :(int)length :(int)start;

-(void) set_vertial_marker_lines :(int)impact :(int)skid :(int)roll;
-(void) set_impact_marker_line_draw_pos_x :(int)x;
  
-(void) turn_ball_rpm_graph_on;
-(void) turn_ball_rpm_graph_off;

-(void) turn_graph_display_on;
-(void) turn_graph_display_off;

@end
