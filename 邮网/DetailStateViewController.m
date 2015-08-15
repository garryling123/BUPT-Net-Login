//
//  DetailStateViewController.m
//  邮网
//
//  Created by lgy on 15/8/8.
//  Copyright © 2015年 lgy. All rights reserved.
//

#import "DetailStateViewController.h"
#import <Masonry.h>

@interface DetailStateViewController ()
@property (strong, nonatomic) UIScrollView *mainview;
@property (strong, nonatomic) UILabel *totalOnlineNumLabel;
@property (strong, nonatomic) NSMutableDictionary *ipOnlineDic;
@end

@implementation DetailStateViewController

- (instancetype) init {
    if (self = [super init]) {
        self.mainview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height + 20)];
        self.mainview.backgroundColor = [UIColor whiteColor];
        self.mainview.contentSize = self.view.frame.size;
        self.totalOnlineNumLabel = [[UILabel alloc] init];
        self.ipOnlineDic = [[NSMutableDictionary alloc] init];
        [self.view addSubview:self.mainview];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    NSInteger totalNumOnlineInt = [self accessOnlineNum];
    self.totalOnlineNumLabel.text = [NSString stringWithFormat:@"在线用户数目为 %ld ", totalNumOnlineInt];
    self.totalOnlineNumLabel.backgroundColor = [UIColor greenColor];
    [self.mainview addSubview:self.totalOnlineNumLabel];
    [self.totalOnlineNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
//        make.top.equalTo(self.mainview.mas_top).offset(10);
        make.centerY.equalTo(self.view).multipliedBy(0.5);
    }];
}

- (NSInteger) accessOnlineNum {
    NSError *error;
    NSString *regxString = @"<td>(\d{2,3}\\.\\d{2,3}\\.\\d{2,3}\\.\\d{2,3})&nbsp\\;</td>\n<td>&nbsp\\;</td>\n<td>000000000000&nbsp\\;</td>\n<td style=\"display:none\\;\">(\\d{2,3})</td>";
    NSRegularExpression *regOnlineNum = [NSRegularExpression regularExpressionWithPattern:@"tooffline\\(this\\)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *results = [regOnlineNum matchesInString:self.detailContent options:0 range:NSMakeRange(0, [self.detailContent length])];
    return [results count];
}

@end
