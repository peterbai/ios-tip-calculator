//
//  SettingsViewController.m
//  ios-tip-2
//
//  Created by Peter Bai on 12/31/14.
//  Copyright (c) 2014 Peter Bai. All rights reserved.
//

#import "SettingsViewController.h"


@interface SettingsViewController()

@property (nonatomic) int tipPercentDefault;
@property (nonatomic) int tipPercentMin;
@property (nonatomic) int tipPercentMax;
@property (nonatomic) BOOL darkMode;
@property (nonatomic) NSUserDefaults *userDefaults;

- (void)percentDefaultTextFieldDidFinishEditing:(UITextField *)textField;
- (void)percentMinTextFieldDidFinishEditing:(UITextField *)textField;
- (void)percentMaxTextFieldDidFinishEditing:(UITextField *)textField;
- (void)themeSwitchDidChange:(id)sender;
- (void)onSettingsPageTapped;
- (void)validateInput:(NSString *)inputType :(int)value;
- (void)saveToSettings;

@end

@implementation SettingsViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.tableView.scrollEnabled = NO;
        
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Settings";
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Load settings
    self.userDefaults = [NSUserDefaults standardUserDefaults];

    // Populate text fields with existing settings
    self.tipPercentDefault = [self.userDefaults integerForKey:@"percentAmountDefault"];
    self.tipPercentMin = [self.userDefaults integerForKey:@"percentAmountMin"];
    self.tipPercentMax = [self.userDefaults integerForKey:@"percentAmountMax"];
    self.darkMode = [self.userDefaults boolForKey:@"darkMode"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // Recognize taps on settings page
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSettingsPageTapped)];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Tip Percentage";
    } else if (section == 1) {
        return @"Appearance";
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create an instance of UITableViewCell with default appearance
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];

    // Reload from settings
    self.tipPercentDefault = [self.userDefaults integerForKey:@"percentAmountDefault"];
    self.tipPercentMin = [self.userDefaults integerForKey:@"percentAmountMin"];
    self.tipPercentMax = [self.userDefaults integerForKey:@"percentAmountMax"];
    
    // Set cell content
    if ([indexPath section] == 0) {
        // Create a textfield for user input
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(180, 5, 120, 35)];
        textField.adjustsFontSizeToFitWidth = YES;
        textField.placeholder = @"%";
        textField.textAlignment = NSTextAlignmentRight;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.delegate = self;
        [cell.contentView addSubview:textField];

        // Set each cell's unique label and text field
        switch ([indexPath row]) {
            case 0:
                [cell.textLabel setText:@"Default"];
                textField.text = [NSString stringWithFormat:@"%d", self.tipPercentDefault];
                [textField addTarget:self
                              action:@selector(percentDefaultTextFieldDidFinishEditing:)
                    forControlEvents:UIControlEventEditingDidEnd];
                break;
            case 1:
                [cell.textLabel setText:@"Minimum"];
                textField.text = [NSString stringWithFormat:@"%d", self.tipPercentMin];
                [textField addTarget:self
                              action:@selector(percentMinTextFieldDidFinishEditing:)
                    forControlEvents:UIControlEventEditingDidEnd];
                break;
                break;
            case 2:
                [cell.textLabel setText:@"Maximum"];
                textField.text = [NSString stringWithFormat:@"%d", self.tipPercentMax];
                [textField addTarget:self
                              action:@selector(percentMaxTextFieldDidFinishEditing:)
                    forControlEvents:UIControlEventEditingDidEnd];
                break;
            default:
                break;
        }
    } else if ([indexPath section] == 1) {
        if ([indexPath row] == 0) {
            [cell.textLabel setText:@"Dark Theme"];
            
            // Create a switch for changing themes
            UISwitch *themeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(254, 6, 0, 0)];
            themeSwitch.on = self.darkMode;
            [themeSwitch addTarget:self
                            action:@selector(themeSwitchDidChange:)
                  forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:themeSwitch];
        }
    }

    // Disable cell selection
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

- (void)percentDefaultTextFieldDidFinishEditing:(UITextField *)textField
{
    int percentDefaultValue = [textField.text intValue];
    [self validateInput:@"default" :percentDefaultValue];
}

- (void)percentMinTextFieldDidFinishEditing:(UITextField *)textField
{
    int percentMinValue = [textField.text intValue];
    [self validateInput:@"min" :percentMinValue];
}

- (void)percentMaxTextFieldDidFinishEditing:(UITextField *)textField
{
    int percentMaxValue = [textField.text intValue];
    [self validateInput:@"max" :percentMaxValue];
}

- (void)themeSwitchDidChange:(id)sender {
    if([sender isOn]) {
        self.darkMode = YES;
    } else {
        self.darkMode = NO;
    }
    [self saveToSettings];
}

- (void)onSettingsPageTapped
{
    [self.view endEditing:YES];
}

- (void)validateInput:(NSString *)inputType :(int)value
{
    if ([inputType isEqualToString:@"default"]) {
        NSLog(@"input type default: %d", value);

        self.tipPercentDefault = value;
        if (value > self.tipPercentMax) {
            self.tipPercentMax = value;
        }
        if (value < self.tipPercentMin) {
            self.tipPercentMin = value;
        }

    } else if ([inputType isEqualToString:@"min"]) {
        NSLog(@"input type min: %d", value);
        
        self.tipPercentMin = value;
        if (value > self.tipPercentDefault) {
            self.tipPercentDefault = value;
        }
        if (value > self.tipPercentMax - 10) {
            self.tipPercentMax = value + 10;
        }

    } else {
        NSLog(@"input type max: %d", value);
        
        if (value < 10) {
            value = 10;
        }
        
        self.tipPercentMax = value;
        if (value < self.tipPercentMin + 10) {
            self.tipPercentMin = value - 10;
        }
        if (value < self.tipPercentDefault) {
            self.tipPercentDefault = value;
        }
    }
    [self saveToSettings];
    [self.tableView reloadData];
}

- (void)saveToSettings
{
    [self.userDefaults setInteger:self.tipPercentDefault forKey:@"percentAmountDefault"];
    [self.userDefaults setInteger:self.tipPercentMin forKey:@"percentAmountMin"];
    [self.userDefaults setInteger:self.tipPercentMax forKey:@"percentAmountMax"];
    [self.userDefaults setBool:self.darkMode forKey:@"darkMode"];
}

@end
