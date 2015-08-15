//
//  LoginViewController.m
//  邮网
//
//  Created by lgy on 15/8/8.
//  Copyright © 2015年 lgy. All rights reserved.
//

#import "LoginViewController.h"
#import "DetailStateViewController.h"
#import "SSKeychain.h"
#import "SSKeychainQuery.h"
#import "AFNetworking.h"

@interface LoginViewController ()
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) UIScrollView *loginScrollView;
@property (strong, nonatomic) NSString *loginString;
@property (strong, nonatomic) NSString *loginActionString;
@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong ,nonatomic) NSString *getCodeString;
@property (strong ,nonatomic) NSString *onlineString;
@property (assign, nonatomic) int keyboardHeight;
@end


@implementation LoginViewController
- (instancetype) init {
    if (self = [super init]) {
        self.loginScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.loginScrollView setContentSize:self.view.bounds.size];
        [self.loginScrollView setScrollEnabled:YES];
        [self.view addSubview:self.loginScrollView];
        self.loginString = @"http://gwself.bupt.edu.cn/nav_login";
        self.loginActionString = @"http://gwself.bupt.edu.cn/LoginAction.action";
        self.getCodeString = @"http://gwself.bupt.edu.cn/RandomCodeAction.action?randomNum=0.38489018077962";
        self.onlineString = @"http://gwself.bupt.edu.cn/nav_offLine";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];

    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTextEditingTapSel:)];
    [self.view addGestureRecognizer:tap];
}

- (void) viewDidAppear:(BOOL)animated {
    for (UIView *view in self.loginScrollView.subviews) {
        [view removeFromSuperview];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.username = [userDefault objectForKey:@"username"];
    if (self.username == nil) {
        [self showFirstLoginView];
    }else {
        UIWebView *uv = [[UIWebView alloc] init];
        [self webViewDidFinishLoad:uv];
    }
}

- (void) showFirstLoginView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"用户登录";
    self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 240, self.view.bounds.size.width - 60, 40)];
    self.usernameTextField.placeholder = @"账号";
    [self.usernameTextField setTag:1];
    self.usernameTextField.layer.borderColor = [UIColor yellowColor].CGColor;
    [self.usernameTextField addTarget:self action:@selector(endTextEditingTapSel:) forControlEvents:UIControlEventEditingDidEnd];
    [self.usernameTextField addTarget:self action:@selector(startTextEditingTapSel:) forControlEvents:UIControlEventEditingDidBegin];
    [self.usernameTextField addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.usernameTextField.layer.borderWidth = 1.0f;
    
    self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 290, self.view.bounds.size.width - 60, 40)];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.placeholder = @"密码";
    self.passwordTextField.layer.borderColor = [UIColor yellowColor].CGColor;
    self.passwordTextField.layer.borderWidth = 1.0f;
    [self.passwordTextField setTag:2];
    [self.passwordTextField addTarget:self action:@selector(endTextEditingTapSel:) forControlEvents:UIControlEventEditingDidEnd];
    [self.passwordTextField addTarget:self action:@selector(textChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(startTextEditingTapSel:) forControlEvents:UIControlEventEditingDidBegin];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    loginButton.frame = CGRectMake(100, 330, self.view.bounds.size.width - 200, 40);
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(toDetailView:) forControlEvents:UIControlEventTouchDown];
    [self.loginScrollView addSubview:self.usernameTextField];
    [self.loginScrollView addSubview:self.passwordTextField];
    [self.loginScrollView addSubview:loginButton];
}

- (void) toDetailView:(UIButton *)sender {
    for (UIView *view in self.loginScrollView.subviews) {
        if (view.tag == 1 || view.tag == 2) {
            UITextField *textField = (UITextField *) view;
            textField.text = nil;
        }
    }
    // get webview content
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    webView.delegate = self;
    NSBundle *thisBundle = [NSBundle mainBundle];
    NSString *path;
    path = [thisBundle pathForResource:@"login" ofType:@"html"];
    webView.delegate = self;
    NSURL *instructionsURL = [NSURL fileURLWithPath:path];
    [webView loadRequest:[NSURLRequest requestWithURL:instructionsURL]];
    [self.loginScrollView addSubview:webView];
}

- (void) endTextEditingTapSel:(id)notification {
    if ([notification isKindOfClass:[UITextField class]]) {
        UITextField *nf = (UITextField *)notification;
        if (nf.tag == 1) {
            if ([nf.text  isEqual: @""]) {
                nf.placeholder = @"账号";
            } else {
                self.username = nf.text;
            }
        }else if (nf.tag == 2) {
            if ([nf.text  isEqual: @""]) {
                nf.placeholder = @"密码";
            } else {
                self.password = nf.text;
            }
        }
        self.loginScrollView.frame = CGRectMake(self.loginScrollView.frame.origin.x, self.loginScrollView.frame.origin.y + self.keyboardHeight, self.loginScrollView.frame.size.width, self.loginScrollView.frame.size.height);
    }
    
    [self.loginScrollView endEditing:YES];
}

- (void) startTextEditingTapSel:(id)notification {
    if ([notification isKindOfClass:[UITextField class]]) {
        UITextField *nf = (UITextField *)notification;
        nf.placeholder = nil;
        self.loginScrollView.frame = CGRectMake(self.loginScrollView.frame.origin.x, self.loginScrollView.frame.origin.y - self.keyboardHeight, self.loginScrollView.frame.size.width, self.loginScrollView.frame.size.height);
    }
}

