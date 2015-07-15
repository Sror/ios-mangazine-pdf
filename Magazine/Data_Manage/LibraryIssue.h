//
//  LibrayIssue.h
//  Magazine
//
//  Created by Myongsok Kim on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define STATUS_NOTYET                  0
#define STATUS_DOWNLOADING             1
#define STATUS_PAUSED                  2
#define STATUS_READABLE                3

@interface LibraryIssue : NSObject
{
    NSInteger nStatus;
    
    NSString * sFileURL;    
    NSInteger nReadCnt;
    
    NSString * sSeriesId;
    NSString * sSeriesTitle;    
    NSString * sIssueId;
    NSString * sIssueTitle;
    
    NSString * sDate;
    NSString * sPublisher;
    NSString * sPublishedDate;
    
}

@property ( nonatomic, assign ) NSInteger  nStatus;
@property ( nonatomic, retain ) NSString * sFileURL;
@property ( nonatomic, assign ) NSInteger  nReadCnt;
@property ( nonatomic, retain ) NSString * sSeriesId;
@property ( nonatomic, retain ) NSString * sSeriesTitle;
@property ( nonatomic, retain ) NSString * sIssueId;
@property ( nonatomic, retain ) NSString * sIssueTitle;
@property ( nonatomic, retain ) NSString * sDate;
@property ( nonatomic, retain ) NSString * sPublisher;
@property ( nonatomic, retain ) NSString * sPublishedDate;

- (id)initWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)createDictionary;

- (BOOL)setThumbImageWithFile:(NSString *)strPath;
- (BOOL)setThumbImage:(UIImage *)image;
- (BOOL)setPDFFile:(NSString *)strPath;
- (BOOL)setPDFFileWithData:(NSData *)data;

@end
