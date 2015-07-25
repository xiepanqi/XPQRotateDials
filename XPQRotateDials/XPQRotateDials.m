//
//  XPQRotateDials.m
//  XPQRotateDials
//
//  Created by RHC on 15/7/24.
//  Copyright (c) 2015年 com.launch. All rights reserved.
//

#import "XPQRotateDials.h"

@interface XPQRotateDials () {
    CGFloat _rulingWidth;
}

@property (nonatomic) CGFloat needleAngle;

@property (nonatomic, strong) UIImageView *needleView;

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
    // 初始值
    _minValue = 0.0;
    _maxValue = 1.0;
    _rulingStartAngle = -225.0;
    _rulingStopAngle = 45.0;
    _rulingCount = 10;
    _rulingTextColor = [UIColor blackColor];
    _rulingTextFont = [UIFont systemFontOfSize:20];
    _subRulingStartAngle = -225.0;
    _subRulingStopAngle = 45.0;
    _subRulingCount = 10;
    _subRulingTextColor = [UIColor blackColor];
    _subRulingTextFont = [UIFont systemFontOfSize:10];
    _warningValue = DBL_MAX;
    _animationEnable = YES;
    _animationTime = 1.0;
}

#pragma mark -属性
-(void)setNeedleImage:(UIImage *)needleImage {
    _needleImage = needleImage;
    self.needleView = [[UIImageView alloc] initWithImage:self.needleImage];
    self.needleView.frame = self.bounds;
    [self addSubview:self.needleView];
    self.value = self.minValue;
}

-(void)setValue:(CGFloat)value {
    if (value > self.maxValue) {
        value = self.maxValue;
    }
    if (value < self.minValue) {
        value = self.minValue;
    }
    
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
    // 根据图大小来计算刻度线宽度
    _rulingWidth = (rect.size.height < rect.size.width ? rect.size.height : rect.size.width) / 100;
    // 中心点
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    // 半径
    CGFloat radii = (rect.size.height < rect.size.width ? rect.size.height : rect.size.width) / 2;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawPuling:&context center:center radii:radii];
    [self drawSubPuling:&context center:center radii:radii];
}

-(void)drawPuling:(CGContextRef *)context center:(CGPoint)center radii:(CGFloat)radii {
    // 刻度之间的角度
    CGFloat angle = (self.rulingStopAngle - self.rulingStartAngle) / self.rulingCount;
    // 警告开始角度
    CGFloat warningAngle = [self angleWithValue:self.warningValue];
    CGFloat warningIndex = (warningAngle - self.rulingStartAngle) / angle;
    
    // 画刻度线
    [self drawAllPulingLine:context center:center radii:radii perAngle:angle warningIndex:ceil(warningIndex)];
    // 画刻度点
    [self drawAllPulingPoint:context center:center radii:radii perAngle:angle warningIndex:ceil(warningIndex)];
    // 画刻度文本
    [self drawAllPulingText:context center:center radii:radii perAngle:angle warningIndex:ceil(warningIndex)];
}