- (void) textChange:(id)notification {
    if ([notification isKindOfClass:[UITextField class]]) {
        self.username = self.usernameTextField.text;
        self.password = self.passwordTextField.text;
    }
}

- (void) keyboardWasShown:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.keyboardHeight = MIN(keyboardSize.height,keyboardSize.width) - 30;
    if (self.loginScrollView.frame.origin.y == 0) {
        self.loginScrollView.frame = CGRectMake(self.loginScrollView.frame.origin.x, self.loginScrollView.frame.origin.y - self.keyboardHeight, self.loginScrollView.frame.size.width, self.loginScrollView.frame.size.height);
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if (self.password != nil) {
        NSString *jsCallBack = [NSString stringWithFormat:@"calcMD5('%@')", self.password];
        NSString *result = [webView stringByEvaluatingJavaScriptFromString:jsCallBack];
        self.password = result;
        [SSKeychain setPassword:self.password
                     forService:@"邮网"
                        account:self.username];
        NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
        [userInfo setObject:self.username forKey:@"username"];
    } else {
        self.password = [SSKeychain passwordForService:@"邮网" account:self.username];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    NSDictionary *parameters = @{@"account":self.username, @"password":self.password};
    NSLog(@"%@", self.loginString);
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    [manager GET:self.loginString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSString *content = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *loginContent = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSError *err = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"checkcode=\"(\\d+?)\";" options:NSRegularExpressionCaseInsensitive error:&err];
        NSTextCheckingResult *matchOfCheckcode = [regex firstMatchInString:loginContent options:0 range:NSMakeRange(0, [loginContent length])];
        NSString *checkCode = nil;
        if (matchOfCheckcode) {
            NSRange matchRange = [matchOfCheckcode rangeAtIndex:1];
            checkCode = [loginContent substringWithRange:matchRange];
            NSLog(@"checkcode =====%@", checkCode);
        }
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//        NSString *cookieName = nil;
//        NSString *cookieValue = nil;
        NSString *cookieString = nil;
        for (NSHTTPCookie *cookie in cookies) {
//            cookieName = cookie.name;
//            cookieValue = cookie.value;
            cookieString = [NSString stringWithFormat:@"%@=%@", cookie.name, cookie.value];
            NSLog(@"%@", cookieString);
        }
        
        NSMutableDictionary *loginParams = [[NSMutableDictionary alloc] init];
        [loginParams setObject:self.username forKey:@"account"];
        [loginParams setObject:self.password forKey:@"password"];
        [loginParams setObject:checkCode forKey:@"checkcode"];
        [loginParams setObject:@"" forKey:@"code"];
        [loginParams setObject:@"%E7%99%BB+%E5%BD%95" forKey:@"Submit"];
        [self getcode:cookieString andParamString:loginParams];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];

//    [manager POST:self.loginString parameters:(id) constructingBodyWithBlock: success:<#^(AFHTTPRequestOperation *operation, id responseObject)success#> failure:<#^(AFHTTPRequestOperation *operation, NSError *error)failure#>];
    
}

- (void) getcode:(NSString *)cookieString andParamString:(NSMutableDictionary *)params{
    AFHTTPRequestOperationManager *loginManager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:cookieString forHTTPHeaderField:@"Cookie"];
    loginManager.requestSerializer = requestSerializer;
    loginManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [loginManager GET:self.getCodeString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"fucking code");
        [self loginReqauest:params andCookieString:cookieString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error");
    }];
}

//- (void) loginReqauest:(NSMutableDictionary *)params andCookieName:(NSString *)cookieName andCookieValue:(NSString *)cookieValue{
- (void) loginReqauest:(NSMutableDictionary *)params andCookieString:(NSString *)cookieString {
    AFHTTPRequestOperationManager *loginManager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
//    [requestSerializer setValue:cookieValue forHTTPHeaderField:cookieName];
    [requestSerializer setValue:cookieString forHTTPHeaderField:@"Cookie"];
//    NSLog(@"cookiename %@", cookieName);
//    NSLog(@"cookievalue %@", cookieValue);
    NSLog(@"%@", params);
    self.password = nil;
    loginManager.requestSerializer = requestSerializer;
    loginManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [loginManager POST:self.loginActionString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *content = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self getcurrentOnline:content andCookieString:cookieString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void) getcurrentOnline:(NSString *)content andCookieString:(NSString *)cookieString {
    NSError *error;
    NSRegularExpression *login = [NSRegularExpression regularExpressionWithPattern:@"info_title" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange rangeExist = [login rangeOfFirstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
    if (!NSEqualRanges(rangeExist, NSMakeRange(NSNotFound, 0))) {
//        NSLog(@"succ");
        AFHTTPRequestOperationManager *loginManager = [AFHTTPRequestOperationManager manager];
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:cookieString forHTTPHeaderField:@"Cookie"];
        loginManager.requestSerializer = requestSerializer;
        loginManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [loginManager GET:self.onlineString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DetailStateViewController *detailStateViewController = [[DetailStateViewController alloc] init];
            detailStateViewController.detailContent = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            [self.navigationController pushViewController:detailStateViewController animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"fucking");
        }];
    } else {
//        NSLog(@"error");
    }
}
@end
