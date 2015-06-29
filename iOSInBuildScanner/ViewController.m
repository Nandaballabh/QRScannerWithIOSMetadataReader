//
//  ViewController.m
//  iOSInBuildScanner
//
//  Created by Nanda Ballabh on 6/29/15.
//  Copyright (c) 2015 Nanda Ballabh. All rights reserved.
//

#import "ViewController.h"
#import "NBScanner.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startButtonTapped:(id)sender {
    [[NBScanner scanner] scanMetadataWithTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeAztecCode] completionBlock:^(NSString *scannedString, BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc]initWithTitle:@"" message:scannedString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        });
    }];
}
@end
