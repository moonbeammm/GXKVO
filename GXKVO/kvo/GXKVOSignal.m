//
//  GXKVOSignal.m
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import "GXKVOSignal.h"
#import <pthread.h>

@interface GXKVOSignal ()
{
    pthread_mutex_t _mutex;
}

@end

@implementation GXKVOSignal

- (id)initWithTarget:(__weak NSObject *)target observer:(__weak NSObject *)observer keyPath:(NSString *)keyPath {
    if (self = [super init]) {
        if (target == nil) {
            return nil;
        }
        if (observer == nil) {
            return nil;
        }
        if (keyPath.length == 0) {
            return nil;
        }
        _options = NSKeyValueObservingOptionInitial;
        _weakTarget = target;
        _observer = observer;
        _keyPath = keyPath;
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}
- (GXKVOSignal *)configOptions:(NSKeyValueObservingOptions)options {
    pthread_mutex_lock(&_mutex);
    _options = options;
    pthread_mutex_unlock(&_mutex);
    return self;
}
- (void)subscribNext:(GXKVOSignalBlock)nextBlock {
    pthread_mutex_lock(&_mutex);
    _block = [nextBlock copy];
    pthread_mutex_unlock(&_mutex);
    [self.weakTarget addObserver:self forKeyPath:self.keyPath options:self.options context:(__bridge void *)self];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != (__bridge void *)self) {
        return;
    }
    if (![keyPath isEqualToString:self.keyPath]) {
        return;
    }
    if (object != self.weakTarget) {
        return;
    }
    
    NSDictionary<NSKeyValueChangeKey, id> *changeWithKeyPath = change;
    GXKVOSignalBlock block;
    id observer;
    id target;
    
    // lock
    pthread_mutex_lock(&_mutex);
    
    block = self.block;
    observer = self.observer;
    target = self.weakTarget;
    
    NSMutableDictionary<NSString *, id> *tempChange = [NSMutableDictionary dictionaryWithObject:keyPath?:@"" forKey:GXKVOSignalKeyPath];
    [tempChange addEntriesFromDictionary:change];
    changeWithKeyPath = [tempChange copy];
    
    // unlock
    pthread_mutex_unlock(&_mutex);
    
    if (block == nil || target == nil) return;
    block(target, observer, changeWithKeyPath);
}
- (void)dealloc {
    [self.weakTarget removeObserver:self forKeyPath:self.keyPath];
    pthread_mutex_destroy(&_mutex);
    NSLog(@"GXKVOSignal dealloc!");
}

@end

static NSMapTable <NSObject *,NSMutableSet <GXKVOSignal *>*>* keyPathSignalsMap;
@implementation GXKVOWrapper

+ (GXKVOSignal *)addObserver:(NSObject *)observer target:(NSObject *)target keyPath:(NSString *)keyPath {
    @synchronized (self) {
        if (!keyPathSignalsMap) {
            keyPathSignalsMap = [NSMapTable weakToStrongObjectsMapTable];
        }
        
        // 检查是否已添加过监听
        NSMutableSet *signals = [keyPathSignalsMap objectForKey:observer];
        if (!signals) {
            signals = [NSMutableSet new];
            [keyPathSignalsMap setObject:signals forKey:observer];
        }
        for (GXKVOSignal *tempSignal in signals) {
            if (tempSignal.observer == observer && [tempSignal.keyPath isEqualToString:keyPath]) {
                return nil;
            }
        }
        
        GXKVOSignal *signal = [[GXKVOSignal alloc] initWithTarget:target observer:observer keyPath:keyPath];
        
        // 保存新的监听
        [signals addObject:signal];
        
        return signal;
    }
    return nil;
}
+ (void)removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    @synchronized (self) {
        NSMutableSet *signals = [keyPathSignalsMap objectForKey:keyPath];
        for (GXKVOSignal *tempSignal in signals) {
            if (tempSignal.observer == observer && [tempSignal.keyPath isEqualToString:keyPath]) {
                NSMutableSet *tempSignals = [NSMutableSet setWithSet:signals];
                [tempSignals removeObject:tempSignal];
                [keyPathSignalsMap setObject:[tempSignals copy] forKey:keyPath];
                break;
            }
        }
    }
}

@end
