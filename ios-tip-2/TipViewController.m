//
//  TipViewController.m
//  ios-tip-2
//
//  Created by Peter Bai on 12/31/14.
//  Copyright (c) 2014 Peter Bai. All rights reserved.
//

#import "TipViewController.h"
#import "SettingsViewController.h"
#import "BillView.h"
#import "TotalView.h"
#import "SplitView.h"
#import "NSString+FontAwesome.h"

@interface TipViewController ()

@property (nonatomic) float totalAmount;
@property (nonatomic) int tipPercentMin;
@property (nonatomic) int tipPercentMax;
@property (nonatomic) int tipPercentTapStart;
@property (nonatomic) float viewBgColorBrightnessValue;
@property (nonatomic) float viewBgColorSaturationValue;

@property (nonatomic, strong) TotalView *totalAmountView;
@property (nonatomic, strong) SplitView *splitAmountView;

@property (nonatomic, strong) UIBarButtonItem *settingsBarButtonItem;

@property (nonatomic, strong) UITextField *billAmountTextField;
@property (nonatomic, strong) UILabel *totalAmountLabel;
@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) UILabel *splitLabelPeopleTwo;
@property (nonatomic, strong) UILabel *splitLabelPeopleThree;
@property (nonatomic, strong) UILabel *splitLabelPeopleFour;
@property (nonatomic, strong) UILabel *splitIconLabelPeopleTwo;
@property (nonatomic, strong) UILabel *splitIconLabelPeopleThree;
@property (nonatomic, strong) UILabel *splitIconLabelPeopleFour;

@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;

@property (nonatomic) CGRect billAmountFullFrame;
@property (nonatomic) CGRect billAmountSmallFrame;
@property (nonatomic) CGRect percentAmountHidden;
@property (nonatomic) CGRect percentAmountVisible;
@property (nonatomic) CGRect percentAmountActive;
@property (nonatomic) CGRect totalViewHiddenFrame;
@property (nonatomic) CGRect totalViewVisibleFrame;
@property (nonatomic) UIColor* billAmountViewColorDefault;
@property (nonatomic) UIColor* billAmountViewColor;

// Taps and gestures
- (void)onTotalAmountTapped;
- (void)onTotalAmountPanned:(UIPanGestureRecognizer *)recognizer;
- (void)onSettingsButton;

// Calcluations
- (void)setInitialBillAndPercentValues;
- (void)textFieldDidChange;
- (void)constrainTipPercentToSettings;
- (void)updateCalculation;

// Animations
- (void)displayCalculation;
- (void)hideCalculation;
- (void)updateBillAmountViewColor:(BOOL)animated;
- (void)clearBillAmountViewColor;
- (void)percentShowLarge;
- (void)percentReturnNormal;

// UI
- (void)setDarkModeAttributes;
- (void)setLightModeAttributes;

@end

@implementation TipViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        // navItem.title = @"Tip";
        
        // Create a settings bar button item and set it as the right item in navItem
        self.settingsBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithTitle:[NSString fontAwesomeIconStringForEnum:FACog]
                                                  style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(onSettingsButton)];
        
        NSDictionary *settingsTitleProperties = @{
                                                  NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:22],
                                                  NSForegroundColorAttributeName: [UIColor colorWithWhite:0 alpha:0.2]
                                                  };
        
        [self.settingsBarButtonItem setTitleTextAttributes:settingsTitleProperties forState:UIControlStateNormal];
        navItem.rightBarButtonItem = self.settingsBarButtonItem;
        
        // Initialize settings
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL didLoadBefore = [defaults boolForKey:@"didLoadBefore"];
        
        if (didLoadBefore != YES) {
            // write initial settings if first time loading
            [defaults setInteger:20 forKey:@"percentAmountDefault"];
            [defaults setInteger:10 forKey:@"percentAmountMin"];
            [defaults setInteger:30 forKey:@"percentAmountMax"];
            [defaults setBool:NO forKey:@"darkMode"];
            [defaults setBool:YES forKey:@"didLoadBefore"];
            [defaults synchronize];
        }
        
        // Create currency formatter
        self.currencyFormatter = [[NSNumberFormatter alloc] init];
        [self.currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        // [self.currencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    }
    return self;
}

