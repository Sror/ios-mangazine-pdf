/*
 
    FetchURI.m have been created for Forex Yellow Pages project in 2/14/2012 by Myongsok Kim
 
    Modified on 2012.08.21 by Myongsok Kim 
    Modified on 2012.09.07 by Myongsok Kim for pause/resume of downloading
 
 */


#import "FetchURI.h"
#import "LocalStorage.h"

#define TEMP_FOLDER             @"tmpfetch"

@interface FetchURI ( Private )
- (void)callDelegateFinished:(NSTimer *)timer;
- (NSString *)tempFolder;
- (NSString *)makeHashStringFromText:(NSString *)plain;
@end

static int ConnectCount = 0;

@implementation FetchURI

@synthesize status;
@synthesize bCache;
@synthesize fPercent;
@synthesize fetchURL;
@synthesize delegate;
@synthesize bFileDownload;
@synthesize bAllowResume;
@synthesize fileHandle;

@synthesize identifier;
@synthesize userData;

#pragma mark -
- (id)init
{
    self = [super init];
    
    if( self )
    {
        bCache      = YES;
        fetchURL    = nil;
        fPercent    = 0.0;
        fetchURL    = nil;
        
        userData    = nil;
        identifier  = 0;
        
        bFileDownload = NO;
        bAllowResume  = NO;
        fileHandle    = nil;
        fileName      = nil;
    }
    
    return self;
}

- (id)initWithURL:(NSString *)url delegate:(id<FetchDelegate>)dgt
{
    self = [super init];
    
    if( self )
    {
        bCache      = YES;
        fetchData   = nil;
        fPercent    = 0.0;
        fetchURL    = [[NSString alloc] initWithString:url];
        delegate    = dgt;
        
        userData    = nil;
        identifier  = 0;
        
        bFileDownload = NO;
        bAllowResume  = NO;
        fileHandle    = nil;
        fileName      = nil;
    }
    
    return self;
}

- (void)dealloc
{
    
    if( status == FETCH_STATUS_FETCHING )
        [self stopFetch];
        
    [fetchURL release];
    [fetchData release];
    [fileHandle release];
    [userData release];
    [fileName release];
    
    [super dealloc];
}

+ (id)fetchWithURL:(NSString *)url delegate:(id<FetchDelegate>)dgt
{
    FetchURI * fetchURL = [[[FetchURI alloc] initWithURL:url delegate:dgt] autorelease];
    
    return fetchURL;
}

+ (id)fetchFileWithURL:(NSString *)url delegate:(id<FetchDelegate>)dgt allowResume:(BOOL)bAllow
{
    FetchURI * fetchURL = [[FetchURI alloc] initWithURL:url delegate:dgt];
    fetchURL.bCache        = NO;
    fetchURL.bFileDownload = YES;
    fetchURL.bAllowResume  = bAllow;
    
    return fetchURL;
}

#pragma mark -
#pragma mark Public Method
+ (void)removeAllCache
{
    [[LocalStorage shareLocalStorage] removeAllCached];
}


- (void)removeTempFile
{
    if( bFileDownload )
    {
        if( fileHandle != nil )
        {
            [fileHandle closeFile];
            self.fileHandle = nil;
        }
 
        if( fileName == nil )
            fileName = [[self makeHashStringFromText:fetchURL] retain];
        NSString * filePath = [[self tempFolder] stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];        
    }
}

