//
//  VDMRegressionTest.h
//  VidM01
//
//  Created by Juergen Haas on 7/31/15.
//  Copyright (c) 2015 Blast. All rights reserved.
//

#ifndef VidM01_VDMRegressionTest_h
#define VidM01_VDMRegressionTest_h


#endif



@interface VDMRegressionTest : NSObject {
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
 

/*
@implementation VDMRegressionTest

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
