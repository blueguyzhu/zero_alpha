//
//  VSpinner.h
//  TempusZero_Alpha
//
//  Created by Wenlu Zhang on 06/11/14.
//  Copyright (c) 2014 TEMPUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (VSpinner)

@property (nonatomic, strong, readonly) NSMutableDictionary *spinners;

- (void) showSpinnerWithName: (NSString *)key inView: (UIView *)supView;
- (void) removeSpinnerWithName: (NSString *)key;

@end