-(void)drawSubPuling:(CGContextRef *)context center:(CGPoint)center radii:(CGFloat)radii {
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
        [self drawPulingLine:context center:center radii:radii angle:((self.rulingStartAngle + i * angle) * M_PI / 180) pathStartScale:lineStartScale pathEndScale:lineEndScale];
    }
    CGContextStrokePath(*context);
    
    CGFloat startAngle = self.subRulingStartAngle + angle / 2;
    for (int i = 0; i < self.subRulingCount; i++) {
        [self drawPulingPoint:context center:center radii:radii angle:((startAngle + i * angle) * M_PI / 180) pointSize:_rulingWidth / 2 pathScale:pointScale];
    }
    CGContextStrokePath(*context);
    
    for (int i = 0; i <= self.subRulingCount && i < self.subRulingText.count; i++) {
        [self drawPulingText:context center:center radii:radii angle:((self.subRulingStartAngle + i * angle) * M_PI / 180) text:self.subRulingText[i] attributes:attributes textScale:textScale];
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
-(void)drawAllPulingLine:(CGContextRef *)context center:(CGPoint)center radii:(CGFloat)radii perAngle:(CGFloat)angle warningIndex:(int)warningIndex {
    static const float pathStartScale = 0.85;
    static const float pathEndScale = 0.73;
    
    CGContextSetStrokeColorWithColor(*context, self.rulingLineColor.CGColor);
    CGContextSetLineWidth(*context, _rulingWidth);
    for (int i = 0; i <= self.rulingCount && i < warningIndex; i++) {
        [self drawPulingLine:context center:center radii:radii angle:((self.rulingStartAngle + i * angle) * M_PI / 180) pathStartScale:pathStartScale pathEndScale:pathEndScale];
    }
    CGContextStrokePath(*context);
    // 警告值后的刻度
    if (self.warningValue <= self.maxValue) {
        CGContextSetStrokeColorWithColor(*context, [UIColor redColor].CGColor);
        CGContextSetLineWidth(*context, _rulingWidth);
        for (int i = warningIndex; i <= self.rulingCount; i++) {
            [self drawPulingLine:context center:center radii:radii angle:((self.rulingStartAngle + i * angle) * M_PI / 180) pathStartScale:pathStartScale pathEndScale:pathEndScale];
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
-(void)drawAllPulingPoint:(CGContextRef *)context center:(CGPoint)center radii:(CGFloat)radii perAngle:(CGFloat)angle warningIndex:(int)warningIndex {
    static const float pathScale = 0.82;
    
    CGContextSetFillColorWithColor(*context, self.rulingPointColor.CGColor);
    CGFloat startAngle = self.rulingStartAngle + angle / 2;
    for (int i = 0; i < self.rulingCount && i < warningIndex; i++) {
        [self drawPulingPoint:context center:center radii:radii angle:((startAngle + i * angle) * M_PI / 180) pointSize:_rulingWidth pathScale:pathScale];
    }
    CGContextStrokePath(*context);
    // 警告值后的刻度
    if (self.warningValue <= self.maxValue) {
        CGContextSetFillColorWithColor(*context, [UIColor redColor].CGColor);
        CGContextSetLineWidth(*context, _rulingWidth);
        for (int i = ceil(warningIndex); i < self.rulingCount; i++) {
            [self drawPulingPoint:context center:center radii:radii angle:((startAngle + i * angle) * M_PI / 180) pointSize:_rulingWidth pathScale:pathScale];
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
-(void)drawAllPulingText:(CGContextRef *)context center:(CGPoint)center radii:(CGFloat)radii perAngle:(CGFloat)angle warningIndex:(int)warningIndex {
    static const float textScale = 0.60;
    
    NSDictionary *attributes = @{NSFontAttributeName:self.rulingTextFont, NSForegroundColorAttributeName:self.rulingTextColor};
    CGContextSetLineWidth(*context, _rulingWidth);
    for (int i = 0; i <= self.rulingCount && i < self.rulingText.count && i < warningIndex; i++) {
        [self drawPulingText:context center:center radii:radii angle:((self.rulingStartAngle + i * angle) * M_PI / 180) text:self.rulingText[i] attributes:attributes textScale:textScale];
    }
    CGContextStrokePath(*context);
    // 警告值后的刻度
    if (self.warningValue <= self.maxValue) {
        attributes = @{NSFontAttributeName:self.rulingTextFont, NSForegroundColorAttributeName:[UIColor redColor]};
        CGContextSetLineWidth(*context, _rulingWidth);
        for (int i = ceil(warningIndex); i <= self.rulingCount && i < self.rulingText.count; i++) {
            [self drawPulingText:context center:center radii:radii angle:((self.rulingStartAngle + i * angle) * M_PI / 180) text:self.rulingText[i] attributes:attributes textScale:textScale];
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
- (void)drawPulingLine:(CGContextRef *)context center:(CGPoint)center radii:(CGFloat)radii angle:(CGFloat)angle pathStartScale:(CGFloat)pathStartScale pathEndScale:(CGFloat)pathEndScale {
    // 因为画线的点是画线的左侧点，会有一点偏差，这里纠正过来
    CGFloat offset = asin((_rulingWidth / 2) / (pathStartScale * radii));
    angle += offset;
    
    // 计算刻度线两端的点
    // 计算公式为：所在比例 * cos或者sin * 半径 + 中心点x或者y
    CGFloat x1 = pathStartScale * cos(angle) * radii + center.x;
    CGFloat y1 = pathStartScale * sin(angle) * radii + center.x;
    CGFloat x2 = pathEndScale * cos(angle) * radii + center.x;
    CGFloat y2 = pathEndScale * sin(angle) * radii + center.x;
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
- (void)drawPulingPoint:(CGContextRef *)context center:(CGPoint)center radii:(CGFloat)radii angle:(CGFloat)angle pointSize:(CGFloat)pointSize pathScale:(CGFloat)pathScale {
    // 计算刻度点的中心
    // 计算公式为：所在比例 * cos或者sin * 半径 + 中心点x或者y
    CGFloat x = pathScale * cos(angle) * radii + center.x;
    CGFloat y = pathScale * sin(angle) * radii + center.y;
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
- (void)drawPulingText:(CGContextRef *)context center:(CGPoint)center radii:(CGFloat)radii angle:(CGFloat)angle text:(NSString *)text attributes:(NSDictionary *)attributes textScale:(CGFloat)textScale {
    // 计算文本需要占的大小
    CGSize textSize = [text sizeWithAttributes:attributes];
    // 计算文本的左上角位置
    CGFloat x = textScale * cos(angle) * radii + center.x - textSize.width / 2;
    CGFloat y = textScale * sin(angle) * radii + center.y - textSize.height / 2;
    
    [text drawAtPoint:CGPointMake(x, y) withAttributes:attributes];
}

#pragma mark -辅助函数
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
