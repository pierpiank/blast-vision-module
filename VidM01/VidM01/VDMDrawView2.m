//
//  VDMDrawView2.m
//  VidM01
//
//  Created by Juergen Haas on 5/17/14.
//  Copyright (c) 2014 Blast. All rights reserved.
//

//  This class is used to draw over the Blast sensor data graph.

#import "VDMDrawView2.h"

@implementation VDMDrawView2

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        offset_x = 0;
        offset_y = 0;
        box_width_half = 30;
        box_height_half = 30;
        synch_offset = 0;
        slider_accel = 6.0f;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    
    printf("      From VDMDrawView2 -- drawRect - offset_x: %d   offset_y: %d \n",  offset_x, offset_y);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    self.backgroundColor = [UIColor clearColor];
    
    //-------testing
    /*
    // CGContextSetLineWidth(context, 2.0);
    // CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGRect rectangle = CGRectMake(160,10,200,80);
    CGContextAddRect(context, rectangle);
    // CGContextStrokePath(context);
    
    CGColorSpaceRef colorspace2 = CGColorSpaceCreateDeviceRGB();
    
    // CGFloat components[] = {0.0, 0.0, 1.0, 1.0};     // color blue
    CGFloat components2[] = {0.0, 0.0, 1.0, 0.2};     // color blue
    
    CGColorRef color2 = CGColorCreate(colorspace2, components2);

    CGContextSetFillColorWithColor(context, color2);
    CGContextFillRect(context, rectangle);
    */
    //-------------------
    
    
    CGContextSetLineWidth(context, 1.0);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    // CGFloat components[] = {0.0, 0.0, 1.0, 1.0};     // color blue
    CGFloat components_blue[]        = {0.0, 0.0, 1.0, 1.0};     // color blue
    CGFloat components_blue2[]       = {0.0, 0.2, 0.8, 1.0};     // color blue
    CGFloat components_dark_red[]    = {0.8, 0.0, 0.0, 1.0};     // color dark red
    CGFloat components_light_green[] = {0.0, 0.9, 0.0, 1.0};     // color light green
    CGFloat components_dark_purple[] = {0.9, 0.4, 0.9, 1.0};     // color dark purple
    CGFloat components_black[]       = {0.0, 0.0, 0.0, 1.0};     // color black
    CGFloat components_gray[]        = {0.8, 0.9, 0.7, 1.0};     // color gray (light green)
    
    CGColorRef color_blue        = CGColorCreate(colorspace, components_blue);
    CGColorRef color_blue2       = CGColorCreate(colorspace, components_blue2);
    CGColorRef color_dark_red    = CGColorCreate(colorspace, components_dark_red);
    CGColorRef color_light_green = CGColorCreate(colorspace, components_light_green);
    CGColorRef color_dark_purple = CGColorCreate(colorspace, components_dark_purple);
    CGColorRef color_black       = CGColorCreate(colorspace, components_black);
    CGColorRef color_gray        = CGColorCreate(colorspace, components_gray);
    
    CGContextSetStrokeColorWithColor(context, color_blue);
    
    /*
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 300, 400);
    CGContextAddLineToPoint(context, 30, 20);
    CGContextAddLineToPoint(context, 600, 0);
    */
    
    // CGContextMoveToPoint(context,    100, offset_y + 100);
    // CGContextAddLineToPoint(context, 150, offset_y + 150);
    // CGContextAddLineToPoint(context, 100, offset_y + 200);
    // CGContextAddLineToPoint(context,  50, offset_y + 150);
    // CGContextAddLineToPoint(context, 100, offset_y + 100);
    
    /*
    CGContextMoveToPoint(context,     offset_x - box_width_half, offset_y - box_height_half);
    CGContextAddLineToPoint(context,  offset_x - box_width_half, offset_y + box_height_half);
    CGContextAddLineToPoint(context,  offset_x + box_width_half, offset_y + box_height_half);
    CGContextAddLineToPoint(context,  offset_x + box_width_half, offset_y - box_height_half);
    CGContextAddLineToPoint(context,  offset_x - box_width_half, offset_y - box_height_half);
    */
    
    if (offset_x != 0)
    {
        // int x_slide = 335 + ((synch_offset + offset_x) * 6);     // offset_x and synch_offset are in video frames
        // int slider_speed_scaling = // ratio of drawRect_width and drawRect_width_default (used on iPad mini)
        // int synch_offset_scaled = synch_offset * slider_speed_scaling;
        
        
        // int slider_accel_scaled = slider_accel * slider_speed_scaling;
        int x_slide = (int) (((float)x_slide_offset) + (((float)(synch_offset + offset_x)) * slider_accel));     // offset_x and synch_offset are in video frames
        int x_slide_scaled = (int) (((float) x_slide) * slider_accel_scaling);
        CGContextMoveToPoint(   context, x_slide_scaled, 0);
        CGContextAddLineToPoint(context, x_slide_scaled, 200);
        CGContextStrokePath(context);
    }
    // printf("         VDMDrawView2 - offset_x: %d \n", offset_x);
    
    
    
    if (graph_display_on) // (graph_display_on)
    {
        // Determine the drawing locations of the "Impact", "Skid", "Roll" marks:
        int graph_field_width  = self.frame.size.width;
        int graph_field_height = self.frame.size.height;
        float draw_point_x = 1.0f; // 20.0f;
        float draw_point_x_step_size = ((float)graph_field_width) / ((float)ball_speed_graph_length); // 4;
 //       draw_point_x_step_size *= 2; // TODO: TEMPORARY
        // float impact_marker_line_draw_pos_x   = 0.0f;
        // float impact_marker_line_draw_pos_x   = graph_field_width - 20;
        float skid_end_marker_line_draw_pos_x = 0.0f;
        float roll_end_marker_line_draw_pos_x = 298.0f;
        int valid_graph_entry_cnt = 0;
        /*
        for (int frame_no = 0; frame_no < ball_speed_graph_length; frame_no++)
        {
            if (impact_frame > 0)
            {
                draw_point_x += draw_point_x_step_size;
                // if (frame_no == ball_speed_arr_impact_frame_no)  { impact_marker_line_draw_pos_x = draw_point_x; }
                if (frame_no == ball_speed_arr_impact_frame_no)  { impact_marker_line_draw_pos_x = graph_field_width - 23; }
                
                int frame_no_offset = ball_speed_arr_impact_frame_no - impact_frame;   // difference between frame_no's in graph in frame_no's in video
                
                int ball_speed_arr_skid_end_frame_no = (skid_end_frame - 2) + frame_no_offset;
                if (frame_no == ball_speed_arr_skid_end_frame_no)  { skid_end_marker_line_draw_pos_x = draw_point_x; }
                
                int idx = ball_speed_graph_start_idx + frame_no;
                if (idx >= ball_speed_graph_length) { idx -= ball_speed_graph_length; }   // wrap around
                float graph_value = ball_speed_graph[idx];
                if (graph_value != (-999999.0)) { valid_graph_entry_cnt++; }
            }
        }
        */
        
        if (ball_speed_arr_impact_frame_no > 0)
        {
            int num_frames_since_impact = frame - impact_frame;
            impact_marker_line_draw_pos_x = (graph_field_width - 28) - (num_frames_since_impact * draw_point_x_step_size);
            
            if (skid_end_frame > 0)
            {
                int num_frames_since_skid_end = frame - skid_end_frame;
                skid_end_marker_line_draw_pos_x = (graph_field_width - 28) - (num_frames_since_skid_end * draw_point_x_step_size);
            }
            
            /*x
            if (impact_marker_line_draw_pos_x == 0)
            {
                impact_marker_line_draw_pos_x = graph_field_width - 28;
            }
            else
            {
                if (ball_speed_graph_is_updated)
                {
                    // impact_marker_line_draw_pos_x -= draw_point_x_step_size;
                    impact_marker_line_draw_pos_x = (graph_field_width - 28) - (num_frames_since_impact * draw_point_x_step_size);
                }
            }
            x*/
        }
        ball_speed_graph_is_updated = false;
        
        // if (valid_graph_entry_cnt < 35) { roll_end_marker_line_draw_pos_x = 0.0f; }   // show roll end marker only if ball_speed_graph[] is occupied beyond threshold
        if (skid_end_marker_line_draw_pos_x == 0.0f) { roll_end_marker_line_draw_pos_x = 0.0f; }   // show roll end marker only if skid_end_marker_line is shown
        
        printf("      ---ml--- impact_frame: %d   ball_speed_arr_impact_frame_no: %d   impact_marker_line_draw_pos_x: %d  skid_end_frame: %d   skid_end_marker_line_draw_pos_x: %5.2f \n",  impact_frame, ball_speed_arr_impact_frame_no, impact_marker_line_draw_pos_x, skid_end_frame, skid_end_marker_line_draw_pos_x);
        
        
        // Draw "Impact", "Skid", "Roll" marks (vertical lines):
        CGContextSetStrokeColorWithColor(context, color_black);
        int vertical_line_x = (int)impact_marker_line_draw_pos_x; // 40;
        CGContextMoveToPoint(   context, vertical_line_x, 20);    // Impact vertial line marker - drawing location should be determined by the impact frame
        CGContextAddLineToPoint(context, vertical_line_x, 80);
        vertical_line_x = (int)skid_end_marker_line_draw_pos_x; // 140;
        CGContextMoveToPoint(   context, vertical_line_x, 20);    // Skid vertial line marker - drawing location should be computed
        CGContextAddLineToPoint(context, vertical_line_x, 80);
        vertical_line_x = (int)roll_end_marker_line_draw_pos_x; // 298;
        CGContextMoveToPoint(   context, vertical_line_x, 20);    // Roll line marker - drawing location should be computed?
        CGContextAddLineToPoint(context, vertical_line_x, 80);
        CGContextStrokePath(context);
        // Draw base line:
        CGContextMoveToPoint(   context, 0, 80);
        CGContextAddLineToPoint(context, 300, 80);
        CGContextStrokePath(context);
        
        
        
        // Draw clubhead speed curve:
        int last_head_speed_draw_point_x = 0;
        int last_head_speed_draw_point_y = 0;     // used to draw the label
        if (head_speed_graph_on)
        {
            CGContextSetStrokeColorWithColor(context, color_gray);
            draw_point_x = -25.0f; // 1.0f; // 20.0f;
            int draw_point_y_base = 75;     // this should be computed from graph_field_height
            int draw_point_y = draw_point_y_base;
            float graph_amplification = 2.0f;
            bool draw_start_point_is_set = false;
            for (int frame_no = 0; frame_no < head_speed_graph_length; frame_no++)
            {
                draw_point_x += draw_point_x_step_size;
                int idx = head_speed_graph_start_idx + frame_no; // + 1;
                if (idx >= head_speed_graph_length) { idx -= head_speed_graph_length;  head_speed_graph_is_filled = true; }   // wrap around
                float graph_value = head_speed_graph[idx];                 // <<<<<<<<<<<<
                if (graph_value != (-999999.0))
                {
                    draw_point_y = draw_point_y_base - ((int) (graph_value * graph_amplification));
                    if (! draw_start_point_is_set) { CGContextMoveToPoint( context, draw_point_x, draw_point_y);  draw_start_point_is_set = true; }
                    CGContextAddLineToPoint(context, (int)draw_point_x, draw_point_y);
                    last_head_speed_draw_point_x = (int)draw_point_x;
                }
                // printf("      ---2-- VDMDrawView2 -- frame_no: %d   head_speed_graph_start_idx: %d   draw_point_x: %5.1f   last_head_speed_draw_point_x: %d   graph_field_width: %d   ball_speed_graph_length: %d   graph_value: %5.2f \n",  frame_no, head_speed_graph_start_idx, draw_point_x, last_head_speed_draw_point_x, graph_field_width, ball_speed_graph_length, graph_value);
            }
            CGContextStrokePath(context);
            last_head_speed_draw_point_y = draw_point_y;
        }

        
        // Draw ball speed curve:
        int last_speed_draw_point_x = 0;
        int last_speed_draw_point_y = 0;     // used to draw the label
        if (ball_speed_graph_on)
        {
            CGContextSetStrokeColorWithColor(context, color_light_green);
            draw_point_x = -25.0f; // 1.0f; // 20.0f;
            int draw_point_y_base = 75;     // this should be computed from graph_field_height
            int draw_point_y = draw_point_y_base;
            float graph_amplification = 2.0f;
            //x  CGContextMoveToPoint( context, draw_point_x, draw_point_y);
            bool draw_start_point_is_set = false;
            for (int frame_no = 0; frame_no < ball_speed_graph_length; frame_no++)
            {
                draw_point_x += draw_point_x_step_size;
                int idx = ball_speed_graph_start_idx + frame_no; // + 1;
                if (idx >= ball_speed_graph_length) { idx -= ball_speed_graph_length;  ball_speed_graph_is_filled = true; }   // wrap around
                // int scrolled_idx = idx;
                // if (ball_speed_graph_is_filled)
                // {
                //     scrolled_idx = ball_speed_graph_start_idx;
                // }
                float graph_value = ball_speed_graph[idx];                 // <<<<<<<<<<<<
                if (graph_value != (-999999.0))
                {
                    draw_point_y = draw_point_y_base - ((int) (graph_value * graph_amplification));
                    if (! draw_start_point_is_set) { CGContextMoveToPoint( context, draw_point_x, draw_point_y);  draw_start_point_is_set = true; }
                    CGContextAddLineToPoint(context, (int)draw_point_x, draw_point_y);
                    last_speed_draw_point_x = (int)draw_point_x;
                }
                // printf("      ---1-- VDMDrawView2 -- frame_no: %d   ball_speed_graph_start_idx: %d   draw_point_x: %5.1f   last_speed_draw_point_x: %d   graph_field_width: %d   ball_speed_graph_length: %d   graph_value: %5.2f \n",  frame_no, ball_speed_graph_start_idx, draw_point_x, last_speed_draw_point_x, graph_field_width, ball_speed_graph_length, graph_value);
            }
            CGContextStrokePath(context);
            last_speed_draw_point_y = draw_point_y;
        }
        
        
        // Draw ball rpm curve:
        int last_rpm_draw_point_x = 0;
        int last_rpm_draw_point_y = 0;
        if (ball_rpm_graph_on)
        {
            CGContextSetStrokeColorWithColor(context, color_dark_purple);
            draw_point_x = -25.0f; // 1.0f;
            int draw_point_y_base = 75;     // this should be computed from graph_field_height
            int draw_point_y = draw_point_y_base;
            float graph_amplification = 0.05f; // 0.1f;   // TODO:
            // draw_point_x -= draw_point_x_step_size; // why is this needed??
            //x  CGContextMoveToPoint( context, draw_point_x, draw_point_y);
            bool draw_start_point_is_set = false;
            for (int frame_no = 0; frame_no < ball_rpm_graph_length; frame_no++)
            {
                draw_point_x += draw_point_x_step_size;
                int idx = ball_rpm_graph_start_idx + frame_no; // + 1;
                // int idx = frame_no;
                if (idx >= ball_rpm_graph_length) { idx -= ball_rpm_graph_length; }    // wrap around
                float graph_value = ball_rpm_graph[idx];
                if (graph_value != (-999999.0))
                {
                    draw_point_y = draw_point_y_base - ((int) (graph_value * graph_amplification));
                    if (! draw_start_point_is_set) { CGContextMoveToPoint( context, draw_point_x, draw_point_y);  draw_start_point_is_set = true; }
                    CGContextAddLineToPoint(context, (int)draw_point_x, draw_point_y);
                    last_rpm_draw_point_x = draw_point_x;
                }
                // printf("      ---3-- VDMDrawView2 -- frame_no: %d   ball_rpm_graph_start_idx: %d   draw_point_x: %5.1f   last_rpm_draw_point_x: %d   graph_field_width: %d   ball_speed_graph_length: %d   graph_value: %5.2f \n",  frame_no, ball_rpm_graph_start_idx, draw_point_x, last_rpm_draw_point_x, graph_field_width, ball_rpm_graph_length, graph_value);
            }
            CGContextStrokePath(context);
            last_rpm_draw_point_y = draw_point_y;
        }

        
        
        // Draw text:
        // Write the labels (Impact, Skid, Roll)
        
        CGRect viewBounds = self.bounds;
        CGContextTranslateCTM(context, 0, viewBounds.size.height);     // invert the graph field
        CGContextScaleCTM(context, 1, -1);
        int text_draw_point_y = viewBounds.size.height - 7;
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextSetLineWidth(context, 2.0);
        CGContextSelectFont(context, "Helvetica", 10.0, kCGEncodingMacRoman);
        CGContextSetCharacterSpacing(context, 1.1);
        CGContextSetTextDrawingMode(context, kCGTextFill);
        // CGContextShowTextAtPoint(context,  15, text_draw_point_y, "Impact", 6);
        // CGContextShowTextAtPoint(context, 120, text_draw_point_y, "Skid", 4);
        // CGContextShowTextAtPoint(context, 280, text_draw_point_y, "Roll", 4);
        
        if (impact_marker_line_draw_pos_x > 0.0f)
        {
            int impact_draw_pos_x = (int) fmax(15, (int)(impact_marker_line_draw_pos_x - 40.0f));     // make sure the text is not cut off on the left edge
            CGContextShowTextAtPoint(context, impact_draw_pos_x, text_draw_point_y, "Impact", 6);
        }
        
        if (skid_end_marker_line_draw_pos_x > 30.0f)
        {
//            CGContextShowTextAtPoint(context, (int)(skid_end_marker_line_draw_pos_x - 20.0f), text_draw_point_y, "Skid", 4);   // TODO:
            CGContextShowTextAtPoint(context, (int)(skid_end_marker_line_draw_pos_x - 40.0f + 30.0f), text_draw_point_y, "Skid", 4);
            CGContextShowTextAtPoint(context, 280, text_draw_point_y, "Roll", 4);
        }
        
        
        
        text_draw_point_y = viewBounds.size.height - last_speed_draw_point_y;
        CGContextSetRGBFillColor(context, 0.0, 0.8, 0.0, 1.0);
        CGContextShowTextAtPoint(context, last_speed_draw_point_x + 4, text_draw_point_y, "mph", 3);
        
        int rpm_text_draw_point_y = viewBounds.size.height - last_rpm_draw_point_y;
        if (    (last_rpm_draw_point_y < (last_speed_draw_point_y + 3)          // Adjust draw height of "rpm" if it overlaps with "mph"
            &&  (last_rpm_draw_point_y > (last_speed_draw_point_y - 3))))
        {
            rpm_text_draw_point_y += 10;
        }
        CGContextSetRGBFillColor(context, 0.8, 0.4, 0.8, 1.0);
        CGContextShowTextAtPoint(context, last_rpm_draw_point_x + 4, rpm_text_draw_point_y, "rpm", 3);
        
        int head_text_draw_point_y = viewBounds.size.height - last_head_speed_draw_point_y;
        if (    (last_head_speed_draw_point_y < (last_speed_draw_point_y + 3)          // Adjust draw height of "rpm" if it overlaps with "mph"
            &&  (last_head_speed_draw_point_y > (last_speed_draw_point_y - 3))))
        {
            head_text_draw_point_y += 10;
        }
        if (    (head_text_draw_point_y < (rpm_text_draw_point_y + 3)          // Adjust draw height of "rpm" if it overlaps with "mph"
            &&  (head_text_draw_point_y > (rpm_text_draw_point_y - 3))))
        {
            head_text_draw_point_y += 10;
        }
        CGContextSetRGBFillColor(context, 0.8, 0.9, 0.7, 1.0); 
        CGContextShowTextAtPoint(context, last_speed_draw_point_x + 4, head_text_draw_point_y, "hd", 2);
        

    }
    
    

    CGColorSpaceRelease(colorspace);
    CGColorRelease(color_blue);
    CGColorRelease(color_blue2);
    CGColorRelease(color_dark_red);
    CGColorRelease(color_dark_purple);
    CGColorRelease(color_light_green);
    CGColorRelease(color_black);
}


