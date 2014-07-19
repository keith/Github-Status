//
//  KSMenuManager.h
//  Github Status
//
//  Created by Keith Smiley on 7/18/14.
//  Copyright (c) 2014 Keith Smiley. All rights reserved.
//

@interface KSMenuManager : NSObject

@property (nonatomic) NSMenu *menu;

- (void)setLastCheckedReadableDateString:(NSString *)dateString;
- (void)setGithubStatusString:(NSString *)status;
- (void)setGithubMessageString:(NSString *)message;
- (void)setGithubUpdatedAtDateString:(NSString *)dateString;
- (void)setRefreshTarget:(id)target;
- (void)setRefreshSelector:(SEL)selector;

@end
