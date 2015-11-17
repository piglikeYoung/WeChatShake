//
//  ViewController.m
//  WeChatShake
//
//  Created by piglikeyoung on 15/11/17.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ViewController () {
    SystemSoundID shakingMaleSound;
    SystemSoundID shakingMatchSound;
    SystemSoundID shakingNoMatchSound;
}

// 摇一摇上半图片
@property (nonatomic, strong) UIImageView *shakeUpImageView;
// 下半图片
@property (nonatomic, strong) UIImageView *shakeDownImageView;

@property (nonatomic, strong) UIImageView *shakeUpLineImageView;
@property (nonatomic, strong) UIImageView *shakeDownLineImageView;


// 背景图片
@property (nonatomic, strong) UIImageView *shakeBackgroundImageView;

// 图片移动的距离
@property (nonatomic, assign) CGFloat animationDistans;


@end

@implementation ViewController

#pragma mark - Propertys

- (UIImageView *)shakeUpImageView {
    if (!_shakeUpImageView) {
        _shakeUpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) * 1.0 / 3)];
        _shakeUpImageView.backgroundColor = self.view.backgroundColor;
        _shakeUpImageView.image = [UIImage imageNamed:@"Shake_Logo_Up"];
        _shakeUpImageView.contentMode = UIViewContentModeBottom;
        
        [_shakeUpImageView addSubview:self.shakeUpLineImageView];
    }
    return _shakeUpImageView;
}

- (UIImageView *)shakeDownImageView {
    if (!_shakeDownImageView) {
        _shakeDownImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shakeUpImageView.frame), CGRectGetWidth(self.shakeUpImageView.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.shakeUpImageView.bounds))];
        _shakeDownImageView.backgroundColor = self.view.backgroundColor;
        _shakeDownImageView.userInteractionEnabled = YES;
        _shakeDownImageView.image = [UIImage imageNamed:@"Shake_Logo_Down"];
        _shakeDownImageView.contentMode = UIViewContentModeTop;
        
        [_shakeDownImageView addSubview:self.shakeDownLineImageView];
    }
    return _shakeDownImageView;
}

- (UIImageView *)shakeUpLineImageView {
    if (!_shakeUpLineImageView) {
        _shakeUpLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_shakeUpImageView.frame) - 3, CGRectGetWidth(self.view.bounds), 10)];
        _shakeUpLineImageView.image = [UIImage imageNamed:@"Shake_Line_Up"];
        _shakeUpLineImageView.hidden = YES;
    }
    return _shakeUpLineImageView;
}

- (UIImageView *)shakeDownLineImageView {
    if (!_shakeDownLineImageView) {
        _shakeDownLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -7, CGRectGetWidth(self.view.bounds), 10)];
        _shakeDownLineImageView.image = [UIImage imageNamed:@"Shake_Line_Down"];
        _shakeDownLineImageView.hidden = YES;
    }
    return _shakeDownLineImageView;
}

- (UIImageView *)shakeBackgroundImageView {
    if (!_shakeBackgroundImageView) {
        _shakeBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.shakeUpImageView.frame) - self.animationDistans, CGRectGetWidth(self.view.bounds), self.animationDistans * 2)];
        _shakeBackgroundImageView.image = [UIImage imageNamed:@"AlbumHeaderBackgrounImage"];
    }
    return _shakeBackgroundImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.animationDistans = 100;
    
    self.view.backgroundColor = [UIColor colorWithRed:0.102 green:0.102 blue:0.114 alpha:1.000];
    
    [self.view addSubview:self.shakeUpImageView];
    [self.view addSubview:self.shakeDownImageView];
    
    [self.view addSubview:self.shakeBackgroundImageView];
    [self.view sendSubviewToBack:self.shakeBackgroundImageView];
    
    // 控制器支持摇动
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    
    
    // 加载音频
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)([NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"shake_sound_male.wav" ofType:@""]]), &shakingMaleSound);
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)([NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"shake_match.wav" ofType:@""]]), &shakingMatchSound);
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)([NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"shake_match.wav" ofType:@""]]), &shakingNoMatchSound);
}

- (void)shaking {
    
    // 向上动画
    CABasicAnimation *shakeUpImageViewAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    shakeUpImageViewAnimation.fromValue = 0;
    shakeUpImageViewAnimation.toValue = [NSNumber numberWithFloat:-self.animationDistans];
    shakeUpImageViewAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shakeUpImageViewAnimation.duration = 0.4;
    shakeUpImageViewAnimation.removedOnCompletion = NO;
    shakeUpImageViewAnimation.fillMode = kCAFillModeBoth;
    shakeUpImageViewAnimation.autoreverses = YES;
    
    // 向下动画
    CABasicAnimation *shakeDownImageViewAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    shakeDownImageViewAnimation.delegate = self;// 设置代理
    shakeDownImageViewAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shakeDownImageViewAnimation.fromValue = 0;
    shakeDownImageViewAnimation.toValue = [NSNumber numberWithFloat:self.animationDistans];
    shakeDownImageViewAnimation.duration = 0.4;
    shakeDownImageViewAnimation.removedOnCompletion = NO;
    shakeDownImageViewAnimation.autoreverses = YES;
    shakeDownImageViewAnimation.fillMode = kCAFillModeBoth;
    
    // 添加动画
    [self.shakeUpImageView.layer addAnimation:shakeUpImageViewAnimation forKey:@"shakeUpImageViewAnimationKey"];
    [self.shakeDownImageView.layer addAnimation:shakeDownImageViewAnimation forKey:@"shakeDownImageViewAnimationKey"];
}

#pragma mark - Animation Delegate
- (void)animationDidStart:(CAAnimation *)anim {
    self.shakeUpLineImageView.hidden = NO;
    self.shakeDownLineImageView.hidden = NO;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    self.shakeUpLineImageView.hidden = flag;
    self.shakeDownLineImageView.hidden = flag;
    
    // 匹配成功声音
    AudioServicesPlaySystemSound(shakingMatchSound);
    // 匹配失败声音
//    AudioServicesPlaySystemSound(shakingNoMatchSound);
}

#pragma mark - Event Delegate
/**
 *  摇一摇结束调用
 */
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if(motion == UIEventSubtypeMotionShake) {
        // 播放声音
        AudioServicesPlaySystemSound(shakingMaleSound);
        // 震动
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        // 真实一点的摇动动画
        [self shaking];
    }
}

@end
