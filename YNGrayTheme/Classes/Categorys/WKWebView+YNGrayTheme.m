//
//  WKWebView+YNGrayTheme.m
//  UXin_S
//
//  Created by YN on 2022/12/1.
//  Copyright © 2022 karl. All rights reserved.
//

#import "WKWebView+YNGrayTheme.h"
#import <objc/runtime.h>
#import "YNGrayThemeManager.h"

@implementation WKWebView (YNGrayTheme)

+ (void)load {
    Method customMethod = class_getInstanceMethod([self class], @selector(swizzLoadRequest:));
    Method originMethod = class_getInstanceMethod([self class], @selector(loadRequest:));
    method_exchangeImplementations(customMethod, originMethod);//方法交换
}

- (nullable WKNavigation *)swizzLoadRequest:(NSURLRequest *)request {
    WKWebView *webView = self;
    BOOL isOpenWhiteBlackModel = [YNGrayThemeManager hasUIView:webView];
    if (isOpenWhiteBlackModel) {
        // js脚本
        NSString *jScript = @"var filter = '-webkit-filter:grayscale(100%);-moz-filter:grayscale(100%); -ms-filter:grayscale(100%); -o-filter:grayscale(100%) filter:grayscale(100%);';document.getElementsByTagName('html')[0].style.filter = 'grayscale(100%)';";
        // 注入
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        // 配置对象
        WKWebViewConfiguration *configuration = webView.configuration;
        WKUserContentController *userContentController = configuration.userContentController;
        [userContentController addUserScript:wkUScript];
    }
    return [self swizzLoadRequest:request];
}

@end
