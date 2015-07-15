//
//  RatingView.m
//  Magazine
//
//  Created by Myongsok Kim on 10/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RatingView.h"

#define NUMBER_OF_STAR          5
#define STAR_WIDTH              15
#define STAR_HEIGHT             15
#define MARGIN                  5

@interface RatingView ()
- (NSInteger)indexFromPoint:(CGPoint)pos;
@end

@implementation RatingView
@synthesize nRate;
@synthesize target, action;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if( self )
    {
        // Initialization code
        [self initMembers];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if( self )
    {
        [self initMembers];        
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        [self initMembers];        
    }
    
    return self;
}

- (void)initMembers
{
    imageStarFull  = [[UIImage imageNamed:@"star_full.png"] retain];
    imageStarEmpty = [[UIImage imageNamed:@"star_empty.png"] retain];
    self.backgroundColor = [UIColor clearColor];
    
    nRate = 0;
}

- (void)dealloc
{
    [imageStarFull release];
    [imageStarEmpty release];
    [super dealloc];
}

- (void)setNRate:(NSInteger)n
{
    if( nRate != n )
    {
        nRate = n;    
        [self setNeedsDisplay];        
    }   
}

- (void)drawRect:(CGRect)rect
{
    CGRect frame = self.frame;
    
    if( frame.size.width  < NUMBER_OF_STAR * ( STAR_WIDTH + MARGIN ) + MARGIN || 
        frame.size.height < STAR_HEIGHT + MARGIN * 2 )
        return;
    
    NSInteger w = STAR_WIDTH;
    NSInteger h = STAR_HEIGHT;
    NSInteger space_x = (float)( frame.size.width - NUMBER_OF_STAR * STAR_WIDTH ) / (float)( NUMBER_OF_STAR + 1 );
    NSInteger space_y = ( frame.size.height - STAR_HEIGHT ) / 2;
    
        
    CGRect starRect;
    starRect.size.width  = w;
    starRect.size.height = h;
    
    for( NSInteger i = 0 ; i < NUMBER_OF_STAR ; i++ )
    {
        starRect.origin.x = space_x + ( w + space_x ) * i;
        starRect.origin.y = space_y;
        
        
        if( i < nRate )
            [imageStarFull drawInRect:starRect];
        else
            [imageStarEmpty drawInRect:starRect];
    }
}

#pragma mark - Private Method
- (NSInteger)indexFromPoint:(CGPoint)pos
{
    CGRect frame = self.frame;
    
    NSInteger w = STAR_WIDTH;
    //NSInteger h = STAR_HEIGHT;
    NSInteger space_x = (float)( frame.size.width - NUMBER_OF_STAR * STAR_WIDTH ) / (float)( NUMBER_OF_STAR + 1 );
    NSInteger space_y = ( frame.size.height - STAR_HEIGHT ) / 2;


    if( space_y > pos.y || pos.y > space_y + w ||
        space_x > pos.x )
        return 0;
    
    return (float)( pos.x - space_x ) / (float)( w + space_x ) + 1;
    
}

#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    
    self.nRate = [self indexFromPoint:pos];    
    if( (target != nil) && (action != nil) )
    {
        if( [target respondsToSelector:action] )        
            [target performSelector:action withObject:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    
    self.nRate = [self indexFromPoint:pos];    
    if( (target != nil) && (action != nil) )
    {
        if( [target respondsToSelector:action] )        
            [target performSelector:action withObject:self];
    }    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    
    self.nRate = [self indexFromPoint:pos];    
    if( (target != nil) && (action != nil) )
    {
        if( [target respondsToSelector:action] )        
            [target performSelector:action withObject:self];
    }    
}

@end
