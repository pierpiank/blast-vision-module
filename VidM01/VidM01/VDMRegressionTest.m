//
//  VDMRegressionTest.m
//  VidM01
//
//  Created by Juergen Haas on 7/31/15.
//  Copyright (c) 2015 Blast. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDMRegressionTest.h"


 @implementation VDMRegressionTest : NSObject 
 
 @synthesize num_files_int, num_metric_matches, num_metric_differences, num_files_without_diff, num_files_with_diff, messages;
 
 - (void) dealloc {
 // [num_files release];
 // [num_successes release];
 // [num_failure release];
 // [messages release];
 // [super release];
 }
 @end

