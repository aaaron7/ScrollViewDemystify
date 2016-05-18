//
//  ViewController.m
//  ScrollViewDemystify
//
//  Created by aaaron7 on 5/13/16.
//  Copyright © 2016 aaaron7. All rights reserved.
//

#import "ViewController.h"
#import "CustomScrollView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CustomScrollView* view = [[CustomScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 300)];
    view.backgroundColor = [UIColor purpleColor];
    view.contentSize = CGSizeMake(320, 600);
    view.layer.masksToBounds = YES;
    [self.view addSubview:view];

    for (int i = 0 ; i < 10; i ++) {
        UILabel* label  = [[UILabel alloc] initWithFrame:CGRectMake(50, i * 50, 70, 20)];
        label.text = [NSString stringWithFormat:@"Label_%d",i];
        [view addSubview:label];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
