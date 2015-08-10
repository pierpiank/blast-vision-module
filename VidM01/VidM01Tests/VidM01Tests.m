//
//  VidM01Tests.m
//  VidM01Tests
//
//  Created by Juergen Haas on 3/1/14.
//  Copyright (c) 2014 Blast. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VDMViewController.h"

#import "VDMAppDelegate.h"



@interface VidM01Tests : XCTestCase

@end

@implementation VidM01Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // [VDMViewController set_regression_test :true];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    // XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    printf("   --- VidM01Tests - testExample\n");
    
    // Run regression test:
    
    // [VDMViewController regression_test];        // calling (static) class method
    
    // @autoreleasepool {
    //     int argc = 0;
    //     char * * argv = NULL;
    //     int result = UIApplicationMain(argc, argv, nil, NSStringFromClass([VDMAppDelegate class]));
    // }

    // @autoreleasepool
    // {
    //     [VDMViewController set_regression_test :true];
    // }
    
    // Card *card1 = [[Card alloc] init];
    
    VDMViewController * vid1 = [[VDMViewController alloc] init];
    
    [VDMViewController set_regression_test :true];
    
    bool regression_test_mode = [VDMViewController get_regression_test];
    printf("   --- regression_test_switch: %d \n", regression_test_mode);
    
    [vid1 viewDidLoad];
    
    // Problem here: main thread (application) terminates before background thread are finished:
    [vid1 run_demo_t1];
    // [vid1 run_demo_putt_black_clubhead2];
    
    [NSThread sleepForTimeInterval:20.0];
}

@end