-(void) set_offset_x: (int) n {
    offset_x = n;
}

-(int) get_offset_x {
    return offset_x;
}


-(void) set_offset_y: (int) n {
    offset_y = n;
}

-(int) get_offset_y {
    return offset_y;
}


-(void) set_box_width: (int) n {
    box_width_half = n;
}

-(int) get_box_width {
    return box_width_half;
}


-(void) set_box_height: (int) n {
    box_height_half = n;
}

-(int) get_box_height {
    return box_height_half;
}


-(void) set_x_slide_offset: (int) n {
    x_slide_offset = n;
}

-(int) get_x_slide_offset {
    return x_slide_offset;
}


-(void) set_synch_offset: (int) n {
    synch_offset = n;
}

-(int) get_synch_offset {
    return synch_offset;
}


-(void) set_slider_accel: (float) n {
    slider_accel = n;
}

-(float) get_slider_accel {
    return slider_accel;
}

-(void) set_slider_accel_scaling: (float) n {
    slider_accel_scaling = n;
}

-(float) get_slider_accel_scaling {
    return slider_accel_scaling;
}

-(void) set_ball_speed_graph :(float *)n :(int)length :(int)start    // one time initialization
{
    ball_speed_graph = n;
    ball_speed_graph_length = length;
    ball_speed_graph_start_idx = start;
    ball_speed_graph_on = true;
    frame = 0;
}

