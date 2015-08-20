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
@property (nonatomic, weak) UILabel *valueLabel;
@property (nonatomic, weak) UIImageView *titleImageView;
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
    [self configParam];
    [self configSubview];
}

-(void)configParam {
    // 初始值
    _minValue = 0.0;
    _maxValue = 1.0;
    _rulingStartAngle = -225.0;
    _rulingStopAngle = 45.0;
    _rulingCount = 10;
    _rulingTextColor = [UIColor blackColor];
    _rulingTextFont = [UIFont systemFontOfSize:20];
    _showSubRuling = YES;
    _subMinValue = 0.0;
    _subMaxValue = 1.0;
    _subRulingStartAngle = -225.0;
    _subRulingStopAngle = 45.0;
    _subRulingCount = 10;
    _subRulingTextColor = [UIColor blackColor];
    _subRulingTextFont = [UIFont systemFontOfSize:10];
    _warningValue = DBL_MAX;
    _warningWiggleEnable = YES;
    _animationEnable = YES;
    _animationTime = 0.5;
    _titleColor = [UIColor whiteColor];
    _titleFont = [UIFont systemFontOfSize:20];
}

-(void)configSubview {
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.textColor = [UIColor redColor];
    valueLabel.frame = CGRectMake(_dialCenter.x - 0.25 * _radii, _dialCenter.y + 0.44 * _radii, 0.5 * _radii, 0.28 * _radii);
    [self addSubview:valueLabel];
    self.valueLabel = valueLabel;
}

#pragma mark -属性
-(void)setNeedleImage:(UIImage *)needleImage {
    _needleImage = needleImage;
    UIImageView *needleView = [[UIImageView alloc] initWithImage:_needleImage];
    needleView.frame = CGRectMake(_dialCenter.x - _radii, _dialCenter.y - _radii, 2 * _radii, 2 * _radii);
    [self addSubview:needleView];
    [self.needleView removeFromSuperview];
    self.needleView = needleView;
    self.value = self.minValue;
}

-(void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    self.backgroundColor = [UIColor colorWithPatternImage:[self adjustImageSize:backgroundImage]];
    NSLog(@"%s", __FUNCTION__);
}

-(void)setTitleImage:(UIImage *)titleImage {
    _titleImage = titleImage;
    [self.titleImageView removeFromSuperview];
    if (titleImage == nil) {
        self.titleImageView = nil;
    }
    else {
        UIImageView *view = [[UIImageView alloc] initWithImage:titleImage];
        self.titleImageView = view;
        [self addSubview:view];
        self.titleImageView.frame = CGRectMake(_dialCenter.x - 0.12 * _radii, _dialCenter.y + 0.1 * _radii, 0.24 * _radii, 0.24 * _radii);
    }    
}

-(void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    // 中心点
    _dialCenter = CGPointMake(bounds.size.width / 2, bounds.size.height / 2);
    // 半径
    _radii = (bounds.size.height < bounds.size.width ? bounds.size.height : bounds.size.width) / 2;
    // 根据图大小来计算刻度线宽度
    _rulingWidth = _radii / 50;
    if (_rulingWidth > 0.1) {
        [self adjustSubview];
    }
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    // 中心点
    _dialCenter = CGPointMake(frame.size.width / 2, frame.size.height / 2);
    // 半径
    _radii = (frame.size.height < frame.size.width ? frame.size.height : frame.size.width) / 2;
    // 根据图大小来计算刻度线宽度
    _rulingWidth = _radii / 50;
    if (_rulingWidth > 0.1) {
        [self adjustSubview];
    }
}

