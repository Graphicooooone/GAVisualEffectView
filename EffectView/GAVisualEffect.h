//
//  GAVisualEffect.h
//  iOS7Late
//
//  Created by Peter Gra on 2017/6/5.
//  Copyright © 2017年 Peter Gra. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,GAVisualEffectScheme){
    GAVisualEffectScheme_Auto       = 0,
    ///< when using "GAVisualEffectScheme_Auto"
    ///< priority is GAVisualEffectScheme_CoreImage > GAVisualEffectScheme_GPUImage
    
    GAVisualEffectScheme_CoreImage  = 1,
    GAVisualEffectScheme_GPUImage   = 2,
};

typedef NS_ENUM(NSInteger, GABlurEffectStyle) {
    GABlurEffectStyleExtraLight,
    GABlurEffectStyleLight,
    GABlurEffectStyleDark,
    
    ///< null enum ....
    GABlurEffectStyleExtraDark __TVOS_AVAILABLE(10_0) __IOS_PROHIBITED __WATCHOS_PROHIBITED,
    GABlurEffectStyleRegular NS_ENUM_AVAILABLE_IOS(10_0), // Adapts to user interface style
    GABlurEffectStyleProminent NS_ENUM_AVAILABLE_IOS(10_0), // Adapts to user interface style
};

@interface GAVisualEffect : NSObject   @end

