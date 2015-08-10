//
//  VDMDrawView.m
//  VidM01
//
//  Created by Juergen Haas on 4/11/14.
//  Copyright (c) 2014 Blast. All rights reserved.
//

//  This class is used to draw over the video.

#import "VDMDrawView.h"

@implementation VDMDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        rotation_angle = 0.7f; // 0.0f;  // in radians
        offset_x = 0;
        offset_y = 0;
        box_width_half = 30;
        box_height_half = 30;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    bool temp_draw_filter = true; // false;    // true = do not filter
    // clubhead_subimg_mask_on = false;
    
    // Drawing code
    
    printf("      From VDMDrawView -- drawRect - offset_x: %d   offset_y: %d \n",  offset_x, offset_y);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    self.backgroundColor = [UIColor clearColor];
    
    // CGContextSetLineWidth(context, 1.0);
    CGContextSetLineWidth(context, 0.5);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    // CGFloat components_blue[]     = {0.0, 0.0, 1.0, 1.0};     // color blue
    CGFloat components_red[]         = {1.0, 0.0, 0.0, 1.0};     // color red
    CGFloat components_orange[]      = {1.0, 0.5, 0.5, 1.0};     // color orange
    CGFloat components_magenta[]     = {1.0, 0.0, 1.0, 1.0};     // color magenta
    CGFloat components_purple1[]     = {0.6, 0.3, 1.0, 1.0};     // color purple1
    CGFloat components_yellow[]      = {1.0, 1.0, 0.0, 1.0};     // color yellow
    CGFloat components_blue[]        = {0.0, 0.0, 1.0, 1.0};     // color blue
    CGFloat components_light_blue[]  = {0.0, 0.8, 1.0, 1.0};     // color light blue
    CGFloat components_light_green[] = {0.0, 1.0, 0.0, 1.0};     // color light green
    CGFloat components_white[]       = {0.0, 0.0, 0.0, 1.0};     // color white
    
    CGColorRef color_red          = CGColorCreate(colorspace, components_red);
    CGColorRef color_orange       = CGColorCreate(colorspace, components_orange);
    CGColorRef color_magenta      = CGColorCreate(colorspace, components_magenta);
    CGColorRef color_purple1      = CGColorCreate(colorspace, components_purple1);
    CGColorRef color_yellow       = CGColorCreate(colorspace, components_yellow);
    CGColorRef color_blue         = CGColorCreate(colorspace, components_blue);
    CGColorRef color_light_blue   = CGColorCreate(colorspace, components_light_blue);
    CGColorRef color_light_green  = CGColorCreate(colorspace, components_light_green);
    CGColorRef color_white        = CGColorCreate(colorspace, components_white);
    
    // CGContextSetStrokeColorWithColor(context, color_red);
    CGContextSetStrokeColorWithColor(context, color_yellow);
    
    // CGContextMoveToPoint(context, 0, 0);
    // CGContextAddLineToPoint(context, 300, 400);
    // CGContextAddLineToPoint(context, 30, 20);
    // CGContextAddLineToPoint(context, 600, 0);
    
    // CGContextMoveToPoint(context,    100, offset_y + 100);
    // CGContextAddLineToPoint(context, 150, offset_y + 150);
    // CGContextAddLineToPoint(context, 100, offset_y + 200);
    // CGContextAddLineToPoint(context,  50, offset_y + 150);
    // CGContextAddLineToPoint(context, 100, offset_y + 100);
    
    float pt1_x = - box_width_half;
    float pt1_y = - box_height_half;
    
    float pt2_x =   box_width_half;
    float pt2_y = - box_height_half;
    
    float pt3_x =   box_width_half;
    float pt3_y =   box_height_half;
    
    float pt4_x = - box_width_half;
    float pt4_y =   box_height_half;
    
    // Now rotate these four points around 0,0 by "rotation_angle":
    // rotation_angle = 0.7f;   // temporary for testing
    [self rotate_point_around_origin :&pt1_x :&pt1_y :rotation_angle];
    [self rotate_point_around_origin :&pt2_x :&pt2_y :rotation_angle];
    [self rotate_point_around_origin :&pt3_x :&pt3_y :rotation_angle];
    [self rotate_point_around_origin :&pt4_x :&pt4_y :rotation_angle];

    // CGContextMoveToPoint(context,     offset_x - box_width_half, offset_y - box_height_half);
    // CGContextAddLineToPoint(context,  offset_x - box_width_half, offset_y + box_height_half);
    // CGContextAddLineToPoint(context,  offset_x + box_width_half, offset_y + box_height_half);
    // CGContextAddLineToPoint(context,  offset_x + box_width_half, offset_y - box_height_half);
    // CGContextAddLineToPoint(context,  offset_x - box_width_half, offset_y - box_height_half);
    
    CGContextMoveToPoint(context,     offset_x + pt1_x, offset_y + pt1_y);
    CGContextAddLineToPoint(context,  offset_x + pt2_x, offset_y + pt2_y);
    
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, color_red);

    CGContextMoveToPoint(context,     offset_x + pt2_x, offset_y + pt2_y);
    CGContextAddLineToPoint(context,  offset_x + pt3_x, offset_y + pt3_y);
    CGContextAddLineToPoint(context,  offset_x + pt4_x, offset_y + pt4_y);
    CGContextAddLineToPoint(context,  offset_x + pt1_x, offset_y + pt1_y);
    
    CGContextStrokePath(context);
    
    
    
    // Draw blue box:
    CGContextSetStrokeColorWithColor(context, color_light_blue);

    pt1_x = - box2_width_half;
    pt1_y = - box2_height_half;
    
    pt2_x =   box2_width_half;
    pt2_y = - box2_height_half;
    
    pt3_x =   box2_width_half;
    pt3_y =   box2_height_half;
    
    pt4_x = - box2_width_half;
    pt4_y =   box2_height_half;
    
    
    CGContextMoveToPoint(context,     box2_offset_x + pt1_x, box2_offset_y + pt1_y);
    CGContextAddLineToPoint(context,  box2_offset_x + pt2_x, box2_offset_y + pt2_y);
    
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context,     box2_offset_x + pt2_x, box2_offset_y + pt2_y);
    CGContextAddLineToPoint(context,  box2_offset_x + pt3_x, box2_offset_y + pt3_y);
    CGContextAddLineToPoint(context,  box2_offset_x + pt4_x, box2_offset_y + pt4_y);
    CGContextAddLineToPoint(context,  box2_offset_x + pt1_x, box2_offset_y + pt1_y);
    
    CGContextStrokePath(context);
    
    
    
    // Draw green box:
    if (clubhead_subimg_mask_on)
    {
        // box3_offset_x = 100;    // testing
        // box3_offset_y = 100;    // testing
        // box3_width_half = 10;   // testing
        // box3_height_half = 10;  // testing
        CGContextSetStrokeColorWithColor(context, color_light_green);
        
        pt1_x = - box3_width_half;
        pt1_y = - box3_height_half;
        
        pt2_x =   box3_width_half;
        pt2_y = - box3_height_half;
        
        pt3_x =   box3_width_half;
        pt3_y =   box3_height_half;
        
        pt4_x = - box3_width_half;
        pt4_y =   box3_height_half;
        
        
        CGContextMoveToPoint(context,     box3_offset_x + pt1_x, box3_offset_y + pt1_y);
        CGContextAddLineToPoint(context,  box3_offset_x + pt2_x, box3_offset_y + pt2_y);
        
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context,     box3_offset_x + pt2_x, box3_offset_y + pt2_y);
        CGContextAddLineToPoint(context,  box3_offset_x + pt3_x, box3_offset_y + pt3_y);
        CGContextAddLineToPoint(context,  box3_offset_x + pt4_x, box3_offset_y + pt4_y);
        CGContextAddLineToPoint(context,  box3_offset_x + pt1_x, box3_offset_y + pt1_y);
        
        CGContextStrokePath(context);
    }
    
    
    
    // Draw (inverse of) clubhead_subimg_mask:
    if (clubhead_subimg_mask_on)
    {
        CGContextSetStrokeColorWithColor(context, color_purple1);
        float pix_x = 0,  pix_y = 0;
        if (box2_height_half > 0)
        {
            int x_anchor = box2_offset_x - box2_width_half;    // upper left corner of rectangle on canvas
            int y_anchor = box2_offset_y - box2_height_half;   // upper left corner of rectangle on canvas
            // float draw_step_x = ((float)box2_width_half)  / ((float)box2_width_half_orig);
            // float draw_step_y = ((float)box2_height_half) / ((float)box2_height_half_orig);
            
            int clubhead_subimg_idx = 0;
            int mask_val = 0;
            
            // Travers the the un-scaled mask rectangle:
            int x_start = 0;
            int x_end   = 2 * box2_width_half_orig;
            int y_start = 0;
            int y_end   = 2 * box2_height_half_orig;
            for (int pixel_x_orig = x_start;  pixel_x_orig < x_end;  pixel_x_orig++)
            {
                for (int pixel_y_orig = y_start;  pixel_y_orig < y_end;  pixel_y_orig++)
                {
                    mask_val = clubhead_subimg_mask[clubhead_subimg_idx++];
                    if (mask_val == 1)
                    {
                        pix_x = ((float)x_anchor) + (((float)pixel_x_orig) * *video_scale_factor_x);
                        pix_y = ((float)y_anchor) + (((float)pixel_y_orig) * *video_scale_factor_y);
                        CGContextMoveToPoint(context,     pix_x, pix_y);
                        CGContextAddLineToPoint(context,  pix_x, pix_y + 0.5f);
                        
                        CGContextStrokePath(context);
                    }
                }
            }
        }
    }
    
    
    
    // Draw (inverse of) club_shaft_subimg_mask:
    if (clubhead_subimg_mask_on)
    {
        float horizontal_adjustment = 0; // 1;
        
        CGContextSetStrokeColorWithColor(context, color_purple1);
        float pix_x = 0,  pix_y = 0;
        if (box3_height_half > 0)
        {
            int x_anchor = box3_offset_x - box3_width_half;    // upper left corner of rectangle on canvas
            int y_anchor = box3_offset_y - box3_height_half;   // upper left corner of rectangle on canvas
            
            int clubhead_subimg_idx = 0;
            int mask_val = 0;
            
            // Travers the the un-scaled mask rectangle:
            int x_start = 0;
            int x_end   = 2 * box3_width_half_orig;
            int y_start = 0;
            int y_end   = 2 * box3_height_half_orig;
            for (int pixel_x_orig = x_start;  pixel_x_orig < x_end;  pixel_x_orig++)
            {
                for (int pixel_y_orig = y_start;  pixel_y_orig < y_end;  pixel_y_orig++)
                {
                    mask_val = club_shaft_subimg_mask[clubhead_subimg_idx++];
                    if (mask_val == 1)
                    {
                        pix_x = (float)x_anchor + ((float)pixel_x_orig * *video_scale_factor_x);
                        pix_y = (float)y_anchor + ((float)pixel_y_orig * *video_scale_factor_y);
                        pix_x += horizontal_adjustment;
                        CGContextMoveToPoint(context,     pix_x, pix_y);
                        CGContextAddLineToPoint(context,  pix_x, pix_y + 0.5f);
                        
                        CGContextStrokePath(context);
                    }
                }
            }
        }
    }
    
    
    
    if (temp_draw_filter)
    {
        // Draw linear regression line:
        CGContextSetStrokeColorWithColor(context, color_yellow);
        // TODO: shaft line
        int subimg_anchor_x = box3_offset_x - box3_width_half;    // upper left corner of rectangle on canvas
        int subimg_anchor_y = box3_offset_y - box3_height_half;   // upper left corner of rectangle on canvas
        float shaft_line_start_point_x = (float)subimg_anchor_x + ((float)shaft_line_offset * *video_scale_factor_x);
        float shaft_line_start_point_y = (float)subimg_anchor_y;
        float shaft_line_vector_x = (float)shaft_line_slope;
        float shaft_line_vector_y = 1.0f;
        float vector_length = 90.0f;
        float shaft_line_end_point_x = shaft_line_start_point_x + (vector_length * shaft_line_vector_x);
        float shaft_line_end_point_y = shaft_line_start_point_y + (vector_length * shaft_line_vector_y);
        CGContextMoveToPoint(    context,  shaft_line_start_point_x, shaft_line_start_point_y );
        CGContextAddLineToPoint( context,  shaft_line_end_point_x,   shaft_line_end_point_y );
        CGContextStrokePath(context);
    }
    
    
    
    if (temp_draw_filter)
    {
        // Mark line with start and end point:
        CGContextSetStrokeColorWithColor(context, color_magenta);
        
        CGContextMoveToPoint(context,     marker_line1_x1, marker_line1_y1);
        CGContextAddLineToPoint(context,  marker_line1_x1, marker_line1_y1 + 1);
        
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context,     marker_line1_x2, marker_line1_y2);
        CGContextAddLineToPoint(context,  marker_line1_x2, marker_line1_y2 + 1);
        
        CGContextStrokePath(context);
        
        
        // Mark line with start and end point:
        CGContextSetStrokeColorWithColor(context, color_light_blue);
        
        CGContextMoveToPoint(context,     marker_line2_x1, marker_line2_y1);
        CGContextAddLineToPoint(context,  marker_line2_x1, marker_line2_y1 + 1);
        
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context,     marker_line2_x2, marker_line2_y2);
        CGContextAddLineToPoint(context,  marker_line2_x2, marker_line2_y2 + 1);
        
        CGContextStrokePath(context);
    }
    
    
    // Circle
    /*
    CGContextSetStrokeColorWithColor(context, color_red);
    
    // CGContextRef contextRef = UIGraphicsGetCurrentContext();
    // CGPoint point = ...
    int touchPos_x = 300;
    int touchPos_y = 200;
    CGContextSetLineWidth(context, 2.0);
    CGContextSetRGBFillColor(context, 0, 0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, 0, 0, 1.0, 1.0);
    CGRect circlePoint = (CGRectMake(touchPos_x, touchPos_y, 100.0, 60.0));
    
    CGContextFillEllipseInRect(context, circlePoint);
    */
    
    if (temp_draw_filter)
    {
        /* Draw a circle */
        // marker_circle_offset_x = 20;    // for debugging
        // marker_circle_offset_y = 10;    // for debugging
        int diameter = (int) (marker_circle_radius1 * 2.0f);
        int x_centered = marker_circle_offset_x - ((int) marker_circle_radius1);
        int y_centered = marker_circle_offset_y - ((int) marker_circle_radius1);
        CGRect circle_rect = CGRectMake( x_centered, y_centered , diameter, diameter );
        // CGRect circle_rect = CGRectMake( radius, radius, radius, radius );
        
        // Set the border width
        CGContextSetLineWidth(context, 1.0);
        
        // Set the circle fill color to GREEN
        // CGContextSetRGBFillColor(contextRef, 0.0, 255.0, 0.0, 1.0);
        
        // Set the cicle border color to red / orange
        // CGContextSetRGBStrokeColor(context, 255.0, 0.0, 0.0, 1.0);
        CGContextSetRGBStrokeColor(context, 1.0, 0.5, 0.5, 1.0);
        
        // Fill the circle with the fill color
        // CGContextFillEllipseInRect(contextRef, circle_rect);
        
        // Draw the circle border
        CGContextStrokeEllipseInRect(context, circle_rect);
        
        
        // Draw ghost of circle (marking ball) at impact:
        x_centered = impact_offset_x - ((int) marker_circle_radius1);
        y_centered = impact_offset_y - ((int) marker_circle_radius1);
        circle_rect = CGRectMake( x_centered, y_centered , diameter, diameter );
        CGContextStrokeEllipseInRect(context, circle_rect);
        
        
        // Draw ghost of circle (marking ball) at ninety deg ball orientation:
        x_centered = ninety_deg_offset_x - ((int) marker_circle_radius1);
        y_centered = ninety_deg_offset_y - ((int) marker_circle_radius1);
        circle_rect = CGRectMake( x_centered, y_centered , diameter, diameter );
        CGContextStrokeEllipseInRect(context, circle_rect);
    }
    
    
    // Draw the blastman
    if (temp_draw_filter)
    {
        CGContextSetStrokeColorWithColor(context, color_light_green);
        for (int point_no = 0; point_no < num_blastman_points; point_no++)
        {
            CGContextMoveToPoint(context,     blast_man_points_x[point_no], blast_man_points_y[point_no]);
            CGContextAddLineToPoint(context,  blast_man_points_x[point_no], blast_man_points_y[point_no] + 1);
            
            CGContextStrokePath(context);
        }
    }
    
    
    if ((text_display_on) && (temp_draw_filter))
    {
        // Draw text "Ball Roll" and "90 Deg. Point":
        
        float last_speed_draw_point_x = 4;
        float last_speed_draw_point_y = 30;
        CGRect viewBounds = self.bounds;
        CGContextTranslateCTM(context, 0, viewBounds.size.height);     // invert the field
        CGContextScaleCTM(context, 1, -1);
        int text_draw_point_y = viewBounds.size.height - last_speed_draw_point_y;
        // CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);    // white
        float red   = 1.0f;
        float green = 1.0f;
        float blue  = 1.0f;
        CGContextSetLineWidth(context, 2.0);
        CGContextSelectFont(context, "Helvetica", 14.0, kCGEncodingMacRoman);
        CGContextSetCharacterSpacing(context, 1.1);
        CGContextSetTextDrawingMode(context, kCGTextFill);
        float orientation_deg = ball_orientation;
        NSString *ball_roll_str = [NSString stringWithFormat:@"Ball Roll: %3.0f deg ",orientation_deg];
        float ninety_deg_point = ninety_degree_point; // 12.0f;
        NSString *ninety_deg_point_str = [NSString stringWithFormat:@"90  Point: %2.1f in.",ninety_deg_point];       // 260 = degree symbol    // \u00A1   // \xBA
        // CGContextShowTextAtPoint(context, last_speed_draw_point_x, text_draw_point_y, [ball_roll_str UTF8String], 18);
        int text_length = 18;
        [ self draw_text :context :last_speed_draw_point_x :text_draw_point_y :ball_roll_str :text_length :red :green :blue ];
        last_speed_draw_point_y = 50;
        text_draw_point_y = viewBounds.size.height - last_speed_draw_point_y;
        // CGContextShowTextAtPoint(context, last_speed_draw_point_x, text_draw_point_y, [ninety_deg_point_str UTF8String], 18);
        text_length = 18;
        [ self draw_text :context :last_speed_draw_point_x :text_draw_point_y :ninety_deg_point_str :text_length :red :green :blue ];
        
        // Draw the "degree" symbol:
        
        CGContextSelectFont(context, "Helvetica", 8.0, kCGEncodingMacRoman);
        last_speed_draw_point_x = 21;
        last_speed_draw_point_y = 44;
        const char *degree_symbol = "o";
        text_draw_point_y = viewBounds.size.height - last_speed_draw_point_y;
        CGContextShowTextAtPoint(context, last_speed_draw_point_x, text_draw_point_y, degree_symbol, 1);
        
        
        // Draw text "Force" and "Distance"
        
        CGContextSelectFont(context, "Helvetica", 14.0, kCGEncodingMacRoman);
        last_speed_draw_point_x = 140;
        last_speed_draw_point_y = 30;
        text_draw_point_y = viewBounds.size.height - last_speed_draw_point_y;
        // CGContextSetRGBFillColor(context, 0.0, 0.8, 0.0, 1.0);      // green
        // CGContextShowTextAtPoint(context, 10.0, 10.0, "rpm", 3);
        float tavel_distance_in_feet = ball_travel_distance * 3.21084f;
        NSString *force_str = [NSString stringWithFormat:@"Force:     %5.2f N ",force_for_ball_momentum];
        NSString *distance_str = [NSString stringWithFormat:@"Distance: %5.2f feet ",tavel_distance_in_feet];
        // CGContextShowTextAtPoint(context, last_speed_draw_point_x + 4, text_draw_point_y, "Force: ", 17);
        // CGContextShowTextAtPoint(context, last_speed_draw_point_x + 4, text_draw_point_y, [force_str UTF8String], 18);
        text_length = 18;
        [ self draw_text :context :(last_speed_draw_point_x + 4) :text_draw_point_y :force_str :text_length :red :green :blue ];
        last_speed_draw_point_y = 50;
        text_draw_point_y = viewBounds.size.height - last_speed_draw_point_y;
        // CGContextShowTextAtPoint(context, last_speed_draw_point_x + 4, text_draw_point_y, "Distance: ", 20);
        // CGContextShowTextAtPoint(context, last_speed_draw_point_x + 4, text_draw_point_y, [distance_str UTF8String], 20);
        text_length = 20;
        [ self draw_text :context :(last_speed_draw_point_x + 4) :text_draw_point_y :distance_str :text_length :red :green :blue ];
        // CGContextShowTextAtPoint(context, 10.0, 10.0, "speed (mph)", 11);
        
        
        // Draw "fps" in lower right corner:
        
        CGContextSelectFont(context, "Helvetica", 14.0, kCGEncodingMacRoman);
        last_speed_draw_point_x = 3;
        last_speed_draw_point_y = 170;
        text_draw_point_y = viewBounds.size.height - last_speed_draw_point_y;
        int display_fps2 = display_fps;
        NSString *display_fps_str = [NSString stringWithFormat:@"%3d fps",display_fps2];
        text_length = 7;
        [ self draw_text :context :(last_speed_draw_point_x + 4) :text_draw_point_y :display_fps_str :text_length :red :green :blue ];

    }
    

    
    
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color_red);
    CGColorRelease(color_orange);
    CGColorRelease(color_magenta);
    CGColorRelease(color_yellow);
    CGColorRelease(color_blue);
    CGColorRelease(color_light_blue);
    CGColorRelease(color_light_green);
    CGColorRelease(color_white);
}


