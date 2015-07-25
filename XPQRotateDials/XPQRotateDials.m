//
//  XPQRotateDials.m
//  XPQRotateDials
//
//  Created by RHC on 15/7/24.
//  Copyright (c) 2015年 com.launch. All rights reserved.
//

#import "XPQRotateDials.h"

@interface XPQRotateDials () {
    CGFloat _radii;
    CGPoint _dialCenter;
    CGFloat _rulingWidth;
}

@property (nonatomic) CGFloat needleAngle;

@property (nonatomic, weak) UIImageView *needleView;
@property (nonatomic, weak) UIImageView *backgroundView;
@property (nonatomic, weak) UILabel *valueLabel;
@end

@implementation XPQRotateDials

-(instancetype)init {
    self = [super init];
    if (self) {
        [self configSelf];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configSelf];
        [self adjustSubview];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configSelf];
    }
    return self;
}

- (void)configSelf {
    // 初始值
    _minValue = 0.0;
    _maxValue = 1.0;
    _rulingStartAngle = -225.0;
    _rulingStopAngle = 45.0;
    _rulingCount = 10;
    _rulingTextColor = [UIColor blackColor];
    _rulingTextFont = [UIFont systemFontOfSize:20];
    _showSubRuling = YES;
    _subRulingStartAngle = -225.0;
    _subRulingStopAngle = 45.0;
    _subRulingCount = 10;
    _subRulingTextColor = [UIColor blackColor];
    _subRulingTextFont = [UIFont systemFontOfSize:10];
    _warningValue = DBL_MAX;
    _animationEnable = YES;
    _animationTime = 1.0;
    
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.textColor = [UIColor redColor];
    [self addSubview:valueLabel];
    self.valueLabel = valueLabel;
}

#pragma mark -属性
-(void)setNeedleImage:(UIImage *)needleImage {
    _needleImage = needleImage;
    UIImageView *needleView = [[UIImageView alloc] initWithImage:needleImage];
    needleView.frame = self.bounds;
    [self addSubview:needleView];
    self.needleView = needleView;
    self.value = self.minValue;
}

-(void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundView.frame = self.bounds;
    [self addSubview:backgroundView];
    self.backgroundView = backgroundView;
    [self sendSubviewToBack:self.backgroundView];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    // 中心点
    _dialCenter = CGPointMake(frame.size.width / 2, frame.size.height / 2);
    // 半径
    _radii = (frame.size.height < frame.size.width ? frame.size.height : frame.size.width) / 2;
    // 根据图大小来计算刻度线宽度
    _rulingWidth = _radii / 50;
    
    [self adjustSubview];
}

-(void)setValue:(CGFloat)value {
    if (value > self.maxValue) {
        value = self.maxValue;
    }
    if (value < self.minValue) {
        value = self.minValue;
    }
    
    self.valueLabel.text = [NSString stringWithFormat:@"%.1lf", value];
    self.needleAngle = [self angleWithValue:value];
}

-(CGFloat)value {
    return [self valueWithAngle:_needleAngle];
}

-(void)setNeedleAngle:(CGFloat)needleAngle {
    // 因为指针指向上，所以要偏90度
    CGFloat oldAngle = _needleAngle + 90;
    _needleAngle = needleAngle;
    needleAngle += 90;
    
    if (self.animationEnable) {
        [self rotateAnimationWithAngle:oldAngle toAngle:needleAngle];
    }
    else {
        self.needleView.transform = CGAffineTransformMakeRotation(needleAngle * M_PI / 180);
    }
}

#pragma mark -画图
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawPuling:&context];
    if (self.isShowSubRuling) {
        [self drawSubPuling:&context];
    }
}

-(void)drawPuling:(CGContextRef *)context{
    // 刻度之间的角度
    CGFloat angle = (self.rulingStopAngle - self.rulingStartAngle) / self.rulingCount;
    // 警告开始角度
    CGFloat warningAngle = [self angleWithValue:self.warningValue];
    CGFloat warningIndex = (warningAngle - self.rulingStartAngle) / angle;
    
    // 画刻度线
    [self drawAllPulingLine:context perAngle:angle warningIndex:ceil(warningIndex)];
    // 画刻度点
    [self drawAllPulingPoint:context perAngle:angle warningIndex:ceil(warningIndex)];
    // 画刻度文本
    [self drawAllPulingText:context perAngle:angle warningIndex:ceil(warningIndex)];
}

