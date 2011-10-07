//
//  GoogleSuggestSampleViewController.m
//  GoogleSuggestSample
//
//  Created by takeuchi on 11/08/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GoogleSuggestSampleViewController.h"
#import "DDXMLDocument.h"
#import "DDXMLElement.h"

@interface GoogleSuggestSampleViewController (Private)
- (NSString *)encodeURIComponent:(NSString* )s;
- (void)reloadTableView;
@end;

@implementation GoogleSuggestSampleViewController

@synthesize dataSouce;

- (void)dealloc {
	[suggestTableView release];
	[dataSouce release];
	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// サーチーバー生成
	searchBar = [[UISearchBar alloc] init];
	searchBar.delegate = self;
	searchBar.showsCancelButton = YES;
	searchBar.placeholder = @"検索ワード";
	searchBar.keyboardType = UIKeyboardTypeDefault;
	searchBar.frame = CGRectMake(0, 0, 320, 50);
	searchBar.barStyle = UIBarStyleBlack;
	[self.view addSubview:searchBar];
	[searchBar release];
	
	// テーブルビュー生成
	suggestTableView = [[SuggestTableView alloc] initWithFrame:CGRectMake(0, searchBar.frame.size.height, 320, self.view.frame.size.height - searchBar.frame.size.height) style:UITableViewStylePlain];
	suggestTableView.dataSource = self;
	suggestTableView.delegate = self;
	suggestTableView.touchSelector = @selector(touchToTableView:);
	suggestTableView.rowHeight = 40;
	suggestTableView.contentMode = UIViewContentModeScaleAspectFill;
	suggestTableView.clipsToBounds = YES;
	suggestTableView.delaysContentTouches = NO; // UIScrollViewのフリック判定の待ち時間を０にする
	[self.view addSubview:suggestTableView];
	[suggestTableView release];
	
	// データソース初期化
	self.dataSouce = [[NSMutableArray alloc] init];
}

- (void)reloadTableView {
	[suggestTableView reloadData];
}


//================
// デリゲート
//================

//--------------------------
// SuggestTableViewDelegate
//--------------------------

- (void)touchToTableView:(SuggestTableView *)_suggestTableView {
	[searchBar resignFirstResponder];
}

//---------------------
// UICearchBarDelegate
//---------------------

// 検索テキストボックス内に変更があったときに呼ばれる
- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)_searchText {
	
	// テキストボックスに入力された内容で、URLを生成
	NSString *url = [[NSString alloc]initWithFormat:@"http://google.co.jp/complete/search?output=toolbar&q=%@&hl=en", [self encodeURIComponent:_searchText]];
	
	// リクエスト
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	// 既に通信中ならキャンセルする。
	if (suggestConnection != nil) {
		[suggestConnection cancel];
	}
	suggestConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
}

// キャンセルボタンを押すと呼ばれる
-(void)searchBarCancelButtonClicked:(UISearchBar*)_searchBar {
	[_searchBar resignFirstResponder];
}

//--------------------------
// NSURLConnectionDelegate
//--------------------------

// ヘッダ受信
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	// データを初期化
	async_data = [[NSMutableData alloc] initWithData:0];
	
}

// ダウンロード中
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	// データを追加する
	[async_data appendData:data];
}

// エラー発生
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//NSString *error_str = [error localizedDescription];
	[suggestConnection release];
	suggestConnection = nil;
	[async_data release];
}

// ダウンロード完了
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	DDXMLDocument *_doc = [[[DDXMLDocument alloc] initWithData:async_data options:0 error:nil] autorelease];
	DDXMLElement *_root = [_doc rootElement];
	NSArray *_titleArray = [_root nodesForXPath:@"/toplevel/CompleteSuggestion/suggestion/@data" error:nil ];
	
	[dataSouce removeAllObjects];
	for (int i = 0; i < [_titleArray count]; i++) {
        [self.dataSouce addObject:[[_titleArray objectAtIndex:i] stringValue]];
	}
	
	[suggestConnection release];
	suggestConnection = nil;
	[async_data release];
	
	[self reloadTableView];
}

//-------------------------
// TableViewDelegate
//-------------------------

- (NSString *) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger) section {
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [dataSouce count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = [dataSouce objectAtIndex:indexPath.row];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// セルの選択状態を解除する
    [suggestTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	// ここで選択された文字列で検索等を行う。
	UIAlertView *alert = [
						  [UIAlertView alloc]
						  initWithTitle : NSLocalizedString(@"お知らせ", @"")
						  message : [NSString stringWithFormat:@"%@ が選択されました。", [dataSouce objectAtIndex:indexPath.row]]
						  delegate : nil
						  cancelButtonTitle : @"OK"
						  otherButtonTitles : nil
						  ];
	[alert show];
	[alert release];
}

//===============
// Util
//===============

// エンコード
- (NSString *)encodeURIComponent:(NSString* )s {
    return [((NSString*)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																(CFStringRef)s,
																NULL,
																(CFStringRef)@"!*'();:@&=+$,/?%#[]",
																kCFStringEncodingUTF8)) autorelease];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

@end
