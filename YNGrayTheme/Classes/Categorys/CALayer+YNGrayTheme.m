//
//  CALayer+YNGrayTheme.m
//  handhelddoctor
//
//  Created by YN on 2020/10/21.
//  Copyright © 2022 karl. All rights reserved.
//

#import "CALayer+YNGrayTheme.h"
#include <objc/runtime.h>
#import "YNGrayThemeManager.h"


@implementation CALayer (YNGrayTheme)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(setBackgroundColor:),
            @selector(setBorderColor:),
            @selector(setShadowColor:),
            @selector(addSublayer:),
            @selector(insertSublayer:atIndex:),
            @selector(insertSublayer:below:),
            @selector(insertSublayer:above:),
            @selector(replaceSublayer:with:),
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

- (void)YN_addSublayer:(CALayer *)layer {
    if ([YNGrayThemeManager hasCALayer:self]) {
        [YNGrayThemeManager handleGrayThemeWithSuperLayer:layer];
    }
    [self YN_addSublayer:layer];
}

- (void)YN_insertSublayer:(CALayer *)layer atIndex:(unsigned)idx {
    if ([YNGrayThemeManager hasCALayer:self]) {
        [YNGrayThemeManager handleGrayThemeWithSuperLayer:layer];
    }
    [self YN_insertSublayer:layer atIndex:idx];
}

- (void)YN_insertSublayer:(CALayer *)layer below:(nullable CALayer *)sibling {
    if ([YNGrayThemeManager hasCALayer:self]) {
        [YNGrayThemeManager handleGrayThemeWithSuperLayer:layer];
    }
    [self YN_insertSublayer:layer below:sibling];
}

- (void)YN_insertSublayer:(CALayer *)layer above:(nullable CALayer *)sibling {
    if ([YNGrayThemeManager hasCALayer:self]) {
        [YNGrayThemeManager handleGrayThemeWithSuperLayer:layer];
    }
    [self YN_insertSublayer:layer above:sibling];
}

- (void)YN_replaceSublayer:(CALayer *)oldLayer with:(CALayer *)newLayer {
    if ([YNGrayThemeManager hasCALayer:self]) {
        [YNGrayThemeManager handleGrayThemeWithSuperLayer:newLayer];
    }
    [self YN_replaceSublayer:oldLayer with:newLayer];
}

- (void)YN_setBackgroundColor:(CGColorRef)backgroundColor {
    if ([YNGrayThemeManager hasCALayer:self]) {
        CGColorRef newColorRef = [YNGrayThemeManager makeGrayColor:[UIColor colorWithCGColor:backgroundColor]].CGColor;
        [self YN_setBackgroundColor:newColorRef];
    } else {
        [self YN_setBackgroundColor:backgroundColor];
    }
}

- (void)YN_setBorderColor:(CGColorRef)borderColor {
    if ([YNGrayThemeManager hasCALayer:self]) {
        CGColorRef newColorRef  = [YNGrayThemeManager makeGrayColor:[UIColor colorWithCGColor:borderColor]].CGColor;
        [self YN_setBorderColor:newColorRef];
    } else {
        [self YN_setBorderColor:borderColor];
    }
}

- (void)YN_setShadowColor:(CGColorRef)shadowColor {
    if ([YNGrayThemeManager hasCALayer:self]) {
        CGColorRef newColorRef  = [YNGrayThemeManager makeGrayColor:[UIColor colorWithCGColor:shadowColor]].CGColor;
        [self YN_setShadowColor:newColorRef];
    } else {
        [self YN_setShadowColor:shadowColor];
    }
}

@end
