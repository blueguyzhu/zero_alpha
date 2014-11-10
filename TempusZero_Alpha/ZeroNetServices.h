//
//  ZeroNetServices.h
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 03/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntryInfo.h"

@interface ZeroNetServices : NSObject

+ (NSDictionary *) refreshEmployeeList;
+ (NSDictionary *) refreshSiteList;
+ (NSDictionary *) regEntry: (EntryInfo*)info;

@end
