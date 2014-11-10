//
//  HomeViewController.h
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 03/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *msgTextField;
@property (nonatomic, weak) IBOutlet UISegmentedControl *switchSegment;
@property (nonatomic, weak) IBOutlet UIButton *toTempusGoBtn;
@property (nonatomic, weak) IBOutlet UIButton *settingBtn;

- (IBAction)toTempusGoBtnPressed:(id)sender;
- (void) displayMsg: (NSString *)msg;
@end