- (BOOL)startFetch
{
    BOOL bRet = NO;    

    do
    {
        if( fetchURL == nil )
            break;
        
        if( self.status == FETCH_STATUS_FETCHING )
            break;        
        
        if( bCache )
        {
            // Check if the url content exists in local storage.
            NSString * cachedFile = [[LocalStorage shareLocalStorage] cachedFile:fetchURL];
            
            if( cachedFile != nil )
            {
                fetchData = [[NSMutableData alloc] initWithContentsOfFile:cachedFile];
                
                self.status = FETCH_STATUS_SUCCESS;
                
                if( delegate != nil )
                {
                    if( [delegate respondsToSelector:@selector(fetchDidFinished:)] )
                        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(callDelegateFinished:) userInfo:nil repeats:NO];
                }

                bRet = YES;
                
                break;
            }
        }
        
        // Create the request.
        NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:fetchURL]
                                                                cachePolicy:bFileDownload ? NSURLRequestReloadIgnoringCacheData : NSURLRequestUseProtocolCachePolicy
                                                     timeoutInterval:60.0];        
        
        
        
        if( bFileDownload )
        {
            fileName = [[self makeHashStringFromText:fetchURL] retain];
            NSString * filePath = [[self tempFolder] stringByAppendingPathComponent:fileName];
            NSError * error = nil;            
            NSFileManager * fm = [NSFileManager defaultManager];
            if( [fm fileExistsAtPath:filePath] )
            {
                if( bAllowResume )
                {
                    NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filePath error:&error];                
                    
                    if( (error == nil ) && fileDictionary )
                    {
                        nReceivedBytes = [fileDictionary fileSize];
                    }
                    
                    if( nReceivedBytes > 0 )
                    {
                        NSString * requestRange = [NSString stringWithFormat:@"bytes=%d-", nReceivedBytes];
                        [theRequest setValue:requestRange forHTTPHeaderField:@"Range"];
                    }
                    
                }
            }
            else
            {
                [fm createFileAtPath:filePath contents:nil attributes:nil];
            }
            
        }
        else
        {
            // Create the NSMutableData to hold the received data.
            // receivedData is an instance variable declared elsewhere.
            if( fetchData != nil )
                [fetchData release];
            
            fetchData = [[NSMutableData data] retain];                    
        }
        
        // create the connection with the request
        // and start loading the data
        curConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if(curConnection)
        {
            self.status = FETCH_STATUS_FETCHING;
            
            bRet = YES;
            
            if( ConnectCount == 0 )
            {
                UIApplication * app = [UIApplication sharedApplication];
                app.networkActivityIndicatorVisible = YES;        
            }
            ConnectCount++;
        }
        
    }while( 0 );
    
    return bRet;

}

