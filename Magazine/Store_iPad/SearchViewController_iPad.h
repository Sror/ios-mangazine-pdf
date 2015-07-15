//
//  SearchViewController_iPad.h
//  Magazine
//
//  Created by Myongsok Kim on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IssueViewController_iPad.h"

@interface SearchViewController_iPad : IssueViewController_iPad <UISearchBarDelegate>
{
    UISearchBar * searchBar;    
}

@end
