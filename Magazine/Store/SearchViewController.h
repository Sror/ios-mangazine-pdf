//
//  SearchViewController.h
//  Magazine
//
//  Created by Myongsok Kim on 9/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IssueViewController.h"

@interface SearchViewController : IssueViewController <UISearchBarDelegate>
{    
    UISearchBar * searchBar;
}

@end
