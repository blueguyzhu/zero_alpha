//
//  GeoManager.m
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 04/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#define kMONITOR_RADIUS     200

#import "GeoManager.h"
#import "SiteInfo.h"
#import "EntryInfo.h"
#import "ZeroNetServices.h"
#import "WLLog.h"

@interface GeoManager ()

@property (nonatomic, strong) CLLocationManager *locMngr;
@property (nonatomic, copy) void (^getLocSuc) (CLLocationCoordinate2D, NSString *);
@property (nonatomic, copy) void (^getLocFail) (NSString *);
//@property (nonatomic, strong) NSMutableArray *monitoredRegions;
@property (nonatomic, strong) NSMutableDictionary *monitoredRegions;

@end

@implementation GeoManager

+ (GeoManager *) sharedInstance
{
    static GeoManager *sharedInstance;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GeoManager alloc] init];
    });
    
    return sharedInstance;
}


- (id) init
{
    self = [super init];
    if (self) {
        _locMngr = [[CLLocationManager alloc] init];
        _locMngr.delegate = self;
        _locMngr.desiredAccuracy = kCLLocationAccuracyBest;
        if ([_locMngr respondsToSelector:@selector(requestAlwaysAuthorization)])
            [_locMngr requestAlwaysAuthorization];
        
//        _monitoredRegions = [[NSMutableArray alloc] init];
        _monitoredRegions = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (void) startToMonitorRegions: (NSArray *) targetRegions
{
    NSMutableDictionary *locations = [[NSMutableDictionary alloc] init];
    
    for (SiteInfo *siteInfo in targetRegions) {
        NSString *siteIdStr = [NSString stringWithFormat:@"%ld", siteInfo.siteId];
        CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:siteInfo.coord
                                                                     radius:kMONITOR_RADIUS
                                                                 identifier:siteIdStr];
        
        [_locMngr startMonitoringForRegion:region];
        
        [_monitoredRegions setObject:siteInfo forKey:siteIdStr];
        
        [locations setObject:[NSKeyedArchiver archivedDataWithRootObject:siteInfo] forKey:siteIdStr];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:locations forKey:@"locations"];
}


- (void) clearAllMonitorinRegion
{
    NSArray *monitoredRegions = [[_locMngr monitoredRegions] allObjects];
    for (CLRegion *region in monitoredRegions) {
        [_locMngr stopMonitoringForRegion:region];
    }
    
    [_monitoredRegions removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"locations"];
}


- (NSArray *) currentMonitoredRegions
{
    NSArray *geoRegs = [[_locMngr monitoredRegions] allObjects];
    NSDictionary *archivedSiteInfo = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"locations"];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for (CLRegion *region in geoRegs) {
        if ([archivedSiteInfo objectForKey:region.identifier]) {
            NSData *data = [archivedSiteInfo objectForKey:region.identifier];
            SiteInfo *siteInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
            [arr addObject:siteInfo];
        }
    }
    
    
    return arr;
}


- (void) currentLocationWithSuc: (void (^)(CLLocationCoordinate2D, NSString *)) suc withFailure: (void (^)(NSString *)) fail
{
    [_locMngr startUpdatingLocation];
    _getLocFail = fail;
    _getLocSuc = suc;
}


- (void) geocodeAddr: (NSString *) addr withSuc: (void(^)(CLLocationCoordinate2D coord)) suc withFail: (void (^)(NSString *)) fail;
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:addr completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            [WLLog logWithLevel:ERROR withTime:nil withContent:@"Geodecode address %@ failed. \n %@", addr, error];
            fail ([NSString stringWithFormat:NSLocalizedString(@"GEOCODE_FAIL", @"geocoding failure"), addr]);
        }else {
            [WLLog logWithLevel:INFO withTime:nil withContent:@"Geodecode address %@ successfully.", addr];
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocationCoordinate2D coord = placemark.location.coordinate;
            
            suc (coord);
        }
    }];
}


#pragma mark - CLLocationManager delegate
- (void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    SiteInfo *siteInfo = [_monitoredRegions objectForKey: region.identifier];
//    [_homeVC displayMsg:[NSString stringWithFormat:@"Start to monitor %@", siteInfo.addr]];
    [WLLog logWithLevel:INFO withTime:nil withContent:@"Start to monitor %@", siteInfo.addr];
//    [_locMngr requestStateForRegion:region];
}


- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    SiteInfo *siteInfo = [_monitoredRegions objectForKey: region.identifier];
    [_homeVC displayMsg:[NSString stringWithFormat:@"Failed to monitor %@", siteInfo.addr]];
}


