//
//  HMWebViewController.m
//  homeApp
//
//  Created by 唐嗣成 on 2018/4/12.
//  Copyright © 2018年 axxt. All rights reserved.
//

#import "HMWebViewController.h"
#import "JYTTitleLabel.h"
#import <Masonry/Masonry.h>
#import "NSTimer+Addition.h"
#import "BMPopActionViewManager.h"
#import "BMMediatorManager.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import <JavaScriptCore/JavaScriptCore.h>

#import "BMUserInfoModel.h"
#import "SVProgressHUD.h"
#import "UIView+Util.h"
#import "NSString+Util.h"
#import<WebKit/WebKit.h>

@protocol HMJSExport <JSExport>

- (void)closePage;

@end

typedef void(^BMNativeHandle)(void);

@interface HMNative : NSObject <HMJSExport>
@property (nonatomic, copy)BMNativeHandle closePageBlock;
@end

@implementation HMNative

- (void)closePage
{
    if (self.closePageBlock) {
        self.closePageBlock();
    }
}

@end

@interface HMWebViewController () <WKNavigationDelegate, WKUIDelegate, JSExport>
{
    BOOL _showProgress;
}
@property (nonatomic, strong) WKWebView *webView;

/** 伪进度条 */
@property (nonatomic, strong) CAShapeLayer *progressLayer;
/** 进度条定时器 */
@property (nonatomic, strong) NSTimer *timer;

/** 要打开的url */
@property (nonatomic, copy) NSString *urlStr;

@property (nonatomic, copy) NSString *currentStr;
/** js端传的分享内容 */
@property (nonatomic, strong) BMShareModel *shareModel;

/** 底部弹出的功能页面 */
@property (nonatomic, strong) BMPopActionViewManager *actionView;

@end

@implementation HMWebViewController

- (void)dealloc
{
    NSLog(@"dealloc >>>>>>>>>>>>> BMWebViewController");
}
- (WKWebView *)webView
{
    if (!_webView) {
        
        CGFloat height = K_SCREEN_HEIGHT - 64;
        if (!self.routerInfo.navShow) {
            height = K_SCREEN_HEIGHT;
        }
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, K_SCREEN_WIDTH, height)];
        _webView.backgroundColor = K_BACKGROUND_COLOR;
        _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//        _webView.scalesPageToFit = YES;
        _webView.multipleTouchEnabled = YES;
        _webView.userInteractionEnabled = YES;
        _webView.scrollView.scrollEnabled = YES;
        _webView.contentMode = UIViewContentModeScaleAspectFit;
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        [self.view addSubview:_webView];
    }
    return _webView;
}

- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer) {
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(0, self.navigationController.navigationBar.height - 2)];
        [path addLineToPoint:CGPointMake(K_SCREEN_WIDTH, self.navigationController.navigationBar.height - 2)];
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.path = path.CGPath;
        _progressLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        _progressLayer.fillColor = K_CLEAR_COLOR.CGColor;
        _progressLayer.lineWidth = 2;
        
        _progressLayer.strokeStart = 0.0f;
        _progressLayer.strokeEnd = 0.0f;
        
        
        [self.navigationController.navigationBar.layer addSublayer:_progressLayer];
        
        //        [self.view.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}

- (BMPopActionViewManager *)actionView
{
    if (!_actionView) {
        _actionView = [[BMPopActionViewManager alloc] init];
    }
    return _actionView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[BMMediatorManager shareInstance] setCurrentViewController:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    if (_progressLayer) {
        [_progressLayer removeFromSuperlayer];
        _progressLayer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* 解析 router 数据 */
    self.urlStr = self.routerInfo.url;
    self.navigationItem.title = self.routerInfo.title;
    self.shareModel = self.routerInfo.shareModel;
    
    self.view.backgroundColor = K_BACKGROUND_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    /* 判断是否需要隐藏导航栏 并设置weex页面高度
     注：使用FDFullscreenPopGesture方法设置，自定义pop返回动画
     */
    if (!self.routerInfo.navShow) {
        self.fd_prefersNavigationBarHidden = YES;
    } else {
        self.fd_prefersNavigationBarHidden = NO;
    }
    
    /* 返回按钮 */
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBar_BackItemIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backItemClicked)];
//    self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked)];
    self.navigationItem.leftBarButtonItems = @[backItem, closeItem];
    /** 功能面板 */
    UIBarButtonItem * shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"actionIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    /** 显示右侧分享按钮*/
