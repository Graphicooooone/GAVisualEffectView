//
//  GAVisualEffectView.m
//  iOS7Late
//
//  Created by Peter Gra on 2017/6/1.
//  Copyright © 2017年 Peter Gra. All rights reserved.
//

#import "GAVisualEffectView.h"

#import "GABlurEffect.h"
#import "GAVibrancyEffect.h"

#import <objc/runtime.h>
#import <float.h>


__asm(
      ".section        __DATA,__objc_classrefs,regular,no_dead_strip\n"
#if	TARGET_RT_64_BIT
      ".align          3\n"
      "L_OBJC_CLASS_UIVisualEffectView:\n"
      ".quad           _OBJC_CLASS_$_UIVisualEffectView\n"
#else
      ".align          2\n"
      "_OBJC_CLASS_UIVisualEffectView:\n"
      ".long           _OBJC_CLASS_$_UIVisualEffectView\n"
#endif
      ".weak_reference _OBJC_CLASS_$_UIVisualEffectView\n"
      );

__attribute__((constructor))
static void GAVisualEffectViewRuntime(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if (objc_getClass("UIVisualEffectView")) {
                return;
            }
            
            Class * c = NULL;
            
#if TARGET_CPU_ARM
            __asm("movw %0, :lower16:(_OBJC_CLASS_UIVisualEffectView-(LPC0+4))\n"
                  "movt %0, :upper16:(_OBJC_CLASS_UIVisualEffectView-(LPC0+4))\n"
                  "LPC0: add %0, pc" : "=r"(c));
#elif TARGET_CPU_ARM64
            __asm("adrp %0, L_OBJC_CLASS_UIVisualEffectView@PAGE\n"
                  "add  %0, %0, L_OBJC_CLASS_UIVisualEffectView@PAGEOFF" : "=r"(c));
#elif TARGET_CPU_X86_64
            __asm("leaq L_OBJC_CLASS_UIVisualEffectView(%%rip), %0" : "=r"(c));
#elif TARGET_CPU_X86
            void *pc = NULL;
            __asm("calll L0\n"
                  "L0: popl %0\n"
                  "leal _OBJC_CLASS_UIVisualEffectView-L0(%0), %1" : "=r"(pc), "=r"(c));
#else
#error Unsupported CPU
#endif
            
            if (c && !*c) {
                Class class = objc_allocateClassPair([GAVisualEffectView class], "UIVisualEffectView", 0);
                if (class) {
                    objc_registerClassPair(class);
                    *c = class;
                }
            }
        }
    });
}


/**
__attribute__((constructor))
static void Gra_MethodSwizzling (void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class visualEffect = objc_getClass("UIVisualEffect");
        Class blurEffect = objc_getClass("UIBlurEffect");
        Class vibrancyEffect = objc_getClass("UIVibrancyEffect");
        Class visualEffectView = objc_getClass("UIVisualEffectView");
        
        if (visualEffect || blurEffect || vibrancyEffect || visualEffectView) return ;
        
        Class gaVisualEffect = objc_allocateClassPair([GAVisualEffect class], "UIVisualEffect", 0);
        if (gaVisualEffect) {
            objc_registerClassPair(gaVisualEffect);
        }
        Class gaBlurEffect = objc_allocateClassPair([GABlurEffect class], "UIBlurEffect", 0);
        if (gaBlurEffect) {
            objc_registerClassPair(gaBlurEffect);
        }
        Class gaVibrancyEffect = objc_allocateClassPair([GAVibrancyEffect class], "UIVibrancyEffect", 0);
        if (gaVibrancyEffect) {
            objc_registerClassPair(gaVibrancyEffect);
        }
        Class gaVisualEffectView = objc_allocateClassPair([GAVisualEffectView class], "UIVisualEffectView", 0);
        if (gaVisualEffectView) {
            objc_registerClassPair(gaVisualEffectView);
        }
    });
}
 */