-(void) set_head_speed_graph :(float *)n :(int)length :(int)start    // one time initialization
{
    head_speed_graph = n;
    head_speed_graph_length = length;
    head_speed_graph_start_idx = start;
    head_speed_graph_on = true;
    frame = 0;
}

-(void) set_ball_speed_graph_start_idx :(int)frame_no :(int)start
{
    ball_speed_graph_start_idx = start;
    head_speed_graph_start_idx = start;
    ball_rpm_graph_start_idx   = start;
    ball_speed_graph_is_updated = true;
    frame = frame_no;
}

-(void) set_head_speed_graph_start_idx :(int)frame_no :(int)start
{
    head_speed_graph_start_idx = start;
    head_speed_graph_is_updated = true;
    frame = frame_no;
}

-(void)set_ball_speed_arr_impact_frame_no :(int)frame_no
{
    // if (ball_speed_arr_impact_frame_no == 0)
    // {
    ball_speed_arr_impact_frame_no = frame_no;
    // }
}

-(void)set_head_speed_arr_impact_frame_no :(int)frame_no
{
    // if (ball_speed_arr_impact_frame_no == 0)
    // {
    head_speed_arr_impact_frame_no = frame_no;
    // }
}

-(void) set_ball_speed_graph_is_filled :(bool)b
{
    ball_speed_graph_is_filled = b;
}

