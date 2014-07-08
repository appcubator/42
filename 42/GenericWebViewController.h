//
//  GenericWebViewController.h
//  42
//
//  Created by Ilter Canberk on 7/7/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenericWebViewController : UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil title:(NSString*)title url:(NSString *)url;

@property (strong, nonatomic) NSString* pageTitle;
@property (strong, nonatomic) NSString* url;

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UINavigationItem *titleText;


@end
