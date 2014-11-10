//
//  LocationPickViewController.m
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 04/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import "LocationPickViewController.h"
#import "GeoManager.h"
#import "UIViewController+VSpinner.h"

@interface LocationPickViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;
@property (nonatomic, assign) CLLocationCoordinate2D tmpCoord;
@end

@implementation LocationPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) viewDidAppear:(BOOL)animated
{
    _saveAddrInfo.hidden = YES;
    _saveAddrInfo.enabled = NO;
    
    [self showActivityIndicator];
    
    __weak LocationPickViewController *weakSelf = self;
    [[GeoManager sharedInstance] currentLocationWithSuc:^(CLLocationCoordinate2D coord, NSString *addr) {
        [weakSelf stopActivityIndicator];
        [_addrIndicator setText:addr];
        _tmpCoord = coord;
        _saveAddrInfo.hidden = NO;
        _saveAddrInfo.enabled = YES;
    } withFailure:^(NSString *errMsg) {
        [weakSelf stopActivityIndicator];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errMsg delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", "ok") otherButtonTitles:nil];
        [alertView show];
    }];
}


- (void) showActivityIndicator
{
    if (!_spinnerView) {
        CGSize size = self.view.bounds.size;
        
        _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        [_spinnerView setFrame:CGRectMake(0, 0, size.width, size.height)];
        _spinnerView.hidesWhenStopped = YES;
        _spinnerView.alpha = 0.7;
        _spinnerView.backgroundColor = [UIColor grayColor];
        _spinnerView.center = CGPointMake(size.width / 2.0f, size.height / 2.0f);
    }
    
    [self.view addSubview:_spinnerView];
    [_spinnerView startAnimating];
}


- (void) stopActivityIndicator
{
    if (_spinnerView) {
        [_spinnerView stopAnimating];
        [_spinnerView removeFromSuperview];
    }
}


- (IBAction)saveBtnPressed:(id)sender
{
    NSMutableDictionary *locInfo = [[NSMutableDictionary alloc] init];
    NSString *addr = [NSString stringWithString:_addrIndicator.text];
    [locInfo setObject:addr forKey:@"name"];
    [locInfo setObject:[NSNumber numberWithFloat:_tmpCoord.latitude] forKey:@"lat"];
    [locInfo setObject:[NSNumber numberWithFloat:_tmpCoord.longitude] forKey:@"long"];
    
    [[NSUserDefaults standardUserDefaults] setObject:locInfo forKey:@"location"];
    
    [[GeoManager sharedInstance] clearAllMonitorinRegion];
//    [[GeoManager sharedInstance] addRegionToBeMonitored:_tmpCoord name:addr];

    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)useDefBtnPressed:(id)sender
{
    static NSString *addr = @"Valhallavägen 159, 11553 Stockholm";
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(59.340652, 18.093948);
    
    NSDictionary *locInfo = [[NSDictionary alloc] initWithObjectsAndKeys:addr, @"name", [NSNumber numberWithFloat:coord.latitude], @"lat",
                             [NSNumber numberWithFloat:coord.longitude], @"long", nil];
    [[NSUserDefaults standardUserDefaults] setObject:locInfo forKey:@"location"];
    
    [[GeoManager sharedInstance] clearAllMonitorinRegion];
//    [[GeoManager sharedInstance] addRegionToBeMonitored:coord name:addr];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
