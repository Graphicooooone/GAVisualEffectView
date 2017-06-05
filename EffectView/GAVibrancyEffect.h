//
//  GAVibrancyEffect.h
//  iOS7Late
//
//  Created by Peter Gra on 2017/6/5.
//  Copyright © 2017年 Peter Gra. All rights reserved.
//

#import "GAVisualEffect.h"

@class GABlurEffect;

NS_ASSUME_NONNULL_BEGIN

@interface GAVibrancyEffect : GAVisualEffect

+ (instancetype)effectForBlurEffect:(GABlurEffect *)blurEffect;

@end

NS_ASSUME_NONNULL_END
