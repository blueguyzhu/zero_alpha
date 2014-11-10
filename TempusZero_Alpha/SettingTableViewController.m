//
//  SettingTableViewController.m
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 03/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import "SettingTableViewController.h"
#import "ZeroNetServices.h"
#import "ZeroNetServicesParser.h"
#import "EmployeeSelectViewControllerTableViewController.h"
#import "EntryInfo.h"
#import "LocationPickViewController.h"
#import "LocationSelectViewControllerTableViewController.h"
#import "UIViewController+VSpinner.h"
#import "SiteInfo.h"
#import "GeoManager.h"

@interface SettingTableViewController ()

@property (nonatomic, strong) EmployeeSelectViewControllerTableViewController *employeeVC;
@property (nonatomic, strong) LocationPickViewController *locPickVC;
@property (nonatomic, strong) LocationSelectViewControllerTableViewController *locSelectVC;
@property (nonatomic, assign) BOOL needReload;
@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _needReload = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    if (_needReload)
        [(UITableView *)self.view reloadData];
    
    _needReload = NO;
}


- (void)viewWillDisappear:(BOOL)animated
{
    _needReload = YES;
}


#pragma mark - private methods


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *settingCellName = @"settingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:settingCellName];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:settingCellName];
    
    switch (indexPath.row) {
        case 0:
        {
            if ([[NSUserDefaults standardUserDefaults] stringForKey:@"employeeID"] &&
                [[NSUserDefaults standardUserDefaults] stringForKey:@"employeeName"])
            {
                [cell.textLabel setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"employeeName"]];
            }
            else
            {
                [cell.textLabel setText: NSLocalizedString(@"SEL_EMPLOYEE", "select the emloyee num")];
            }
        }
            break;
            
            
        case 1:
        {
            [cell.textLabel setText:NSLocalizedString(@"SEL_LOC", "select location")];
        }
            break;
            
            
        case 2:
        {
            [cell.textLabel setText:NSLocalizedString(@"CHECK_LOCATION", "Check monitored location")];
        }
            
            break;
            
        default:
            break;
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - table deleage
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            NSDictionary *dict;
            dict = [ZeroNetServices refreshEmployeeList];
            NSHTTPURLResponse *rep = (NSHTTPURLResponse *)[dict objectForKey:@"rep"];
            
            if ([rep statusCode] != 200)
            {
                NSLog(@"ERROR: %@", rep);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NET_FAILS", @"Network failure")
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
                
                [alert show];
            }else {
                NSData *data = (NSData *) [dict objectForKey:@"data"];
                id result = (NSArray *)[ZeroNetServicesParser parseEmployeeList: data];
                if (![result isKindOfClass:[NSArray class]]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DATA_PARSE_FAILS", @"Parse data failure")
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                } else {
                    NSArray *employeeList = (NSArray *) result;
                    _employeeVC = [[EmployeeSelectViewControllerTableViewController alloc] initWithDataSource:employeeList];
                    
                    [self.navigationController pushViewController:_employeeVC animated:YES];
                    
                }
                
            }
        }
            
            break;
            
           /*
        case 1:
        {
            if (!_locPickVC) {
                _locPickVC = [[LocationPickViewController alloc] initWithNibName:@"LocationPickView" bundle:[NSBundle mainBundle]];
            }
            
            [self.navigationController pushViewController:_locPickVC animated:YES];
        }
            */
            
        case 1:
        {
            [self showSpinnerWithName:NSStringFromClass([self class]) inView:self.view];
            NSDictionary *dict = [ZeroNetServices refreshSiteList];
            [self removeSpinnerWithName:NSStringFromClass([self class])];
            if ([dict objectForKey:@"err"] || ![dict objectForKey:@"rep"] ||
                [((NSHTTPURLResponse *)[dict objectForKey:@"rep"]) statusCode] != 200) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NET_FAILS", @"Network failure")
                                                                message:NSLocalizedString(@"NET_FAIL_TRY_AGAIN", @"try again")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                      otherButtonTitles:nil];
                
                [alert show];
            } else {
                NSData *rep = [dict objectForKey:@"data"];
                id result = [ZeroNetServicesParser parseSiteList:rep];
                
                if (![result isKindOfClass:[NSArray class]]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DATA_PARSE_FAILS", @"Parse data failure")
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                } else {
                    NSArray *siteList = (NSArray *) result;
                    if (!_locSelectVC)
                        _locSelectVC = [[LocationSelectViewControllerTableViewController alloc] initWithDataSource:siteList];
                    else
                        [_locSelectVC updateDataSource:siteList];
                    
                    
                    [self.navigationController pushViewController:_locSelectVC animated:YES];
                }
            }
        }
            break;
            
            
        case 2:
        {
            [self performSegueWithIdentifier:@"segToMonitoredLocView" sender:self];
        }
            break;
            
            
            
           /*
        case 1:
        {
            EntryInfo *entryInfo = [[EntryInfo alloc] init];
            entryInfo.siteId = 620;
            entryInfo.employeeId = 350;
            entryInfo.recdType = OUT;
            
            NSDictionary *dict = [ZeroNetServices regEntry:entryInfo];
            if ([dict objectForKeyedSubscript:@"err"]) {
                NSLog(@"ERROR: %@", [dict objectForKeyedSubscript:@"err"]);
                break;
            }
            
            NSHTTPURLResponse *httpRep = [dict objectForKeyedSubscript:@"rep"];
            NSData *repData = [dict objectForKeyedSubscript:@"data"];
            
            if ([httpRep statusCode] != 200) {
                NSString *decodedData = [[NSString alloc] initWithData:repData encoding:NSUTF8StringEncoding];
                NSLog(@"ERROR: Bad Http request. \n %@ \n %@", httpRep, decodedData);
                break;
            }
            
            NSLog(@"%@", dict);
        }
        
            break;
            */
            
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
