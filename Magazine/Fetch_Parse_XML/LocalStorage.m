//
//  LocalStorage.m
//  Forex Yellow Pages
//
//  Created by Myongsok Kim on 2/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "LocalStorage.h"

#define CACHE_FOLDER    @"eAIPTemp"
#define CACHE_NUMBER    200


@implementation LocalStorage

static LocalStorage * shareObject = nil;

+ (LocalStorage *)shareLocalStorage
{
    if( shareObject == nil )
    {
        shareObject = [[LocalStorage alloc] init];
    }
    return shareObject;
}

+ (NSString *)cachePath
{
    NSArray * searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if( searchPath == nil || [searchPath count] == 0 )
        return nil;
    
    NSString * documentDirectory = [searchPath objectAtIndex:0];
    NSString * retPath = [documentDirectory stringByAppendingPathComponent:CACHE_FOLDER];

    return retPath;
}

- (id)init
{
    self = [super init];
    if( self )
    {
        folderPath = [[self class] cachePath];
        if( folderPath == nil )
        {
            cacheList = nil;
        }
        else
        {
            
            cacheList = [[NSMutableArray alloc] init];                
            
            NSFileManager * defaultManager = [NSFileManager defaultManager];
            
            if( [defaultManager fileExistsAtPath:folderPath isDirectory:nil] == NO )
            {
                // if cache folder does not exists.
                NSError * err;
                if( [defaultManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&err] && (err == nil) )
                {
                    [folderPath retain];
                }
                else
                    folderPath = nil;
                
            }
            else
            {
                // if cache folder already exist.
                [folderPath retain];
                
                NSDirectoryEnumerator * fileEnum = [defaultManager enumeratorAtPath:folderPath];
                
                if( fileEnum != nil )
                {
                    NSString * strCachedFile;
                    
                    while( (strCachedFile = [fileEnum nextObject]) )
                    {
                        NSString * strCachedFilePath = [folderPath stringByAppendingPathComponent:strCachedFile];
                        
                        [defaultManager removeItemAtPath:strCachedFilePath error:nil];
                    }
                }
                
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [folderPath release];
    [cacheList release];
    [super dealloc];
}


/*  캐쉬된 파일의 경로를 귀환한다. 
 NSString * url : 캐쉬파일의 식별문자렬 - 보통 url사용.
 귀환값: 파일의 경로. 
        식별자에 해당한 캐쉬파일이 없으면 nil 귀환.
 */
- (NSString *)cachedFile:(NSString *)url
{
    
@synchronized( self )
{
   
    if( folderPath == nil )
        return  nil;
    
    NSString * filePath = nil;
    NSString * cachedFileName = [self hashString:url];
    if( cachedFileName )
    {
        NSDictionary * theDic;
        NSString * theStr;
        for( NSUInteger i = 0 ; i < [cacheList count] ; i++ )
        {
            theDic = [cacheList objectAtIndex:i];
            theStr = [theDic objectForKey:@"PATH"];
            
            if( [cachedFileName compare:theStr] == NSOrderedSame )
            {
                    // if file exists in cache list
                NSNumber * numOfReference = [theDic objectForKey:@"REFE"];
                NSInteger intOfReferenct = 0;
                // increase reference count
                if( numOfReference )
                    intOfReferenct = [numOfReference integerValue] + 1;
                // replace with new 
                theDic = [NSDictionary dictionaryWithObjectsAndKeys:cachedFileName, @"PATH", [NSNumber numberWithInteger:intOfReferenct], @"REFE", nil];
                [cacheList replaceObjectAtIndex:i withObject:theDic];
                
                filePath = [folderPath stringByAppendingPathComponent:cachedFileName];
                break;
            }
        }
    }
    return filePath;
}
    
}

/*  data 를 캐쉬하고 그 결과를 귀환한다.
 NSString * url : 캐쉬파일의 식별문자렬 - 보통 url사용.
 귀환값: 파일의 경로. 
 */
- (BOOL)cache:(NSString *)url with:(NSData *)data
{
    
@synchronized( self )
{
    if( folderPath == nil )
        return NO;

    BOOL bRet = NO;
    NSString * cachedFileName = [self hashString:url];
    if( cachedFileName )
    {
        NSDictionary * theDic;
        NSString * theStr;
        NSNumber * theNum;
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * filePath = [folderPath stringByAppendingPathComponent:cachedFileName];        
        NSInteger min = 100000, minIndex = 0;
        
        for( NSUInteger i = 0 ; i < [cacheList count] ; i++ )
        {
            theDic = [cacheList objectAtIndex:i];
            theStr = [theDic objectForKey:@"PATH"];
            theNum = [theDic objectForKey:@"REFE"];
            
            if( [theNum integerValue] < min )
            {
                min = [theNum integerValue];
                minIndex = i;
            }
            
            if( [cachedFileName compare:theStr] == NSOrderedSame )
            {
                if( data )
                {
                    NSError * err;
                    [fileManager removeItemAtPath:filePath error:&err];
                    if( [data writeToFile:filePath options:NSDataWritingAtomic error:&err] )
                        bRet = YES;
                }
                break;
            }
        }
        
        if( bRet == NO )
        {
            theDic = [NSDictionary dictionaryWithObjectsAndKeys:cachedFileName, @"PATH", [NSNumber numberWithInteger:1], @"REFE", nil];
            if( data )
            {
                NSError * err;
                if( [data writeToFile:filePath options:NSDataWritingAtomic error:&err] )
                    bRet = YES;
            }
            if( [cacheList count] < CACHE_NUMBER )
            {
                [cacheList addObject:theDic];
            }
            else
            {
                NSDictionary * minDic = [cacheList objectAtIndex:minIndex];
                NSString * minPath = [minDic objectForKey:@"PATH"];
                if( minPath )
                {
                    [fileManager removeItemAtPath:minPath error:nil];
                }
                [cacheList replaceObjectAtIndex:minIndex withObject:theDic];
            }
        }
    }
    return bRet;
    
}
    
}

- (void)removeAllCached
{
    
@synchronized( self )
{
    if( folderPath == nil )
        return;
    
    NSDictionary * theDic;
    NSString * theStr;
    NSString * filePath;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    for( NSInteger i = [cacheList count] - 1 ; i >= 0 ; i-- )
    {
        theDic = [cacheList objectAtIndex:i];
        theStr = [theDic objectForKey:@"PATH"];
        
        if( theStr )
        {
            filePath = [folderPath stringByAppendingPathComponent:theStr];
            [fileManager removeItemAtPath:filePath error:nil];
        }
        [cacheList removeLastObject];
    }
}
    
}

/*  Create simple Hash code and return to String    */
- (NSString *)hashString:(NSString *)str
{
    if( str == nil || [str length] == 0 )
        return nil;
    
    const char * cstr = [str UTF8String];
    
    int hashValue = 0x0;
    int index;
    
    int * cstrPos = (int *)cstr;
    int seed;
    
    for( index = 0 ; index < strlen(cstr) / 4 ; index++ )
    {
        seed = *cstrPos;
        hashValue ^= seed;
        cstrPos++;
    }
    
    int restDigit = strlen(cstr) % 4;
    if( restDigit > 0 )
    {
        seed = *cstrPos;
        
        seed &= ( 0xFFFFFFFF >> (( 4 - restDigit ) * 8) );
        
        hashValue ^= seed;
    }

    NSString * hashStr = [NSString stringWithFormat:@"%08X", hashValue];
    
    return hashStr;
}

@end