-(void) set_head_speed_graph_is_filled :(bool)b
{
    head_speed_graph_is_filled = b;
}

-(void) turn_head_speed_graph_on
{
    head_speed_graph_on = true;
}

-(void) turn_head_speed_graph_off
{
    head_speed_graph_on = false;
}

-(void) turn_ball_speed_graph_on
{
    ball_speed_graph_on = true;
}

-(void) turn_ball_speed_graph_off
{
    ball_speed_graph_on = false;
}

-(void) set_ball_rpm_graph :(float *)n :(int)length :(int)start;    // one time initialization
{
    ball_rpm_graph = n;
    ball_rpm_graph_length = length;
    ball_rpm_graph_start_idx = start;
    ball_rpm_graph_on = true;
}

-(void) set_vertial_marker_lines :(int)impact :(int)skid :(int)roll
{
    impact_frame = impact;
    skid_end_frame = skid;
    roll_end_frame = roll;
}

-(void) set_impact_marker_line_draw_pos_x :(int)x
{
    impact_marker_line_draw_pos_x = x;
}

-(void) turn_ball_rpm_graph_on
{
    ball_rpm_graph_on = true;
}

-(void) turn_ball_rpm_graph_off
{
    ball_rpm_graph_on = false;
}


-(void) turn_graph_display_on
{
    graph_display_on = true;
}


-(void) turn_graph_display_off
{
    graph_display_on = false;
}


@end
