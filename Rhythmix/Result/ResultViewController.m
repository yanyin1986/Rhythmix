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
#import "GlobalSetting.h"

@interface ResultViewController ()
{
    NSMutableArray      *_times;
    NSUInteger           _timeCount;
    NSTimeInterval       _duration;
}

@end

@implementation ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self sortTimes];
    [self writeMOV];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)dealloc
{
}

- (void)sortTimes
{
    KeyFrame *beginFrame = _keyframes[0];
    double beginTime = beginFrame.time;
    
    _times = [NSMutableArray array];
    _timeCount = _keyframes.count - 1;
    
    for(NSInteger i = 0; i < _timeCount; i++) {
        KeyFrame *frame = _keyframes[i];
        if (i != 0) {
            // 0.2 time fix for humen reflection
            [_times addObject:@(frame.time - beginTime - 0.2)];
        }
//        CMTime currentTime = CMTimeMakeWithSeconds(frame.time - beginTime, 120); // fps?
        if (i == _timeCount - 1) {
            //_duration =  frame.time - beginTime;
        }
    }
    
    _duration = [[_times lastObject] doubleValue];
}

- (void)writeMOV
{
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *videoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"test_output.mov"];
    [[NSFileManager defaultManager] removeItemAtPath:videoOutputPath error:nil];
    NSURL *file = [NSURL fileURLWithPath:videoOutputPath];
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:file
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:nil];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings =
    @{
      AVVideoCodecKey  : AVVideoCodecH264,
      AVVideoWidthKey  : @(640),
      AVVideoHeightKey : @(640),
      };
    
    /*[NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:640], AVVideoWidthKey,
                                   [NSNumber numberWithInt:640], AVVideoHeightKey,
                                   nil];
     */
    
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
    
//    CMTime beginTime = _times[0];
    
    ALAsset* asset = [[GlobalSetting sharedInstance] assetWithIndex:0];
//    asset.defaultRepresentation.fullScreenImage
    CVPixelBufferRef buffer = [self pixelBufferFromCGImage:asset.defaultRepresentation.fullScreenImage];
    NSUInteger assetIndex = 0;
    
//    double duration = CMTimeGetSeconds(_duration);
    double frame = 30 * _duration;
    
    for (int i = 0; i < frame; i++) {
        double time = i / 30.0;
        BOOL needChangeBuffer = NO;
        if (assetIndex < _timeCount) {
            NSTimeInterval t1 = [_times[assetIndex + 1] doubleValue];
            
            if (time >= t1) {
                NSLog(@"go to next!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                assetIndex++;
                needChangeBuffer = YES;
            } else {
                
            }
        }
        NSLog(@"frame[%d] -> time [%g] -> assetIndex[%d]", i, time, assetIndex);
        
        if (needChangeBuffer) {
            CVPixelBufferRelease(buffer);
            ALAsset *asset = [[GlobalSetting sharedInstance] assetWithIndex:assetIndex];
            buffer = [self pixelBufferFromCGImage:asset.defaultRepresentation.fullScreenImage];
        }
        if (adaptor.assetWriterInput.readyForMoreMediaData) {
            [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(i, 30)];
        }
    }
    [videoWriterInput markAsFinished];
    [videoWriter finishWritingWithCompletionHandler:^{
        NSLog(@"!!finish");
        [self export];
    }];
    /*
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
     */
    
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

- (void)export
{
    // video
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *videoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"test_output.mov"];
    NSURL *file = [NSURL fileURLWithPath:videoOutputPath];

    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:file];
    CMTime duration = [videoAsset duration];
    
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo][0];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    
    // audio
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSURL *music = [[NSBundle mainBundle] URLForResource:@"run" withExtension:@"mp3"];
    AVURLAsset *audioAsset = [AVURLAsset assetWithURL:music];
    
    AVAssetTrack *audioAssetTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio][0];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    NSString *mp4Path = [documentsDirectory stringByAppendingPathComponent:@"test_output.mp4"];
    [[NSFileManager defaultManager] removeItemAtPath:mp4Path error:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = [NSURL fileURLWithPath:mp4Path];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"export finished!!!");
        
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:mp4Path] completionBlock:^(NSURL *assetURL, NSError *error) {
            NSLog(@"!!!! save OK!!!");
        }];
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will ofte n want to do a little preparation before navigation
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
