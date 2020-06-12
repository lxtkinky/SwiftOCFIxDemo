//
//  ViewController.m
//  TestDemo
//
//  Created by ULDD on 2019/12/30.
//  Copyright © 2019 ULDD. All rights reserved.
//

#import "ViewController.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "TestDemo-Bridging-Header.h"
#import "TestDemo-Swift.h"

//#import <Lottie/Lottie-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UIViewController *controller = [[UIViewController alloc] init];
//    NSString *name = @"sdfsdf";
//
//    NSMutableArray *array = [NSMutableArray array];
//    for (int i = 0; i < 20; i++) {
//        [array addObject:[NSString stringWithFormat:@"i = %d", i]];
//    }
//    [array enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"lxt--%@", str);
//        if (idx == 15) {
//            [array removeObject:str];
//        }
//    }];
//    NSLog(@"lxt--更新数据");
    
//    [self getAllFuncName];
    [self lxt_testLottie];
}

- (void)lxt_testLottie{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"666" ofType:@"json"];
    NSLog(@"lxt-%@", path);
    
    
    
//    CompatibleAnimationView *animationView = [[CompatibleAnimationView alloc] init];
//    CompatibleAnimationView *animationView = [[CompatibleAnimationView alloc] init];
//    CompatibleAnimation *animation = [[CompatibleAnimation alloc] initWithName:@"666" bundle:[NSBundle mainBundle]];
//    animationView
//    AnimationView *animationView = [[AnimationView alloc] init];
    
    LOTAnimationView *animationView = [LOTAnimationView animationWithFilePath:path];
    animationView.loopAnimation = YES;
    animationView.frame = CGRectMake(0, 0, 100, 100);
    [self.view addSubview:animationView];
    animationView.center = self.view.center;
    [animationView play];
}

- (void)dealloc{
    
}

- (void)getAllFuncName{
    unsigned int count;
    Method *methods = class_copyMethodList([UIViewController class], &count);
    for (int i = 0; i < count; i++)
    {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);

//        if ([name hasPrefix:@"test"])
        NSLog(@"方法 名字 ==== %@",name);
        if (name)
        {
            //avoid arc warning by using c runtime
//            objc_msgSend(self, selector);
        }
//        NSLog(@"Test '%@' completed successfuly", [name substringFromIndex:4]);
    }
}

@end
