//
//  HomeViewController.m
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 03/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import "HomeViewController.h"
#import "GeoManager.h"
#import <QuartzCore/QuartzCore.h>


@interface HomeViewController ()
- (void) switchSegChange: (id)sender;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [GeoManager sharedInstance].homeVC = self;
    [_switchSegment addTarget:self action:@selector(switchSegChange:) forControlEvents:UIControlEventValueChanged];
    _switchSegment.enabled = NO;
    
    _toTempusGoBtn.layer.borderWidth = 1.0f;
    _toTempusGoBtn.layer.cornerRadius = 5.0f;
    _toTempusGoBtn.layer.borderColor = _toTempusGoBtn.titleLabel.textColor.CGColor;
    
    _settingBtn.layer.borderWidth = 1.0f;
    _settingBtn.layer.borderColor = _settingBtn.titleLabel.textColor.CGColor;
    _settingBtn.layer.cornerRadius = 5.0f;
    
    
    _msgTextField.layer.borderWidth = 0.5f;
    _msgTextField.layer.cornerRadius = 2.0f;
    _msgTextField.layer.borderColor = [UIColor whiteColor].CGColor;
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


- (IBAction)toTempusGoBtnPressed:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://go.tempus.no/Home/Index/218000108088057249234132002250220190134094207160/1#_home"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void) displayMsg:(NSString *)msg
{
    [_msgTextField setText:msg];
}

- (void) switchSegChange: (id)sender
{
    NSInteger index = [_switchSegment selectedSegmentIndex];
    if (0 == index) //on
    {
        if (![[NSUserDefaults standardUserDefaults] stringForKey:@"employeeID"] || ![[NSUserDefaults standardUserDefaults] stringForKey:@"employeeName"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"", "Employ is unset")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", "ok")
                                                  otherButtonTitles:nil];
            
            [alert show];
            return;
        }
        
        
        [[GeoManager sharedInstance] clearAllMonitorinRegion];
        NSDictionary *location = [[NSUserDefaults standardUserDefaults] objectForKey:@"location"];
        if (!location) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"", "Location is unset")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", "ok")
                                                  otherButtonTitles:nil];
            
            [alert show];
            
            return;
        }
       
        /*
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(<#CLLocationDegrees latitude#>, <#CLLocationDegrees longitude#>)
        [GeoManager sharedInstance] addRegionToBeMonitored:<#(CLLocationCoordinate2D)#> name:<#(NSString *)#>
         */
    }
    else{
        [[GeoManager sharedInstance] clearAllMonitorinRegion];
    }
}

@end
