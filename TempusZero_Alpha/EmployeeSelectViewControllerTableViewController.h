//
//  EmployeeSelectViewControllerTableViewController.h
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 03/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmployeeSelectViewControllerTableViewController : UITableViewController

- (id) initWithDataSource: (NSArray *) dataSource;
- (void) updateDataSource: (NSArray *) dataSource;

@end
