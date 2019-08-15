//
//  NSObject+GXKVOWrapper.m
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import "NSObject+GXKVOWrapper.h"
#import <objc/runtime.h>

static NSString *keyPathSignalsMapKey = @"keyPathSignalsMapKey";

@interface NSObject ()

@property (nonatomic, strong) NSMapTable <NSObject *,NSArray <GXKVOSignal *>*>*keyPathSignalsMap;

@end

@implementation NSObject (GXKVOWrapper)

- (GXKVOSignal *)addObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    @synchronized (self) {
        // 检查是否已添加过监听
        NSArray *signals = [self.keyPathSignalsMap objectForKey:observer];
        for (GXKVOSignal *tempSignal in signals) {
            if (tempSignal.observer == observer && [tempSignal.keyPath isEqualToString:keyPath]) {
                return nil;
            }
        }

        GXKVOSignal *signal = [[GXKVOSignal alloc] initWithTarget:self observer:observer keyPath:keyPath];
        
        // 保存新的监听
        NSMutableArray *tempSignals = [NSMutableArray arrayWithArray:signals];
        [tempSignals addObject:signal];
        [self.keyPathSignalsMap setObject:[tempSignals copy] forKey:observer];
        
        return signal;
    }
    return nil;
}
- (void)removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    @synchronized (self) {
        NSArray *signals = [self.keyPathSignalsMap objectForKey:keyPath];
        for (GXKVOSignal *tempSignal in signals) {
            if (tempSignal.observer == observer && [tempSignal.keyPath isEqualToString:keyPath]) {
                NSMutableArray *tempSignals = [NSMutableArray arrayWithArray:signals];
                [tempSignals removeObject:tempSignal];
                [self.keyPathSignalsMap setObject:[tempSignals copy] forKey:keyPath];
                break;
            }
        }
    }
}

- (void)setKeyPathSignalsMap:(NSString *)keyPathSignalsMap {
    objc_setAssociatedObject(self, &keyPathSignalsMapKey, keyPathSignalsMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMapTable *)keyPathSignalsMap {
    NSMapTable *keyPathSignalsMap = objc_getAssociatedObject(self, &keyPathSignalsMapKey);
    if (!keyPathSignalsMap) {
        keyPathSignalsMap = [NSMapTable weakToStrongObjectsMapTable];
        objc_setAssociatedObject(self, &keyPathSignalsMapKey, keyPathSignalsMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return keyPathSignalsMap;
}

@end
