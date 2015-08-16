//
//  LocationClass.m
//  邮网
//
//  Created by lgy on 15/8/15.
//  Copyright © 2015年 lgy. All rights reserved.
//

#import "LocationClass.h"

@interface LocationClass ()
@property (nonatomic, strong) NSDictionary *locationDic;
@end

@implementation LocationClass
- (id) init {
    if (self = [super init]) {
        self.locationDic = @{@"101":@"教一",
                             @"102":@"教二",
                             @"103":@"教三",
                             @"104":@"教四",
                             @"105":@"主教",
                             @"106":@"教六",
                             @"107":@"明光楼",
                             @"108":@"新科研楼",
                             @"109":@"新科研楼",
                             @"110":@"创新大本营 学十楼北地下室 综合服务楼",
                             @"201":@"学一",
                             @"202":@"学二",
                             @"203":@"学三",
                             @"204":@"学四",
                             @"205":@"学五",
                             @"206":@"学六",
                             @"207":@"学七",
                             @"208":@"学八",
                             @"209":@"学九",
                             @"210":@"学⑩",
                             @"211":@"学十一",
                             @"212":@"学十二",
                             @"213":@"学十三",
                             @"214":@"学十四",
                             @"215":@"学二十九",
                             };
    }
    return self;
}


- (NSString *)findLocation:(NSString *)midIpSting {
    return self.locationDic[midIpSting];
}
@end
