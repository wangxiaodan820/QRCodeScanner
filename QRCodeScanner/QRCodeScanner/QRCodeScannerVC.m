//
//  QRCodeScannerVC.m
//  QRCodeScanner
//
//  Created by admin on 2018/3/13.
//  Copyright © 2018年 王晓丹. All rights reserved.
//

#import "QRCodeScannerVC.h"
#import <AVFoundation/AVFoundation.h>
@interface QRCodeScannerVC ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;

@property (nonatomic, strong) UIImageView *lineImageView;

@property (nonatomic, strong) NSTimer *timer;



@end

@implementation QRCodeScannerVC{
    CGRect rc;
    CGFloat marginWidth;
    CGFloat marginHeight;
    
    
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSubViews];
    [self requestAccessMedia];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopRunning];
    [super viewWillDisappear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    
}
#pragma mark - Custom Accessores
- (void)customSubViews {
    self.view.backgroundColor = [UIColor blackColor];
    
    rc = [[UIScreen mainScreen] bounds];
    marginWidth = (rc.size.width - self.scannerWidth)/2;
    marginHeight = (rc.size.height - self.scannerHeight)/2;
    CGFloat alpha = 0.5;
    
    //最上部view
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rc.size.width, marginHeight)];
    upView.alpha = alpha;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, marginHeight, marginWidth, marginHeight+self.scannerHeight)];
    leftView.alpha = alpha;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    
    //中间扫描区域
    UIImageView *scanCropView=[[UIImageView alloc] initWithFrame:CGRectMake(marginWidth, marginHeight,self.scannerWidth, self.scannerHeight)];
    scanCropView.image=[UIImage imageNamed:@"QRBarIcon"];
    scanCropView. backgroundColor =[ UIColor clearColor ];
    [ self.view addSubview :scanCropView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(marginWidth + self.scannerWidth, marginHeight, marginWidth, marginHeight+self.scannerHeight)];
    rightView.alpha = alpha;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    //底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(marginWidth, marginHeight+self.scannerHeight, self.scannerWidth, marginHeight)];
    downView.alpha = alpha;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    //用于说明的label
    self.warnLable= [[UILabel alloc] init];
    self.warnLable.backgroundColor = [UIColor clearColor];
    self.warnLable.frame=CGRectMake(marginWidth, rc.size.height - marginHeight, self.scannerWidth, 40);
    self.warnLable.numberOfLines=0;
    self.warnLable.textColor=[UIColor whiteColor];
    self.warnLable.textAlignment = NSTextAlignmentCenter;
    self.warnLable.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.warnLable];
    
    //画中间的基准线
    self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake (marginWidth, marginHeight, self.scannerWidth, 5)];
    self.lineImageView.image = [UIImage imageNamed:@"lineIcon"];
    [self.view addSubview:self.lineImageView];
    
    
    //返回
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"QRBarIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(pressBackButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}
#pragma mark - Click Action
- (void)pressBackButton {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)moveLine{
    
    CGFloat Y = self.lineImageView.frame.origin.y;
    if (marginHeight + self.scannerHeight == Y) {
        [UIView beginAnimations: @"asa" context:nil];
        [UIView setAnimationDuration:1.5];
        CGRect frame = self.lineImageView.frame;
        frame.origin.y = marginHeight;
        self.lineImageView.frame = frame;
        [UIView commitAnimations];
    } else if (marginHeight == Y){
        [UIView beginAnimations: @"asa" context:nil];
        [UIView setAnimationDuration:1.5];
        CGRect frame = self.lineImageView.frame;
        frame.origin.y = marginHeight + self.scannerHeight;
        self.lineImageView.frame = frame;
        [UIView commitAnimations];
    }
}

#pragma mark - Private
/** 请求相机权限 **/
- (void)requestAccessMedia{
    //AVMediaTypeVideo  相机权限。  AVMediaTypeAudio  麦克风权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if(granted) {
            //一般调用的相册，麦克风，通讯录什么玩意的权限 都需要回到主线程调用
            dispatch_async(dispatch_get_main_queue(), ^{
                //创建扫描界面
                [self loadScanView];
                [self startRuning];
            });
        }else {
            NSString *title = @"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
            [alertView show];
        }
        
    }];
}

- (void)loadScanView {
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    self.session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [self.session addInput:input];
    [self.session addOutput:output];
    //设置扫码支持的编码格式
    switch (self.scannerType) {
        case QRCodeScannerTypeAll:
            output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,
                                         AVMetadataObjectTypeEAN13Code,
                                         AVMetadataObjectTypeEAN8Code,
                                         AVMetadataObjectTypeUPCECode,
                                         AVMetadataObjectTypeCode39Code,
                                         AVMetadataObjectTypeCode39Mod43Code,
                                         AVMetadataObjectTypeCode93Code,
                                         AVMetadataObjectTypeCode128Code,
                                         AVMetadataObjectTypePDF417Code];
            break;
            
        case QRCodeScannerTypeQRCode:
            output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode];
            break;
            
        case QRCodeScannerTypeBarcode:
            output.metadataObjectTypes=@[AVMetadataObjectTypeEAN13Code,
                                         AVMetadataObjectTypeEAN8Code,
                                         AVMetadataObjectTypeUPCECode,
                                         AVMetadataObjectTypeCode39Code,
                                         AVMetadataObjectTypeCode39Mod43Code,
                                         AVMetadataObjectTypeCode93Code,
                                         AVMetadataObjectTypeCode128Code,
                                         AVMetadataObjectTypePDF417Code];
            break;
            
        default:
            break;
    }
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
}

#pragma mark - Public

- (void)startRuning {
    if(self.session) {
        [self.session startRunning];
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
    }
}
- (void)stopRunning {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil ;
    }
    
    [self.session stopRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];
        NSString *result = metadataObject.stringValue;
        
        if (self.resultBlock) {
            self.resultBlock(result?:@"");
        }
        
        [self pressBackButton];
    }
}
#pragma mark - Object

@end
