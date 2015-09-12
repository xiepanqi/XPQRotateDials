//
//  ViewController.m
//  XPQRotateDials
//
//  Created by RHC on 15/7/23.
//  Copyright (c) 2015年 com.launch. All rights reserved.
//

#import "ViewController.h"
#import "XPQRotateDials.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *needle;
@property (weak, nonatomic) IBOutlet UITextField *textValue;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet XPQRotateDials *rotateDials;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 可以用代码设置参数，也可以在storyboard上直接修改
//    self.rotateDials.minValue = 0;
//    self.rotateDials.maxValue = 140;
//    self.rotateDials.value = 0.0;
//    self.rotateDials.rulingStartAngle = -225.0;
//    self.rotateDials.rulingStopAngle = 45.0;
//    self.rotateDials.rulingCount = 14;
//    self.rotateDials.rulingLineColor = [UIColor whiteColor];
//    self.rotateDials.rulingPointColor = [UIColor whiteColor];
//    self.rotateDials.rulingTextColor = [UIColor whiteColor];
//    self.rotateDials.rulingTextFont = [UIFont systemFontOfSize:20];
    self.rotateDials.rulingText = @[@"0", @"", @"20", @"", @"40", @"", @"60", @"", @"80", @"", @"100", @"", @"120", @"", @"140"];
//    self.rotateDials.warningValue = 100;
    
    
//    self.rotateDials.subRulingStartAngle = -225.0;
    self.rotateDials.subRulingStopAngle = [self.rotateDials angleWithValue:136.7];
    self.rotateDials.subRulingCount = 11;
    self.rotateDials.subRulingColor = [UIColor colorWithRed:0.261 green:0.866 blue:0.824 alpha:1.0];
    self.rotateDials.subRulingTextColor = [UIColor colorWithRed:0.261 green:0.866 blue:0.824 alpha:1.0];
    self.rotateDials.subRulingText = @[@"0", @"20", @"40", @"60", @"80", @"100", @"120", @"140", @"160", @"180", @"200", @"220"];
    self.rotateDials.subRulingStyle = XPQRulingStyleCycline;
    
    self.rotateDials.needleImage = [UIImage imageNamed:@"needle_mph"];
    self.rotateDials.backgroundImage = [UIImage imageNamed:@"background"];
    self.rotateDials.needleAngleOffset = -0.45;
//    self.rotateDials.frame = CGRectMake(0, 0, 100, 100);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)textEditEnd:(UITextField *)sender {
    self.slider.value = sender.text.floatValue / 360;
}

- (IBAction)sliderChanged:(UISlider *)sender {
//    self.needle.transform = CGAffineTransformMakeRotation(2 * M_PI * sender.value);
    self.rotateDials.value = sender.value;
    self.textValue.text = [NSString stringWithFormat:@"%lf", self.rotateDials.subValue];
}
- (IBAction)clickButton:(id)sender {
    self.rotateDials.value = 0;
    self.rotateDials.frame = CGRectOffset(self.rotateDials.frame, -10, -10);
}

@end
