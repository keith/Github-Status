//
//  KSAppDelegate.m
//  Github Status
//
//  Created by Keith Smiley on 12/10/12.
//  Copyright (c) 2012 Keith Smiley. All rights reserved.
//

#import "KSAppDelegate.h"
#import "KSConstants.h"

#import "AFNetworking.h"
#import "Reachability.h"
#import "MPLoginItems/MPLoginItems.h"

@implementation KSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    [[NSUserDefaults standardUserDefaults] setBool:[MPLoginItems loginItemExists:bundleURL] forKey:openAtLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self checkStatus];
}

- (void)awakeFromNib
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setImage:[self normalStatusImageHighlighted:NO]];
    [self.statusItem setAlternateImage:[self normalStatusImageHighlighted:YES]];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setTarget:self];
    
    [self setupMenu];
    [self.statusItem setMenu:self.statusMenu];
}

- (NSImage *)normalStatusImageHighlighted:(BOOL)highlighted
{
    NSString *iconKey = @"\U0000f09b";
    return [self imageWithUnicodeString:iconKey isHightlighted:highlighted];
}

- (NSImage *)warningStatusImageHighlighted:(BOOL)highlighted
{
    NSString *iconKey = @"\U0000f071";
    return [self imageWithUnicodeString:iconKey isHightlighted:highlighted];
}

- (NSImage *)imageWithUnicodeString:(NSString *)unicode isHightlighted:(BOOL)hightlighted
{
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    NSFont *fontAwesome = [NSFont fontWithName:@"FontAwesome" size:thickness - 1];
    NSColor *textColor = hightlighted ? [NSColor whiteColor] : [NSColor blackColor];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];

    NSDictionary *attributes = @{NSFontAttributeName : fontAwesome, NSForegroundColorAttributeName : textColor, NSParagraphStyleAttributeName : style};
    
    NSSize imageSize = NSMakeSize(thickness, thickness);
    NSImage *image = [[NSImage alloc] initWithSize:imageSize];
    [image lockFocus];
    [unicode drawInRect:NSMakeRect(0, 1, imageSize.width, imageSize.height) withAttributes:attributes];
    [image unlockFocus];
    return image;
}

- (void)setupMenu
{
    if (!self.statusMenu) {
        self.statusMenu = [[NSMenu alloc] init];
        [self.statusMenu addItemWithTitle:@"About Github Status" action:@selector(showAbout) keyEquivalent:@""];
        [self.statusMenu addItemWithTitle:@"Refresh" action:@selector(checkStatus) keyEquivalent:@""];
    }
    
    if (!self.lastChecked) {
        self.lastChecked = [[NSMenuItem alloc] init];
        [self.lastChecked setHidden:YES];
        [self.statusMenu addItem:self.lastChecked];
    }
    
    if (!self.separatorItem) {
        self.separatorItem = [NSMenuItem separatorItem];
        [self.separatorItem setHidden:YES];
        [self.statusMenu addItem:self.separatorItem];
    }
    
    if (!self.githubStatusItem) {
        self.githubStatusItem = [[NSMenuItem alloc] init];
        [self.githubStatusItem setHidden:YES];
        [self.statusMenu addItem:self.githubStatusItem];
    }
    
    if (!self.githubMessageItem) {
        self.githubMessageItem = [[NSMenuItem alloc] init];
        [self.githubMessageItem setHidden:YES];
        [self.statusMenu addItem:self.githubMessageItem];
    }
    
    if (!self.githubUpdatedDate) {
        self.githubUpdatedDate = [[NSMenuItem alloc] init];
        [self.githubUpdatedDate setHidden:YES];
        [self.statusMenu addItem:self.githubUpdatedDate];
    }
    
    
    
    if (!self.loginItem) {
        [self.statusMenu addItem:[NSMenuItem separatorItem]];
        
        self.loginItem = [[NSMenuItem alloc] initWithTitle:@"Open at Login" action:@selector(setOpenAtLogin) keyEquivalent:@""];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:openAtLogin]) {
            [self.loginItem setState:NSOnState];
        }
        [self.statusMenu addItem:self.loginItem];
    }
    
    if (!self.quitItem) {
        self.quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit Github Status" action:@selector(terminate:) keyEquivalent:@""];
        [self.statusMenu addItem:self.quitItem];
    }
}

