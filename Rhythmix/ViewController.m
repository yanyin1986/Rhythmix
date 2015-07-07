//
//  ViewController.m
//  Rhythmix
//
//  Created by yin.yan on 6/16/15.
//  Copyright (c) 2015 tinycomic. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "GlobalSetting.h"
#import "CGGeometry+Utils.h"
#import "MBProgressHUD.h"

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

@property (nonatomic, strong) IBOutlet UIView *previewView;
@property (nonatomic, strong) IBOutlet UIScrollView *assetsScrollView;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
//@property(nonatomic,strong) NSArray *images;
@property (nonatomic, strong) NSMutableArray *keyFrames;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger zPosition;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) IBOutlet UIButton *progressButton;
@property (nonatomic, strong) MBProgressHUD *progressView;
@property (nonatomic, strong) CATextLayer *textLayer;

@property (nonatomic, assign) BOOL ready;
@property (nonatomic, assign) BOOL start;
@property (nonatomic, assign) BOOL inTitle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _previewView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [_previewView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [_previewView addGestureRecognizer:pan];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadPreviewAssets];
}

- (IBAction)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)loadPreviewAssets
{
    NSInteger count = [[GlobalSetting sharedInstance] selectedAssetsCount];
    _assetsScrollView.contentInset = UIEdgeInsetsMake(0, _assetsScrollView.bounds.size.width / 2.0, 0, 0);
    
    for (NSInteger i = 0; i < count; i++) {
        CGRect frame = CGRectMake(i * _assetsScrollView.bounds.size.height, 0, _assetsScrollView.bounds.size.height, _assetsScrollView.bounds.size.height);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        [_assetsScrollView addSubview:imageView];
        dispatch_async(dispatch_get_main_queue(), ^{
            ALAsset *asset = [[GlobalSetting sharedInstance] assetWithIndex:i];
            imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
        });
    }
    
    _index = 0;
    NSInteger scale = 4;
    CGFloat scalef = 4.0;
    CGSize size = CGSizeSub(_previewView.bounds.size, CGSizeMake(10, 10));
    CGPoint origin = CGPointMake(5, 5);
    
    
    //UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld.JPG", _index]];
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
        
        ALAsset *asset = [[GlobalSetting sharedInstance] assetWithIndex:_index];
        if (asset) {
            layer.contents = (__bridge id) asset.thumbnail;
        }
        
        layer.shadowOffset = CGSizeMake(0, 0);// , i * - 0.2);
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOpacity = 1.0;
        layer.shadowRadius = 0.0;// i * 0.5;
        
        [_previewView.layer addSublayer:layer];
    }
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
            if (_start && _inTitle) {
                
                CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
                anim.fromValue = @(0.75);
                anim.toValue = @(0.0);
                anim.duration = 0.5;
                anim.fillMode = kCAFillModeBoth;
                anim.removedOnCompletion = NO;
                
                [_textLayer addAnimation:anim forKey:@"opacity"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.49 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _inTitle = NO;
                });
                return;
            } else if (_start) {
                int nextIndex = _index + 1;//) % 34;
                
                if (nextIndex > [[GlobalSetting sharedInstance] selectedAssetsCount]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [_player pause];
                        _nextButton.enabled = YES;
                        
                    });
                }
                
                [CATransaction begin];
                [CATransaction setAnimationDuration:0.0];
                
                for (CALayer *layer  in _previewView.layer.sublayers) {
                    ALAsset *asset = [[GlobalSetting sharedInstance] assetWithIndex:nextIndex];
                    if (asset) {
                        layer.contents = (__bridge id) asset.thumbnail;
                    }
                }
                [CATransaction commit];
                _index ++;
                [_assetsScrollView setContentOffset:CGPointMake(_assetsScrollView.contentOffset.x + _assetsScrollView.bounds.size.height, 0) animated:YES];
                }
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
        if (!_progressView) {
            _progressView = [[MBProgressHUD alloc] initWithView:self.view];
            _progressView.mode = MBProgressHUDModeText;
            [self.view addSubview:_progressView];
        }
        [self.view bringSubviewToFront:_progressView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSLog(@"3");
            [_progressView show:YES];
            _progressView.labelText = @"3";
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"2");
                _progressView.labelText = @"2";
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    NSLog(@"1");
                    _progressView.labelText = @"1";
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        [_progressView hide:YES];
                        [_player play];
                        
                        // add title for music
                        if (!_textLayer) {
                            CATextLayer *textLayer = [CATextLayer layer];
                            textLayer.string = @"Run boy run\n";
                            textLayer.fontSize = 48.0;
                            textLayer.alignmentMode = @"center";// NSTextAlignmentCenter;
                            textLayer.bounds = _previewView.bounds;
                            textLayer.opacity = 0.0;
                            textLayer.position = CGPointMake(_previewView.bounds.size.width / 2.0, _previewView.bounds.size.height / 2.0);
                            
                            [_previewView.layer addSublayer:textLayer];
                            _textLayer = textLayer;
                        }
                        
                        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
                        anim.fromValue = @(0.0);
                        anim.toValue = @(0.75);
                        anim.duration = 0.5;
                        anim.fillMode = kCAFillModeBoth;
                        anim.removedOnCompletion = NO;
                        
                        [_textLayer addAnimation:anim forKey:@"opacity"];
                        
                        _inTitle = YES;
                        _start = YES;
                    });
                });
            });
        });
    }
}



@end
