//
//  FindUserOnline.h
//  邮网
//
//  Created by lgy on 15/8/16.
//  Copyright © 2015年 lgy. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FindUserOnlineNotifi;
extern NSString *const UserinfoNotifi;

@interface FindUserOnline : NSObject
@property (nonatomic, strong) NSMutableDictionary *ipOnlineDic;
- (void) findUsers;
@end
