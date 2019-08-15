//
//  GXKVOTestModelShare.h
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GXKVOTestModelShare : NSObject
+ (instancetype)shared;
@property (nonatomic, strong) NSString *country;
@end

NS_ASSUME_NONNULL_END