-(void)drawSubPuling:(CGContextRef *)context {
    static const float lineStartScale = 0.45;
    static const float lineEndScale = 0.40;
    static const float pointScale = 0.425;
    static const float textScale = 0.32;
    
    // 刻度之间的角度
    CGFloat angle = (self.subRulingStopAngle - self.subRulingStartAngle) / self.subRulingCount;
    NSDictionary *attributes = @{NSFontAttributeName:self.subRulingTextFont, NSForegroundColorAttributeName:self.subRulingTextColor};
    
    CGContextSetStrokeColorWithColor(*context, self.subRulingColor.CGColor);
    CGContextSetFillColorWithColor(*context, self.subRulingColor.CGColor);
    CGContextSetLineWidth(*context, _rulingWidth / 2);
    for (int i = 0; i <= self.subRulingCount; i++) {
        [self drawPulingLine:context angle:((self.rulingStartAngle + i * angle) * M_PI / 180) pathStartScale:lineStartScale pathEndScale:lineEndScale];
    }
    CGContextStrokePath(*context);
    
    CGFloat startAngle = self.subRulingStartAngle + angle / 2;
    for (int i = 0; i < self.subRulingCount; i++) {
        [self drawPulingPoint:context angle:((startAngle + i * angle) * M_PI / 180) pointSize:_rulingWidth / 2 pathScale:pointScale];
    }
    CGContextStrokePath(*context);
    
    for (int i = 0; i <= self.subRulingCount && i < self.subRulingText.count; i++) {
        [self drawPulingText:context angle:((self.subRulingStartAngle + i * angle) * M_PI / 180) text:self.subRulingText[i] attributes:attributes textScale:textScale];
    }
    CGContextStrokePath(*context);
}

/**
 *  @brief  画所有的主圈刻度线
 *  @param  center  画布中心点
 *  @param  radii   半径
 *  @param  perAngle    刻度线之间角度差
 *  @param  warningIndex    警告值开始的索引
 */
-(void)drawAllPulingLine:(CGContextRef *)context perAngle:(CGFloat)angle warningIndex:(int)warningIndex {
    static const float pathStartScale = 0.85;
    static const float pathEndScale = 0.73;
    
    CGContextSetStrokeColorWithColor(*context, self.rulingLineColor.CGColor);
    CGContextSetLineWidth(*context, _rulingWidth);
    for (int i = 0; i <= self.rulingCount && i < warningIndex; i++) {
        [self drawPulingLine:context angle:((self.rulingStartAngle + i * angle) * M_PI / 180) pathStartScale:pathStartScale pathEndScale:pathEndScale];
    }
    CGContextStrokePath(*context);
    // 警告值后的刻度
    if (self.warningValue <= self.maxValue) {
        CGContextSetStrokeColorWithColor(*context, [UIColor redColor].CGColor);
        CGContextSetLineWidth(*context, _rulingWidth);
        for (int i = warningIndex; i <= self.rulingCount; i++) {
            [self drawPulingLine:context angle:((self.rulingStartAngle + i * angle) * M_PI / 180) pathStartScale:pathStartScale pathEndScale:pathEndScale];
        }
        CGContextStrokePath(*context);
    }
}

/**
 *  @brief  画所有的主圈刻度点
 *  @param  center  画布中心点
 *  @param  radii   半径
 *  @param  perAngle    刻度线之间角度差
 *  @param  warningIndex    警告值开始的索引
 */
