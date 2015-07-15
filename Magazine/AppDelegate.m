//
//  AppDelegate.m
//  Magazine
//
//  Created by Myongsok Kim on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "AppConstants.h"
#import "Library.h"
#import "IssueFactory.h"

//  iPhone
#import "SeriesViewController.h"
#import "FeaturedViewController.h"
#import "BrowseViewController.h"
#import "SearchViewController.h"
#import "WebPageController.h"

//  iPad
#import "SeriesViewController_iPad.h"
#import "FeaturedViewController_iPad.h"
#import "BrowseViewController_iPad.h"
#import "SearchViewController_iPad.h"

//  Urban Airship
#import "UAirship.h"
#import "UAPush.h"

@implementation AppDelegate

@synthesize window;
@synthesize storeBarController;

- (void)dealloc
{
    [window release];
    [storeBarController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //  Clear Local Storage
    [FetchURI removeAllCache];
    
    //  Load Library info
    [Library sharedLibrary];

    //  Init Issue Factory
    [IssueFactory sharedFactory];

    //  Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
//    [UAirship takeOff:takeOffOptions];    
    [self registerDeviceForPushNotification];
    
    //  Init UI
    [self initUI];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    DLog(@"OK");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    DLog(@"OK");    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    DLog(@"OK");    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
        
    [[UAPush shared] setBadgeNumber:1];
    [[UAPush shared] resetBadge];
    UIViewController * featuredViewController = [storeBarController.viewControllers objectAtIndex:1];
    featuredViewController.tabBarItem.badgeValue = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPushNotification object:nil];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[Library sharedLibrary] saveLibrary];
    [Library destroyLibrary];
    
    [IssueFactory destroyFactory];
    
    [UAirship land];    
}


// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if( viewController == webPageController )
        [webPageController showAbout:tabBarController.tabBar.selectedItem];
    else
        [webPageController dismissAbout:tabBarController.tabBar.selectedItem];
    
    if( tabBarController.selectedIndex == 1 )
    {
        //  Set badge Counter on Server side to zero
        [[UAPush shared] setBadgeNumber:1];
        [[UAPush shared] resetBadge];
        
        viewController.tabBarItem.badgeValue = nil;
    }
}


/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

- (void)initUI
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Override point for customization after application launch.
    storeBarController = [[UITabBarController alloc] init];    
    storeBarController.delegate = self;
    
    //  Series
    UIViewController * seriesViewController;
    if( USER_DEVICE_IS_PHONE )
        seriesViewController     = [[[SeriesViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    else
        seriesViewController     = [[[SeriesViewController_iPad alloc] initWithNibName:@"SeriesView_iPad" bundle:nil] autorelease];    
    UINavigationController * navSeriesController    = [[[UINavigationController alloc] initWithRootViewController:seriesViewController] autorelease];    
    
    //  Featured
    UIViewController * featuredViewController;
    if( USER_DEVICE_IS_PHONE )
        featuredViewController = [[[FeaturedViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    else
        featuredViewController = [[[FeaturedViewController_iPad alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    UINavigationController * navFeaturedController  = [[[UINavigationController alloc] initWithRootViewController:featuredViewController] autorelease];
    
    //  Browse
    UIViewController * browseViewController;
    if( USER_DEVICE_IS_PHONE )
        browseViewController = [[[BrowseViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    else
        browseViewController = [[[BrowseViewController_iPad alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    UINavigationController * navBrowseController = [[[UINavigationController alloc] initWithRootViewController:browseViewController] autorelease];
    
    
    //  Search
    UIViewController * searchViewController;
    if( USER_DEVICE_IS_PHONE )
        searchViewController = [[[SearchViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    else
        searchViewController = [[[SearchViewController_iPad alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    UINavigationController * navSearchViewController = [[[UINavigationController alloc] initWithRootViewController:searchViewController] autorelease];
    
    
    //  About
    webPageController = [[[WebPageController alloc] initWithNibName:@"WebPage" bundle:nil] autorelease];
    
    storeBarController.viewControllers = [NSArray arrayWithObjects:navFeaturedController, navBrowseController, navSeriesController, navSearchViewController, webPageController, nil];
    
    
    
    //  Series Tab
    navSeriesController.tabBarItem.title = @"Series";
    navSeriesController.tabBarItem.image = [UIImage imageNamed:@"series"];
    
    //  Featuread Tab
    navFeaturedController.tabBarItem.title = @"Featured";
    navFeaturedController.tabBarItem.image = [UIImage imageNamed:@"featured"];
    
    //  Browse Tab
    navBrowseController.tabBarItem.title = @"Browse";
    navBrowseController.tabBarItem.image = [UIImage imageNamed:@"browse"];
    
    //  Search Tab
    navSearchViewController.tabBarItem.title = @"Search";
    navSearchViewController.tabBarItem.image = [UIImage imageNamed:@"search"];
    
    // About Tab
    webPageController.tabBarItem.title = @"About";
    webPageController.tabBarItem.image = [UIImage imageNamed:@"about"];
    
    self.window.rootViewController = self.storeBarController;
    [self.window makeKeyAndVisible];    
}

- (void)registerDeviceForPushNotification
{
    // Register for notifications
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];                    
    [[UAPush shared] setAutobadgeEnabled:YES];        
    [[UAPush shared] setBadgeNumber:1];
    [[UAPush shared] resetBadge];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
    // Updates the device token and registers the token with UA
    NSString *str = [NSString stringWithFormat:@"%@",deviceToken];
    NSString * newDeviceToken = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    newDeviceToken = [newDeviceToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    newDeviceToken = [newDeviceToken stringByReplacingOccurrencesOfString:@">" withString:@""];
    DLog(@"%@", newDeviceToken);

    [[NSUserDefaults standardUserDefaults] setObject:newDeviceToken forKey:kDeviceToken];
    
    
    [[UAPush shared] registerDeviceToken:deviceToken];            
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err 
{
    DLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
    UALOG(@"Received remote notification: %@", userInfo);
    
    NSDictionary * aps = [userInfo objectForKey:@"aps"];
    NSString * alert = [NSString stringWithFormat:@"%@", [aps objectForKey:@"alert"]];
    NSString * badge = [NSString stringWithFormat:@"%@", [aps objectForKey:@"badge"]];

    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Notification" message:alert delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
    [alertView release];
    
    if( storeBarController.selectedIndex != 1 )
    {
        UIViewController * featuredViewController = [storeBarController.viewControllers objectAtIndex:1];
        featuredViewController.tabBarItem.badgeValue = badge;
    }
    else
    {
        //  Set badge Counter on Server side to zero
        [[UAPush shared] setBadgeNumber:1];
        [[UAPush shared] resetBadge];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPushNotification object:nil];
    
}

@end
