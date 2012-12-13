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
    // Setup NSUserDefaults
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Preferences" ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    [[NSUserDefaults standardUserDefaults] setBool:[MPLoginItems loginItemExists:bundleURL] forKey:openAtLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Check status on launch
    self.githubIsUp = YES;
    [self checkStatus];
}

- (void)awakeFromNib
{
    // Add the status item with normal images
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self setNormalIcons];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setTarget:self];
    
    [self setupMenu];
    [self.statusItem setMenu:self.statusMenu];
}

- (void)checkStatus
{
    // Make sure status.github.com is reachable
    if (![Reachability reachabilityWithHostname:kGithubReachabilityString].isReachable)
    {
        [self deliverGithubIsUnreachableNotification];
        [self setErrorIcons];
        [self setLastCheckedStringWithDate:[NSDate date]];
        [self setMenuWithStatus:GITHUB_UNREACHABLE message:nil dateString:nil];
        
        self.githubIsUp = false;

        Reachability *reach = [Reachability reachabilityWithHostname:kGithubMainAPIString];
        
        [reach setReachableBlock:^(Reachability *reachability) {
            [self checkStatus];
        }];
        
        [reach startNotifier];
        
        return;
    }

    // Run GET request from status.github.com
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:kGithubAPIURLString]];
    NSURLRequest *request = [client requestWithMethod:@"GET" path:kGithubMainAPIString parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        [self setLastCheckedStringWithDate:[NSDate date]];

        // Attempt to make a prettier date from the returned date and update the menu items
        if ([JSON valueForKey:kGithubDateKey]) {
            NSString *dateString = [JSON valueForKey:kGithubDateKey];
            NSDate *githubUpdateDate = [NSDate dateWithNaturalLanguageString:[JSON valueForKey:kGithubDateKey]];
            if (githubUpdateDate) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dateFormatter setLocale:[NSLocale currentLocale]];
                dateString = [dateFormatter stringFromDate:githubUpdateDate];
            }

            [self setMenuWithStatus:[JSON valueForKey:kGithubStatusKey]
                            message:[JSON valueForKey:kGithubMessageKey]
                         dateString:[NSString stringWithFormat:@"Updated: %@", dateString]];
        } else {
            [self setMenuWithStatus:[JSON valueForKey:kGithubStatusKey] message:[JSON valueForKey:kGithubMessageKey] dateString:nil];
        }
        
        
        // Change the icon and present notifications based on the previous status
        BOOL githubWasUp = self.githubIsUp;
        
        if ([[JSON valueForKey:kGithubStatusKey] isEqualToString:kGithubNormalStatus]) {
            [self setNormalIcons];
            self.githubIsUp = true;
        } else {
            [self setErrorIcons];
            self.githubIsUp = false;
        }
        
        if (githubWasUp && !self.githubIsUp) {
            [self deliverGithubIsDownNotification];
        } else if (!githubWasUp && self.githubIsUp) {
            [self deliverGithubIsBackNotification];
        }
        
        if (self.githubIsUp) {
            [self runTimerWithTimeInterval:[[[NSUserDefaults standardUserDefaults] objectForKey:refreshInterval] intValue]];
        } else {
            [self runTimerWithTimeInterval:[[[NSUserDefaults standardUserDefaults] objectForKey:downRefreshInterval] intValue]];
        }
        
    }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        // When the request fails, display the error in the menu item
        [self setLastCheckedStringWithDate:[NSDate date]];
        [self setErrorIcons];
        [self.separatorItem setHidden:NO];
        [self setMenuWithStatus:@"Error checking status" message:[error localizedDescription] dateString:nil];
        
        [self setErrorIcons];
        if (self.githubIsUp) {
            [self deliverGithubIsUnreachableNotification];
        }
        
        self.githubIsUp = false;
        
        [self runTimerWithTimeInterval:[[[NSUserDefaults standardUserDefaults] objectForKey:downRefreshInterval] intValue]];
    }];
    
    [operation start];
}

- (void)runTimerWithTimeInterval:(NSTimeInterval)interval
{
    [NSTimer scheduledTimerWithTimeInterval:interval
                                     target:self
                                   selector:@selector(checkStatus)
                                   userInfo:nil
                                    repeats:NO];
}

#pragma mark - Menu configuration

- (void)setupMenu
{
    if (!self.statusMenu) {
        self.statusMenu = [[NSMenu alloc] init];
        [self.statusMenu addItemWithTitle:@"About Github Status" action:@selector(showAbout) keyEquivalent:@""];
        [self.statusMenu addItemWithTitle:@"Refresh" action:@selector(checkStatus) keyEquivalent:@"r"];
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

- (void)setMenuWithStatus:(NSString *)status message:(NSString *)message dateString:(NSString *)dateString
{
    if (status) {
        [self.githubStatusItem setTitle:status];
        [self.githubStatusItem setHidden:NO];
        [self.separatorItem setHidden:NO];
    } else {
        [self.githubStatusItem setHidden:YES];
    }
    
    if (message) {
        [self.githubMessageItem setTitle:message];
        [self.githubMessageItem setHidden:NO];
        [self.separatorItem setHidden:NO];
    } else {
        [self.githubMessageItem setHidden:YES];
    }
    
    if (dateString) {
        [self.githubUpdatedDate setTitle:dateString];
        [self.githubUpdatedDate setHidden:NO];
        [self.separatorItem setHidden:NO];
    } else {
        [self.githubUpdatedDate setHidden:YES];
    }

    if (self.githubStatusItem.isHidden && self.githubMessageItem.isHidden && self.githubUpdatedDate.isHidden) {
        [self.separatorItem setHidden:YES];
    }
    
    [self.statusMenu update];
}

- (void)setLastCheckedStringWithDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [self.lastChecked setTitle:[NSString stringWithFormat:@"Last Checked: %@", [dateFormatter stringFromDate:date]]];
    [self.lastChecked setHidden:NO];
}


#pragma mark - Status item helper methods

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


#pragma mark - User Notifications

- (void)deliverGithubIsBackNotification
{
    [self deliverUserNotificationWithText:@"Github is back online!"];
}

- (void)deliverGithubIsUnreachableNotification
{
    [self deliverUserNotificationWithText:GITHUB_UNREACHABLE];
}

- (void)deliverGithubIsDownNotification
{
    [self deliverUserNotificationWithText:@"Github is down :("];
}

- (void)deliverUserNotificationWithText:(NSString *)text
{
    if (NSClassFromString(@"NSUserNotificationCenter")) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:@"Github Status"];
        [notification setInformativeText:text];
        
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center removeAllDeliveredNotifications];
        [center deliverNotification:notification];
    }
}


#pragma mark - Helper methods

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

- (void)showAbout
{
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:self];
}

- (void)dealloc {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

@end
