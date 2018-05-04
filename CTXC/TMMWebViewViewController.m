//
//  BDNewsDetailViewController.m
//  SHInsuranceAgent
//
//  Created by 唐明明 on 2016/11/30.
//  Copyright © 2016年 Methodname. All rights reserved.
//

#import "TMMWebViewViewController.h"
#import <WebKit/WebKit.h>
#import "Masonry.h"
#import <AudioToolbox/AudioToolbox.h>

@interface TMMWebViewViewController ()<WKNavigationDelegate,WKUIDelegate,CAAnimationDelegate>
/*!
 *  @author methodname, 16-08-10 13:08:13
 *
 *  网页容器
 */
@property (weak, nonatomic) WKWebView *webView;

@property(weak,nonatomic)CAShapeLayer *loadline;

@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)BOOL fs;
@property(nonatomic,assign)double oldusdt;
@property(nonatomic,strong)UILabel *usdt;
@property(nonatomic,strong)UILabel *cny;



@end

@implementation TMMWebViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    WKWebView* webView = [[WKWebView alloc] init];
    webView.translatesAutoresizingMaskIntoConstraints = YES;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    webView.navigationDelegate = self;
    webView.UIDelegate = self;
    [self.view addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);  
    }];
    self.webView = webView;
    
    self.usdt = [UILabel new];
    [self.usdt setFont:[UIFont systemFontOfSize:40.0f]];
    [self.usdt setText:@"0.00"];
    
    self.cny = [UILabel new];
    [self.cny setFont:[UIFont systemFontOfSize:30.0f]];
    [self.cny setText:@"0.00"];
    
    UIView *maskView = [UIView new];
    [maskView setBackgroundColor:[UIColor whiteColor]];
    [maskView addSubview:self.usdt];
    [maskView addSubview:self.cny];
    [self.view addSubview:maskView];
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    
    [self.usdt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(maskView);
        
    }];
    
    [self.cny mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(maskView);
        make.top.equalTo(self.usdt).offset(80);
        
    }];
    
    
    
    self.oldusdt = 0.0f;
    
    [self loadUrl];
    
    self.fs = NO;
    
   
    
}





/**
 加载链接
 */

-(void)loadUrl
{
    NSLog(@"open url：%@",self.url);
    if (self.url!= nil && self.url.length!= 0)
    {
        //加载pdf
        if ([self.url rangeOfString:@".pdf"].location != NSNotFound) {
            //[self.webView loadFileURL:[NSURL URLWithString:self.url] allowingReadAccessToURL:[NSURL URLWithString:self.url]];
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
            [self.webView loadRequest:req];
        }
        else
        {
            
            NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
            [self.webView loadRequest:req];
        }
        
    }
    else if(self.content != nil)
    {
        [self.webView loadHTMLString:self.content baseURL:nil];
    }

}


/**
 webView开始加载

 @param webView s
 @param navigation s
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
{
    [self pathLineStart:0.1 End:0.25 Duration:1.5 OldAnimateKey:@"" AnimateKey:@"line1"];
}



/**
 确认提交

 @param webView s
 @param navigation s
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    [self pathLineStart:0.25 End:0.4 Duration:5.0 OldAnimateKey:@"line1" AnimateKey:@"line2"];
}


/**
 webView加载完成

 @param webView s
 @param navigation s
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self pathLineStart:0.25 End:1 Duration:0.35 OldAnimateKey:@"line2" AnimateKey:@"lineEnd"];
    
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(refuresh) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

}


-(void)refuresh
{
    

    //ticker_close
    //ticker_close
    NSString * jsStr = @"document.getElementsByClassName('ticker_close')[0].innerText";
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id item, NSError * _Nullable error) {
        // 执行结果回调
        if (!error ) {
            //NSLog(@"%@",item);
            
            self.oldusdt = self.usdt.text.doubleValue;
            
            [self.usdt setText:item];
            double usdt =[item doubleValue];
            //降价
            if (usdt > self.oldusdt) {
                [self.usdt setTextColor:[UIColor colorWithRed:37/255.0f green:215/255.0f blue:148/255.0f alpha:1]];
            }else if(usdt < self.oldusdt){
                //涨价
                [self.usdt setTextColor:[UIColor redColor]];
            }else{
                //[self.usdt setTextColor:[UIColor lightGrayColor]];
            }
            
            //cny提示
            if (self.swcb) {
                if (self.sw) {
                    //涨价目标值
                    if (usdt >= self.usdTotal) {
                        
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                }
                else
                {
                    //降价目标值
                    if (usdt <= self.usdTotal) {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                }
            }
            
        }
    }];
    
    
//    tickerCny_ticker_bar
    NSString * tickerCny_ticker_bar = @"document.getElementById('tickerCny_ticker_bar').innerText";
    [self.webView evaluateJavaScript:tickerCny_ticker_bar completionHandler:^(id item, NSError * _Nullable error) {
        // 执行结果回调
        if (!error ) {
//            NSLog(@"%@",item);
            NSString *cnystr = [[item stringByReplacingOccurrencesOfString:@"≈ " withString:@""] stringByReplacingOccurrencesOfString:@" CNY" withString:@""];
//            NSLog(@"%@",cny);
            [self.cny setText:cnystr];
            double cny =[cnystr doubleValue];
            if (self.swcb) {
                if (self.sw) {
                    //超过目标值
                    if (cny >= self.usdTotal) {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                }
                else
                {
                    //低于等于目标值
                    if (cny <= self.usdTotal) {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    }
                }
            }
            

        }
    }];
}



/**
 *  画线
 */