-(void)setValue:(CGFloat)value {
    if (value > self.maxValue) {
        value = self.maxValue;
    }
    if (value < self.minValue) {
        value = self.minValue;
    }
    
    if (self.isWarningWiggleEnable) {
        if (value > self.warningValue) {
            // 这里如果不采用延时调用启动动画，而是直接在动画里设置延时参数的画，则会在旋转读书大于180°时第一段动画无法执行。
            [self performSelector:@selector(startWiggleAnimationView:) withObject:self.needleView afterDelay:self.animationTime];
//            [self startWiggleAnimationView:self.needleView];
        }
        else {
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startWiggleAnimationView:) object:self.needleView];
            [self stopWiggleAnimationView:self.needleView];
        }
    }
    
    self.valueLabel.text = [NSString stringWithFormat:@"%.1lf", value];
    self.needleAngle = [self angleWithValue:value];
}

-(CGFloat)value {
    return [self valueWithAngle:_needleAngle];
}

-(void)setSubValue:(CGFloat)subValue {
    self.value = subValue / (self.subMaxValue - self.subMinValue) * (self.maxValue - self.minValue);
}

-(CGFloat)subValue {
    return [self subValueWithSubAngle:_needleAngle];
}
-(void)setValueColor:(UIColor *)valueColor {
    self.valueLabel.textColor = valueColor;
}

-(UIColor *)valueColor {
    return self.valueLabel.textColor;
}

-(void)setValueFont:(UIFont *)valueFont {
    self.valueLabel.font = valueFont;
}

-(UIFont *)valueFont {
    return self.valueLabel.font;
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
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawRuling:&context];
    if (self.isShowSubRuling) {
        [self drawSubRuling:&context];
    }
    [self drawTitle:&context];
}

-(void)drawTitle:(CGContextRef *)context {
    if (self.titleImage == nil) {
        NSDictionary *attributes = @{NSFontAttributeName:self.titleFont,
                                     NSForegroundColorAttributeName:self.titleColor};
        CGContextSetLineWidth(*context, _rulingWidth);
        [self drawRulingText:context angle:M_PI_2 text:self.title attributes:attributes textScale:0.2];
    }
}

-(void)drawRuling:(CGContextRef *)context {
    // 刻度之间的角度
    CGFloat angle = (self.rulingStopAngle - self.rulingStartAngle) / self.rulingCount;
    // 警告开始角度
    CGFloat warningAngle = [self angleWithValue:self.warningValue];
    CGFloat warningIndex = (warningAngle - self.rulingStartAngle) / angle;
    
    // 画刻度线
    [self drawAllRulingLine:context perAngle:angle warningIndex:ceil(warningIndex)];
    // 画刻度点
    [self drawAllRulingPoint:context perAngle:angle warningIndex:ceil(warningIndex)];
    // 画刻度文本
    [self drawAllRulingText:context perAngle:angle warningIndex:ceil(warningIndex)];
}

