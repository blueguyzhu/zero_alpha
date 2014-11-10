//
//  LocationSelectViewControllerTableViewController.m
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 04/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import "LocationSelectViewControllerTableViewController.h"
#import "SiteInfo.h"
#import "UIViewController+VSpinner.h"
#import "GeoManager.h"

@interface LocationSelectViewControllerTableViewController ()
@property (nonatomic, strong) NSArray *locList;
@property (atomic, assign) NSInteger updatedCount;
@property (nonatomic, strong) NSMutableArray *selectedLocList;
@end

@implementation LocationSelectViewControllerTableViewController

- (id) initWithDataSource:(NSArray *)locList
{
    self = [self initWithNibName:@"LocationSelectViewController" bundle:[NSBundle mainBundle]];
    //self = [self init];
    
    if (self) {
        _locList = locList;
        _updatedCount = 0;
        _selectedLocList = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView allowsMultipleSelectionDuringEditing];
    [self.tableView allowsMultipleSelection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - private methods
- (void) updateNavigationBarForSelection {
    UIBarButtonItem *save = [[UIBarButtonItem alloc]
                             initWithTitle: NSLocalizedString(@"SAVE_BTN_TITLE", @"save button title")
                             style:UIBarButtonItemStylePlain
                             target:self
                             action:@selector(saveSelectedBtnPressed)];
    
    self.navigationItem.rightBarButtonItem = save;
}


- (void) saveSelectedBtnPressed {
    if (![[NSUserDefaults standardUserDefaults] stringForKey:@"employeeID"] ||
        ![[NSUserDefaults standardUserDefaults] stringForKey:@"employeeName"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"SEL_EMPLOYEE_FIRST", @"not select employee")
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"ok")
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [self.tableView setEditing:NO animated:YES];
    
    if (_selectedLocList.count) {
        [[GeoManager sharedInstance] clearAllMonitorinRegion];
        [[GeoManager sharedInstance] startToMonitorRegions:_selectedLocList];
    }
    
    self.navigationItem.rightBarButtonItem = nil;
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - public methods
- (void) updateDataSource:(NSArray *)locList
{
    _locList = locList;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _locList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *locCellName = @"locationTableCell";
    __block UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:locCellName];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locCellName];
    }
    
    CGRect cellFrame = cell.frame;
    cellFrame.size = CGSizeMake(tableView.frame.size.width, cellFrame.size.height);
    cell.frame = cellFrame;
    __block SiteInfo *siteInfo = [_locList objectAtIndex:indexPath.row];
    [cell.textLabel setText: siteInfo.addr];
   
    if ((siteInfo.coord.latitude != siteInfo.coord.latitude || siteInfo.coord.longitude != siteInfo.coord.longitude) &&
        siteInfo.valid) {
        [self showSpinnerWithName:[NSString stringWithFormat:@"%ld", siteInfo.siteId] inView:cell];
        [[GeoManager sharedInstance] geocodeAddr:siteInfo.addr withSuc:^(CLLocationCoordinate2D coord) {
            ++_updatedCount;
            [self removeSpinnerWithName:[NSString stringWithFormat:@"%ld", siteInfo.siteId]];
            siteInfo.coord = coord;
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%f, %f", coord.latitude, coord.longitude]];
            
            if (_updatedCount == _locList.count) {
               [self.tableView setEditing:YES animated:YES];
                [self updateNavigationBarForSelection];
            }
        } withFail:^(NSString *errMsg) {
            ++_updatedCount;
            [self removeSpinnerWithName:[NSString stringWithFormat:@"%ld", siteInfo.siteId]];
            [cell.detailTextLabel setText:errMsg];
            siteInfo.valid = NO;
            
            if (_updatedCount == _locList.count) {
               [self.tableView setEditing:YES animated:YES];
                [self updateNavigationBarForSelection];
            }
        }];
    }else {
        ++_updatedCount;
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%f, %f", siteInfo.coord.latitude, siteInfo.coord.longitude]];
    }
    
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    SiteInfo *siteInfo = [_locList objectAtIndex:indexPath.row];
    
    return siteInfo.valid;
}


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

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    // Navigation logic may go here, for example:
    // Create the next view controller.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SiteInfo *siteInfo = [_locList objectAtIndex:indexPath.row];
    [_selectedLocList addObject:siteInfo];
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    SiteInfo *siteInfo = [_locList objectAtIndex:indexPath.row];
    [_selectedLocList removeObject:siteInfo];
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
