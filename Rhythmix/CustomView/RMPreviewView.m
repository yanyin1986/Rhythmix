//
//  RMPreviewView.m
//  Rhythmix
//
//  Created by yin.yan on 7/22/15.
//  Copyright © 2015 tinycomic. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "RMPreviewView.h"

@interface RMPreviewView ()
{
    CAEAGLLayer *_glLayer;
    EAGLContext *_context;
    
    GLuint _colorRenderBuffer;
}
@end


@implementation RMPreviewView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setupLayer
{
    // setup layer
    _glLayer = (CAEAGLLayer *) self.layer;
    _glLayer.opaque = YES;
    _glLayer.drawableProperties =
    @{
      kEAGLDrawablePropertyRetainedBacking : @(NO),
      kEAGLDrawablePropertyColorFormat     : kEAGLColorFormatRGBA8,
      };
    
}

- (void)setupContext
{
    // setup context
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"doesn't support GLES 2.0");
        return;
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"set context failed");
        return;
    }
}

- (void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
}


@end
