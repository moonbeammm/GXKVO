//
//  GXKVOTestModelShare.m
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import "GXKVOTestModelShare.h"

@implementation GXKVOTestModelShare
+ (instancetype)shared {
    static GXKVOTestModelShare *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GXKVOTestModelShare alloc] init];
    });
    return manager;
}
@end