- (void)loadView
{
    // Define frame sizes
    self.billAmountFullFrame = CGRectMake(10, 140, 300, 80);
    self.billAmountSmallFrame = CGRectMake(10, 60, 300, 80);
    self.percentAmountHidden = CGRectMake(200, 310, 110, 50);
    self.percentAmountVisible = CGRectMake(200, 150, 110, 50);
    self.percentAmountActive = CGRectMake(10, 140, 110, 50);
    self.totalViewHiddenFrame = CGRectMake(0, 356, 320, 160);
    self.totalViewVisibleFrame = CGRectMake(0, 200, 320, 160);

    // Create bill amount view and set it as the view of this viewcontroller
    BillView *billAmountView = [[BillView alloc] init];
    self.view = billAmountView;
    
    // Create and add bill input text field
    self.billAmountTextField = [[UITextField alloc] initWithFrame:self.billAmountFullFrame];
    self.billAmountTextField.placeholder = [self.currencyFormatter currencySymbol];
    self.billAmountTextField.backgroundColor = [UIColor clearColor];
    self.billAmountTextField.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:70];
    self.billAmountTextField.textAlignment = NSTextAlignmentRight;
    self.billAmountTextField.adjustsFontSizeToFitWidth = YES;
    self.billAmountTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.billAmountTextField.delegate = self;
    [self.billAmountTextField addTarget:self
                                 action:@selector(textFieldDidChange)
                       forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.billAmountTextField];

    // Create and add percent label as hidden
    self.percentLabel = [[UILabel alloc] initWithFrame:self.percentAmountHidden];
    self.percentLabel.text = @"%";
    self.percentLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:32];
    self.percentLabel.adjustsFontSizeToFitWidth = YES;
    self.percentLabel.textAlignment = NSTextAlignmentRight;
    self.percentLabel.alpha = 0.0;
    self.totalAmountView.hidden = YES;
    [self.view addSubview:self.percentLabel];
    
    // Create total amount label
    self.totalAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 80)];
    self.totalAmountLabel.text = [self.currencyFormatter currencySymbol];
    self.totalAmountLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:70];
    self.totalAmountLabel.textAlignment = NSTextAlignmentRight;
    self.totalAmountLabel.adjustsFontSizeToFitWidth = YES;
    
    // Create and add total amount view as hidden
    self.totalAmountView = [[TotalView alloc] initWithFrame:self.totalViewHiddenFrame];
    self.totalAmountView.hidden = YES;
    [self.totalAmountView addSubview:self.totalAmountLabel];  // Add total amount label to total amount view
    [self.view addSubview:self.totalAmountView];
    
    // Create split amount view
    self.splitAmountView = [[SplitView alloc] initWithFrame:CGRectMake(0, 352, 320, 240)];
    self.splitAmountView.backgroundColor = [UIColor whiteColor];
    
    // Create labels for split amounts
    // for 2 people
    self.splitLabelPeopleTwo = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 190, 60)];
    self.splitLabelPeopleTwo.text = [self.currencyFormatter currencySymbol];
    self.splitLabelPeopleTwo.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:28];
    self.splitLabelPeopleTwo.textAlignment = NSTextAlignmentRight;
    self.splitLabelPeopleTwo.adjustsFontSizeToFitWidth = YES;
    
    // for 3 people
    self.splitLabelPeopleThree = [[UILabel alloc] initWithFrame:CGRectMake(120, 65, 190, 60)];
    self.splitLabelPeopleThree.text = [self.currencyFormatter currencySymbol];
    self.splitLabelPeopleThree.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:28];
    self.splitLabelPeopleThree.textAlignment = NSTextAlignmentRight;
    self.splitLabelPeopleThree.adjustsFontSizeToFitWidth = YES;
    
    // for 4 people
    self.splitLabelPeopleFour = [[UILabel alloc] initWithFrame:CGRectMake(120, 130, 190, 60)];
    self.splitLabelPeopleFour.text = [self.currencyFormatter currencySymbol];
    self.splitLabelPeopleFour.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:28];
    self.splitLabelPeopleFour.textAlignment = NSTextAlignmentRight;
    self.splitLabelPeopleFour.adjustsFontSizeToFitWidth = YES;
    
    // Create label icons for split amounts
    // for 2 people
    self.splitIconLabelPeopleTwo = [[UILabel alloc] initWithFrame:CGRectMake(20, 2, 100, 60)];
    self.splitIconLabelPeopleTwo.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16];
    self.splitIconLabelPeopleTwo.textColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    self.splitIconLabelPeopleTwo.text = [NSString stringWithFormat:@"%@  %@",
                                    [NSString fontAwesomeIconStringForEnum:FAUser],
                                    [NSString fontAwesomeIconStringForEnum:FAUser]];
    
    // for 3 people
    self.splitIconLabelPeopleThree = [[UILabel alloc] initWithFrame:CGRectMake(20, 67, 100, 60)];
    self.splitIconLabelPeopleThree.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16];
    self.splitIconLabelPeopleThree.textColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    self.splitIconLabelPeopleThree.text = [NSString stringWithFormat:@"%@  %@  %@",
                                    [NSString fontAwesomeIconStringForEnum:FAUser],
                                    [NSString fontAwesomeIconStringForEnum:FAUser],
                                    [NSString fontAwesomeIconStringForEnum:FAUser]];
    
    // for 4 people
    self.splitIconLabelPeopleFour = [[UILabel alloc] initWithFrame:CGRectMake(20, 132, 100, 60)];
    self.splitIconLabelPeopleFour.font = [UIFont fontWithName:kFontAwesomeFamilyName size:16];
    self.splitIconLabelPeopleFour.textColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    self.splitIconLabelPeopleFour.text = [NSString stringWithFormat:@"%@  %@  %@  %@",
                                    [NSString fontAwesomeIconStringForEnum:FAUser],
                                    [NSString fontAwesomeIconStringForEnum:FAUser],
                                    [NSString fontAwesomeIconStringForEnum:FAUser],
                                    [NSString fontAwesomeIconStringForEnum:FAUser]];
    
    // Add labels and icons to split amount view
    [self.splitAmountView addSubview:self.splitLabelPeopleTwo];
    [self.splitAmountView addSubview:self.splitLabelPeopleThree];
    [self.splitAmountView addSubview:self.splitLabelPeopleFour];
    [self.splitAmountView addSubview:self.splitIconLabelPeopleTwo];
    [self.splitAmountView addSubview:self.splitIconLabelPeopleThree];
    [self.splitAmountView addSubview:self.splitIconLabelPeopleFour];
    
    // Add split amount view as hidden
    self.splitAmountView.hidden = YES;
    [self.view addSubview:self.splitAmountView];

    // Pre-populate bill and percent amounts
    [self setInitialBillAndPercentValues];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Recognize taps on total amount view
    UITapGestureRecognizer *totalAmountTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTotalAmountTapped)];
    [self.totalAmountView addGestureRecognizer:totalAmountTapRecognizer];
    
    // Recognize swipes on total amount view
    UIPanGestureRecognizer *totalAmountPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onTotalAmountPanned:)];
    totalAmountPanRecognizer.maximumNumberOfTouches = 1;
    [self.totalAmountView addGestureRecognizer:totalAmountPanRecognizer];
    
    // Make navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Load settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.tipPercentMin = [defaults integerForKey:@"percentAmountMin"];
    self.tipPercentMax = [defaults integerForKey:@"percentAmountMax"];
    BOOL darkMode = [defaults boolForKey:@"darkMode"];
    
    if (darkMode) {
        [self setDarkModeAttributes];
    } else {
        [self setLightModeAttributes];
    }

    [self constrainTipPercentToSettings];
    [self updateCalculation];
    
    if ([self.billAmountTextField.text isEqualToString:@""]) {
        [self.billAmountTextField becomeFirstResponder];
        self.billAmountTextField.placeholder = [self.currencyFormatter currencySymbol];
        [self clearBillAmountViewColor];
    } else {
        [self updateBillAmountViewColor:YES];
    }
}

