//
//  GoogleSuggestSampleAppDelegate.h
//  GoogleSuggestSample
//
//  Created by takeuchi on 11/08/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GoogleSuggestSampleViewController;

@interface GoogleSuggestSampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GoogleSuggestSampleViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GoogleSuggestSampleViewController *viewController;

@end

