//
//  YNGrayThemeManager.m
//  handhelddoctor
//
//  Created by YN on 2022/11/27.
//  Copyright © 2022 karl. All rights reserved.
//

#import "YNGrayThemeManager.h"

@interface YNGrayThemeManager ()

@property(nonatomic, strong) NSHashTable <CALayer *>*layerList; // 缓存 CALayer
@property(nonatomic, strong) NSHashTable <UIView *>*viewList;   // 缓存 UIView
//用这个保证请求数据延时的时候，要么都置灰，要么都不置灰
@property(nonatomic, strong) NSNumber *canGrayFlag;
@property (nonatomic, assign) BOOL isForceGray;

@end

@implementation YNGrayThemeManager

+ (instancetype)sharedInstance {
    static YNGrayThemeManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+ (void)setGlobalGayByForce:(BOOL)isForceGray {
    [YNGrayThemeManager sharedInstance].isForceGray = isForceGray;
}

// 把该控件以及它的子控件置灰，并且添加到缓存中
+ (void)handleGrayThemeWithSuperView:(UIView *)superView {
    if (![[YNGrayThemeManager sharedInstance] __canSetGray]) {
        return;
    }
    if (superView == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[YNGrayThemeManager sharedInstance] __makeCurrentViewGray:superView];
        [[YNGrayThemeManager sharedInstance] __makeSubviewsGrayWithSuperView:superView];
        [[YNGrayThemeManager sharedInstance] __makeCurrentLayerGray:superView.layer];
        [[YNGrayThemeManager sharedInstance] __makeSublayersGrayWithSuperLayer:superView.layer];
    });
}

+ (void)handleGrayThemeWithSuperLayer:(CALayer *)superLayer {
    if (![[YNGrayThemeManager sharedInstance] __canSetGray]) {
        return;
    }
    if (superLayer == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[YNGrayThemeManager sharedInstance] __makeSublayersGrayWithSuperLayer:superLayer];
        [[YNGrayThemeManager sharedInstance] __makeCurrentLayerGray:superLayer];
    });
}

+ (void)configCanGray:(BOOL)canGray {
    if ([YNGrayThemeManager sharedInstance].canGrayFlag == nil) {
        if (canGray) {
            [YNGrayThemeManager sharedInstance].canGrayFlag = @1;
        } else {
            [YNGrayThemeManager sharedInstance].canGrayFlag = @0;
        }
    }
}

#pragma mark - 私有方法


// 是否可以置灰
- (BOOL)__canSetGray {
    BOOL canGray = NO;
    // 用这个保证请求数据延时的时候，要么都置灰，要么都不置灰
    if (self.canGrayFlag == nil) {
        self.canGrayFlag = @0;
    } else if (self.canGrayFlag.integerValue == 1) {
        canGray = YES;
    }
    return canGray;
}

// 把所有子View的UI置灰，此方法递归调用
- (void)__makeSubviewsGrayWithSuperView:(UIView *)superView {
    for (UIView *view in superView.subviews) {
        [self __makeCurrentViewGray:view];
        [self __makeSubviewsGrayWithSuperView:view];
    }
}

// 当前View根据类型置灰，并且添加到缓存
- (void)__makeCurrentViewGray:(UIView *)view {
    if ([self.viewList containsObject:view]) {
        return;
    }
    [self.viewList addObject:view];
    view.backgroundColor = [YNGrayThemeManager makeGrayColor:view.backgroundColor];
    view.tintColor = [YNGrayThemeManager makeGrayColor:view.tintColor];
    // 根据类型判断处理
    if ([view isKindOfClass:[UIImageView class]]) {
        UIImageView *imgView = (UIImageView *)view;
        imgView.image = [YNGrayThemeManager makeGrayImage:imgView.image];
        if (imgView.animationImages.count > 0) {
            NSMutableArray *imageArr = [[NSMutableArray alloc] init];
            for (UIImage *img in imgView.animationImages) {
                [imageArr addObject:[YNGrayThemeManager makeGrayImage:img]];
            }
            imgView.animationImages = imageArr;
        }
    } else if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        label.textColor = [YNGrayThemeManager makeGrayColor:label.textColor];
    }  else if ([view isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)view;
        textField.textColor = [YNGrayThemeManager makeGrayColor:textField.textColor];
    }  else if ([view isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)view;
        textView.textColor = [YNGrayThemeManager makeGrayColor:textView.textColor];
    }
}

// 把所有子Layer的UI置灰，此方法递归调用
- (void)__makeSublayersGrayWithSuperLayer:(CALayer *)superLayer {
    for (CALayer *layer in superLayer.sublayers) {
        [self __makeSublayersGrayWithSuperLayer:layer];
        [self __makeCurrentLayerGray:layer];
    }
}

// 当前Layer根据类型置灰，并且添加到缓存
- (void)__makeCurrentLayerGray:(CALayer *)layer {
    if ([self.layerList containsObject:layer]) {
        return;
    }
    [self.layerList addObject:layer];
    // 处理当前view的layer
    layer.backgroundColor = [YNGrayThemeManager makeGrayColor:[UIColor colorWithCGColor:layer.backgroundColor]].CGColor;
    layer.shadowColor = [YNGrayThemeManager makeGrayColor:[UIColor colorWithCGColor:layer.shadowColor]].CGColor;
    layer.borderColor = [YNGrayThemeManager makeGrayColor:[UIColor colorWithCGColor:layer.borderColor]].CGColor;
}

#pragma mark - 工具方法

// 把图片设置为灰色
+ (UIImage *)makeGrayImage:(UIImage *)image {
    //修改饱和度为0
    CIImage *beginImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter * filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    //饱和度 0---2 默认为1
    [filter setValue:0 forKey:@"inputSaturation"];
    // 得到过滤后的图片
    CIImage *outputImage = [filter outputImage];
    // 转换图片, 创建基于GPU的CIContext对象
    CIContext *context = [CIContext contextWithOptions: nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg scale:image.scale orientation:image.imageOrientation];
    // 释放C对象
    CGImageRelease(cgimg);
    return newImg;
}

// 把颜色改为灰色
+ (UIColor *)makeGrayColor:(UIColor *)color {
    if (CGColorGetNumberOfComponents(color.CGColor) == 4) {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        CGFloat r = components[0];
        CGFloat g = components[1];
        CGFloat b = components[2];
        CGFloat a = components[3];
        CGFloat average = (r + g + b)/3.0;
        return [UIColor colorWithRed:average green:average blue:average alpha:a];
    } else {
        return color;
    }
}

#pragma mark - 判断该控件是否在缓存中

+ (BOOL)hasCALayer:(CALayer *)layer {
    if ([YNGrayThemeManager sharedInstance].isForceGray) {
        return  YES;
    }
    if ([YNGrayThemeManager sharedInstance].canGrayFlag.intValue != 1) {
        return NO;
    }
    return  [[YNGrayThemeManager sharedInstance].layerList containsObject:layer];
}

+ (BOOL)hasUIView:(UIView *)view {
    if ([YNGrayThemeManager sharedInstance].isForceGray) {
        return  YES;
    }
    if ([YNGrayThemeManager sharedInstance].canGrayFlag.intValue != 1) {
        return NO;
    }
    return  [[YNGrayThemeManager sharedInstance].viewList containsObject:view];
}

#pragma mark - 缓存懒加载
- (NSHashTable *)viewList {
    if (!_viewList) {
        _viewList = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _viewList;
}

- (NSHashTable *)layerList {
    if (!_layerList) {
        _layerList = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _layerList;
}



@end
