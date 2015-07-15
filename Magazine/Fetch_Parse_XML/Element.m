/*
 
    Element.m have been created for Forex Yellow Pages by Myongsok Kim  on 02/15/2012
 
    Modified by Myongsok Kim on 08/22/2012
        - Add new method( getValueOfTag )
 
 */

#import "Element.h"


@implementation Element

@synthesize tag;
@synthesize val;

@synthesize attr;
@synthesize chld;

- (id)init
{
    self = [super init];
    if( self )
    {
        tag = nil;
        val = nil;
        
        attr = nil;
        chld = nil;
    }
    return self;
}

- (void)dealloc
{
    [tag release];
    [val release];
    [attr release];
    [chld release];
    
    [super dealloc];
}

//  Return val according to sTag in child elements.
- (NSString *)getValueOfTag:(NSString *)sTag
{
    if( chld == nil || sTag == nil )
        return nil;
    
    for( NSUInteger i = 0 ; i < [chld count] ; i++ )
    {
        Element * theChildElement = [chld objectAtIndex:i];
        
        if( [theChildElement.tag isEqualToString:sTag] )
        {
            return theChildElement.val;
        }
    }
    
    return nil;
}


@end
