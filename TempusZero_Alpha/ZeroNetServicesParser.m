//
//  ZeroNetServicesParser.m
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 03/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import "ZeroNetServicesParser.h"
#import "SiteInfo.h"

@implementation ZeroNetServicesParser

+ (id) parseEmployeeList:(NSData *)data
{
    NSError *err = nil;
    NSArray *employeeJsonArr = [NSJSONSerialization JSONObjectWithData:data options:2 error:&err];
    
    if (err)
        return err;
    
    
    return employeeJsonArr;
}


+ (id) parseSiteList:(NSData *)data
{
    NSError *err = nil;
    NSArray *sitesJsonArr = [NSJSONSerialization JSONObjectWithData:data options:2 error:&err];
    
    if (err)
        return err;
    
    
    NSMutableArray *siteList = [[NSMutableArray alloc] initWithCapacity:sitesJsonArr.count];
    for (NSDictionary *jsonSite in sitesJsonArr) {
        SiteInfo *siteInfo = [[SiteInfo alloc] init];
        
        NSString *siteIdStr = (NSString *) [jsonSite objectForKey:@"Nr"];
        [siteInfo setSiteId:[siteIdStr integerValue]];
        
        NSString *name = [[NSString alloc] initWithString:[jsonSite objectForKey:@"Navn"]];
        [siteInfo setName:name];
        
        NSString *addr = [[NSString alloc] initWithString:[jsonSite objectForKey:@"Lokasjon"]];
        [siteInfo setAddr:addr];
        
        siteInfo.coord = CLLocationCoordinate2DMake(NAN, NAN);
        
        [siteList addObject:siteInfo];
    }
    
    
    return siteList;
}


@end
