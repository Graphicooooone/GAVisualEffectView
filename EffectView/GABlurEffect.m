//
//  GABlurEffect.m
//  iOS7Late
//
//  Created by Peter Gra on 2017/6/5.
//  Copyright © 2017年 Peter Gra. All rights reserved.
//

#import "GABlurEffect.h"

#import <objc/runtime.h>
#import <float.h>

__asm(
      ".section        __DATA,__objc_classrefs,regular,no_dead_strip\n"
#if	TARGET_RT_64_BIT
      ".align          3\n"
      "L_OBJC_CLASS_UIBlurEffect:\n"
      ".quad           _OBJC_CLASS_$_UIBlurEffect\n"
#else
      ".align          2\n"
      "_OBJC_CLASS_UIBlurEffect:\n"
      ".long           _OBJC_CLASS_$_UIBlurEffect\n"
#endif
      ".weak_reference _OBJC_CLASS_$_UIBlurEffect\n"
      );

__attribute__((constructor))
static void GABlurEffectRuntime(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            if (objc_getClass("UIBlurEffect")) {
                return;
            }
            
            Class * c = NULL;
            
#if TARGET_CPU_ARM
            __asm("movw %0, :lower16:(_OBJC_CLASS_UIBlurEffect-(LPC0+4))\n"
                  "movt %0, :upper16:(_OBJC_CLASS_UIBlurEffect-(LPC0+4))\n"
                  "LPC0: add %0, pc" : "=r"(c));
#elif TARGET_CPU_ARM64
            __asm("adrp %0, L_OBJC_CLASS_UIBlurEffect@PAGE\n"
                  "add  %0, %0, L_OBJC_CLASS_UIBlurEffect@PAGEOFF" : "=r"(c));
#elif TARGET_CPU_X86_64
            __asm("leaq L_OBJC_CLASS_UIBlurEffect(%%rip), %0" : "=r"(c));
#elif TARGET_CPU_X86
            void *pc = NULL;
            __asm("calll L0\n"
                  "L0: popl %0\n"
                  "leal _OBJC_CLASS_UIBlurEffect-L0(%0), %1" : "=r"(pc), "=r"(c));
#else
#error Unsupported CPU
#endif
            
            if (c && !*c) {
                Class class = objc_allocateClassPair([GABlurEffect class], "UIBlurEffect", 0);
                if (class) {
                    objc_registerClassPair(class);
                    *c = class;
                }
            }
        }
    });
}

#pragma mark - GABlurEffect
@implementation GABlurEffect
+ (instancetype)effectWithStyle:(GABlurEffectStyle)style{
    GABlurEffect* e = [GABlurEffect new];
    objc_setAssociatedObject(e, _cmd, @(style), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return e;
}
@end
