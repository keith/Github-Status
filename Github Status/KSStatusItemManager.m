//
//  KSStatusItemManager.m
//  Github Status
//
//  Created by Keith Smiley on 7/18/14.
//  Copyright (c) 2014 Keith Smiley. All rights reserved.
//

#import "KSStatusItemManager.h"

@interface KSStatusItemManager ()

@property (nonatomic) NSImage *normalStatusImage;
@property (nonatomic) NSImage *warningStatusImage;
@property (nonatomic) NSStatusItem *statusItem;

@end

@implementation KSStatusItemManager

- (void)setStatusItemMenu:(NSMenu *)menu
{
    self.statusItem.menu = menu;
}

- (void)useNormalImage
{
    self.statusItem.image = self.normalStatusImage;
}

- (void)useWarningImage
{
    self.statusItem.image = self.warningStatusImage;
}

- (void)removeStatusItem
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

- (NSStatusItem *)statusItem
{
    if (!_statusItem) {
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        _statusItem.highlightMode = YES;
        _statusItem.image = self.normalStatusImage;
//        _statusItem.menu
    }

    return _statusItem;
}

- (NSImage *)normalStatusImage
{
    if (!_normalStatusImage) {
        _normalStatusImage = [NSImage imageNamed:@"octocat"];
        [_normalStatusImage setTemplate:YES];
    }

    return _normalStatusImage;
}

- (NSImage *)warningStatusImage
{
    if (!_warningStatusImage) {
#warning test this
        _warningStatusImage = [NSImage imageNamed:NSImageNameCaution];
        [_warningStatusImage setTemplate:YES];
    }

    return _warningStatusImage;
}

@end
