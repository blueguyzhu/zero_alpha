//
//  LocationSelectViewControllerTableViewController.h
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 04/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationSelectViewControllerTableViewController : UITableViewController

- (id) initWithDataSource: (NSArray *)locList;
- (void) updateDataSource: (NSArray *)locList;

@end