-(void)drawSubRuling:(CGContextRef *)context {
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
        [self drawRulingLine:context angle:((self.rulingStartAngle + i * angle) * M_PI / 180) pathStartScale:lineStartScale pathEndScale:lineEndScale];
    }
    CGContextStrokePath(*context);
    
    CGFloat startAngle = self.subRulingStartAngle + angle / 2;
    for (int i = 0; i < self.subRulingCount; i++) {
        [self drawRulingPoint:context angle:((startAngle + i * angle) * M_PI / 180) pointSize:_rulingWidth / 2 pathScale:pointScale];
    }
    CGContextStrokePath(*context);
    
    // 单位
    [self drawRulingText:context angle:((self.subRulingStartAngle - angle / 2) * M_PI / 180) text:self.subRulingUnit attributes:attributes textScale:pointScale];
    
    for (int i = 0; i <= self.subRulingCount && i < self.subRulingText.count; i++) {
        [self drawRulingText:context angle:((self.subRulingStartAngle + i * angle) * M_PI / 180) text:self.subRulingText[i] attributes:attributes textScale:textScale];
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
-(void)drawAllRulingLine:(CGContextRef *)context perAngle:(CGFloat)angle warningIndex:(int)warningIndex {
    static const float pathStartScale = 0.85;
    static const float pathEndScale = 0.73;
    
    CGContextSetStrokeColorWithColor(*context, self.rulingLineColor.CGColor);
    CGContextSetLineWidth(*context, _rulingWidth);
    for (int i = 0; i <= self.rulingCount && i < warningIndex; i++) {
        [self drawRulingLine:context angle:((self.rulingStartAngle + i * angle) * M_PI / 180) pathStartScale:pathStartScale pathEndScale:pathEndScale];
    }
    CGContextStrokePath(*context);
    // 警告值后的刻度
    if (self.warningValue <= self.maxValue) {
        CGContextSetStrokeColorWithColor(*context, [UIColor redColor].CGColor);
        CGContextSetLineWidth(*context, _rulingWidth);
        for (int i = warningIndex; i <= self.rulingCount; i++) {
            [self drawRulingLine:context angle:((self.rulingStartAngle + i * angle) * M_PI / 180) pathStartScale:pathStartScale pathEndScale:pathEndScale];
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
-(void)drawAllRulingPoint:(CGContextRef *)context perAngle:(CGFloat)angle warningIndex:(int)warningIndex {
    static const float pathScale = 0.82;
    
    CGContextSetFillColorWithColor(*context, self.rulingPointColor.CGColor);
    CGFloat startAngle = self.rulingStartAngle + angle / 2;
    for (int i = 0; i < self.rulingCount && i < warningIndex; i++) {
        [self drawRulingPoint:context angle:((startAngle + i * angle) * M_PI / 180) pointSize:_rulingWidth pathScale:pathScale];
    }
    CGContextStrokePath(*context);
    // 警告值后的刻度
    if (self.warningValue <= self.maxValue) {
        CGContextSetFillColorWithColor(*context, [UIColor redColor].CGColor);
        CGContextSetLineWidth(*context, _rulingWidth);
        for (int i = ceil(warningIndex); i < self.rulingCount; i++) {
            [self drawRulingPoint:context angle:((startAngle + i * angle) * M_PI / 180) pointSize:_rulingWidth pathScale:pathScale];
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
-(void)drawAllRulingText:(CGContextRef *)context perAngle:(CGFloat)angle warningIndex:(int)warningIndex {
    static const float textScale = 0.60;
    
    CGContextSetLineWidth(*context, _rulingWidth);
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName:self.rulingTextColor};
    // 单位
    if (self.isShowSubRuling) {
        [self drawRulingText:context angle:((self.rulingStartAngle - angle / 2) * M_PI / 180) text:self.rulingUnit attributes:attributes textScale:0.7];
    }
    else {
        [self drawRulingText:context angle:3 * M_PI_2 text:self.rulingUnit attributes:attributes textScale:0.4];
    }
    CGContextStrokePath(*context);
    
    attributes = @{NSFontAttributeName:self.rulingTextFont,
                   NSForegroundColorAttributeName:self.rulingTextColor};
    for (int i = 0; i <= self.rulingCount && i < self.rulingText.count && i < warningIndex; i++) {
        [self drawRulingText:context angle:((self.rulingStartAngle + i * angle) * M_PI / 180) text:self.rulingText[i] attributes:attributes textScale:textScale];
    }
    CGContextStrokePath(*context);
    // 警告值后的刻度
    if (self.warningValue <= self.maxValue) {
        attributes = @{NSFontAttributeName:self.rulingTextFont, NSForegroundColorAttributeName:[UIColor redColor]};
        CGContextSetLineWidth(*context, _rulingWidth);
        for (int i = ceil(warningIndex); i <= self.rulingCount && i < self.rulingText.count; i++) {
            [self drawRulingText:context angle:((self.rulingStartAngle + i * angle) * M_PI / 180) text:self.rulingText[i] attributes:attributes textScale:textScale];
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
- (void)drawRulingLine:(CGContextRef *)context angle:(CGFloat)angle pathStartScale:(CGFloat)pathStartScale pathEndScale:(CGFloat)pathEndScale {
    // 因为画线的点是画线的左侧点，会有一点偏差，这里纠正过来
    CGFloat offset = asin((_rulingWidth / 2) / (pathStartScale * _radii));
    angle += offset;
    
    // 计算刻度线两端的点
    // 计算公式为：所在比例 * cos或者sin * 半径 + 中心点x或者y
    CGFloat x1 = pathStartScale * cos(angle) * _radii + _dialCenter.x;
    CGFloat y1 = pathStartScale * sin(angle) * _radii + _dialCenter.y;
    CGFloat x2 = pathEndScale * cos(angle) * _radii + _dialCenter.x;
    CGFloat y2 = pathEndScale * sin(angle) * _radii + _dialCenter.y;
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
- (void)drawRulingPoint:(CGContextRef *)context angle:(CGFloat)angle pointSize:(CGFloat)pointSize pathScale:(CGFloat)pathScale {
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
- (void)drawRulingText:(CGContextRef *)context angle:(CGFloat)angle text:(NSString *)text attributes:(NSDictionary *)attributes textScale:(CGFloat)textScale {
    // 计算文本需要占的大小
    CGSize textSize = [text sizeWithAttributes:attributes];
    // 计算文本的左上角位置
    CGFloat x = textScale * cos(angle) * _radii + _dialCenter.x - textSize.width / 2;
    CGFloat y = textScale * sin(angle) * _radii + _dialCenter.y - textSize.height / 2;
    
    [text drawAtPoint:CGPointMake(x, y) withAttributes:attributes];
}

#pragma mark -辅助函数
- (UIImage *)adjustImageSize:(UIImage *)image {
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(self.bounds.size);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(_dialCenter.x - _radii, _dialCenter.y - _radii, 2 * _radii, 2 * _radii)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

// 调整子视图位置
-(void)adjustSubview {
    self.valueLabel.frame = CGRectMake(_dialCenter.x - 0.25 * _radii, _dialCenter.y + 0.44 * _radii, 0.5 * _radii, 0.28 * _radii);

    self.titleImage = self.titleImage;
    self.backgroundImage = self.backgroundImage;
    self.needleImage = self.needleImage;
}

#pragma mark - 数值转换函数
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

-(CGFloat)subAngleWithSubValue:(CGFloat)value {
    CGFloat rangVale = self.subMaxValue - self.subMinValue;
    CGFloat rangAngle = self.subRulingStopAngle - self.subRulingStartAngle;
    return (value - self.subMinValue) / rangVale * rangAngle + self.subRulingStartAngle;
}

-(CGFloat)subValueWithSubAngle:(CGFloat)angle {
    CGFloat rangVale = self.subMaxValue - self.subMinValue;
    CGFloat rangAngle = self.subRulingStopAngle - self.subRulingStartAngle;
    return (angle - self.subRulingStartAngle) / rangAngle * rangVale + self.subMinValue;
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
        [UIView beginAnimations:@"rotation1" context:NULL];
        [UIView setAnimationDuration:time1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.needleView.transform = CGAffineTransformMakeRotation((oldAngle + anlge1) * M_PI / 180);
        [UIView commitAnimations];
        
        
        [UIView beginAnimations:@"rotation2" context:NULL];
        [UIView setAnimationDelay:time1];
        [UIView setAnimationDuration:self.animationTime - time1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.needleView.transform = CGAffineTransformMakeRotation(newAngle * M_PI / 180);
        [UIView commitAnimations];
    }
}

-(void)startWiggleAnimationView:(UIView *)view {
    CATransform3D transform = CATransform3DRotate(view.layer.transform, -0.05, 0, 0, 1.0);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    animation.autoreverses = YES;
    animation.duration = 0.05;   //间隔时间
    animation.repeatCount = FLT_MAX;   //重复的次数
    animation.delegate = self;
    [view.layer addAnimation:animation forKey:@"wiggleAnimation"];
}

-(void)stopWiggleAnimationView:(UIView *)view {
    [view.layer removeAnimationForKey:@"wiggleAnimation"];
}
@end
