//
//  FindUserOnline.m
//  邮网
//
//  Created by lgy on 15/8/16.
//  Copyright © 2015年 lgy. All rights reserved.
//

#import "FindUserOnline.h"
#import <SSKeychain.h>
#import <AFNetworking.h>

@interface FindUserOnline ()
@property (nonatomic, strong) NSString* loginString;
@property (nonatomic, strong) NSString* getCodeString;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *loginActionString;
@property (nonatomic, strong) NSString *onlineString;
@property (nonatomic, strong) NSString *detailContent;
@property (nonatomic, strong) NSDictionary *userinfos;
@property (nonatomic, strong) NSString *userinfoString;
@end

NSString *const FindUserOnlineNotifi = @"FindUserOnlineNotifi";
NSString *const UserinfoNotifi = @"UserinfoNotifi";
@implementation FindUserOnline

- (instancetype)init {
    if (self = [super init]) {
        self.loginString = @"http://gwself.bupt.edu.cn/nav_login";
        self.loginActionString = @"http://gwself.bupt.edu.cn/LoginAction.action";
        self.getCodeString = @"http://gwself.bupt.edu.cn/RandomCodeAction.action?randomNum=0.38489018077962";
        self.onlineString = @"http://gwself.bupt.edu.cn/nav_offLine";
        self.userinfoString = @"http://gwself.bupt.edu.cn/nav_getUserInfo";
        [self findUsers];
    }
    return self;
}

- (void) findUsers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.username = [defaults objectForKey:@"username"];
    self.password = [SSKeychain passwordForService:@"邮网" account:self.username];
    [self toLoginServicePage];
//    return self.ipOnlineDic;
}

- (void) toLoginServicePage {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager GET:self.loginString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *loginContent = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSError *err = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"checkcode=\"(\\d+?)\";" options:NSRegularExpressionCaseInsensitive error:&err];
        NSTextCheckingResult *matchOfCheckcode = [regex firstMatchInString:loginContent options:0 range:NSMakeRange(0, [loginContent length])];
        NSString *checkCode = nil;
        if (matchOfCheckcode) {
            NSRange matchRange = [matchOfCheckcode rangeAtIndex:1];
            checkCode = [loginContent substringWithRange:matchRange];
        }
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        NSString *cookieString = nil;
        for (NSHTTPCookie *cookie in cookies) {
            cookieString = [NSString stringWithFormat:@"%@=%@", cookie.name, cookie.value];
        }
        
        NSMutableDictionary *loginParams = [[NSMutableDictionary alloc] init];
        [loginParams setObject:self.username forKey:@"account"];
        [loginParams setObject:self.password forKey:@"password"];
        [loginParams setObject:checkCode forKey:@"checkcode"];
        [loginParams setObject:@"" forKey:@"code"];
        [loginParams setObject:@"%E7%99%BB+%E5%BD%95" forKey:@"Submit"];
        [self getcode:cookieString andParamString:loginParams];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"111");
    }];
//    [manager.operationQueue waitUntilAllOperationsAreFinished];
}

- (void) getcode:(NSString *)cookieString andParamString:(NSMutableDictionary *)loginParams {
    AFHTTPRequestOperationManager *loginManager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:cookieString forHTTPHeaderField:@"Cookie"];
    loginManager.requestSerializer = requestSerializer;
    loginManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [loginManager GET:self.getCodeString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self loginReqauest:loginParams andCookieString:cookieString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"222");
    }];
//    [loginManager.operationQueue waitUntilAllOperationsAreFinished];
}

- (void) loginReqauest:(NSMutableDictionary *)params andCookieString:(NSString *)cookieString {
    AFHTTPRequestOperationManager *loginManager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:cookieString forHTTPHeaderField:@"Cookie"];
    self.password = nil;
    loginManager.requestSerializer = requestSerializer;
    loginManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [loginManager POST:self.loginActionString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *content = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self getcurrentOnline:content andCookieString:cookieString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"333");
    }];
//    [loginManager.operationQueue waitUntilAllOperationsAreFinished];
}

