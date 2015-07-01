//
//  ViewController.m
//  Rhythmix
//
//  Created by yin.yan on 6/16/15.
//  Copyright (c) 2015 tinycomic. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "CGGeometry+Utils.h"

typedef enum : NSUInteger {
    KeyFrameActionChange,
    KeyFrameActionUp,
    KeyFrameActionDown,
    KeyFrameActionLeft,
    KeyFrameActionRight,
} KeyFrameAction;

@interface KeyFrame : NSObject

@property (nonatomic,assign) double time;
@property (nonatomic,assign) KeyFrameAction action;

@end

@interface ViewController ()

@property (nonatomic,strong) IBOutlet UIView *previewView;
//@property(nonatomic,strong) NSArray *images;
@property (nonatomic,strong) NSMutableArray *keyFrames;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) NSInteger zPosition;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) IBOutlet UIButton *progressButton;

@property (nonatomic,assign) BOOL ready;
@property (nonatomic,assign) BOOL start;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    NSMutableArray *array = [NSMutableArray array];
//    for (int i = 0; i < 22; i++) {
//        NSString *name = [NSString stringWithFormat:@"%d.JPG", i + 1];
//        UIImage *image = [UIImage imageNamed:name];
//        
//        [array addObject:image];
//    }
    
//    _images = [NSArray arrayWithArray:array];
    _index = 1;
    
    NSInteger scale = 4;
    CGFloat scalef = 4.0;
    CGSize size = CGSizeSub(_previewView.bounds.size, CGSizeMake(10, 10));
    CGPoint origin = CGPointMake(5, 5);
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.JPG", _index]];
    //_previewView.bounds.size
    for (int i = 0; i < scale * scale; i++) {
        CALayer *layer = [CALayer layer];
        layer.bounds = CGRectMake(0, 0, size.width / scalef, size.height / scalef);
        
        CGPoint position = CGPointMake(size.width / scalef * (i % scale) + size.width / scalef / 2.0 + origin.x, size.height / scalef * (i / scale) + size.height / scalef / 2.0 + origin.y);
        CGRect contentsRect = CGRectMake(size.width / scalef * (i % scale) / size.width,
                                         size.height / scalef * (i / scale) / size.height,
                                         1/ scalef,
                                         1/ scalef);
        layer.position = position;
        layer.contentsRect = contentsRect;
        layer.contents = (__bridge id) image.CGImage;
        
        layer.shadowOffset = CGSizeMake(0, 0);// , i * - 0.2);
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 1.0;
        layer.shadowRadius = 0.0;// i * 0.5;
        
        [_previewView.layer addSublayer:layer];
    }
//    _previewView.layer.contents = (__bridge id) ([UIImage imageNamed:[NSString stringWithFormat:@"%d.JPG", _index]]).CGImage;
//    _previewView.layer.contentsGravity = @"resizeAspectFill";
    _previewView.layer.masksToBounds = YES;
    
    NSURL *music = [[NSBundle mainBundle] URLForResource:@"run" withExtension:@"mp3"];
    _player = [AVPlayer playerWithURL:music];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapHandler:(id)sender
{
//    int nextIndex = (_index + 1) % 34;
//    
////    anim.duration = 1;/// 100.0;
////    anim.fromValue = (__bridge id) ((UIImage *) _images[index]).CGImage;
////    anim.toValue = (__bridge id) ((UIImage *) _images[nextIndex]).CGImage;
////    anim.fillMode = kCAFillModeForwards;
//    
////    [_previewView.layer addAnimation:anim forKey:@"1"];
//    [CATransaction begin];
//    [CATransaction setAnimationDuration:0.0];
//    _previewView.layer.contents = (__bridge id) ([UIImage imageNamed:[NSString stringWithFormat:@"%d.JPG", nextIndex]]).CGImage;
////    _previewView.layer.contents = (__bridge id) ((UIImage *) _images[nextIndex]).CGImage;
//    [CATransaction commit];
//    _index ++;
    _zPosition ++;
    if (_previewView.layer.sublayers.count > 0) {
        NSInteger count = arc4random() % 4;
        
        NSMutableSet *set = [NSMutableSet set];
        do {
            NSInteger index = arc4random() % _previewView.layer.sublayers.count;
            if (![set containsObject:@(index)]) {
                [set addObject:@(index)];
                
                if (set.count >= count) {
                    break;
                }
            }
        } while(1);
        
        for (NSNumber *index in set) {
            CALayer *layer = [_previewView.layer.sublayers objectAtIndex:[index integerValue]];
            
            layer.zPosition = _zPosition;
            
            CAKeyframeAnimation *shadowRadiusAnim = [CAKeyframeAnimation animationWithKeyPath:@"shadowRadius"];
            shadowRadiusAnim.keyTimes = @[@(0.0), @(0.5), @(1.0)];
            shadowRadiusAnim.values = @[@(0.0), @(10.0), @(0.0)];
            shadowRadiusAnim.beginTime = CACurrentMediaTime() + 0.0;
            shadowRadiusAnim.duration = 0.35;
            
            [layer addAnimation:shadowRadiusAnim forKey:@"shadowRadius"];
        }
    }
}

- (IBAction)panHandler:(UIPanGestureRecognizer *)sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateEnded:
        {
            int nextIndex = (_index + 1) % 34;
            
            //    anim.duration = 1;/// 100.0;
            //    anim.fromValue = (__bridge id) ((UIImage *) _images[index]).CGImage;
            //    anim.toValue = (__bridge id) ((UIImage *) _images[nextIndex]).CGImage;
            //    anim.fillMode = kCAFillModeForwards;
            
            //    [_previewView.layer addAnimation:anim forKey:@"1"];
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.0];
            
            for (CALayer *layer  in _previewView.layer.sublayers) {
                layer.contents = (__bridge id) ([UIImage imageNamed:[NSString stringWithFormat:@"%d.JPG", nextIndex]]).CGImage;
            }
//            _previewView.layer.contents = (__bridge id) ([UII3ddmage imageNamed:[NSString stringWithFormat:@"%d.JPG", nextIndex]]).CGImage;
            //    _previewView.layer.contents = (__bridge id) ((UIImage *) _images[nextIndex]).CGImage;
            [CATransaction commit];
            _index ++;
        }
            break;
            
        default:
            break;
    }
    
}

- (IBAction)start:(id)sender
{
    if (!_ready) {
        _ready = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSLog(@"3");
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"2");
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    NSLog(@"1");
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        [_player play];
                        _start = YES;
                    });
                });
            });
        });
    }
}



@end
