//
//  KSConstants.h
//  Github Status
//
//  Created by Keith Smiley on 12/10/12.
//  Copyright (c) 2012 Keith Smiley. All rights reserved.
//

#import <Foundation/Foundation.h>

// Preferences
FOUNDATION_EXPORT NSString * const openAtLogin;
FOUNDATION_EXPORT NSString * const refreshInterval;
FOUNDATION_EXPORT NSString * const downRefreshInterval;

// Github strings
FOUNDATION_EXPORT NSString * const kGithubAPIURLString;
FOUNDATION_EXPORT NSString * const kGithubReachabilityString;
FOUNDATION_EXPORT NSString * const kGithubMainAPIString;
FOUNDATION_EXPORT NSString * const kGithubStatusKey;
FOUNDATION_EXPORT NSString * const kGithubMessageKey;
FOUNDATION_EXPORT NSString * const kGithubDateKey;

FOUNDATION_EXPORT NSString * const kGithubNormalStatus;

// User strings
FOUNDATION_EXPORT NSString * const GITHUB_UNREACHABLE;

@interface KSConstants : NSObject
@end