-(void)drawAllPulingPoint:(CGContextRef *)context perAngle:(CGFloat)angle warningIndex:(int)warningIndex {
    static const float pathScale = 0.82;
    
    CGContextSetFillColorWithColor(*context, self.rulingPointColor.CGColor);
    CGFloat startAngle = self.rulingStartAngle + angle / 2;
    for (int i = 0; i < self.rulingCount && i < warningIndex; i++) {
        [self drawPulingPoint:context angle:((startAngle + i * angle) * M_PI / 180) pointSize:_rulingWidth pathScale:pathScale];
    }
    CGContextStrokePath(*context);
    // 警告值后的刻度
    if (self.warningValue <= self.maxValue) {
        CGContextSetFillColorWithColor(*context, [UIColor redColor].CGColor);
        CGContextSetLineWidth(*context, _rulingWidth);
        for (int i = ceil(warningIndex); i < self.rulingCount; i++) {
            [self drawPulingPoint:context angle:((startAngle + i * angle) * M_PI / 180) pointSize:_rulingWidth pathScale:pathScale];
        }
        CGContextStrokePath(*context);
    }
}

/**
 *  @brief  画所有的主圈刻度文本
 *  @param  center  画布中心点
 *  @param  radii   半径
 *  @param  perAngle    刻度线之间角度差
 *  @param  warningIndex    警告值开始的索引
 */
-(void)drawAllPulingText:(CGContextRef *)context perAngle:(CGFloat)angle warningIndex:(int)warningIndex {
    static const float textScale = 0.60;
    
    NSDictionary *attributes = @{NSFontAttributeName:self.rulingTextFont, NSForegroundColorAttributeName:self.rulingTextColor};
    CGContextSetLineWidth(*context, _rulingWidth);
    for (int i = 0; i <= self.rulingCount && i < self.rulingText.count && i < warningIndex; i++) {
        [self drawPulingText:context angle:((self.rulingStartAngle + i * angle) * M_PI / 180) text:self.rulingText[i] attributes:attributes textScale:textScale];
    }
    CGContextStrokePath(*context);
    // 警告值后的刻度
    if (self.warningValue <= self.maxValue) {
        attributes = @{NSFontAttributeName:self.rulingTextFont, NSForegroundColorAttributeName:[UIColor redColor]};
        CGContextSetLineWidth(*context, _rulingWidth);
        for (int i = ceil(warningIndex); i <= self.rulingCount && i < self.rulingText.count; i++) {
            [self drawPulingText:context angle:((self.rulingStartAngle + i * angle) * M_PI / 180) text:self.rulingText[i] attributes:attributes textScale:textScale];
        }
        CGContextStrokePath(*context);
    }
}

/**
 *  @brief  画刻度线
 *  @param  context 上下文环境
 *  @param  center  画布中心点
 *  @param  radii   半径
 *  @param  angle   刻度线所在角度
 *  @param  pathStartScale  刻度线所在位置比例，既在半径上的百分比
 *  @param  pathEndScale    pathStartScale必须大于pathEndScale，不然会有误差
 */
- (void)drawPulingLine:(CGContextRef *)context angle:(CGFloat)angle pathStartScale:(CGFloat)pathStartScale pathEndScale:(CGFloat)pathEndScale {
    // 因为画线的点是画线的左侧点，会有一点偏差，这里纠正过来
    CGFloat offset = asin((_rulingWidth / 2) / (pathStartScale * _radii));
    angle += offset;
    
    // 计算刻度线两端的点
    // 计算公式为：所在比例 * cos或者sin * 半径 + 中心点x或者y
    CGFloat x1 = pathStartScale * cos(angle) * _radii + _dialCenter.x;
    CGFloat y1 = pathStartScale * sin(angle) * _radii + _dialCenter.x;
    CGFloat x2 = pathEndScale * cos(angle) * _radii + _dialCenter.x;
    CGFloat y2 = pathEndScale * sin(angle) * _radii + _dialCenter.x;
    CGContextMoveToPoint(*context, x1, y1);
    CGContextAddLineToPoint(*context, x2, y2);
}

/**
 *  @brief  画刻度点
 *  @param  context 上下文环境
 *  @param  center  画布中心点
 *  @param  radii   半径
 *  @param  angle   刻度点所在角度
 *  @param  pathScale   刻度点中心所在半径上的百分比
 */