#define GA_HAS_GPUIMAGE
#define GA_HAS_YYIMAGE

#if __has_include (<GPUImage.h>)
#import <GPUImage.h>
#elif __has_include ("GPUImage.h")
#import "GPUImage.h"
#else
#undef GA_HAS_GPUIMAGE
#endif


#pragma mark - Util 
///< category ...
@interface UIView (GAEffectView)
- (UIImage* )ga_snapshoot2Image;
@end
@implementation UIView (UIView)
- (UIImage* )ga_snapshoot2Image:(CGSize)targetSize{
    ///< one path
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    ///< two path
    UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = (CGRect){{0,0},targetSize};
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    UIGraphicsBeginImageContext(targetSize);
    [imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resultImage;
}
@end


@interface UIImage (GAEffectView)
- (UIImage *)blurImage;
- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;
@end

@import Accelerate;

@implementation UIImage (GAEffectView)

- (UIImage *)blurImage {
    return [self applyBlurWithRadius:20
                           tintColor:[UIColor colorWithWhite:0 alpha:0.0]
               saturationDeltaFactor:1.4
                           maskImage:nil];
}

- (UIImage *)applyLightEffect{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyExtraLightEffect {
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyDarkEffect {
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor {
    const CGFloat EffectColorAlpha = 0.6;
    UIColor      *effectColor      = tintColor;
    int           componentCount   = (int)CGColorGetNumberOfComponents(tintColor.CGColor);
    
    if (componentCount == 2) {
        
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
        
    } else {
        
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    
    return [self applyBlurWithRadius:20 tintColor:effectColor saturationDeltaFactor:1.4 maskImage:nil];
}

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage {
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1)  return nil;
    
    if (!self.CGImage) return nil;
    
    if (maskImage && !maskImage.CGImage) return nil;
    
    CGRect   imageRect   = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur             = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1;
            }
            
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (uint32_t)radius, (uint32_t)radius, 0, kvImageEdgeExtend);
        }
        
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            
            if (hasBlur) {
                
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
                
            } else {
                
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        
        if (!effectImageBuffersAreSwapped) {
            
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped) {
            
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        }
        
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        
        CGContextSaveGState(outputContext);
        
        if (maskImage) {
            
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}


@end









#pragma mark - GAVisualEffectView
@interface GAVisualEffectView ()
@property (nonatomic, strong, readwrite) UIView *contentView;
@end
@implementation GAVisualEffectView
{
    UIView* _targetView;
    GABlurEffectStyle _curStyle;
}

#pragma mark - Public
- (instancetype)initWithEffect:(nullable GAVisualEffect *)effect{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.effect = effect;
        [self _configSomething];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _configSomething];
    }
    return self;
}

- (void)setEffect:(GAVisualEffect *)effect{
    if (_effect == effect) return ;
    
    if ([effect isMemberOfClass:[GABlurEffect class]]) { ///< GABlurEffect
        GABlurEffect* tmpBlurEffect = (GABlurEffect* )effect;
        _curStyle = [objc_getAssociatedObject(tmpBlurEffect, @selector(effectWithStyle:)) integerValue];
    }else if ([effect isMemberOfClass:[GAVibrancyEffect class]]){ ///< GAVibrancyEffect
        GAVibrancyEffect* tmpVibrancyEffect = (GAVibrancyEffect* )effect;
        GABlurEffect* assBlurEffect = objc_getAssociatedObject(tmpVibrancyEffect, @selector(effectForBlurEffect:));
        _curStyle = [objc_getAssociatedObject(assBlurEffect, @selector(effectWithStyle:)) integerValue];
    }
    
    _effect = effect;
}

- (void)setCurEffectScheme:(GAVisualEffectScheme)curEffectScheme{
    _curEffectScheme = curEffectScheme;
    
    if (_curEffectScheme == GAVisualEffectScheme_Auto) {
        _contentView = [UIImageView new];
    }else if (_curEffectScheme == GAVisualEffectScheme_CoreImage){
        _contentView = [UIImageView new];
    }else if (_curEffectScheme == GAVisualEffectScheme_GPUImage){
#ifdef GA_HAS_GPUIMAGE
        _contentView = [GPUImageView new];
        _contentView.layer.contentsScale = 2.0f;
        _contentView.clipsToBounds = YES;
        _contentView.layer.contentsGravity = kCAGravityTop;
#else
        NSAssert(false, @"The project does not contain GPUImage framework");
#endif
    }else{
        _contentView = [UIImageView new];
    }
    
    if (!_contentView.superview) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
        [self bringSubviewToFront:_contentView];
    }
}

