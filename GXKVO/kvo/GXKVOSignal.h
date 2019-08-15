//
//  GXKVOSignal.h
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define GXObserve(TARGET, KEYPATH) \
    ({ \
        __weak id weakTarget = (TARGET); \
        [GXKVOWrapper addObserver:self target:weakTarget keyPath:@keypath(TARGET, KEYPATH)]; \
    })

#define GXRemoveObserve(TARGET, KEYPATH) \
    ({ \
        [GXKVOWrapper removeObserver:self keyPath:@keypath(TARGET, KEYPATH)]; \
    })

static NSString *const GXKVOSignalKeyPath = @"GXKVOSignalKeyPath";
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


@interface GXKVOWrapper : NSObject
+ (GXKVOSignal *)addObserver:(NSObject *)observer target:(NSObject *)target keyPath:(NSString *)keyPath;
+ (void)removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath;
@end

NS_ASSUME_NONNULL_END
