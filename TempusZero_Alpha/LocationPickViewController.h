//
//  LocationPickViewController.h
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 04/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationPickViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField *addrIndicator;
@property (nonatomic, weak) IBOutlet UIButton *saveAddrInfo;
@property (nonatomic, weak) IBOutlet UIButton *useDefaultAddr;

- (IBAction)saveBtnPressed:(id)sender;
- (IBAction)useDefBtnPressed:(id)sender;

@end
