//
//  NSUserNotificationCenter+KSNotifications.h
//  Github Status
//
//  Created by Keith Smiley on 7/18/14.
//  Copyright (c) 2014 Keith Smiley. All rights reserved.
//

@interface NSUserNotificationCenter (KSNotifications)

- (void)ks_deliverNotificationWithText:(NSString *)text;

@end
