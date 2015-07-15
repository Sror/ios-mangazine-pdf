//
//  ParserXML.h
//  Forex Yellow Pages
//
//  Created by Myongsok Kim on 2/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Element.h"

@interface ParserXML : NSObject 
{
    
}

+ (Element *)parse:(NSString *)strXML;

@end
