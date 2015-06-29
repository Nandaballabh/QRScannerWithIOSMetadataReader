//
//  NBScanner.m
//  iOSInBuildScanner
//
//  Created by Nanda Ballabh on 6/29/15.
//  Copyright (c) 2015 Nanda Ballabh. All rights reserved.
//

#import "NBScanner.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

typedef  void ((^completionBlock)(NSString * scanedString , BOOL finished));

@interface NBScanner()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, copy) completionBlock completionBlock;
@property (nonatomic, assign) BOOL isReading;

@end

@implementation NBScanner

static id _scanner = nil;

+ (instancetype) scanner {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _scanner = [[self alloc] init];
    });
    return _scanner;
}

- (instancetype) init {
    self = [super init];
    if(self) {
        self.isReading = NO;
    }
    return self;
}


- (void) scanMetadataWithCompletionBlock:(void (^)(NSString * scanedString , BOOL finished))completionBlock {
    
    self.completionBlock = completionBlock;
    if(self.isReading) {
        [self startReading];
    }
    [self startReading];
}

#pragma mark - Private method implementation

- (BOOL)startReading {
    
    NSError *error = nil;
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!inputDevice) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    self.captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [self.captureSession addInput:inputDevice];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:[UIScreen mainScreen].bounds];
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:self.videoPreviewLayer];
    
    
    // Start video capture.
    [self.captureSession startRunning];
    
    return YES;
}


-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [self.captureSession stopRunning];
    self.captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoPreviewLayer removeFromSuperlayer];
    });
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.
            // [metadataObj stringValue]
            if(self.completionBlock)
                self.completionBlock ([metadataObj stringValue],YES);
            [self stopReading];
        }
    }
    
}

@end
