//
//  KidsIQ6AppDelegate.h
//  KidsIQ6
//
//  Created by Chan Komagan on 10/21/12.
//  Copyright (c) 2012 Chan Komagan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class SLViewController;

@interface KidsIQ6AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SLViewController *viewController;
-(BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;

@end