-(void)pathLineStart:(float)p1 End:(float)p2 Duration:(CFTimeInterval)duration OldAnimateKey:(NSString *)oldkey AnimateKey:(NSString *)key
{
    if (self.loadline == nil)
    {
        //创建动画图层
        CAShapeLayer *line1=[CAShapeLayer layer];
        //创建画笔
        UIBezierPath* bezier1Path = UIBezierPath.bezierPath;
        //设置锚点
        [bezier1Path moveToPoint: CGPointMake(0, 44)];
        //添加一个终点
        CGFloat x = self.navigationController.navigationBar.bounds.size.width;
        [bezier1Path addLineToPoint: CGPointMake(x, 44)];
        //设置图层路径为画笔路径
        line1.path=bezier1Path.CGPath;
        //图层线宽
        line1.lineWidth = 2;
        //设置圆角
        
        //设置描边色
        line1.strokeColor=[[UIColor orangeColor] CGColor];
        //将图层添加到视图的图层上
        [self.navigationController.navigationBar.layer addSublayer:line1];
        self.loadline = line1;
    }
   
    if (oldkey.length != 0 ) {
       [self.loadline removeAnimationForKey:oldkey];
    }
    
    
    //创建基础动画
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    //设置开始时间
    animation1.beginTime = CACurrentMediaTime() + 0;
    //设置动画时间
    animation1.duration = duration;
    //设置保留动画完成时的图层
    animation1.removedOnCompletion = NO;
    //设置不还原动画
    animation1.autoreverses = NO;
    //填充模式
    animation1.fillMode = kCAFillModeBoth;
    //开始值
    animation1.fromValue = @(p1);
    //结束值
    animation1.toValue = @(p2);
    
    
    //设置动画曲线
    if (duration>1)
    {
         animation1.timingFunction = [CAMediaTimingFunction  functionWithControlPoints:0.3 : 0.2 :0.1 :0.9];
    }
    animation1.delegate = self;
    //添加动画到图层【执行】
    [self.loadline addAnimation:animation1 forKey:key];
}


/**
 动画停止代理

 @param anim s
 @param flag  s
 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    BOOL fl = NO;
    if (flag) {
        for (NSString *key in self.loadline.animationKeys) {
            if ([key isEqualToString:@"lineEnd"]) {
                fl = YES;
                break;
            }
        }
    }
    
    if (fl) {
        [self removeLineLayer];
    }
    
}


/**
 删除线
 */
- (void)removeLineLayer
{
    BOOL fl = NO;
    int index = -1;
    NSArray *array = self.navigationController.navigationBar.layer.sublayers;
    for (int i = 0;i<array.count;i++ ) {
        if ([array[i] isKindOfClass:[CAShapeLayer class]])
        {
            fl = YES;
            index = i;
            
        }
    }
    if (fl && index != -1) {
        CAShapeLayer *lineLayer = array[index];
        [lineLayer removeAllAnimations];
        [lineLayer removeFromSuperlayer];
    }

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self removeLineLayer];
    [self invalidateTimer];
}







- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{    // js 里面的alert实现，如果不实现，网页的alert函数无效
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
    
    //MBLog(@"%@",message);
}
- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}



-(void)dealloc
{
    
    [self.webView stopLoading];
    self.webView.UIDelegate  = nil;
    self.webView.navigationDelegate = nil;
    
    
}


@end
