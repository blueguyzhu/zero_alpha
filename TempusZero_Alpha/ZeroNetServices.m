//
//  ZeroNetServices.m
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 03/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#define SRV_BASE_URL    @"https://swa201403.servicebus.windows.net/zeroapi/"

#import "ZeroNetServices.h"

@implementation ZeroNetServices
+ (NSDictionary *) refreshEmployeeList
{
    NSURL *url = [NSURL URLWithString:[SRV_BASE_URL stringByAppendingFormat:@"ansatt"]];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse *rep = nil;
    NSError *err = nil;
    NSData *repData = [NSURLConnection sendSynchronousRequest:req returningResponse:&rep error: &err];
   
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:rep, @"rep", repData, @"data", err, @"err", nil];
    
    return dict;
}


+ (NSDictionary *) refreshSiteList
{
    NSURL *url = [NSURL URLWithString:[SRV_BASE_URL stringByAppendingString:@"site"]];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse *rep = nil;
    NSError *err = nil;
    NSData *repData = [NSURLConnection sendSynchronousRequest:req returningResponse:&rep error:&err];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:rep, @"rep", repData, @"data", err, @"err", nil];
    
    return dict;
}


+ (NSDictionary *) regEntry: (EntryInfo*)info
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:[NSNumber numberWithInteger:info.employeeId] forKey:@"AnsattNr"];
    [jsonDict setObject:[NSNumber numberWithInteger:info.siteId] forKey:@"Site"];
    [jsonDict setObject:info.recdType == IN ? @"in" : @"out" forKey:@"InOrOut"];
    
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&err];
    
    if (err) {
        NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:err, @"err", nil];
        return resultDict;
    }
    
    NSURL *url = [NSURL URLWithString:[SRV_BASE_URL stringByAppendingString:@"entry"]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [req setHTTPMethod:@"POST"];
    [req setTimeoutInterval:60.0];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:jsonData];
    
    NSHTTPURLResponse *httpRep = nil;
    NSData *repData = [NSURLConnection sendSynchronousRequest:req returningResponse:&httpRep error:&err];
    
    NSDictionary *resultDict = [[NSDictionary alloc] initWithObjectsAndKeys:repData, @"data", httpRep, @"rep", err, @"err", nil];
    
    return resultDict;
}
@end
