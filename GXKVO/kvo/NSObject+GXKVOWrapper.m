//
//  NSObject+GXKVOWrapper.m
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import "NSObject+GXKVOWrapper.h"
#import <objc/runtime.h>

static NSString *keyPathObserverMapKey = @"keyPathObserverMapKey";

@interface NSObject ()

@property (nonatomic, strong) NSMutableDictionary <NSString *,NSArray <GXKVOSignal *>*>*keyPathObserverMap;

@end

@implementation NSObject (GXKVOWrapper)

- (GXKVOSignal *)addObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    @synchronized (self) {
        // 检查是否已添加过监听
        NSArray *observers = [self.keyPathObserverMap objectForKey:keyPath];
        for (GXKVOSignal *tempTrampoline in observers) {
            if (tempTrampoline.observer == observer && [tempTrampoline.keyPath isEqualToString:keyPath]) {
                return nil;
            }
        }
        
        GXKVOSignal *trampoline = [[GXKVOSignal alloc] initWithTarget:self observer:observer keyPath:keyPath];
        
        // 保存新的监听
        NSMutableArray *tempObservers = [NSMutableArray arrayWithArray:observers];
        [tempObservers addObject:trampoline];
        [self.keyPathObserverMap setObject:[tempObservers copy] forKey:keyPath];
        
        return trampoline;
    }
    return nil;
}
- (void)removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    @synchronized (self) {
        NSArray *observers = [self.keyPathObserverMap objectForKey:keyPath];
        for (GXKVOSignal *tempTrampoline in observers) {
            if (tempTrampoline.observer == observer && [tempTrampoline.keyPath isEqualToString:keyPath]) {
                NSMutableArray *tempObservers = [NSMutableArray arrayWithArray:observers];
                [tempObservers removeObject:tempTrampoline];
                [self.keyPathObserverMap setObject:[tempObservers copy] forKey:keyPath];
                break;
            }
        }
    }
}

- (void)setKeyPathObserverMap:(NSString *)keyPathObserverMap {
    objc_setAssociatedObject(self, &keyPathObserverMapKey, keyPathObserverMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableDictionary *)keyPathObserverMap {
    NSMutableDictionary *keyPathObserverMap = objc_getAssociatedObject(self, &keyPathObserverMapKey);
    if (!keyPathObserverMap) {
        keyPathObserverMap = [NSMutableDictionary new];
        objc_setAssociatedObject(self, &keyPathObserverMapKey, keyPathObserverMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return keyPathObserverMap;
}

@end
