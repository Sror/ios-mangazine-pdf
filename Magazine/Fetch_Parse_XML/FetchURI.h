/*
 
    FetchURI.h have been created for Forex Yellow Pages project in 02/14/2012 by Myongsok Kim
    
    Modified on 08/21/2012 by Myongsok Kim
    
    
 
 */


#import <Foundation/Foundation.h>


@class FetchURI;
@protocol FetchDelegate <NSObject>
@optional
- (void)fetchDidFinished:(FetchURI *)fetch;
- (void)fetchDidFailed:(FetchURI *)fetch;
- (void)fetchDid:(FetchURI *)fetch WithPercent:(float)fPercent;
@end

enum FETCH_STATUS
{
    FETCH_STATUS_READY          = 0,
    FETCH_STATUS_SUCCESS,
    FETCH_STATUS_FETCHING,
    FETCH_STATUS_FAIL,
};

@interface FetchURI : NSObject 
{
    //  Represent FetchURI`s status
    enum
    FETCH_STATUS        status;
    
    //  Before fetch, check LocalStorage and return if exist. 
    //  After  fetched, store onto LocalStorage.
    //  Default is YES
    BOOL                bCache;
    
    //  Represent progress of fetching.
    float               fPercent;
    
    NSString *          fetchURL;
    id<FetchDelegate>   delegate;
    NSMutableData *     fetchData;
    NSURLConnection *   curConnection;
    
    NSUInteger  nTotalBytes;
    NSUInteger  nReceivedBytes;
    
    NSInteger       identifier;
    id              userData;    
    
    
    
    //  Added for pause/resume of downloading
    BOOL            bFileDownload;
    NSFileHandle *  fileHandle;
    NSString *      fileName;
}

@property (assign) enum FETCH_STATUS  status;
@property (assign) BOOL               bCache;
@property (assign) float              fPercent;
@property (assign) id<FetchDelegate>  delegate;
@property (retain) NSString *         fetchURL;
@property (assign) BOOL               bFileDownload;
@property (assign) BOOL               bAllowResume;
@property (retain) NSFileHandle *     fileHandle;

@property (assign) NSInteger  identifier;
@property (retain) id         userData;


#pragma mark - 
#pragma mark Life Cycle
- (id)initWithURL:(NSString *)url delegate:(id<FetchDelegate>)dgt;
+ (id)fetchWithURL:(NSString *)url delegate:(id<FetchDelegate>)dgt;


/*  
    The downloaded data is stored in a file on temp folder.
    
        url:    url to download
        dgt:    delegate for receiving notifications in downloading
allowResume:    if file exists on temp folder, resume the downloading to continue and data is appended to next of the end of the file.
 
 */
+ (id)fetchFileWithURL:(NSString *)url delegate:(id<FetchDelegate>)dgt allowResume:(BOOL)bAllow;

#pragma mark -
#pragma mark Public Method
+ (void)removeAllCache;
- (void)removeTempFile;
- (BOOL)startFetch;
- (void)stopFetch;

#pragma mark -
#pragma mark Access Fetched Data
- (NSString *)getString;
- (NSData *)getData;
- (NSString *)getFile;
@end
