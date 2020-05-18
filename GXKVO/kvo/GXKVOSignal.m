//
//  GXKVOSignal.m
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import "GXKVOSignal.h"
#import <pthread.h>
#import <objc/runtime.h>

@interface GXKVOSignal ()
{
    pthread_mutex_t _mutex;
}
@property (nonatomic, readonly, weak) NSObject *weakTarget;
@property (nonatomic, readonly, weak) NSObject *observer;
@property (nonatomic, readonly, copy) NSString *keyPath;
@property (nonatomic, readonly, assign) NSKeyValueObservingOptions options;
@property (nonatomic, readonly, copy) GXKVOSignalBlock block;

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

- (void)dealloc {
    [self.weakTarget removeObserver:self forKeyPath:self.keyPath];
    pthread_mutex_destroy(&_mutex);
    NSLog(@"GXKVOSignal dealloc!");
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
    
//    NSDictionary<NSKeyValueChangeKey, id> *changeWithKeyPath = change;
    GXKVOSignalBlock block;
    id observer;
    id target;
    
    // lock
    pthread_mutex_lock(&_mutex);
    
    block = self.block;
    observer = self.observer;
    target = self.weakTarget;
    
//    NSMutableDictionary<NSString *, id> *tempChange = [NSMutableDictionary dictionaryWithObject:keyPath?:@"" forKey:GXKVOSignalKeyPath];
//    [tempChange addEntriesFromDictionary:change];
//    changeWithKeyPath = [tempChange copy];
    
    NSObject *value = [object valueForKey:keyPath];
    
    // unlock
    pthread_mutex_unlock(&_mutex);
    
    if (block == nil || target == nil) return;
    block(target, observer, value);
}

@end






















@interface GXKVOController : NSObject
{
    pthread_mutex_t _mutex;
    NSMapTable *_keyPathSignalMap;
}
@end

@implementation GXKVOController

- (instancetype)init {
    if (self = [super init]) {
        _keyPathSignalMap = [NSMapTable weakToStrongObjectsMapTable];
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

- (void)dealloc {
    [self removeAllSignals];
    pthread_mutex_destroy(&_mutex);
}

- (GXKVOSignal *)addObserver:(NSObject *)observer target:(NSObject *)target keyPath:(NSString *)keyPath {
    // lock
    pthread_mutex_lock(&_mutex);

    GXKVOSignal *signal = [_keyPathSignalMap objectForKey:keyPath];
    if (signal) {
        // 已经监听过了。防止重复注册。
        pthread_mutex_unlock(&_mutex);
        return nil;
    }
    
    signal = [[GXKVOSignal alloc] initWithTarget:target observer:observer keyPath:keyPath];
    [_keyPathSignalMap setObject:signal forKey:keyPath];
    
    // unlock
    pthread_mutex_unlock(&_mutex);

    return signal;
}

- (void)removeAllSignals {
    pthread_mutex_lock(&_mutex);
    [_keyPathSignalMap removeAllObjects];
    pthread_mutex_unlock(&_mutex);
}

- (void)removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    pthread_mutex_lock(&_mutex);
    [_keyPathSignalMap removeObjectForKey:keyPath];
    pthread_mutex_unlock(&_mutex);
}

@end




















static NSString *kGXKVOControllerKey = @"kGXKVOControllerKey";

@implementation GXKVOWrapper

+ (GXKVOSignal *)addObserver:(NSObject *)observer target:(NSObject *)target keyPath:(NSString *)keyPath {
    @synchronized (self) {

        GXKVOController *kvoControl = objc_getAssociatedObject(observer, &kGXKVOControllerKey);
        if (!kvoControl) {
            kvoControl = [GXKVOController new];
            objc_setAssociatedObject(observer, &kGXKVOControllerKey, kvoControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        GXKVOSignal *signal = [kvoControl addObserver:observer target:target keyPath:keyPath];

        return signal;
    }
}

+ (void)removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath {
    @synchronized (self) {
        GXKVOController *kvoControl = objc_getAssociatedObject(observer, &kGXKVOControllerKey);
        [kvoControl removeObserver:observer keyPath:keyPath];
    }
}

+ (void)removeAllObserver:(NSObject *)observer {
    @synchronized (self) {
        GXKVOController *kvoControl = objc_getAssociatedObject(observer, &kGXKVOControllerKey);
        [kvoControl removeAllSignals];
    }
}

@end
