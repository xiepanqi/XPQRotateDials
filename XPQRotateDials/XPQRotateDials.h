//
//  XPQRotateDials.h
//  XPQRotateDials
//
//  Created by RHC on 15/7/24.
//  Copyright (c) 2015年 com.launch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XPQRotateDials : UIView
/// 最小值,默认0.0
@property (nonatomic) CGFloat minValue;
/// 最大值，默认1.0
@property (nonatomic) CGFloat maxValue;
/// 值，默认 0.0
@property (nonatomic) CGFloat value;
#pragma mark - 主刻度属性
/// 开始角度，默认-225.0°
@property (nonatomic) CGFloat rulingStartAngle;
/// 结束角度，默认45.0°
@property (nonatomic) CGFloat rulingStopAngle;
/// 刻度数量,默认10（除开其实刻度，也就是说如果该质为10则实际有11个刻度）
@property (nonatomic) NSUInteger rulingCount;
/// 刻度线颜色，默认黑色
@property (nonatomic, strong) UIColor *rulingLineColor;
/// 刻度点颜色，默认黑色
@property (nonatomic, strong) UIColor *rulingPointColor;
/// 刻度文字颜色，默认黑色
@property (nonatomic, strong) UIColor *rulingTextColor;
/// 刻度文字字体，默认[UIFont systemFontOfSize:20]
@property (nonatomic, strong) UIFont *rulingTextFont;
/// 文本数组，默认为nil
@property (nonatomic, strong) NSArray *rulingText;
/// 警告阀值,只对主刻度有效，次刻度无效,默认DBL_MAX
@property (nonatomic) CGFloat warningValue;
#pragma mark - 次刻度属性
/// 内圈刻度开始角度，默认-225.0°
@property (nonatomic) CGFloat subRulingStartAngle;
/// 内圈刻度结束角度，默认45.0°
@property (nonatomic) CGFloat subRulingStopAngle;
/// 内圈刻度数量,默认10
@property (nonatomic) NSUInteger subRulingCount;
/// 内圈刻度线和刻度点颜色，默认黑色
@property (nonatomic, strong) UIColor *subRulingColor;
/// 内圈刻度文字颜色，默认黑色
@property (nonatomic, strong) UIColor *subRulingTextColor;
/// 内圈刻度文字字体，默认[UIFont systemFontOfSize:10]
@property (nonatomic, strong) UIFont *subRulingTextFont;
/// 内圈刻度文本数组，默认为nil
@property (nonatomic, strong) NSArray *subRulingText;
#pragma mark - 指针属性
/// 指针图片，默认nil
@property (nonatomic, strong) UIImage *needleImage;
/// 是否启用指针转动动画，默认YES
@property (nonatomic,getter=isAnimationEnable) BOOL animationEnable;
/// 指针移动动画时间，默认1.0
@property (nonatomic) CGFloat animationTime;

/// 表盘标题,默认nil
@property (nonatomic, strong) NSString *title;

-(CGFloat)angleWithValue:(CGFloat)value;
-(CGFloat)valueWithAngle:(CGFloat)angle;
@end
