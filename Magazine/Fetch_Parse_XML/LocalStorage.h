//
//  LocalStorage.h
//  Forex Yellow Pages
//
//  Created by Myongsok Kim on 2/27/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/*** 도큐멘트 폴더에 캐쉬 폴더를 만들고 제한된 개수의 파일들을 저장관리한다.  ***/

/*** 스레드 safe를 지향했지만 검증이 필요하다.  ***/

@interface LocalStorage : NSObject 
{
    NSString * folderPath;
    NSMutableArray * cacheList;
}

/*  Singleton class method  */
+ (LocalStorage *)shareLocalStorage;

+ (NSString *)cachePath;


/*  캐쉬된 파일의 경로를 귀환한다. 
    NSString * url : 캐쉬파일의 식별문자렬 - 보통 url사용.
    귀환값: 파일의 경로.
 */
- (NSString *)cachedFile:(NSString *)url;

/*  data 를 캐쉬하고 그 결과를 귀환한다.
 NSString * url : 캐쉬파일의 식별문자렬 - 보통 url사용.
 귀환값: 파일의 경로. 
 */
- (BOOL)cache:(NSString *)url with:(NSData *)data;

/*  모들 캐쉬파일들을 지워버린다.
 */
- (void)removeAllCached;


- (NSString *)hashString:(NSString *)str;

@end
