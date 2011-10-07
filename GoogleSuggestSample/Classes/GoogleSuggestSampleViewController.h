//
//  GoogleSuggestSampleViewController.h
//  GoogleSuggestSample
//
//  Created by takeuchi on 11/08/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuggestTableView.h"

@interface GoogleSuggestSampleViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
	SuggestTableView *suggestTableView;
	NSMutableArray *dataSouce;
	NSURLConnection *suggestConnection;
	NSMutableData *async_data;
	UISearchBar *searchBar;
}

@property (nonatomic, retain) NSMutableArray *dataSouce;

- (NSString *)encodeURIComponent:(NSString* )s;
- (void)reloadTableView;

@end

