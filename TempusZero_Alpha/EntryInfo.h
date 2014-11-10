//
//  EntryInfo.h
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 04/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EntryInfo : NSObject
typedef enum {
    IN = 0,
    OUT = 1
} EntryRecdType;


@property (nonatomic, assign) NSInteger siteId;
@property (nonatomic, assign) EntryRecdType recdType;
@property (nonatomic, assign) NSInteger employeeId;

@end