- (void)textFieldDidChange
{
    if ([self.billAmountTextField.text isEqualToString:@""]) {
        self.billAmountTextField.placeholder = [self.currencyFormatter currencySymbol];
        [self hideCalculation];
        [self updateCalculation];
        [self clearBillAmountViewColor];
    } else {
        [self displayCalculation];
        [self updateCalculation];
    }
}

- (void)onTotalAmountTapped
{
    // Hide keypad
    [self.view endEditing:YES];
    
    // Wiggle text to indicate ability to swipe
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values = @[ @0, @4, @-4, @0];
    animation.keyTimes = @[ @0, @.3, @.9, @1];
    animation.duration = 0.3;
    animation.additive = YES;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    [self.totalAmountLabel.layer addAnimation:animation forKey:@"wiggle"];
}

- (void)onTotalAmountPanned:(UIPanGestureRecognizer *)recognizer
{
    // Hide keypad
    [self.view endEditing:YES];
    
    // Update percent based on pan x displacement
    CGPoint translation = [recognizer translationInView:self.view];
    // NSLog(@"Translating: (%f, %f)", translation.x, translation.y);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.tipPercentTapStart = self.tipPercent; // this should be set on touch start only
        [self updateBillAmountViewColor:YES];
        // [self percentShowLarge];
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.tipPercent = (self.tipPercentTapStart - translation.x / 20);

        if (self.tipPercent > self.tipPercentMax) {
            self.tipPercent = self.tipPercentMax;
        } else if (self.tipPercent < self.tipPercentMin) {
            self.tipPercent = self.tipPercentMin;
        }
        
        [self updateCalculation];
        [self updateBillAmountViewColor:NO];
        
    } else {
        // [self percentReturnNormal];
        return;
    }
}

