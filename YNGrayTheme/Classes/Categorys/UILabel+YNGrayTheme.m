//
//  UILabel+YNGrayTheme.m
//  handhelddoctor
//
//  Created by YN on 202/10/21.
//  Copyright © 2022 karl. All rights reserved.
//

#import "UILabel+YNGrayTheme.h"
#include <objc/runtime.h>
#import "YNGrayThemeManager.h"

@implementation UILabel (YNGrayTheme)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(setTextColor:),
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

- (void)YN_setTextColor:(UIColor *)textColor {
    if ([YNGrayThemeManager hasUIView:self]) {
        UIColor *newColor = [YNGrayThemeManager makeGrayColor:textColor];
        [self YN_setTextColor:newColor];
    } else {
        [self YN_setTextColor:textColor];
    }
}

@end