- (void) getcurrentOnline:(NSString *)content andCookieString:(NSString *)cookieString {
    NSError *error;
    NSRegularExpression *login = [NSRegularExpression regularExpressionWithPattern:@"info_title" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange rangeExist = [login rangeOfFirstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
    if (!NSEqualRanges(rangeExist, NSMakeRange(NSNotFound, 0))) {
        AFHTTPRequestOperationManager *loginManager = [AFHTTPRequestOperationManager manager];
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:cookieString forHTTPHeaderField:@"Cookie"];
        loginManager.requestSerializer = requestSerializer;
        [loginManager.operationQueue waitUntilAllOperationsAreFinished];
        loginManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [loginManager GET:self.onlineString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.detailContent = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSError *error;
            NSString *ipRegxString = @"<td>(\\d{2,3}\\.\\d{2,3}\\.\\d{2,3}\\.\\d{2,3})&nbsp\\;</td>";
            NSString *iphashRegxString = @"<td style=\"display:none\\;\">(\\d*)</td>";
            NSRegularExpression *regOnlineIp = [NSRegularExpression regularExpressionWithPattern:ipRegxString options:NSRegularExpressionCaseInsensitive error:&error];
            NSRegularExpression *regIpHash = [NSRegularExpression regularExpressionWithPattern:iphashRegxString options:NSRegularExpressionCaseInsensitive error:&error];
            NSArray *ipRangeArray = [regOnlineIp matchesInString:self.detailContent options:0 range:NSMakeRange(0, [self.detailContent length])];
            NSArray *iphashRangeArray = [regIpHash matchesInString:self.detailContent options:0 range:NSMakeRange(0, [self.detailContent length])];
            NSMutableArray *ipsArray = [NSMutableArray array];
            NSMutableArray *ipHashArray = [NSMutableArray array];
            for (NSTextCheckingResult *ip in ipRangeArray) {
                NSRange ipRange = [ip rangeAtIndex:1];
                NSString *ipAddress = [self.detailContent substringWithRange:ipRange];
                [ipsArray addObject:ipAddress];
            }
            for (NSTextCheckingResult *ipHash in iphashRangeArray) {
                NSRange iphashRange = [ipHash rangeAtIndex:1];
                NSString *ipHash = [self.detailContent substringWithRange:iphashRange];
                [ipHashArray addObject:ipHash];
            }
            self.ipOnlineDic = [[NSMutableDictionary alloc] initWithObjects:ipHashArray forKeys:ipsArray];
            [self.ipOnlineDic setObject:cookieString forKey:@"info"];
            [loginManager.operationQueue waitUntilAllOperationsAreFinished];
            [[NSNotificationCenter defaultCenter] postNotificationName:FindUserOnlineNotifi object:self.ipOnlineDic];
            [self accessuserInfo:cookieString];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"444");
        }];
//
    } else {
    }
    
}

- (void) accessuserInfo:(NSString *)cookieString {
    AFHTTPRequestOperationManager *loginManager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:cookieString forHTTPHeaderField:@"Cookie"];
    loginManager.requestSerializer = requestSerializer;
    [loginManager.operationQueue waitUntilAllOperationsAreFinished];
    loginManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [loginManager GET:self.userinfoString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *infoContent = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *regxMoneyString = @"<font class=\"redtext\">\\s+\n\\s+(\\d+.\\d+)\\s+\n\\s+</font>";
        NSError *error;
        NSRegularExpression *regxMoney = [NSRegularExpression regularExpressionWithPattern:regxMoneyString options:NSRegularExpressionCaseInsensitive error:&error];
        NSTextCheckingResult *moneyExtra = [regxMoney firstMatchInString:infoContent options:0 range:NSMakeRange(0, [infoContent length])];
        NSString *moneyExtraString;
        if (moneyExtra) {
            NSRange moneyextraRange = [moneyExtra rangeAtIndex:1];
            moneyExtraString = [infoContent substringWithRange:moneyextraRange];
        }
//        NSString *flowMString = @"<td class=\"t_r1\">\\s+\n\\s+&nbsp\\;\\s+\n\\s+(\\d+.\\d+)</td>";
        NSString *flowMString = @"<td class=\"t_r1\">\\s+\n\\s+&nbsp\\;\\s+\n\\s+(\\d+.\\d+)\\s+\n\\s+</td>";
        NSRegularExpression *flowMreg = [NSRegularExpression regularExpressionWithPattern:flowMString options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *flowResArray = [flowMreg matchesInString:infoContent options:0 range:NSMakeRange(0, [infoContent length])];
        NSMutableArray *flowuseArray = [NSMutableArray array];
        for (NSTextCheckingResult *flowRes in flowResArray) {
            NSRange flowuseRange = [flowRes rangeAtIndex:1];
            NSString *flowUseString = [infoContent substringWithRange:flowuseRange];
            if (flowUseString) {
                [flowuseArray addObject:flowUseString];
            }
        }
        NSDictionary *userinfosDic = @{
                                       @"flowUse":flowuseArray,
                                       @"moneyRemain":moneyExtraString
                                       };
        [[NSNotificationCenter defaultCenter] postNotificationName:UserinfoNotifi object:userinfosDic];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fuck...");
    }];
}
@end
