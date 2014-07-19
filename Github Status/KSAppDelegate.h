//
//  KSAppDelegate.h
//  Github Status
//
//  Created by Keith Smiley on 12/10/12.
//  Copyright (c) 2012 Keith Smiley. All rights reserved.
//

@interface KSAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *statusMenu;

@property (nonatomic, strong) NSMenuItem *lastChecked;
@property (nonatomic, strong) NSMenuItem *separatorItem;
@property (nonatomic, strong) NSMenuItem *githubStatusItem;
@property (nonatomic, strong) NSMenuItem *githubMessageItem;
@property (nonatomic, strong) NSMenuItem *githubUpdatedDate;
@property (nonatomic, strong) NSMenuItem *loginItem;
@property (nonatomic, strong) NSMenuItem *quitItem;

@property BOOL githubIsUp;

@end
