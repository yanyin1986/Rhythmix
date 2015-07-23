//
//  ResultViewController.m
//  Rhythmix
//
//  Created by yin.yan on 7/7/15.
//  Copyright © 2015 tinycomic. All rights reserved.
//

#import "ResultViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Keyframe.h"

@interface ResultViewController ()


@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self sortTimes];
//    [self export];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)sortTimes
{
    
}

- (void)export
{
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *videoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"test_output.mov"];
    NSURL *file = [NSURL fileURLWithPath:videoOutputPath];
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:file
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:nil];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:640], AVVideoWidthKey,
                                   [NSNumber numberWithInt:640], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    KeyFrame *firstKeyFrame = _keyframes[0];
    double beginTime = firstKeyFrame.time;
    
    CVPixelBufferRef buffer = NULL;
    NSUInteger assetIndex = 0;
    
    NSMutableArray *changTimes = [NSMutableArray array];
    double duration = 0;
    for (int i = 1; i < _keyframes.count; i++) {
        KeyFrame *kf = _keyframes[i];
        if (kf.action == KeyFrameActionChange || KeyFrameActionEnd) {
            double d = kf.time - beginTime;
            [changTimes addObject:@(d)];
            
            if (d > duration) {
                duration = d;
            }
        }
    }
    
    int keyTimeIndex = 0;
    double fps = 30;
    double frameDuration = fps * duration;
    
    for (int i = 0; i < frameDuration; i++) {
        double time = i / fps;
        
        double leftCloseTime = [changTimes[keyTimeIndex] doubleValue];
        double rightCloseTime;
        if (keyTimeIndex + 1 == changTimes.count) {
            rightCloseTime = duration;
        } else {
            rightCloseTime = [changTimes[keyTimeIndex + 1] doubleValue];
        }
        
        if (time >= rightCloseTime) {
            keyTimeIndex++;
            
            leftCloseTime = [changTimes[keyTimeIndex] doubleValue];
            
            if (keyTimeIndex + 1 == changTimes.count) {
                rightCloseTime = duration;
            } else {
                rightCloseTime = [changTimes[keyTimeIndex + 1] doubleValue];
            }
        }
        
        NSLog(@"frame [%d] at time [%g] -> index [%d]", i, time, keyTimeIndex);
    }
    
    /*
    //convert uiimage to CGImage.
    int frameCount = 0;
    double numberOfSecondsPerFrame = 6;
    double frameDuration = fps * numberOfSecondsPerFrame;
    
    //for(VideoFrame * frm in imageArray)
    NSLog(@"**************************************************");
    for(UIImage * img in imageArray)
    {
        //UIImage * img = frm._imageFrame;
        buffer = [self pixelBufferFromCGImage:[img CGImage]];
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < 30) {
            if (adaptor.assetWriterInput.readyForMoreMediaData)  {
                //print out status:
                NSLog(@"Processing video frame (%d,%d)",frameCount,[imageArray count]);
                
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(!append_ok){
                    NSError *error = videoWriter.error;
                    if(error!=nil) {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else {
                printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            printf("error appending image %d times %d\n, with error.", frameCount, j);
        }
        frameCount++;
    }
    NSLog(@"**************************************************");
    
    //Finish the session:
    [videoWriterInput markAsFinished];
    [videoWriter finishWriting];
    //AVAssetWriter *writer = [AVAssetWriter alloc] initWithURL:<#(nonnull NSURL *)#> fileType:<#(nonnull NSString *)#> error:<#(NSError *__autoreleasing  __nullable * __nullable)#>
     */
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
    CGSize size = CGSizeMake(640, 640);
    
    //CGSize size = CGSizeMake(640, 640);
    //NSDictionary *options = @{ kCVPixelBufferCGImageCompatibilityKey : @(YES),
    //                           kCVPixelBufferCGBitmapContextCompatibilityKey : @(YES), };
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess){
        NSLog(@"Failed to create pixel buffer");
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 size.width,
                                                 size.height,
                                                 8,
                                                 4*size.width,
                                                 rgbColorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    //kCGImageAlphaNoneSkipFirst);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGRect frame = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
    CGContextDrawImage(context, frame, image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

@end
