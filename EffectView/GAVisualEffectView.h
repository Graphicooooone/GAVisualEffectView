//
//  GAVisualEffectView.h
//  iOS7Late
//
//  Created by Peter Gra on 2017/6/1.
//  Copyright © 2017年 Peter Gra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "GAVisualEffect.h"

NS_ASSUME_NONNULL_BEGIN

@interface GAVisualEffectView : UIView

@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, copy, nullable) GAVisualEffect *effect;

- (instancetype)initWithEffect:(nullable GAVisualEffect *)effect;

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder;

@property (nonatomic,assign) GAVisualEffectScheme curEffectScheme;///< Default is GAVisualEffectScheme_Auto ...

@end

NS_ASSUME_NONNULL_END

@interface UIVisualEffectView (GAEffectView)

@property (nonatomic,assign) GAVisualEffectScheme curEffectScheme;

@end
