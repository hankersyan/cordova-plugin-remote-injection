//
//  CDVRemoteInjection.m
//

#import <Foundation/Foundation.h>

#import "CDVRemoteInjectionUIWebViewDelegate.h"
#import "CDVRemoteInjectionWebViewBaseDelegate.h"


@implementation CDVRemoteInjectionUIWebViewNotificationDelegate
@dynamic wrappedDelegate;

#if WK_WEB_VIEW_ONLY
#else
#endif

#if WK_WEB_VIEW_ONLY
- (void)webViewDidStartLoad:(WKWebView*)webView
#else
- (void)webViewDidStartLoad:(UIWebView*)webView
#endif
{
    [self.webViewDelegate onWebViewDidStartLoad];
    
    if ([self.wrappedDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.wrappedDelegate webViewDidStartLoad:webView];
    }
}

#if WK_WEB_VIEW_ONLY
- (void)webViewDidFinishLoad:(WKWebView *)webView
#else
- (void)webViewDidFinishLoad:(UIWebView *)webView
#endif
{
    [self.webViewDelegate onWebViewDidFinishLoad:webView];
    
    if ([self.wrappedDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.wrappedDelegate webViewDidFinishLoad:webView];
    }
}

#if WK_WEB_VIEW_ONLY
- (void)webView:(WKWebView *)webView didFailLoadWithError:(NSError *)error
#else
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
#endif
{
    if ([self.wrappedDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.wrappedDelegate webView:webView didFailLoadWithError:error];
    }
    
    [self.webViewDelegate onWebViewFailLoadWithError:error];
}
@end

@implementation CDVRemoteInjectionUIWebViewDelegate
{
    CDVRemoteInjectionUIWebViewNotificationDelegate *notificationDelegate;
}

- (void)initializeDelegate:(CDVRemoteInjectionPlugin *)plugin
{
    self.plugin = plugin;

    // Wrap the current delegate with our own so we can hook into web view events.
    #if WK_WEB_VIEW_ONLY
        WKWebView *uiWebView = [plugin findWebView];
        notificationDelegate = [[CDVRemoteInjectionUIWebViewNotificationDelegate alloc] init];
        notificationDelegate.wrappedDelegate = [uiWebView UIDelegate];
        notificationDelegate.webViewDelegate = self;
        [uiWebView setUIDelegate:notificationDelegate];
    #else
        UIWebView *uiWebView = [plugin findWebView];
        notificationDelegate = [[CDVRemoteInjectionUIWebViewNotificationDelegate alloc] init];
        notificationDelegate.wrappedDelegate = [uiWebView delegate];
        notificationDelegate.webViewDelegate = self;
        [uiWebView setDelegate:notificationDelegate];
    #endif
}

-(void) onWebViewDidStartLoad
{
    [super webViewRequestStart];
}

/*
 * After page load inject cordova and its plugins.
 */
#if WK_WEB_VIEW_ONLY
- (void) onWebViewDidFinishLoad:(WKWebView *)webView
{
    // Cancel the slow request timer.
    [self cancelRequestTimer];
 
    // Inject cordova into the page.
    NSString *scheme = webView.URL.scheme;
 
    if ([self isSupportedURLScheme:scheme]){
        [webView evaluateJavaScript:[self buildInjectionJS] completionHandler:nil];
    }
}
#else
- (void) onWebViewDidFinishLoad:(UIWebView *)webView
{
    // Cancel the slow request timer.
    [self cancelRequestTimer];
 
    // Inject cordova into the page.
    NSString *scheme = webView.request.URL.scheme;
 
    if ([self isSupportedURLScheme:scheme]){
        [webView stringByEvaluatingJavaScriptFromString:[self buildInjectionJS]];
    }
}
#endif

// Handles notifications from the webview delegate whenever a page load fails.
- (void) onWebViewFailLoadWithError:(NSError *)error
{
    [self loadPageFailure:error];
}

- (BOOL) isLoading
{
    #if WK_WEB_VIEW_ONLY
    WKWebView *uiWebView = [self.plugin findWebView];
    #else
    UIWebView *uiWebView = [self.plugin findWebView];
    #endif
    return uiWebView.loading;
}

- (void) retryCurrentRequest
{
    #if WK_WEB_VIEW_ONLY
    WKWebView *webView = [self.plugin findWebView];
    #else
    UIWebView *webView = [self.plugin findWebView];
    #endif
    
    [webView stopLoading];
    [webView reload];
}

@end
