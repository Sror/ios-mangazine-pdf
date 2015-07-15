//
//  AppConstants.h
//  Magazine
//
//  Created by Myongsok Kim on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define USER_DEVICE_IS_PHONE            ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define USER_DEVICE_IS_PAD              ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)


//client.appandus.com
//cexdev.appandus.com

//  URL
#define STORE_URL_GET_SERIES                    @"http://cexdev.appandus.com/mag/get_series.php"
#define STORE_URL_GET_ISSUES_OF_SERIES_ID       @"http://cexdev.appandus.com/mag/get_issue.php?series_id=%@&sortby=%@&limit_start=%d&limit_dur=%d"
#define STORE_URL_GET_FEATURED_ISSUES           @"http://cexdev.appandus.com/mag/get_issue.php?featured_flg=Y&sortby=%@&limit_start=%d&limit_dur=%d"
#define STORE_URL_GET_SEARCHED_ISSUES           @"http://cexdev.appandus.com/mag/get_issue.php?q=%@&limit_start=%d&limit_dur=%d"
#define STORE_URL_GET_SORTED_ISSUES             @"http://cexdev.appandus.com/mag/get_issue.php?sortby=%@&limit_start=%d&limit_dur=%d"

#define FEEDBACK_URL_DOWNLOADED_ISSUE           @"http://cexdev.appandus.com/mag/add_counter.php?action=DWL&issue_id=%@&device_id=%@"
#define FEEDBACK_URL_DELETED_ISSUE              @"http://cexdev.appandus.com/mag/add_counter.php?action=DLT&issue_id=%@&device_id=%@"
#define FEEDBACK_URL_GIVE_RATING_ISSUE          @"http://cexdev.appandus.com/mag/add_counter.php?action=RAT&issue_id=%@&device_id=%@&rating=%d"


#define ABOUT_URL                               @"http://cexdev.appandus.com/about.htm"
#define ANNOUNCE_URL                            @"http://cexdev.appandus.com/announce.htm"
#define PRICE_URL                               @"http://cexdev.appandus.com/price.htm"

// DLog is almost a drop-in replacement for NSLog
// DLog();
// DLog(@"here");
// DLog(@"value: %d", x);
// Unfortunately this doesn't work DLog(aStringVariable); you have to do this instead DLog(@"%@", aStringVariable);
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif


//  Folder name for downloaded issues
#define PDF_FOLDER                  @"PDF"
#define THUMB_FOLDER                @"THUMB"
#define TEMP_FOLDER                 @"Temp"

//  Library File Name
#define LIBRARY_FILE_NAME           @"library.plist"


#define NUMBER_OF_ISSUES_LOAD_ONCE      12


#define SORT_BY_DOWNLOAD_FIELD        @"download_cnt"
#define SORT_BY_TITLE_FIELD           @"title"
#define SORT_BY_SERIES_FIELD          @""
#define SORT_BY_DATE_FIELD            @"release_dt"

#define NUMBER_OF_ITEMS_ONE_PAGE      6


#define IPAD_LABEL_WIDTH                600
#define IPAD_LABEL_HEIGHT               40
#define IPAD_ISSUE_HEIGHT               120


#define FEATURED_PAGE_ANIMATION_DURATION        4.5
#define FEATURED_PAGE_TOP_IMAGE_WIDTH           200
#define FEATURED_PAGE_TOP_IMAGE_HEIGHT          100


#define kPushNotification                       @"CexMagazineNotification"
#define kDeviceToken                            @"DeviceToken"


#define USER_RATE_ALLOW
