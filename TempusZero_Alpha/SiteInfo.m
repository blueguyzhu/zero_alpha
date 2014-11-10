//
//  SiteInfo.m
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 04/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import "SiteInfo.h"

@implementation SiteInfo

- (id) init {
    self = [super init];
    
    if (self) {
        _valid = YES;
        _name = nil;
        _addr = nil;
    }
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *)encoder {
    [encoder encodeInteger:_siteId forKey:@"id"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_addr forKey:@"addr"];
    [encoder encodeBool:_valid forKey:@"valid"];
    [encoder encodeFloat:_coord.latitude forKey:@"latitude"];
    [encoder encodeFloat:_coord.longitude forKey:@"longitude"];
}


- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        _valid = [decoder decodeBoolForKey:@"valid"];
        _siteId = [decoder decodeIntegerForKey:@"id"];
        _name = [decoder decodeObjectForKey:@"name"];
        _addr = [decoder decodeObjectForKey:@"addr"];
        _coord = CLLocationCoordinate2DMake([decoder decodeFloatForKey:@"latitude"], [decoder decodeFloatForKey:@"longitude"]);
    }
    
    return self;
}
@end
