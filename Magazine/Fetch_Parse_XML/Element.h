/*
 
    Element.h have been created for Forex Yellow Pages by Myongsok Kim  on 02/15/2012
 
    Modified by Myongsok Kim on 08/22/2012
        - Add new method( getValueOfTag )
    
 */

#import <Foundation/Foundation.h>

/*
    example : <result>
                <profile>
                        <attribute name="id">12</attribute>
                        <attribute name="key">Forex</attribute>
                </profile>
              </result>
 
 
    rootElement.tag = "result"
    rootElement.val = nil;
    rootElement.attr = nil;
    rootElement.chld = Array( child )
 
    child.tag = "profile"
    child.val = nil;
    child.attr = nil;
    child.chld = Array( childchild1, childchil2 )
 
    childchild1.tag = "attribute"
    childchild1.val = "12"
    childchild1.attribute = Dictionary( "name" => "id" )
    childchild1.chld = nil;

    childchild1.tag = "attribute"
    childchild1.val = "Froex"
    childchild1.attribute = Dictionary( "name" => "key" )
    childchild1.chld = nil; 
 */

@interface Element : NSObject 
{
    NSString * tag;
    NSString * val;

    NSMutableDictionary * attr;
    NSMutableArray * chld;
}

@property (retain) NSString * tag;
@property (retain) NSString * val;

@property (retain) NSMutableDictionary * attr;
@property (retain) NSMutableArray * chld;


//  Return val according to sTag in child elements.
- (NSString *)getValueOfTag:(NSString *)sTag;

@end