- (void)stopFetch
{
    ConnectCount--;
    if( ConnectCount == 0 )
    {
        UIApplication * app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
        
    if( curConnection != nil )
    {
        [curConnection cancel];
        [curConnection release];
        curConnection = nil;
    }
    
    if( fetchData != nil )
    {
        [fetchData release];
        fetchData = nil;
    }
        
    if( bFileDownload )
    {
        [fileHandle closeFile];
        self.fileHandle = nil;
    }
    
    status = FETCH_STATUS_READY;    
}

- (void)callDelegateFinished:(NSTimer *)timer
{
    [delegate fetchDidFinished:self];
}

- (NSString *)tempFolder
{
    NSArray * searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if( searchPath == nil || [searchPath count] == 0 )
        return nil;
    
    NSString * documentDirectory = [searchPath objectAtIndex:0];
    NSString * retPath = [documentDirectory stringByAppendingPathComponent:TEMP_FOLDER];
    
    if( [[NSFileManager defaultManager] fileExistsAtPath:retPath] == NO )
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:retPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    
    return retPath;
}

- (NSString *)makeHashStringFromText:(NSString *)plain
{
    return [[LocalStorage shareLocalStorage] hashString:plain];
}

#pragma mark - 
#pragma mark Access Fetched Data
- (NSString *)getString
{
    NSString * retString = nil;
    if( self.status == FETCH_STATUS_SUCCESS )
    {
        if( fetchData != nil )
        {
            retString = [[[NSString alloc] initWithData:fetchData encoding:NSUTF8StringEncoding] autorelease];
        }
    }
    return retString;
}

- (NSData *)getData;
{
    if( self.status == FETCH_STATUS_SUCCESS )
    {
        return fetchData;
    }
    return nil;
}

- (NSString *)getFile
{
    if( self.status == FETCH_STATUS_SUCCESS )
    {
        NSString * filePath = [[self tempFolder] stringByAppendingPathComponent:fileName];
        return filePath;
    }
    return nil;
}

#pragma mark -
#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    
    if( bFileDownload )
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]]) 
        {
            // I don't know what kind of request this is!
            return;
        }
        
        NSString * filePath = [[self tempFolder] stringByAppendingPathComponent:fileName];    
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
        self.fileHandle = fh;
        switch (httpResponse.statusCode) 
        {
            case 206: 
            {
                NSString *range = [httpResponse.allHeaderFields valueForKey:@"Content-Range"];
                NSError *error = nil;
                NSRegularExpression *regex = nil;
                
                // Check to see if the server returned a valid byte-range
                regex = [NSRegularExpression regularExpressionWithPattern:@"bytes (\\d+)-\\d+/\\d+"
                                                                  options:NSRegularExpressionCaseInsensitive
                                                                    error:&error];
                if (error) 
                {
                    [fh truncateFileAtOffset:0];
                    break;
                }
                
                // If the regex didn't match the number of bytes, start the download from the beginning
                NSTextCheckingResult *match = [regex firstMatchInString:range
                                                                options:NSMatchingAnchored
                                                                  range:NSMakeRange(0, range.length)];
                if (match.numberOfRanges < 2) 
                {
                    [fh truncateFileAtOffset:0];
                    break;
                }
                
                // Extract the byte offset the server reported to us, and truncate our
                // file if it is starting us at "0". Otherwise, seek our file to the
                // appropriate offset.
                NSString *byteStr = [range substringWithRange:[match rangeAtIndex:1]];
                NSInteger bytes = [byteStr integerValue];
                if (bytes <= 0) 
                {
                    [fh truncateFileAtOffset:0];
                    break;
                }
                else
                {
                    [fh seekToFileOffset:bytes];
                }
                break;
            }
                
            default:
                [fh truncateFileAtOffset:0];
                break;
        }        
    }
    else
    {
        // fetchData is an instance variable declared elsewhere.
        [fetchData setLength:0];
        nReceivedBytes = 0;        
    }
    

    
    long long expectedLength = [response expectedContentLength];    
    if( expectedLength < 0 )
        nTotalBytes = nReceivedBytes;
    else
        nTotalBytes = expectedLength + nReceivedBytes;
    


    
    if( nTotalBytes == 0 )
        fPercent = 0;
    else
        fPercent = (float)nReceivedBytes / (float)expectedLength;
    

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to fetchData.
    // fetchData is an instance variable declared elsewhere.
    if( bFileDownload )
    {
        [self.fileHandle writeData:data];
        [self.fileHandle synchronizeFile];        
    }
    else
        [fetchData appendData:data];
    
    
    
    nReceivedBytes += [data length];

    if( delegate == nil || nTotalBytes == 0 )
        return;    
    
    fPercent = (float)nReceivedBytes / (float)nTotalBytes;
    
    if( [delegate respondsToSelector:@selector(fetchDid:WithPercent:)] )
        [delegate fetchDid:self WithPercent:fPercent];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    ConnectCount--;
    
    if( ConnectCount == 0 )
    {
        UIApplication * app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
    
    // release the connection, and the data object
    [connection release];
    curConnection = nil;

    
    
    
    
    if( bFileDownload )
    {
        [fileHandle closeFile];
        self.fileHandle = nil;
    }
    else
    {
        // fetchData is declared as a method instance elsewhere
        [fetchData release];
        fetchData = nil;
    }
    
    
    
    
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    self.status = FETCH_STATUS_FAIL;
    
    if( delegate != nil )
    {
        if( [delegate respondsToSelector:@selector(fetchDidFailed:)] )
            [delegate fetchDidFailed:self];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    ConnectCount--;
    
    if( ConnectCount == 0 )
    {
        UIApplication * app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = NO;
    }
    
    
    
    if( bFileDownload )
    {
        [fileHandle closeFile];
        self.fileHandle = nil;
    }
    

    
    // do something with the data
    // fetchData is declared as a method instance elsewhere
    
    // release the connection, and the data object
    [connection release];
    curConnection = nil;
    
    self.status = FETCH_STATUS_SUCCESS;
    
    /////////////////////////Cache////////////////////////////////////
    if( bCache )
        [[LocalStorage shareLocalStorage] cache:fetchURL with:fetchData];
    //////////////////////////////////////////////////////////////////
    
    
    if( delegate != nil )
    {
        if( [delegate respondsToSelector:@selector(fetchDidFinished:)] )
            [delegate fetchDidFinished:self];
    }
    
}

@end
