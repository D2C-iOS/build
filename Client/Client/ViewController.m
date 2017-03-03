//
//  ViewController.m
//  Client
//
//  Created by 翟泉 on 2017/3/3.
//  Copyright © 2017年 翟泉. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSURL *url = [NSURL URLWithString:@"http://192.168.2.108:22333"];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSString *text = [NSString stringWithUTF8String:data.bytes];
            NSLog(@"%@", text);
        }
    }] resume];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
