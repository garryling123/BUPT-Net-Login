//
//  DetailStateViewController.m
//  邮网
//
//  Created by lgy on 15/8/8.
//  Copyright © 2015年 lgy. All rights reserved.
//

#import "DetailStateViewController.h"
#import "LocationClass.h"
#import <Masonry.h>
#import "SSKeychain.h"
#import "SSKeychainQuery.h"
#import <AFNetworking.h>
#import "FindUserOnline.h"

@interface DetailStateViewController ()
@property (strong, nonatomic) UIScrollView *mainview;
@property (strong, nonatomic) UILabel *totalOnlineNumLabel;
@property (strong, nonatomic) NSString *offlineCode;
@property (strong, nonatomic) NSString *offlineURL;
@property (strong, nonatomic) NSString *gateURL;
@property (assign, nonatomic) NSInteger lastOnlineNum;
@property (strong, nonatomic) NSString *moneyRemainString;
@property (strong, nonatomic) NSString *usedMinString;
@property (strong, nonatomic) NSString *usedFlowString;
@property (strong, nonatomic) UILabel *userinfoLabel;
@end

@implementation DetailStateViewController

- (instancetype) init {
    if (self = [super init]) {
        self.mainview = [[UIScrollView alloc] init];
        self.userinfoLabel = [UILabel new];
        self.navigationItem.hidesBackButton = YES;
        self.title = @"在线用户";
        self.gateURL = @"http://10.3.8.211";
        self.offlineURL = @"http://gwself.bupt.edu.cn/tooffline?t=0.18737324071116745&fldsessionid=";
        self.mainview.backgroundColor = [UIColor whiteColor];
        [self.mainview setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.mainview setScrollEnabled:YES];
        [self.view addSubview:self.mainview];
        [self.mainview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        self.totalOnlineNumLabel = [[UILabel alloc] init];
    }
    return self;
}

- (void) loadView {
    [super loadView];
    if(self.userDic == nil) {
        FindUserOnline *finduOnline = [[FindUserOnline alloc] init];
        [finduOnline findUsers];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findusersOnlie:) name:FindUserOnlineNotifi object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoSel:) name:UserinfoNotifi object:nil];
    }
}

