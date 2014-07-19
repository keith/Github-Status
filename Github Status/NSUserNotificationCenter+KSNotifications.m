//
//  NSUserNotificationCenter+KSNotifications.m
//  Github Status
//
//  Created by Keith Smiley on 7/18/14.
//  Copyright (c) 2014 Keith Smiley. All rights reserved.
//

#import "NSUserNotificationCenter+KSNotifications.h"

@implementation NSUserNotificationCenter (KSNotifications)

- (void)ks_deliverNotificationWithText:(NSString *)text
{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = NSLocalizedString(@"Github Status", nil);
    notification.informativeText = text;

    [self removeAllDeliveredNotifications];
    [self deliverNotification:notification];
}

@end
