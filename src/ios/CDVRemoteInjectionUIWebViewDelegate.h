#import "CDVRemoteInjection.h"
#import "CDVRemoteInjectionWebViewBaseDelegate.h"
#import <WebKit/WebKit.h>

@interface CDVRemoteInjectionUIWebViewDelegate: CDVRemoteInjectionWebViewBaseDelegate <CDVRemoteInjectionWebViewDelegate>
@property (readwrite, weak) CDVRemoteInjectionPlugin *plugin;
- (void) onWebViewDidStartLoad;
#if WK_WEB_VIEW_ONLY
- (void) onWebViewDidFinishLoad:(WKWebView *)webView;
#else
- (void) onWebViewDidFinishLoad:(UIWebView *)webView;
#endif
- (void) onWebViewFailLoadWithError:(NSError *)error;
@end

#if WK_WEB_VIEW_ONLY
@interface CDVRemoteInjectionUIWebViewNotificationDelegate : WrappedDelegateProxy <WKUIDelegate>
#else
@interface CDVRemoteInjectionUIWebViewNotificationDelegate : WrappedDelegateProxy <UIWebViewDelegate>
#endif
@property (readwrite, weak) CDVRemoteInjectionUIWebViewDelegate *webViewDelegate;
@end
