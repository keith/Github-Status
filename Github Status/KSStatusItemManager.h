//
//  KSStatusItemManager.h
//  Github Status
//
//  Created by Keith Smiley on 7/18/14.
//  Copyright (c) 2014 Keith Smiley. All rights reserved.
//

@interface KSStatusItemManager : NSObject

- (void)setStatusItemMenu:(NSMenu *)menu;
- (void)useNormalImage;
- (void)useWarningImage;
- (void)removeStatusItem;

@end
