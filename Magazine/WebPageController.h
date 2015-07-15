//
//  WebPageController.h
//  Magazine
//
//  Created by Myongsok Kim on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebPageController : UIViewController <UIActionSheetDelegate>
{
    
    IBOutlet UINavigationItem * titleBar;
    IBOutlet UIWebView *webView;
    
    NSString * sPageTitle;
    
    UIActionSheet * shownActionSheet;
}

@property ( retain ) NSString * sPageTitle;

- (void)showAbout:(id)sender;
- (void)dismissAbout:(id)sender;
- (void)loadPage:(NSString *)sURL;
- (void)onDone:(id)sender;

@end