- (void)setInitialBillAndPercentValues
{
    if (self.billAmount > 0) {
        self.billAmountTextField.text = [NSString stringWithFormat:@"%.2f", self.billAmount];
        [self displayCalculation];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.tipPercent = [defaults integerForKey:@"percentAmountDefault"];  // use default percent only on load
    }
}

- (void)updateCalculation
{
    self.billAmount = [self.billAmountTextField.text floatValue];
    self.totalAmount = (self.billAmount * self.tipPercent / 100) + self.billAmount;
    
    float splitValueTwo = self.totalAmount / 2;
    float splitValueThree = self.totalAmount / 3;
    float splitValueFour = self.totalAmount / 4;
    
    // NSLog(@"text field: %@, bill amount: %f, total amount: %f", self.billAmountTextField.text, self.billAmount, self.totalAmount);

    // Update total amount label
    NSString *formattedTotalAmount = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:self.totalAmount]];
    self.totalAmountLabel.text = formattedTotalAmount;
    
    // Update split amount labels
    NSString *formattedSplitAmount = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:splitValueTwo]];
    self.splitLabelPeopleTwo.text = formattedSplitAmount;
    formattedSplitAmount = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:splitValueThree]];
    self.splitLabelPeopleThree.text = formattedSplitAmount;
    formattedSplitAmount = [self.currencyFormatter stringFromNumber:[NSNumber numberWithFloat:splitValueFour]];
    self.splitLabelPeopleFour.text = formattedSplitAmount;
    
    // Update percent label
    NSString *percentAmount = [NSString stringWithFormat:@"%d%%", self.tipPercent];
    self.percentLabel.text = percentAmount;
}

- (void)displayCalculation
{
    self.totalAmountView.hidden = NO;
    self.percentLabel.hidden = NO;
    self.splitAmountView.hidden = NO;

    [self updateBillAmountViewColor:YES];
    
    [UIView animateWithDuration:0.4
         animations:^{
             self.billAmountTextField.frame = self.billAmountSmallFrame;
             self.percentLabel.alpha = 1.0;
             self.percentLabel.frame = self.percentAmountVisible;
             self.totalAmountView.frame = self.totalViewVisibleFrame;
         } completion:^(BOOL finished) {
             // done
         }];
}

- (void)hideCalculation
{
    [UIView animateWithDuration:0.4
         animations:^{
             self.billAmountTextField.frame = self.billAmountFullFrame;
             self.percentLabel.alpha = 0.0;
             self.percentLabel.frame = self.percentAmountHidden;
             self.totalAmountView.frame = self.totalViewHiddenFrame;
         } completion:^(BOOL finished) {
             self.totalAmountView.hidden = YES;
             self.percentLabel.hidden = YES;
             self.splitAmountView.hidden = YES;
         }];
}

- (void)percentShowLarge
{
    [UIView animateWithDuration:0.4
         animations:^{
             self.percentLabel.transform = CGAffineTransformScale(self.percentLabel.transform, 4, 4);
             self.percentLabel.frame = self.percentAmountActive;
             self.billAmountTextField.alpha = 0.0;
         } completion:^(BOOL finished) {
             //
         }];
}

- (void)percentReturnNormal
{
    [UIView animateWithDuration:0.4
         animations:^{
             self.percentLabel.transform = CGAffineTransformIdentity;
             self.percentLabel.frame = self.percentAmountVisible;
             self.billAmountTextField.alpha = 1.0;
         } completion:^(BOOL finished) {
             //
         }];
}


- (void)constrainTipPercentToSettings
{
    if (self.tipPercent < self.tipPercentMin) {
        self.tipPercent = self.tipPercentMin;
    }
    if (self.tipPercent > self.tipPercentMax) {
        self.tipPercent = self.tipPercentMax;
    }
}

