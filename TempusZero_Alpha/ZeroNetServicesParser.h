//
//  ZeroNetServicesParser.h
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 03/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZeroNetServicesParser : NSObject

+ (id) parseEmployeeList: (NSData *) data;
+ (id) parseSiteList: (NSData *)data;

@end
