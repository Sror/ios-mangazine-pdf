//
//  ParserXML.m
//  Forex Yellow Pages
//
//  Created by Myongsok Kim on 2/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ParserXML.h"
#import "GDataXMLNode.h"

#define PARSED_ELEMENT      @"PARSED"
#define XML_ELEMENT         @"XML"

@interface ParserXML(private)

@end

@implementation ParserXML

+ (Element *)parse:(NSString *)strXML
{
    if( strXML == nil )
        return nil;
    
    NSError * err = nil;
    GDataXMLDocument * doc = [[GDataXMLDocument alloc] initWithXMLString:strXML options:0 error:&err];
    
    if( err != nil || doc == nil )
        return nil;
    
    NSMutableArray * list = [NSMutableArray array];
    
    Element * rootElement = [[[Element alloc] init] autorelease];
    GDataXMLElement * xmlRootElement = [doc rootElement];
    rootElement.tag = [xmlRootElement name];
    
    NSDictionary * listElement = [NSDictionary dictionaryWithObjectsAndKeys:rootElement, PARSED_ELEMENT, xmlRootElement, XML_ELEMENT, nil];
    [list addObject:listElement];
    
    Element * tmpElement;
    GDataXMLElement * tmpXMLElement;
    GDataXMLNode * childElement;
    
    int i;
    
    while( [list count] > 0 )
    {
        listElement = [list objectAtIndex:0];
        
        tmpElement = [listElement objectForKey:PARSED_ELEMENT];
        tmpXMLElement = [listElement objectForKey:XML_ELEMENT];
        
        
        if( (tmpElement != nil) || (tmpXMLElement == nil) )
        {
            tmpElement.tag = [tmpXMLElement name];
            
            if( [tmpXMLElement attributes] != nil )
            {
                tmpElement.attr = [NSMutableDictionary dictionary];
                NSArray * xmlAttributes = [tmpXMLElement attributes];
                for( i = 0 ; i < [xmlAttributes count] ; i++ )
                {
                    GDataXMLNode * theAttribute = [xmlAttributes objectAtIndex:i];
                    NSString * key = [theAttribute name];
                    NSString * val = [theAttribute stringValue];
                    [tmpElement.attr setObject:val forKey:key];
                }
            }
            
            childElement = [tmpXMLElement childAtIndex:0];
            
            if( [[childElement name] compare:@"text"] == NSOrderedSame )
            {
                tmpElement.val = [tmpXMLElement stringValue];                
            }
            else
            {
                for( i = 0 ; i < [[tmpXMLElement children] count] ; i++ )
                {
                    GDataXMLElement * newXMLElement = [[tmpXMLElement children] objectAtIndex:i];
                    Element * newElement = [[[Element alloc] init] autorelease];
                    
                    if( tmpElement.chld == nil )
                        tmpElement.chld = [NSMutableArray array];
                    [tmpElement.chld addObject:newElement];
                    
                    NSDictionary * newListElement = [NSDictionary dictionaryWithObjectsAndKeys:newElement, PARSED_ELEMENT, newXMLElement, XML_ELEMENT, nil];
                    
                    [list addObject:newListElement];
                }
            }                    
        }
        
        
        [list removeObjectAtIndex:0];
    }
    
    [doc release];
    return rootElement;
}

@end
