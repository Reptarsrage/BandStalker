//
//  AppDelegate.m
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () {
@private SpotifyManager *sharedManager;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // set minimum time to inbetween background tasks
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:600.0]; // 10min
    
    sharedManager = [SpotifyManager sharedManager];
    while (![sharedManager login]) {
        NSLog(@"Login failure. Retrying...");
    }
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (sharedManager.newItems) {
        UITabBarController *tbc = (UITabBarController *)self.window.rootViewController;
        UITabBarItem *tbi = (UITabBarItem*)[[[tbc tabBar] items] objectAtIndex:1];
        [tbi setBadgeValue:@"New"];
        sharedManager.newItems = NO;
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // can last at most 30sec
    sharedManager = [SpotifyManager sharedManager];
    [sharedManager makeBackGroundRequest:10 withCompletionHandler:completionHandler];
}

@end