//    self.navigationItem.rightBarButtonItem = shareItem;
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(progressAnimation:) userInfo:nil repeats:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadURL];
        
        _showProgress = YES;
    });
}

- (void)share
{
    [self.actionView showWebViewActionViewWithWebView:self.webView shareInfo:self.shareModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backItemClicked
{
    
    if ([self.webView canGoBack]) {
        //        NSString *url =self.webView.request.URL.absoluteString;
        //        if([url isEqualToString:self.currentStr]){
        //            [self closeItemClicked];
        //            return;
        //        }
        _showProgress = NO;
        [self.webView goBack];
        
        if ([self.webView canGoBack] && [self.navigationItem.leftBarButtonItems count] < 2) {
            //
            //  barbuttonitems
            //
//            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBar_BackItemIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backItemClicked)];
//            UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked)];
//            self.navigationItem.leftBarButtonItems = @[backItem, closeItem];
            //            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NavBar_BackItemIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backItemClicked)];
            //            self.navigationItem.leftBarButtonItems = @[backItem];
        }
        
    } else {
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//监听右滑事件，如果右滑返回，
- (void)willMoveToParentViewController:(UIViewController*)parent{
    //关闭loading
    [SVProgressHUD dismiss];
}


- (void)closeItemClicked
{
    [SVProgressHUD dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)requestAgain
{
    [self reloadURL];
}

- (void)reloadURL
{
    
    if ([self.urlStr isHasChinese]) {
        self.urlStr = [self.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *loadURL = [NSString stringWithFormat:@"%@",self.urlStr];
    NSURL *url = [NSURL URLWithString:loadURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - WKWebViewDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    if (_showProgress) {
        
        [self.timer resumeTimer];
        
    }
    [SVProgressHUD showWithStatus:@"waiting..."];
    _showProgress = YES;
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    /** 检查一下字体大小 */
    //    [self.webView checkCurrentFontSize];
    //    NSLog(self.webView.request.URL.absoluteString);
    NSString *url =self.webView.URL.absoluteString;
    [SVProgressHUD dismiss];
    self.currentStr = url;
    //    NSString * docTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //    if (docTitle && docTitle.length) {
    //        self.navigationItem.title = docTitle;
    //    }
    
    if (_timer != nil) {
        [_timer pauseTimer];
    }
    
    if (_progressLayer) {
        _progressLayer.strokeEnd = 1.0f;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_progressLayer removeFromSuperlayer];
            _progressLayer = nil;
        });
    }
    
    if([url isEqualToString:@"about:blank"]){
        [self closeItemClicked];
        return;
    }
    
    NSRange range = [url rangeOfString:@"?module=&scope=&detailid="];
    
    if(range.location!= NSNotFound){
        [self closeItemClicked];
        return;
    }
    
}



- (void)progressAnimation:(NSTimer *)timer
{
    self.progressLayer.strokeEnd += 0.005f;
    
    //    NSLog(@"%f",self.progressLayer.strokeEnd);
    
    if (self.progressLayer.strokeEnd >= 0.9f) {
        [_timer pauseTimer];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler();
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}
/**
 注入 js 方法
 */
- (void)injectionJsMethod
{
    /* 注入一个关闭当前页面的方法 */
    HMNative *bmnative = [[HMNative alloc] init];
    @weakify(self);
    bmnative.closePageBlock = ^{
        @strongify(self);
        [self closeItemClicked];
    };
//    _jsContext[@"bmnative"] = bmnative;
}

@end