- (void) locationManager: (CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [_homeVC displayMsg:[NSString stringWithFormat:@"ERROR: %@", error.localizedDescription]];
}

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    SiteInfo *siteInfo = [_monitoredRegions objectForKey:region.identifier];
    
    EntryInfo *entryInfo = [[EntryInfo alloc] init];
    entryInfo.siteId = [region.identifier integerValue];
    entryInfo.employeeId = [[[NSUserDefaults standardUserDefaults] stringForKey:@"employeeID"] integerValue];
    entryInfo.recdType = IN;
    
    NSDictionary *dict = [ZeroNetServices regEntry:entryInfo];
    if ([dict objectForKeyedSubscript:@"err"]) {
        [_homeVC displayMsg:[NSString stringWithFormat:@"In region! ERROR: %@", [dict objectForKeyedSubscript:@"err"]]];
        return;
    }
    
    NSHTTPURLResponse *httpRep = [dict objectForKeyedSubscript:@"rep"];
    NSData *repData = [dict objectForKeyedSubscript:@"data"];
    
    if ([httpRep statusCode] != 200) {
        NSString *decodedData = [[NSString alloc] initWithData:repData encoding:NSUTF8StringEncoding];
        [_homeVC displayMsg:[NSString stringWithFormat:@"ERROR: Bad Http request. \n %@ \n %@", httpRep, decodedData]];
        
        return;
    }
    
    [_homeVC displayMsg:[NSString stringWithFormat:@"Inn %@", siteInfo.addr]];
}


- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    SiteInfo *siteInfo = [_monitoredRegions objectForKey:region.identifier];
    
    EntryInfo *entryInfo = [[EntryInfo alloc] init];
    entryInfo.siteId = region.identifier.integerValue;
    entryInfo.employeeId = [[[NSUserDefaults standardUserDefaults] stringForKey:@"employeeID"] integerValue];
    entryInfo.recdType = OUT;
    
    NSDictionary *dict = [ZeroNetServices regEntry:entryInfo];
    if ([dict objectForKeyedSubscript:@"err"]) {
        [_homeVC displayMsg:[NSString stringWithFormat:@"Ut region! ERROR: %@", [dict objectForKeyedSubscript:@"err"]]];
        return;
    }
    
    NSHTTPURLResponse *httpRep = [dict objectForKeyedSubscript:@"rep"];
    NSData *repData = [dict objectForKeyedSubscript:@"data"];
    
    if ([httpRep statusCode] != 200) {
        NSString *decodedData = [[NSString alloc] initWithData:repData encoding:NSUTF8StringEncoding];
        [_homeVC displayMsg:[NSString stringWithFormat:@"ERROR: Bad Http request. \n %@ \n %@", httpRep, decodedData]];
        
        return;
    }
    
    [_homeVC displayMsg:[NSString stringWithFormat:@"Ut %@", siteInfo.addr]];
}


- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (state == CLRegionStateInside) {
        SiteInfo *siteInfo = [_monitoredRegions objectForKey:region.identifier];
        [_homeVC displayMsg:[NSString stringWithFormat:@"Inn %@", siteInfo.addr]];
        
        EntryInfo *entryInfo = [[EntryInfo alloc] init];
        entryInfo.siteId = siteInfo.siteId;
        entryInfo.employeeId = [[[NSUserDefaults standardUserDefaults] stringForKey:@"employeeID"] integerValue];
        entryInfo.recdType = IN;
        
        NSDictionary *dict = [ZeroNetServices regEntry:entryInfo];
        if ([dict objectForKeyedSubscript:@"err"]) {
            [_homeVC displayMsg:[NSString stringWithFormat:@"In region! ERROR: %@", [dict objectForKeyedSubscript:@"err"]]];
            return;
        }
        
        NSHTTPURLResponse *httpRep = [dict objectForKeyedSubscript:@"rep"];
        NSData *repData = [dict objectForKeyedSubscript:@"data"];
        
        if ([httpRep statusCode] != 200) {
            NSString *decodedData = [[NSString alloc] initWithData:repData encoding:NSUTF8StringEncoding];
            [_homeVC displayMsg:[NSString stringWithFormat:@"ERROR: Bad Http request. \n %@ \n %@", httpRep, decodedData]];
            
            return;
        }
        
        [_homeVC displayMsg:[NSString stringWithFormat:@"Ligger på %@", siteInfo.addr]];
    }
}


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *curLoc = [locations objectAtIndex:0];
    [_locMngr stopUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:curLoc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            if (_getLocFail)
                _getLocFail([NSString stringWithFormat:@"%@", error]);
        } else {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *addr = [[NSString alloc] initWithString:[[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@" "]];
            CLLocationCoordinate2D coord = placemark.location.coordinate;
            
            if (_getLocSuc)
                _getLocSuc(coord, addr);
        }
        
        _getLocSuc = nil;
        _getLocFail = nil;
    }];
}

@end
