//
//  KSAppDelegate.m
//  Github Status
//
//  Created by Keith Smiley on 12/10/12.
//  Copyright (c) 2012 Keith Smiley. All rights reserved.
//

#import <KSGithubStatusAPI/KSGithubStatusAPI.h>
#import <KSGithubStatusAPI/KSGithubStatus.h>
#import "KSAppDelegate.h"
#import "KSMenuManager.h"
#import "KSStatusItemManager.h"
#import "NSUserNotificationCenter+KSNotifications.h"

@interface KSAppDelegate ()

@property (nonatomic) KSStatusItemManager *statusManager;
@property (nonatomic) KSMenuManager *menuManager;
@property (nonatomic) KSGithubStatusAPI *statusAPI;

@property (nonatomic) NSInteger interval;
@property (nonatomic) NSInteger downInterval;
@property (nonatomic) BOOL lastAvailability;

@end

@implementation KSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Preferences" ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    self.lastAvailability = YES;
    [self refreshStatus];
    [self runRefreshTimerWithInterval:self.interval];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self.statusManager removeStatusItem];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)runRefreshTimerWithInterval:(NSInteger)interval
{
    [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:self
                                   selector:@selector(refreshStatus)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)awakeFromNib
{
    [self.statusManager setStatusItemMenu:self.menuManager.menu];
}

- (void)refreshStatus
{
    [self.statusAPI checkStatus:^(KSGithubStatus *status) {
        [self refreshedWithStatus:status];
    }];
}

- (void)refreshedWithStatus:(KSGithubStatus *)status
{
    [self.menuManager setLastCheckedReadableDateString:status.readableCreatedAtDate];
    [self.menuManager setGithubStatusString:status.status];
    [self.menuManager setGithubMessageString:status.details];
    [self.menuManager setGithubUpdatedAtDateString:status.readableGithubUpdatedDate];

    [self setStatusIconWithAvailable:status.isAvailable];
    [self sendNotificationWithStatus:status];

    NSInteger interval = self.interval;
    if (!status.isAvailable) {
        interval = self.downInterval;
    }

    [self runRefreshTimerWithInterval:interval];
}

- (void)setStatusIconWithAvailable:(BOOL)available
{
    if (available) {
        [self.statusManager useNormalImage];
    } else {
        [self.statusManager useWarningImage];
    }
}

- (void)sendNotificationWithStatus:(KSGithubStatus *)status
{
    if (self.lastAvailability == status.isAvailable) {
        return;
    }

    if (status.isAvailable) {
        [[NSUserNotificationCenter defaultUserNotificationCenter]
         ks_deliverNotificationWithText:@"Github is back online!"];
    } else {
        if (status.currentState == KSGithubStatusUnreachable) {
            [[NSUserNotificationCenter defaultUserNotificationCenter]
             ks_deliverNotificationWithText:@"Github is unreachable"];
        } else {
            [[NSUserNotificationCenter defaultUserNotificationCenter]
             ks_deliverNotificationWithText:@"Github is down"];
        }
    }

    self.lastAvailability = status.isAvailable;
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://status.github.com/"]];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#pragma mark - Lazy Accessors

- (KSStatusItemManager *)statusManager
{
    if (!_statusManager) {
        _statusManager = [[KSStatusItemManager alloc] init];
    }

    return _statusManager;
}

- (KSMenuManager *)menuManager
{
    if (!_menuManager) {
        _menuManager = [[KSMenuManager alloc] init];
        [_menuManager setRefreshTarget:self];
        [_menuManager setRefreshSelector:@selector(refreshStatus)];
    }

    return _menuManager;
}

- (KSGithubStatusAPI *)statusAPI
{
    if (!_statusAPI) {
        _statusAPI = [[KSGithubStatusAPI alloc] init];
    }

    return _statusAPI;
}

- (NSInteger)interval
{
    if (!_interval) {
        _interval = [[NSUserDefaults standardUserDefaults] integerForKey:KSGithubStatusRefreshInterval];
    }

    return _interval;
}

- (NSInteger)downInterval
{
    if (!_downInterval) {
        _downInterval = [[NSUserDefaults standardUserDefaults] integerForKey:KSGithubStatusDownRefreshInterval];
    }

    return _downInterval;
}

@end
