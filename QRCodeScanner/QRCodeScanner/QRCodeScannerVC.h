//
//  QRCodeScannerVC.h
//  QRCodeScanner
//
//  Created by admin on 2018/3/13.
//  Copyright © 2018年 王晓丹. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , QRCodeScannerType) {
    QRCodeScannerTypeAll = 0,   //支持扫描 二维码 以及 条形码
    QRCodeScannerTypeQRCode,    //仅支持扫描二维码
    QRCodeScannerTypeBarcode,   //仅支持扫描条形码
};

@interface QRCodeScannerVC : UIViewController

@property (nonatomic, assign) QRCodeScannerType scannerType;
//导航标题
@property (nonatomic, copy) NSString *navTitle;
//提示文字
@property (nonatomic, strong) UILabel *warnLable;
//扫描框宽度
@property (nonatomic, assign) CGFloat scannerWidth;
//扫描框高度
@property (nonatomic, assign) CGFloat scannerHeight;


//扫描结果回调
@property (nonatomic, copy) void (^resultBlock)(NSString *value);


@end
