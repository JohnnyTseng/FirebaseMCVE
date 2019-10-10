//
//  AppDelegate.m
//  FirebaseMCVE
//
//  Created by Johnny on 2019/10/10.
//  Copyright © 2019 BusPlus. All rights reserved.
//

#import "AppDelegate.h"
#import "BPRemoteConfigFetcher.h"
#import <Firebase.h>

@interface AppDelegate ()

@end

NSString *const BPFirstLaunchAppKey = @"tw.firebase.mcve.first-launch";

@implementation AppDelegate

#pragma mark -
#pragma mark Life Cycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupSDKs];
    return YES;
}

#pragma mark -
#pragma mark Convenience

- (void)setupSDKs
{
    if (!FIRApp.defaultApp) {
        [FIRApp configure];
    }
    
    // We only want new users to participate the experiment, so we set a property for users who first launched their App.
    // This line in my App has existed for a long long long time, I can ensure that this line won't be executed
    // when really old version app users upgdate to this version.
    if (![NSUserDefaults.standardUserDefaults boolForKey:BPFirstLaunchAppKey]) {
        [FIRAnalytics setUserPropertyString:@"true" forName:@"mcve_experiment_users"];
        [NSUserDefaults.standardUserDefaults setBool:YES forKey:BPFirstLaunchAppKey];
    }
    
    [BPRemoteConfigFetcher.shared fetch];
    
    [FIRInstanceID.instanceID instanceIDWithHandler:^(FIRInstanceIDResult * _Nullable result,
                                                        NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"[Firebase-Debug] Error fetching remote instance ID: %@", error);
        } else {
            NSLog(@"[Firebase-Debug] Remote instance ID token: %@", result.token);
        }
    }];
}

@end
