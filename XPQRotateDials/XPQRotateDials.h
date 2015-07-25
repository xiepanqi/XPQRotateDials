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
@property (nonatomic) IBInspectable CGFloat minValue;
/// 最大值，默认1.0
@property (nonatomic) IBInspectable CGFloat maxValue;
/// 值，默认 0.0
@property (nonatomic) IBInspectable CGFloat value;

#pragma mark - 主刻度属性
/// 开始角度，默认-225.0°
@property (nonatomic) IBInspectable CGFloat rulingStartAngle;
/// 结束角度，默认45.0°
@property (nonatomic) IBInspectable CGFloat rulingStopAngle;
/// 刻度数量,默认10（除开其实刻度，也就是说如果该质为10则实际有11个刻度）
@property (nonatomic) IBInspectable NSUInteger rulingCount;
/// 刻度单位，默认nil
@property (nonatomic, strong) IBInspectable NSString *rulingUnit;
/// 刻度线颜色，默认黑色
@property (nonatomic, strong) IBInspectable UIColor *rulingLineColor;
/// 刻度点颜色，默认黑色
@property (nonatomic, strong) IBInspectable UIColor *rulingPointColor;
/// 刻度文字颜色，默认黑色
@property (nonatomic, strong) IBInspectable UIColor *rulingTextColor;
/// 刻度文字字体，默认[UIFont systemFontOfSize:20]
@property (nonatomic, strong) UIFont *rulingTextFont;
/// 文本数组，默认为nil
@property (nonatomic, strong) NSArray *rulingText;
/// 警告阀值,只对主刻度有效，次刻度无效,默认DBL_MAX
@property (nonatomic) IBInspectable CGFloat warningValue;

#pragma mark - 次刻度属性
/// 是否显示次刻度
@property (nonatomic, getter=isShowSubRuling) IBInspectable BOOL showSubRuling;
/// 内圈刻度开始角度，默认-225.0°
@property (nonatomic) IBInspectable CGFloat subRulingStartAngle;
/// 内圈刻度结束角度，默认45.0°
@property (nonatomic) IBInspectable CGFloat subRulingStopAngle;
/// 内圈刻度数量,默认10
@property (nonatomic) IBInspectable NSUInteger subRulingCount;
/// 内圈刻度单位，默认nil
@property (nonatomic, strong) IBInspectable NSString *subRulingUnit;
/// 内圈刻度线和刻度点颜色，默认黑色
@property (nonatomic, strong) IBInspectable UIColor *subRulingColor;
/// 内圈刻度文字颜色，默认黑色
@property (nonatomic, strong) IBInspectable UIColor *subRulingTextColor;
/// 内圈刻度文字字体，默认[UIFont systemFontOfSize:10]
@property (nonatomic, strong) UIFont *subRulingTextFont;
/// 内圈刻度文本数组，默认为nil
@property (nonatomic, strong) NSArray *subRulingText;

#pragma mark - 指针属性
/// 指针图片，默认nil
@property (nonatomic, strong) IBInspectable UIImage *needleImage;
/// 背景图片,这其实不是真正的背景，是在刻度与指针之间的一个图层，这个图层可以做点处理让刻度盘看起来更有层次感。如果要使用正在的背景只能在父视图上加。默认nil
@property (nonatomic, strong) IBInspectable UIImage *backgroundImage;

#pragma mark - 动画属性
/// 是否启用指针转动动画，默认YES
@property (nonatomic,getter=isAnimationEnable) IBInspectable BOOL animationEnable;
/// 指针移动动画时间，默认1.0
@property (nonatomic) IBInspectable CGFloat animationTime;
#pragma mark - 标题
/// 表盘标题,默认nil
@property (nonatomic, strong) IBInspectable NSString *title;
/// 标题颜色，默认白色
@property (nonatomic, strong) IBInspectable UIColor *titleColor;
/// 标题字体，默认[UIFont systemFontOfSize:20]
@property (nonatomic, strong) UIFont *titleFont;

/*
 * @brief   值转化成指针对应的角度
 * @param   value   要转换的值
 * @return  转换后的角度
 */
-(CGFloat)angleWithValue:(CGFloat)value;

/*
 * @brief   指针的角度转换成对应的值
 * @param   value   要转换的角度
 * @return  转换后的值
 */
-(CGFloat)valueWithAngle:(CGFloat)angle;
@end