-(void) draw_text :(CGContextRef)context :(int)x :(int)y :(NSString*)text :(int)length :(float)red :(float)green :(float)blue
{
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);      // black shadow
    CGContextShowTextAtPoint(context, x+1, y, [text UTF8String], length);
    
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);      // black shadow
    CGContextShowTextAtPoint(context, x, y-1, [text UTF8String], length);
    
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);      // black shadow
    CGContextShowTextAtPoint(context, x+1, y-1, [text UTF8String], length);
    
    CGContextSetRGBFillColor(context, red, green, blue, 1.0);
    CGContextShowTextAtPoint(context, x, y, [text UTF8String], length);
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


-(void) set_impact_ghost :(int)x :(int)y
{
    impact_offset_x = x;
    impact_offset_y = y;
}


-(void) set_ninety_deg_ghost :(int)x :(int)y
{
    ninety_deg_offset_x = x;
    ninety_deg_offset_y = y;
}


-(void) set_box2_offset_x: (int) n {
    box2_offset_x = n;
}

-(void) set_box2_offset_y: (int) n {
    box2_offset_y = n;
}


-(void) set_box3_offset_x: (int) n {
    box3_offset_x = n;
}

-(void) set_box3_offset_y: (int) n {
    box3_offset_y = n;
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


-(void) set_box2_width: (int) n {
    box2_width_half = n;
}

-(void) set_box2_height: (int) n {
    box2_height_half = n;
}


-(void) set_box3_width: (int) n {
    box3_width_half = n;
}

-(void) set_box3_height: (int) n {
    box3_height_half = n;
}



-(void) set_rotation_angle: (float) n {
    rotation_angle = n;
}

-(float) get_rotation_angle {
    return rotation_angle;
}

-(void) set_marker_circle_radius1: (float) radius {
    marker_circle_radius1 = radius;
}

-(void) set_marker_circle_offset_x: (int) x {
    marker_circle_offset_x = x;
}

-(void) set_marker_circle_offset_y: (int) y {
    marker_circle_offset_y = y;
}



-(void) set_marker_line1 :(int)x1 :(int)y1 :(int)x2 :(int)y2
{
    marker_line1_x1 = x1;
    marker_line1_y1 = y1;
    marker_line1_x2 = x2;
    marker_line1_y2 = y2;
}


-(void) set_marker_line2 :(int)x1 :(int)y1 :(int)x2 :(int)y2
{
    marker_line2_x1 = x1;
    marker_line2_y1 = y1;
    marker_line2_x2 = x2;
    marker_line2_y2 = y2;
}


-(void) init_blastman :(int)num_points
{
    blast_man_points_x = (float *) calloc(num_points, sizeof(float));
    blast_man_points_y = (float *) calloc(num_points, sizeof(float));
}


-(void) free_blastman     // SHOULD CALL THIS IN finalize...
{
    if (blast_man_points_x) { free(blast_man_points_x); }
    if (blast_man_points_y) { free(blast_man_points_y); }
}


-(void) set_blastman_points :(int)num_points :(float *)points_x :(float *)points_y :(float)video_scale_factor_x :(float)video_scale_factor_y
{
    num_blastman_points = num_points;
    for (int point_no = 0; point_no < num_blastman_points; point_no++)
    {
        blast_man_points_x[point_no] = points_x[point_no] * video_scale_factor_x;
        blast_man_points_y[point_no] = points_y[point_no] * video_scale_factor_y;
    }
}


-(void) set_force_and_distance_etc :(float)force :(float) distance :(float)orientation :(float) ninety_deg_point :(int) display_fps1
{
    force_for_ball_momentum = force;
    ball_travel_distance = distance;
    
    ball_orientation = orientation;
    ninety_degree_point = ninety_deg_point;
    
    display_fps = display_fps1;
}



- (void) rotate_point_around_origin :(float *) pt_x :(float *) pt_y :(float) angle
{
   // *pt_x += 3;
    float pt_x_new = cosf(angle) * *pt_x - sinf(angle) * *pt_y;
    float pt_y_new = sinf(angle) * *pt_x + cosf(angle) * *pt_y;
    
    *pt_x = pt_x_new;
    *pt_y = pt_y_new;
}



-(void) turn_text_display_on
{
    text_display_on = true;
}


-(void) turn_text_display_off
{
    text_display_on = false;
}


-(void) set_clubhead_subimg_mask :(int *)mask :(int)length :(int)box_width_orig :(int)box_height_org :(float *)scale_factor_x :(float *)scale_factor_y
{
    clubhead_subimg_mask = mask;
    clubhead_subimg_arr_length = length;
    
    video_scale_factor_x = scale_factor_x;
    video_scale_factor_y = scale_factor_y;
    
    box2_width_half_orig = box_width_orig;
    box2_height_half_orig = box_height_org;
}


-(void) set_club_shaft_subimg_mask :(int *)mask :(int)length :(int)box_width_orig :(int)box_height_org :(float *)scale_factor_x :(float *)scale_factor_y
{
    club_shaft_subimg_mask = mask;
    club_shaft_subimg_arr_length = length;
    
    video_scale_factor_x = scale_factor_x;
    video_scale_factor_y = scale_factor_y;
    
    box3_width_half_orig = box_width_orig;
    box3_height_half_orig = box_height_org;
}


-(void) turn_clubhead_subimg_mask_on
{
    clubhead_subimg_mask_on = true;
}

-(void) turn_clubhead_subimg_mask_off
{
    clubhead_subimg_mask_on = false;
}


- (void) set_shaft_line :(double)slope :(double)offset
{
    shaft_line_slope = slope;
    shaft_line_offset = offset;
}


@end
