//
//  RatingView.h
//  Magazine
//
//  Created by Myongsok Kim on 10/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RatingView : UIView
{
    UIImage * imageStarFull;
    UIImage * imageStarEmpty;
    
    NSInteger nRate;
    
    id         target;
    SEL        action;
}
@property ( nonatomic, assign ) NSInteger   nRate;
@property ( nonatomic, assign ) id          target;
@property ( nonatomic, assign ) SEL         action;

- (void)initMembers;


@end
