//
//  GeoManager.h
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 04/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "HomeViewController.h"

@interface GeoManager : NSObject <CLLocationManagerDelegate>
//modify it to use block or delegate
@property (nonatomic, strong) HomeViewController *homeVC;

+ (GeoManager *) sharedInstance;

- (void) currentLocationWithSuc: (void (^)(CLLocationCoordinate2D, NSString *)) suc withFailure: (void (^)(NSString *)) fail;
- (void) clearAllMonitorinRegion;
- (void) startToMonitorRegions: (NSArray *) targetRegions;
- (void) geocodeAddr: (NSString *) addr withSuc: (void(^)(CLLocationCoordinate2D coord)) suc withFail: (void (^)(NSString *errMsg)) fail;
- (NSArray *) currentMonitoredRegions;

@end