- (void) viewDidAppear:(BOOL)animated {
//    self.totalOnlineNumLabel.text = [NSString stringWithFormat:@"在线用户数目为 %ld ", totalNumOnlineInt];
    for (UIView *view in [self.mainview subviews]) {
        [view removeFromSuperview];
    }
    self.lastOnlineNum = [self.userDic count];
    self.totalOnlineNumLabel.text = [NSString stringWithFormat:@"在线终端"];
    self.totalOnlineNumLabel.font = [UIFont boldSystemFontOfSize:25];
    self.totalOnlineNumLabel.backgroundColor = [UIColor whiteColor];
    [self.mainview addSubview:self.totalOnlineNumLabel];
    [self.totalOnlineNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mainview);
        make.centerY.equalTo(self.mainview).multipliedBy(0.5);
    }];
    NSInteger ipCellTag = 0;
    for (NSString *ipAddress in [self.userDic allKeys]) {
        if ([ipAddress compare:@"info"] == NSOrderedSame) {
            continue;
        }
        NSArray *ipparts = [ipAddress componentsSeparatedByString:@"."];
        LocationClass *locationTrans = [[LocationClass alloc] init];
        NSString *locationDetailString = [locationTrans findLocation:ipparts[1]];
        if (locationDetailString == nil) {
            locationDetailString = @"未知位置";
        }
        UILabel *locationDetailLabel = [[UILabel alloc] init];
        locationDetailLabel.text = locationDetailString;
        locationDetailLabel.textColor = [UIColor blackColor];
        locationDetailLabel.font = [UIFont boldSystemFontOfSize:10];
        UIImageView *terminalView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"terminal"]];
        UIView* ipCell = [UIView new];
        ipCell.layer.borderColor = [[UIColor blackColor] CGColor];
        ipCell.layer.borderWidth = 1;
        [ipCell setTag:ipCellTag];
        
        ipCellTag += 1;
        UILabel *ipAdLabel = [UILabel new];
        ipAdLabel.text = ipAddress;
        ipAdLabel.font = [UIFont boldSystemFontOfSize:10];
        UIButton *offlineButton = [[UIButton alloc] init];
        [offlineButton setImage:[UIImage imageNamed:@"offline"] forState:UIControlStateNormal];
        [offlineButton setTag:[self.userDic[ipAddress] integerValue]];
        [offlineButton addTarget:self action:@selector(toOffline:) forControlEvents:UIControlEventTouchUpInside];
    
        [ipCell addSubview:offlineButton];
        [ipCell addSubview:terminalView];
        [ipCell addSubview:ipAdLabel];
        [ipCell addSubview:locationDetailLabel];
        [terminalView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ipCell).offset(10);
            make.height.equalTo(ipCell.mas_width).multipliedBy(0.1);
            make.width.equalTo(ipCell).multipliedBy(0.1);
            make.centerY.equalTo(ipCell);
        }];
        [ipAdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(terminalView.mas_right).offset(2);
            make.height.equalTo(ipCell).multipliedBy(0.8);
            make.width.equalTo(ipCell).multipliedBy(0.3);
            make.centerY.equalTo(ipCell);
        }];
        [locationDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ipAdLabel.mas_right).offset(2);
            make.height.equalTo(ipCell.mas_height).multipliedBy(0.8);
            make.width.equalTo(ipCell).multipliedBy(0.3);
            make.centerY.equalTo(ipCell);
        }];
        [offlineButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(locationDetailLabel.mas_right).offset(2);
            make.left.equalTo(locationDetailLabel.mas_right);
            make.height.equalTo(ipCell.mas_height).multipliedBy(0.8);
            make.width.equalTo(ipCell).multipliedBy(0.3);
            make.centerY.equalTo(ipCell);
        }];
        
        [self.mainview addSubview:ipCell];
        [ipCell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mainview);
            make.top.equalTo([[self.mainview subviews] objectAtIndex:[[self.mainview subviews] count] - 2].mas_bottom).offset(10);
            make.height.equalTo(self.mainview).multipliedBy(0.1);
            make.width.equalTo(self.mainview).multipliedBy(0.8);
        }];
    }
    UIView *quickLoginView = [[UIView alloc] init];
    UITapGestureRecognizer *connectTapG = [[UITapGestureRecognizer alloc] init];
    [connectTapG addTarget:self action:@selector(connectInterSel:)];
    [quickLoginView addGestureRecognizer:connectTapG];
    [self.mainview addSubview:quickLoginView];
    [quickLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mainview);
        make.top.equalTo([[self.mainview subviews] objectAtIndex:[[self.mainview subviews] count] - 2].mas_bottom).offset(5);
        make.width.equalTo(self.mainview).multipliedBy(0.5);
        make.height.equalTo(self.mainview).multipliedBy(0.1);
    }];
    UIImageView *quickConnectView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connect"]];
    UILabel *quickOnlineLabel = [[UILabel alloc] init];
    quickOnlineLabel.text = @"快速登陆";
    quickOnlineLabel.textColor = [UIColor blackColor];
    quickOnlineLabel.userInteractionEnabled = YES;
    quickConnectView.userInteractionEnabled = YES;
    UITapGestureRecognizer *connectTapG4Label = [[UITapGestureRecognizer alloc] init];
    [connectTapG4Label addTarget:self action:@selector(connectInterSel:)];
    [quickOnlineLabel addGestureRecognizer:connectTapG4Label];
    UITapGestureRecognizer *connectTapG4View = [[UITapGestureRecognizer alloc] init];
    [connectTapG4View addTarget:self action:@selector(connectInterSel:)];
    [quickConnectView addGestureRecognizer:connectTapG4View];
    [quickLoginView addSubview:quickOnlineLabel];
    [quickLoginView addSubview:quickConnectView];
    [quickOnlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.totalOnlineNumLabel.mas_right);
        make.centerY.equalTo(quickLoginView);
        make.top.equalTo(quickLoginView);
        make.height.equalTo(quickLoginView);
    }];
    [quickConnectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(quickOnlineLabel.mas_left);
        make.height.equalTo(quickLoginView).multipliedBy(0.5);
        make.width.equalTo(quickLoginView.mas_height).multipliedBy(0.5);
        make.centerY.equalTo(quickLoginView);
    }];
    [self createUserInfoView];
}

