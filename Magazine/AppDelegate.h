//
//  AppDelegate.h
//  Magazine
//
//  Created by Myongsok Kim on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebPageController;
@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{
    UIWindow * window;
    
    IBOutlet UITabBarController * storeBarController;
    WebPageController * webPageController;
}

@property (retain, nonatomic) UIWindow * window;
@property (retain, nonatomic) IBOutlet UITabBarController *storeBarController;

- (void)initUI;
- (void)registerDeviceForPushNotification;
@end