- (void)drawPulingPoint:(CGContextRef *)context angle:(CGFloat)angle pointSize:(CGFloat)pointSize pathScale:(CGFloat)pathScale {
    // 计算刻度点的中心
    // 计算公式为：所在比例 * cos或者sin * 半径 + 中心点x或者y
    CGFloat x = pathScale * cos(angle) * _radii + _dialCenter.x;
    CGFloat y = pathScale * sin(angle) * _radii + _dialCenter.y;
    CGContextMoveToPoint(*context, x, y);
    CGContextAddArc(*context, x, y, pointSize, 0, 2 * M_PI, 0);
    CGContextDrawPath(*context, kCGPathFill);//绘制填充
}

/**
 *  @brief  画刻度文本
 *  @param  context 上下文环境
 *  @param  center  画布中心点
 *  @param  radii   半径
 *  @param  angle   刻度点所在角度
 *  @param  text    文本内容
 *  @param  attributes  富文本属性
 *  @param  textScale   刻度文本中心所在半径上的百分比
 */
- (void)drawPulingText:(CGContextRef *)context angle:(CGFloat)angle text:(NSString *)text attributes:(NSDictionary *)attributes textScale:(CGFloat)textScale {
    // 计算文本需要占的大小
    CGSize textSize = [text sizeWithAttributes:attributes];
    // 计算文本的左上角位置
    CGFloat x = textScale * cos(angle) * _radii + _dialCenter.x - textSize.width / 2;
    CGFloat y = textScale * sin(angle) * _radii + _dialCenter.y - textSize.height / 2;
    
    [text drawAtPoint:CGPointMake(x, y) withAttributes:attributes];
}

#pragma mark -辅助函数
// 调整子视图位置
-(void)adjustSubview {
    CGRect rect = CGRectMake(_dialCenter.x - _radii, _dialCenter.y - _radii, 2 * _radii, 2 * _radii);
    self.backgroundView.frame = rect;
    self.needleView.frame = rect;
    self.valueLabel.frame = CGRectMake(0.75 * _radii, 1.44 * _radii, 0.5 * _radii, 0.28 * _radii);
}

// 值转成角度
-(CGFloat)angleWithValue:(CGFloat)value {
    CGFloat rangVale = self.maxValue - self.minValue;
    CGFloat rangAngle = self.rulingStopAngle - self.rulingStartAngle;
    return (value - self.minValue) / rangVale * rangAngle + self.rulingStartAngle;
}

// 角度转成值
-(CGFloat)valueWithAngle:(CGFloat)angle {
    CGFloat rangVale = self.maxValue - self.minValue;
    CGFloat rangAngle = self.rulingStopAngle - self.rulingStartAngle;
    return (angle - self.rulingStartAngle) / rangAngle * rangVale + self.minValue;
}

#pragma mark -动画
-(void)rotateAnimationWithAngle:(CGFloat)oldAngle toAngle:(CGFloat)newAngle {
    CGFloat stepAngle = fabs(newAngle - oldAngle);
    if (stepAngle < 180) {
        [UIView beginAnimations:@"rotation" context:NULL];
        [UIView setAnimationDuration:self.animationTime];
        self.needleView.transform = CGAffineTransformMakeRotation(newAngle * M_PI / 180);
        [UIView commitAnimations];
    }
    else {
        // UIView的旋转动画会自动选择小角度旋转，所以大于180度角的分两段执行
        CGFloat anlge1 = newAngle < oldAngle ? 180.1 : 179.9;
        CGFloat time1 = anlge1 / stepAngle * self.animationTime;
        [UIView beginAnimations:@"rotation" context:NULL];
        [UIView setAnimationDuration:time1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.needleView.transform = CGAffineTransformMakeRotation((oldAngle + anlge1) * M_PI / 180);
        [UIView commitAnimations];
        
        
        [UIView beginAnimations:@"rotation" context:NULL];
        [UIView setAnimationDelay:time1];
        [UIView setAnimationDuration:self.animationTime - time1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.needleView.transform = CGAffineTransformMakeRotation(newAngle * M_PI / 180);
        [UIView commitAnimations];
    }
}
@end