- (void)checkStatus
{
    
    if (![Reachability reachabilityWithHostname:kGithubReachabilityString].isReachable)
    {
        Reachability *reach = [Reachability reachabilityWithHostname:kGithubMainAPIString];
        
        [reach setReachableBlock:^(Reachability *reachability) {
            [self checkStatus];
        }];
        
        [reach setUnreachableBlock:^(Reachability *reachability) {
            // Set github down/network fail
        }];
        
        [reach startNotifier];
    }
    
    [self setupMenu];

    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:kGithubAPIURLString]];

    NSURLRequest *request = [client requestWithMethod:@"GET" path:kGithubMainAPIString parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        NSLog(@"%@", JSON);
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [dateFormatter setDateStyle:NSDateFormatterNoStyle];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        
        [self.lastChecked setTitle:[NSString stringWithFormat:@"Last Checked: %@", [dateFormatter stringFromDate:[NSDate date]]]];
        [self.lastChecked setHidden:NO];

        if ([JSON valueForKey:kGithubStatusKey]) {
            [self.githubStatusItem setTitle:[JSON valueForKey:kGithubStatusKey]];
            [self.githubStatusItem setHidden:NO];
            [self.separatorItem setHidden:NO];
            
            if ([[JSON valueForKey:kGithubStatusKey] isEqualToString:kGithubNormalStatus]) {
                [self setNormalIcons];
            } else {
                [self setErrorIcons];
            }
        } else {
            [self.githubStatusItem setHidden:YES];
        }
        
        if ([JSON valueForKey:kGithubMessageKey]) {
            [self.githubMessageItem setTitle:[JSON valueForKey:kGithubMessageKey]];
            [self.githubMessageItem setHidden:NO];
            [self.separatorItem setHidden:NO];
        } else {
            [self.githubMessageItem setHidden:YES];
        }
        
        if ([JSON valueForKey:kGithubDateKey]) {
            NSString *dateString = [JSON valueForKey:kGithubDateKey];
            NSDate *githubUpdateDate = [NSDate dateWithNaturalLanguageString:[JSON valueForKey:kGithubDateKey]];
            if (githubUpdateDate) {
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                dateString = [dateFormatter stringFromDate:githubUpdateDate];
            }

            [self.githubUpdatedDate setTitle:[NSString stringWithFormat:@"Updated %@", dateString]];
            [self.githubUpdatedDate setHidden:NO];
            [self.separatorItem setHidden:NO];
        } else {
            [self.githubUpdatedDate setHidden:YES];
        }
        
        if (self.githubStatusItem.isHidden && self.githubMessageItem.isHidden && self.githubUpdatedDate.isHidden) {
            [self.separatorItem setHidden:YES];
        }
        
        [self.statusMenu update];
        [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(checkStatus) userInfo:nil repeats:NO];
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        NSLog(@"%@ %@", JSON, error);
    }];
    
    [operation start];
}

- (void)setOpenAtLogin
{
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    if (self.loginItem.state == NSOnState) {
        if ([MPLoginItems loginItemExists:bundleURL]) {
            [MPLoginItems removeLoginItemWithURL:bundleURL];
        }
        
        if ([MPLoginItems loginItemExists:bundleURL]) {
            [[NSAlert alertWithMessageText:@"Github Status"
                            defaultButton:nil
                          alternateButton:nil
                              otherButton:nil
                informativeTextWithFormat:@"Failed to remove Github status from your login items. You can remove it manually in System Preferences -> Users & Groups -> Login Items"] runModal];
        } else {
            [self.loginItem setState:NSOffState];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:openAtLogin];
        }
    } else {
        if (![MPLoginItems loginItemExists:bundleURL]) {
            [MPLoginItems addLoginItemWithURL:bundleURL];
        }
        
        if ([MPLoginItems loginItemExists:bundleURL]) {
            [self.loginItem setState:NSOnState];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:openAtLogin];
        } else {
            [[NSAlert alertWithMessageText:@"Github Status"
                             defaultButton:nil
                           alternateButton:nil
                               otherButton:nil
                 informativeTextWithFormat:@"Failed to add Github status from your login items. You can add it manually in System Preferences -> Users & Groups -> Login Items"] runModal];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setNormalIcons
{
    [self.statusItem setImage:[self normalStatusImageHighlighted:NO]];
    [self.statusItem setAlternateImage:[self normalStatusImageHighlighted:YES]];
}

- (void)setErrorIcons
{
    [self.statusItem setImage:[self warningStatusImageHighlighted:NO]];
    [self.statusItem setAlternateImage:[self warningStatusImageHighlighted:YES]];
}

- (void)showAbout
{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:self];
}

@end
