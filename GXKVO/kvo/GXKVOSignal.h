//
//  GXKVOSignal.h
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GXKVOSignalBlock)(id target, id observer, NSDictionary *change);

@interface GXKVOSignal : NSObject

@property (nonatomic, readonly, weak) NSObject *weakTarget;
@property (nonatomic, readonly, weak) NSObject *observer;
@property (nonatomic, readonly, copy) NSString *keyPath;
@property (nonatomic, readonly, assign) NSKeyValueObservingOptions options;
@property (nonatomic, readonly, copy) GXKVOSignalBlock block;

- (id)initWithTarget:(__weak NSObject *)target observer:(__weak NSObject *)observer keyPath:(NSString *)keyPath;
- (void)subscribNext:(GXKVOSignalBlock)nextBlock;
- (GXKVOSignal *)configOptions:(NSKeyValueObservingOptions)options;

@end

NS_ASSUME_NONNULL_END
