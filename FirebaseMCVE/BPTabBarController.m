//
//  BPTabBarController.m
//  FirebaseMCVE
//
//  Created by Johnny on 2019/10/10.
//  Copyright © 2019 BusPlus. All rights reserved.
//

#import "BPTabBarController.h"
#import "BPRemoteConfigFetcher.h"

@interface BPTabBarController ()
@end

@implementation BPTabBarController

#pragma mark -
#pragma mark View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTabBars];
    [BPRemoteConfigFetcher.shared fetchWithCompletionBlock:^(BOOL complete, FIRRemoteConfig * _Nonnull config) {
        [self addExperimentTab];
    }];
}

#pragma mark -
#pragma mark Tab Settings

- (void)setupTabBars
{
    self.tabBar.hidden = NO;
    NSMutableArray *names = [NSMutableArray arrayWithArray:@[@"Tab 1", @"Tab 2"]];
    if (BPRemoteConfigFetcher.shared.shouldInvolveTabExperiment) {
        [names addObject:@"Tab 3"];
    }
    
    [self.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *title = [names objectAtIndex:idx];
        obj.title = title;
    }];
}

// Add 3rd tabBar if user has been dispatched to the `treatment` group
- (void)addExperimentTab
{
    if (!BPRemoteConfigFetcher.shared.shouldInvolveTabExperiment) {
        [self setupTabBars];
        return;
    }
    
    // Already added the third tab
    if (self.viewControllers.count >= 3) {
        return;
    }
    
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.viewControllers];
    UIViewController *experimentController = [[UIViewController alloc] init];
    [controllers insertObject:experimentController atIndex:1];
    [self setViewControllers:controllers];
    
    // Must configure tabBar again after adding new viewControllers to tabBarController
    [self setupTabBars];
}

@end