- (void)drawRect:(CGRect)rect{
    UIImage* _snapshootImage = nil;
    if (_targetView) {
        _snapshootImage = [_targetView ga_snapshoot2Image:self.bounds.size];
    }
    if (_snapshootImage) {
        switch (_curEffectScheme) {
            case GAVisualEffectScheme_Auto:{
                [self _coreImageHandle:_snapshootImage];
                break;
            }
                
            case GAVisualEffectScheme_CoreImage:{
                [self _coreImageHandle:_snapshootImage];
                break;
            }
                
            case GAVisualEffectScheme_GPUImage:{
                [self _gpuImageHandle:_snapshootImage];
                break;
            }
                
            default:{
                [self _coreImageHandle:_snapshootImage];
                break;
            }
        }
    }
    _snapshootImage = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    _targetView = newSuperview;
    _contentView.frame = self.bounds;
    
    [super willMoveToSuperview:newSuperview];
}

#pragma mark - Private
- (void)_configSomething{
    self.curEffectScheme = GAVisualEffectScheme_Auto;
    if (_contentView) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
        [self bringSubviewToFront:_contentView];
    }
}

#pragma mark - Image Handle
- (void)_coreImageHandle:(UIImage* )originImage{
    UIImageView* imageView = (UIImageView* )_contentView;
    UIImage* resultImage = nil;
    switch (_curStyle) {
        case GABlurEffectStyleExtraLight:
            resultImage = [originImage applyExtraLightEffect];
            break;
            
        case GABlurEffectStyleLight:
            resultImage = [originImage applyLightEffect];
            break;
            
        case GABlurEffectStyleDark:
            resultImage = [originImage applyDarkEffect];
            break;
            
        default:
            resultImage = [originImage blurImage];
            NSAssert(false, @"The current mode is not supported");
            break;
    }
    imageView.image = resultImage ?: originImage;
}

- (void)_gpuImageHandle:(UIImage* )originImage{
#ifdef GA_HAS_GPUIMAGE
    GPUImageiOSBlurFilter* _blurFilter = [[GPUImageiOSBlurFilter alloc] init];
    _blurFilter.blurRadiusInPixels = 1.0f;
    GPUImagePicture* _picture = [[GPUImagePicture alloc] initWithImage:originImage];
    [_picture addTarget:_blurFilter];
    [_blurFilter addTarget:(GPUImageView* )_contentView];
    [_picture processImage];
    [_picture processImageWithCompletionHandler:^{
        [_blurFilter removeAllTargets];
    }];
#else
    NSAssert(false, @"The project does not contain GPUImage framework");
#endif
}


@end


@implementation UIVisualEffectView (GAEffectView)

- (void)setCurEffectScheme:(GAVisualEffectScheme)curEffectScheme{
    NSAssert(false, @"Under iOS9 should not use this property, you should add system version of judgment logic.");
    objc_setAssociatedObject(self, _cmd, @(curEffectScheme), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (GAVisualEffectScheme)curEffectScheme{
    NSAssert(false, @"Under iOS9 should not use this property, you should add system version of judgment logic.");
    return [objc_getAssociatedObject(self, @selector(setCurEffectScheme:)) integerValue];
}

@end

