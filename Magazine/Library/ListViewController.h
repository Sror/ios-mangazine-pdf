//
//  ListViewController.h
//  Magazine
//
//  Created by Myongsok Kim on 9/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * arrBooks;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentSort;

- (IBAction)onSort:(id)sender;
@end
