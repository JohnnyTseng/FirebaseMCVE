//
//  BPRemoteConfigFetcher.m
//  BusPlus
//
//  Created by Johnny on 2018/9/2.
//  Copyright © 2018 Johnny Tseng. All rights reserved.
//

#import "BPRemoteConfigFetcher.h"
#import <Firebase/Firebase.h>
#import <FirebaseRemoteConfig/FirebaseRemoteConfig.h>

@interface BPRemoteConfigFetcher ()
@property (nonatomic ,strong) FIRRemoteConfig *config;
@property (nonatomic, assign, readwrite) BOOL shouldInvolveTabExperiment;
@end

NSString *const BPTabExperimentCacheKey = @"busplus.FirebaseMCVE.tab-experiment.cache";
NSString *const ABTestingVarientControlKey = @"control";
NSString *const ABTestingVarientTreatmentKey = @"treatment";

@implementation BPRemoteConfigFetcher

#pragma mark -
#pragma mark Initializations

+ (instancetype)shared
{
    static dispatch_once_t once;
    static BPRemoteConfigFetcher *shared = nil;
    dispatch_once(&once, ^{
        shared = [[BPRemoteConfigFetcher alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!FIRApp.defaultApp) {
            [FIRApp configure];
        }
        self.config = FIRRemoteConfig.remoteConfig;
        // Read cached remote config value from disk.
        self.shouldInvolveTabExperiment = [NSUserDefaults.standardUserDefaults boolForKey:BPTabExperimentCacheKey];
        
        FIRRemoteConfigSettings *settings = [[FIRRemoteConfigSettings alloc] init];
        settings.minimumFetchInterval = 0;
        self.config.configSettings = settings;
    }
    return self;
}

#pragma mark -
#pragma mark Public

- (void)fetchWithCompletionBlock:(void (^)(BOOL, FIRRemoteConfig *))completionBlock
{
    [self.config
     fetchAndActivateWithCompletionHandler:^(FIRRemoteConfigFetchAndActivateStatus status, NSError * _Nullable error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (error) {
                return;
            }
            FIRRemoteConfigValue *configValue = [self.config configValueForKey:@"firebase_mcve_experiment_key"];
            _shouldInvolveTabExperiment = [configValue.stringValue isEqualToString:ABTestingVarientTreatmentKey];
            _tabExperimentGroup = configValue.stringValue;
            
            NSLog(@"----------- Config Value: %@", configValue.stringValue);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSUserDefaults.standardUserDefaults setBool:self.shouldInvolveTabExperiment forKey:BPTabExperimentCacheKey];
                if (completionBlock) {
                    completionBlock(YES, self.config);
                }
            });
        });
    }];
}

- (void)fetch
{
    [self fetchWithCompletionBlock:NULL];
}

@end
