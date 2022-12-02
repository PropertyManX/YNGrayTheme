//
//  UIView+YNGrayTheme.m
//  handhelddoctor
//
//  Created by YN on 2022/11/23.
//  Copyright © 2022 karl. All rights reserved.
//

#import "UIView+YNGrayTheme.h"
#include <objc/runtime.h>
#import "YNGrayThemeManager.h"

@implementation UIView (YNGrayTheme)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(setBackgroundColor:),
            @selector(setTintColor:),
            @selector(addSubview:),
            @selector(insertSubview:atIndex:),
            @selector(insertSubview:belowSubview:),
            @selector(insertSubview:aboveSubview:),
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
            SEL systemSel = selectors[index];
            SEL swizzSel = NSSelectorFromString([@"YN_" stringByAppendingString:NSStringFromSelector(systemSel)]);
            Method systemMethod = class_getInstanceMethod([self class], systemSel);
            Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
            method_exchangeImplementations(systemMethod, swizzMethod);
        }
    });
}

- (void)YN_insertSubview:(UIView *)view atIndex:(NSInteger)index {
    if ([YNGrayThemeManager hasUIView:self]) {
        [YNGrayThemeManager handleGrayThemeWithSuperView:view];
    }
    [self YN_insertSubview:view atIndex:index];
}

- (void)YN_insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    if ([YNGrayThemeManager hasUIView:self]) {
        [YNGrayThemeManager handleGrayThemeWithSuperView:view];
    }
    [self YN_insertSubview:view aboveSubview:siblingSubview];
}

- (void)YN_insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
    if ([YNGrayThemeManager hasUIView:self]) {
        [YNGrayThemeManager handleGrayThemeWithSuperView:view];
    }
    [self YN_insertSubview:view belowSubview:siblingSubview];
}

- (void)YN_addSubview:(UIView *)view {
    [self YN_addSubview:view];
     if ([YNGrayThemeManager hasUIView:self]) {
         [YNGrayThemeManager handleGrayThemeWithSuperView:view];
     }
}

- (void)YN_setBackgroundColor:(UIColor *)backgroundColor {
    if ([YNGrayThemeManager hasUIView:self]) {
        UIColor *newColor = [YNGrayThemeManager makeGrayColor:backgroundColor];
        [self YN_setBackgroundColor:newColor];
    } else {
        [self YN_setBackgroundColor:backgroundColor];
    }
}

- (void)YN_setTintColor:(UIColor *)tintColor {
    if ([YNGrayThemeManager hasUIView:self]) {
        UIColor *newColor = [YNGrayThemeManager makeGrayColor:tintColor];
        [self YN_setTintColor:newColor];
    } else {
        [self YN_setTintColor:tintColor];
    }
}

@end
