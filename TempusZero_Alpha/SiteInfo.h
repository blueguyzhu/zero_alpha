//
//  SiteInfo.h
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 04/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SiteInfo : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger siteId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *addr;
@property (nonatomic, assign) CLLocationCoordinate2D coord;
@property (nonatomic, assign) BOOL valid;

@end
