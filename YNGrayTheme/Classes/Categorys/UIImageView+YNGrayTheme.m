//
//  UIImageView+YNGrayTheme.m
//  handhelddoctor
//
//  Created by YN on 2022/10/21.
//  Copyright © 2022 karl. All rights reserved.
//

#import "UIImageView+YNGrayTheme.h"
#include <objc/runtime.h>
#import "YNGrayThemeManager.h"

@implementation UIImageView (YNGrayTheme)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(setAnimationImages:),
            @selector(setImage:),
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

- (void)YN_setImage:(UIImage *)image {
    if ([YNGrayThemeManager hasUIView:self]) {
        UIImage *newImage = [YNGrayThemeManager makeGrayImage:image];
        [self YN_setImage:newImage];
    } else {
        [self YN_setImage:image];
    }
}

- (void)YN_setAnimationImages:(NSArray<UIImage *> *)animationImages {
    if ([YNGrayThemeManager hasUIView:self]) {
        NSMutableArray *imageArr = [[NSMutableArray alloc] init];
        for (UIImage *img in animationImages) {
            [imageArr addObject:[YNGrayThemeManager makeGrayImage:img]];
        }
        [self YN_setAnimationImages:imageArr];
    } else {
        [self YN_setAnimationImages:animationImages];
    }
}

@end
