//
//  ViewController.m
//  QRCodeScanner
//
//  Created by admin on 2018/3/13.
//  Copyright © 2018年 王晓丹. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeScannerVC.h"
@interface ViewController ()

@end

@implementation ViewController{
    UILabel *titleLable;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customAccessores];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customAccessores {
    UIButton *scannerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scannerButton.frame = CGRectMake((self.view.frame.size.width-200)/2, 200, 200, 50);
    scannerButton.layer.cornerRadius = 5;
    scannerButton.backgroundColor = [UIColor redColor];
    [scannerButton setTitle:@"点击扫描" forState:UIControlStateNormal];
    [scannerButton addTarget:self action:@selector(goScanner:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scannerButton];
    
    titleLable = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, 300, 200, 50)];
    [self.view addSubview:titleLable];
}

- (void)goScanner:(UIButton *)button {
    QRCodeScannerVC *qrScanner = [QRCodeScannerVC new];
    qrScanner.scannerWidth = 200;
    qrScanner.scannerHeight = 270;
    
    [self.navigationController pushViewController:qrScanner animated:YES];
    qrScanner.resultBlock = ^(NSString *value) {
        titleLable.text = value;
        
    };
    
}
@end
