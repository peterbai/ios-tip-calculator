//
//  AppDelegate.m
//  ios-tip-2
//
//  Created by Peter Bai on 12/31/14.
//  Copyright (c) 2014 Peter Bai. All rights reserved.
//

#import "AppDelegate.h"
#import "BillView.h"
#import "TipViewController.h"
#import "SettingsViewController.h"

@interface AppDelegate ()

@property (nonatomic) TipViewController *tipViewController;
@property (nonatomic) NSUserDefaults *userDefaults;

- (void)useLastValues;
- (void)setLastValues;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Initialize main view
    self.tipViewController = [[TipViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:self.tipViewController];
    self.window.rootViewController = nvc;
    
    // Use last values if appropriate
    [self useLastValues];
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
    [self setLastValues];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
}

- (void)useLastValues
{
    // Load previous bill and percent values if app was recently used
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *lastAccessedDate = [self.userDefaults objectForKey:@"last_accessedDate"];
    if (!lastAccessedDate) {
        return;
    }
    
    NSLog(@"Seconds between now and last accessed date: %f", -[lastAccessedDate timeIntervalSinceNow]);
    
    int secondsToHoldValues = 60;
    if (-[lastAccessedDate timeIntervalSinceNow] <= secondsToHoldValues) {
        self.tipViewController.billAmount = [self.userDefaults floatForKey:@"last_billAmount"];
        self.tipViewController.tipPercent = [self.userDefaults integerForKey:@"last_tipPercent"];
    }
}

- (void)setLastValues
{
    // discard bill digits after the 100th decimal place
    float billAmountFloored = floorf(self.tipViewController.billAmount * 100) / 100;
    
    [self.userDefaults setFloat:billAmountFloored forKey:@"last_billAmount"];
    [self.userDefaults setInteger:self.tipViewController.tipPercent forKey:@"last_tipPercent"];
    [self.userDefaults setObject:[NSDate date] forKey:@"last_accessedDate"];
    [self.userDefaults synchronize];
}

@end
