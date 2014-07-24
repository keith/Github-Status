//
//  KSMenuManager.m
//  Github Status
//
//  Created by Keith Smiley on 7/18/14.
//  Copyright (c) 2014 Keith Smiley. All rights reserved.
//

#import <IYLoginItem/NSBundle+LoginItem.h>
#import "KSMenuManager.h"

// From https://gist.github.com/kyleve/8213806 renamed for collisions
#define KSValidateKeyPath(object, keyPath) ({ if (NO) { (void)((object).keyPath); } @#keyPath; })

@interface KSMenuManager ()

@property (nonatomic) NSMenuItem *aboutMenuItem;
@property (nonatomic) NSMenuItem *refreshMenuItem;
@property (nonatomic) NSMenuItem *lastCheckedMenuItem;
@property (nonatomic) NSMenuItem *lastCheckedSeparatorItem;
@property (nonatomic) NSMenuItem *githubStatusItem;
@property (nonatomic) NSMenuItem *githubMessageItem;
@property (nonatomic) NSMenuItem *githubUpdatedItem;
@property (nonatomic) NSMenuItem *loginItem;
@property (nonatomic) NSMenuItem *quitItem;

@property (nonatomic) BOOL loginItemState;

@end

@implementation KSMenuManager

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

    _loginItemState = [[NSUserDefaults standardUserDefaults] boolForKey:KSGithubStatusOpenAtLogin];

    return self;
}

- (void)openAtLogin:(BOOL)openAtLogin
{
    if (openAtLogin) {
        [[NSBundle mainBundle] addToLoginItems];
    } else {
        [[NSBundle mainBundle] removeFromLoginItems];
    }

    BOOL isLoginItem = [[NSBundle mainBundle] isLoginItem];
    [[NSUserDefaults standardUserDefaults] setBool:isLoginItem forKey:KSGithubStatusOpenAtLogin];
}

- (void)showAboutPanel
{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:self];
}

- (void)setLastCheckedReadableDateString:(NSString *)dateString
{
    NSString *titleString = [NSString stringWithFormat:@"Checked: %@", dateString];
    self.lastCheckedMenuItem.title = titleString;
    [self.lastCheckedMenuItem setHidden:!dateString];
}

- (void)setGithubStatusString:(NSString *)status
{
    self.githubStatusItem.title = status;
    [self.githubStatusItem setHidden:!status];
    [self setupLastCheckedSeparator];
}

- (void)setGithubMessageString:(NSString *)message
{
    BOOL emptyMessage = !message;
    [self.githubMessageItem setHidden:emptyMessage];
    if (emptyMessage) {
        return;
    }
    self.githubMessageItem.title = message;
    [self setupLastCheckedSeparator];
}

- (void)setGithubUpdatedAtDateString:(NSString *)dateString
{
    NSString *titleString = [NSString stringWithFormat:@"Updated: %@", dateString];
    self.githubUpdatedItem.title = titleString;
    [self.githubUpdatedItem setHidden:!dateString];
    [self setupLastCheckedSeparator];
}

- (void)setRefreshTarget:(id)target
{
    self.refreshMenuItem.target = target;
}

- (void)setRefreshSelector:(SEL)selector
{
    self.refreshMenuItem.action = selector;
}

- (void)setupLastCheckedSeparator
{
    BOOL hidden = self.githubStatusItem.isHidden &&
                  self.githubMessageItem.isHidden &&
                  self.githubUpdatedItem.isHidden;
    [self.lastCheckedSeparatorItem setHidden:hidden];
}

#pragma mark - Lazy Accessors

- (NSMenu *)menu
{
    if (!_menu) {
        _menu = [[NSMenu alloc] init];
        [_menu addItem:self.aboutMenuItem];
        [_menu addItem:self.refreshMenuItem];
        [_menu addItem:self.lastCheckedMenuItem];
        [_menu addItem:self.lastCheckedSeparatorItem];
        [_menu addItem:self.githubStatusItem];
        [_menu addItem:self.githubMessageItem];
        [_menu addItem:self.githubUpdatedItem];
        [_menu addItem:[NSMenuItem separatorItem]];
        [_menu addItem:self.loginItem];
        [_menu addItem:self.quitItem];
    }

    return _menu;
}

- (NSMenuItem *)aboutMenuItem
{
    if (!_aboutMenuItem) {
        _aboutMenuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"About Github Status", nil)
                                                    action:@selector(showAboutPanel)
                                             keyEquivalent:@""];
        _aboutMenuItem.target = self;
    }

    return _aboutMenuItem;
}

- (NSMenuItem *)refreshMenuItem
{
    if (!_refreshMenuItem) {
        _refreshMenuItem = [[NSMenuItem alloc] initWithTitle:@"Refresh"
                                                      action:nil
                                               keyEquivalent:@"r"];
    }

    return _refreshMenuItem;
}

- (NSMenuItem *)lastCheckedMenuItem
{
    if (!_lastCheckedMenuItem) {
        _lastCheckedMenuItem = [[NSMenuItem alloc] init];
        [_lastCheckedMenuItem setHidden:YES];
    }

    return _lastCheckedMenuItem;
}

- (NSMenuItem *)lastCheckedSeparatorItem
{
    if (!_lastCheckedSeparatorItem) {
        _lastCheckedSeparatorItem = [NSMenuItem separatorItem];
        [_lastCheckedSeparatorItem setHidden:YES];
    }

    return _lastCheckedSeparatorItem;
}

- (NSMenuItem *)githubStatusItem
{
    if (!_githubStatusItem) {
        _githubStatusItem = [[NSMenuItem alloc] init];
        [_githubStatusItem setHidden:YES];
    }

    return _githubStatusItem;
}

- (NSMenuItem *)githubMessageItem
{
    if (!_githubMessageItem) {
        _githubMessageItem = [[NSMenuItem alloc] init];
        [_githubMessageItem setHidden:YES];
    }

    return _githubMessageItem;
}

- (NSMenuItem *)githubUpdatedItem
{
    if (!_githubUpdatedItem) {
        _githubUpdatedItem = [[NSMenuItem alloc] init];
        [_githubUpdatedItem setHidden:YES];
    }

    return _githubUpdatedItem;
}

- (NSMenuItem *)loginItem
{
    if (!_loginItem) {
        _loginItem = [[NSMenuItem alloc] init];
        _loginItem.title = NSLocalizedString(@"Open at Login", nil);
        [_loginItem bind:KSValidateKeyPath(_loginItem, value)
                toObject:self
             withKeyPath:KSValidateKeyPath(self, loginItemState)
                 options:nil];
    }

    return _loginItem;
}

- (NSMenuItem *)quitItem
{
    if (!_quitItem) {
        _quitItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Quit Github Status", nil)
                                               action:@selector(terminate:)
                                        keyEquivalent:@""];
    }

    return _quitItem;
}

- (void)setLoginItemState:(BOOL)loginItemState
{
    _loginItemState = loginItemState;
    [self openAtLogin:loginItemState];
}

@end
