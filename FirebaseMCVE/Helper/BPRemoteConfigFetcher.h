//
//  BPRemoteConfigFetcher.h
//  FirebaseMCVE
//
//  Created by Johnny on 2019/10/10.
//  Copyright © 2019 BusPlus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FirebaseRemoteConfig/FirebaseRemoteConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface BPRemoteConfigFetcher : NSObject
+ (instancetype)shared;
- (void)fetch;
- (void)fetchWithCompletionBlock:(void(^)(BOOL complete, FIRRemoteConfig *config))completionBlock;

@property (nonatomic, copy, readonly) NSString *tabExperimentGroup;
@property (nonatomic, assign, readonly) BOOL shouldInvolveTabExperiment;
@end

NS_ASSUME_NONNULL_END
