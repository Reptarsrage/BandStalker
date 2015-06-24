//
//  AppDelegate.m
//  BandStalker
//
//  Created by Admin on 6/3/15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end
    const NSString *client_id = @"88ac57858a2e451c95cb5334f11686db";
    const NSString * client_secret = @"75a5b55e12b64fd7b82c6870beba34c3";
    long expires;
    NSString *SpotifyAccessToken;
    SPTSession *SpotifySession;

@implementation AppDelegate


- (BOOL)login {
    NSURL *loginUrl = [NSURL URLWithString:@"https://accounts.spotify.com/api/token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginUrl
                                                           cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                       timeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // add the correct headers
    NSString *base_str = [NSString stringWithFormat:@"%@:%@", client_id, client_secret];
    NSData *base_bits = [base_str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encoded_str = [base_bits base64EncodedStringWithOptions:0];
    NSString *header = [NSString stringWithFormat:@"Basic %@", encoded_str];
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    
    // add the body
    NSData *body = [@"grant_type=client_credentials" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *body_length = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:body_length forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:body];
    
    
    
    NSData *urlData;
    NSURLResponse *response;
    NSError *error;
    
    // make synchronous request
    urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"Error logging in: %@",error);
        return NO;
    }
    
    NSMutableDictionary *data = [NSJSONSerialization JSONObjectWithData:urlData
                                                            options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        NSLog(@"Error parsing login response: %@",error);
        return NO;
    }
                                 
    SpotifyAccessToken = [data valueForKey:@"access_token"];
    expires = [[data valueForKey:@"expires_in"] longValue];
    
    if (!SpotifyAccessToken) {
        NSLog(@"Error parsing login response: no token");
        return NO;
    }
    
    if (!expires) {
        NSLog(@"Error parsing login response: no expiration");
        return NO;
    }
    
    SpotifySession = [[SPTSession alloc] initWithUserName:@"reptarsrage" accessToken:SpotifyAccessToken expirationTimeInterval:expires];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    while (![self login]) {
        NSLog(@"Login failure. Retrying...");
    }
    
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
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