- (void) createUserInfoView {
    self.userinfoLabel.text = [NSString stringWithFormat:@"账户余额 %@元\n已使用流量 %@M\n 已使用分钟数%@分", self.moneyRemainString, self.usedFlowString, self.usedMinString];
    self.userinfoLabel.numberOfLines = 0;
    self.userinfoLabel.font = [UIFont systemFontOfSize:15];
    self.userinfoLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainview addSubview:self.userinfoLabel];
    [self.userinfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mainview);
        make.top.equalTo([[self.mainview subviews] objectAtIndex:[[self.mainview subviews] count] - 2].mas_bottom).offset(5);
        make.width.equalTo(self.mainview).multipliedBy(0.5);
//        make.height.equalTo(self.mainview).multipliedBy(0.1);
    }];
}

- (void) userInfoSel:(NSNotification *)notifi {
    if (notifi.object) {
        NSLog(@"%@", notifi.object);
        self.moneyRemainString = notifi.object[@"moneyRemain"];
        self.usedFlowString = notifi.object[@"flowUse"][1];
        self.usedMinString = notifi.object[@"flowUse"][0];
        self.userinfoLabel.text = [NSString stringWithFormat:@"账户余额 %@\n已使用流量 %@\n 已使用分钟数%@", self.moneyRemainString, self.usedFlowString, self.usedMinString];
    }
}

- (void) toOffline:(UIButton *) sender {
    if (sender.tag) {
        [self refreshContent];
        [self performSelector:@selector(waitforcookie) withObject:nil afterDelay:3];
        AFHTTPRequestOperationManager *loginManager = [AFHTTPRequestOperationManager manager];
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:self.offLineCookie forHTTPHeaderField:@"Cookie"];
        loginManager.requestSerializer = requestSerializer;
        NSString *offlineURLtmp = [self.offlineURL stringByAppendingString:[NSString stringWithFormat:@"%ld", sender.tag]];
        NSLog(@"%@", offlineURLtmp);
        loginManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [loginManager GET:offlineURLtmp parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self performSelector:@selector(refreshContent) withObject:nil afterDelay:3];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
    }
}

- (void) connectInterSel:(UITapGestureRecognizer *)tap {
    AFHTTPRequestOperationManager *loginManager = [AFHTTPRequestOperationManager manager];
    loginManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    loginManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [loginManager GET:self.gateURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *gateStatusString = [[NSString alloc] initWithData:responseObject encoding:enc];
        NSString *matchLoginStatusString = @"上网注销窗";
        NSRegularExpression *canInternent = [NSRegularExpression regularExpressionWithPattern:matchLoginStatusString options:NSRegularExpressionCaseInsensitive error:nil];
        NSInteger matchStatus = [canInternent numberOfMatchesInString:gateStatusString options:0 range:NSMakeRange(0, [gateStatusString length])];
        if (matchStatus) {
            [self alertWords:@"本机已登录"];
            [self refreshContent];
        } else {
            [self doNetConnect];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void) alertWords:(NSString *)info {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"通知" message:info preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alertVC addAction:defaultAction];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

- (void) doNetConnect {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults objectForKey:@"username"];
    NSString *password = [SSKeychain passwordForService:@"gate" account:username];
    AFHTTPRequestOperationManager *loginManager = [AFHTTPRequestOperationManager manager];
    loginManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    loginManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSDictionary *params = @{@"DDDDD":username,
                             @"upass":password,
                             @"savePWD":@0,
                             @"0MKKey":@""};
    [loginManager POST:self.gateURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *gateStatusString = [[NSString alloc] initWithData:responseObject encoding:enc];
        NSString *matchLoginStatusString = @"登录成功窗";
        NSRegularExpression *canInternent = [NSRegularExpression regularExpressionWithPattern:matchLoginStatusString options:NSRegularExpressionCaseInsensitive error:nil];
        NSInteger matchStatus = [canInternent numberOfMatchesInString:gateStatusString options:0 range:NSMakeRange(0, [gateStatusString length])];
        if (matchStatus) {
            [self alertWords:@"登陆成功"];
            [self performSelector:@selector(refreshContent) withObject:nil afterDelay:3];
        } else {
            [self alertWords:@"fucking "];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
    }];
}

- (void) findusersOnlie:(NSNotification *)notifi {
    if (notifi != nil) {
        NSDictionary *userDic = notifi.object;
        self.userDic = userDic;
        self.offLineCookie = self.userDic[@"info"];
    }
    [self viewDidAppear:YES];
}

- (void) refreshContent {
    FindUserOnline *fuo = [FindUserOnline new];
    [fuo findUsers];
}

- (void) waitforcookie {
    NSLog(@"wait...");
}
@end
