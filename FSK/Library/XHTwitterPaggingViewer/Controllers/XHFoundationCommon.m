//
//  XHFoundationCommon.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-28.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHFoundationCommon.h"
#import <UIKit/UIKit.h>
@implementation XHFoundationCommon

+ (BOOL)isIOS7 {
    return [[[UIDevice currentDevice] systemVersion] integerValue] >= 7.0;
}

+ (float)getAdapterHeight {
    CGFloat adapterHeight = 0;
    if (![self isIOS7]) {
        adapterHeight = 44;
    }
    return adapterHeight;
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
