//
//  BookcaseViewController.h
//  Magazine
//
//  Created by Myongsok Kim on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookcaseViewController : UIViewController
{
    
    IBOutlet UIScrollView *scrollView;
    
    NSMutableDictionary * dicBookViews;

    
    UIColor * colorPortrait;
    UIColor * colorLandscape;
    
    UIImage * imageShelfPortrait;
    UIImage * imageShelfLandscape;
    
    NSMutableArray * shelfImageViews;
}

- (void)loadBooks;
- (void)editBooks:(BOOL)enable;
- (void)clickBook:(NSString *)sIssueId;

@end
