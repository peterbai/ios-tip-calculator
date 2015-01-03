//
//  TipViewController.h
//  ios-tip-2
//
//  Created by Peter Bai on 12/31/14.
//  Copyright (c) 2014 Peter Bai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TipViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) float billAmount;
@property (nonatomic) int tipPercent;

@end