- (void)onSettingsButton
{
    [self.navigationController pushViewController:[[SettingsViewController alloc] init] animated:YES];
    [self.view endEditing:YES];  // hide keypad to avoid it popping back on without animation
    
}

- (void)updateBillAmountViewColor:(BOOL)animated;
{
    float hueHigh = 0.333;
    float hueLow = 0;
    float viewBgColorHueValue;
    
    viewBgColorHueValue = ((hueHigh - hueLow) / (self.tipPercentMax - self.tipPercentMin)) * (self.tipPercent - self.tipPercentMin) + hueLow;
    
    self.billAmountViewColor = [UIColor colorWithHue:viewBgColorHueValue
                                 saturation:self.viewBgColorSaturationValue
                                 brightness:self.viewBgColorBrightnessValue
                                      alpha:1.0];

    if (animated) {
    [UIView animateWithDuration:0.4
         animations:^{
             self.view.backgroundColor = self.billAmountViewColor;
         }];
    } else {
        self.view.backgroundColor = self.billAmountViewColor;
    }
}

- (void)clearBillAmountViewColor
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.view.backgroundColor = self.billAmountViewColorDefault;
                     }];
}

- (void)setDarkModeAttributes
{
    self.billAmountViewColorDefault = [UIColor blackColor];
    self.billAmountTextField.textColor = [UIColor whiteColor];
    self.billAmountTextField.tintColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.billAmountTextField.attributedPlaceholder = [[NSAttributedString alloc]
                                                      initWithString:[self.currencyFormatter currencySymbol]
                                                      attributes:@{NSForegroundColorAttributeName:
                                                                       [UIColor colorWithWhite:1 alpha:0.3]}];
    self.billAmountTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    
    self.percentLabel.textColor = [UIColor whiteColor];
    
    self.totalAmountView.backgroundColor = [UIColor blackColor];
    self.totalAmountLabel.textColor = [UIColor whiteColor];

    self.splitAmountView.backgroundColor = [UIColor blackColor];
    self.splitLabelPeopleTwo.textColor = [UIColor whiteColor];
    self.splitLabelPeopleThree.textColor = [UIColor whiteColor];
    self.splitLabelPeopleFour.textColor = [UIColor whiteColor];
    self.splitIconLabelPeopleTwo.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.splitIconLabelPeopleThree.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.splitIconLabelPeopleFour.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    
    self.viewBgColorBrightnessValue = 0.3;
    self.viewBgColorSaturationValue = 0.4;
    
    NSDictionary *settingsTitleProperties = @{
                                              NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:22],
                                              NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.3]
                                              };
    [self.settingsBarButtonItem setTitleTextAttributes:settingsTitleProperties forState:UIControlStateNormal];
    
    // Make status bar white text on black
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

- (void)setLightModeAttributes
{
    self.billAmountViewColorDefault = [UIColor whiteColor];
    self.billAmountTextField.textColor = [UIColor blackColor];
    self.billAmountTextField.tintColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.billAmountTextField.attributedPlaceholder = [[NSAttributedString alloc]
                                                      initWithString:[self.currencyFormatter currencySymbol]
                                                      attributes:@{NSForegroundColorAttributeName:
                                                                       [UIColor colorWithWhite:0 alpha:0.2]}];
    self.billAmountTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    
    self.percentLabel.textColor = [UIColor blackColor];
    
    self.totalAmountView.backgroundColor = [UIColor whiteColor];
    self.totalAmountLabel.textColor = [UIColor blackColor];
    
    self.splitAmountView.backgroundColor = [UIColor whiteColor];
    self.splitLabelPeopleTwo.textColor = [UIColor blackColor];
    self.splitLabelPeopleThree.textColor = [UIColor blackColor];
    self.splitLabelPeopleFour.textColor = [UIColor blackColor];
    self.splitIconLabelPeopleTwo.textColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.splitIconLabelPeopleThree.textColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.splitIconLabelPeopleFour.textColor = [UIColor colorWithWhite:0 alpha:0.7];
    
    self.viewBgColorBrightnessValue = 1.0;
    self.viewBgColorSaturationValue = 0.3;
    
    NSDictionary *settingsTitleProperties = @{
                                              NSFontAttributeName: [UIFont fontWithName:kFontAwesomeFamilyName size:22],
                                              NSForegroundColorAttributeName: [UIColor colorWithWhite:0 alpha:0.2]
                                              };
    [self.settingsBarButtonItem setTitleTextAttributes:settingsTitleProperties forState:UIControlStateNormal];
    
    // Return status bar to default
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
