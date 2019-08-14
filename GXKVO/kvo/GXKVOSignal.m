//
//  GXKVOSignal.m
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import "GXKVOSignal.h"

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
    }
    return self;
}
- (GXKVOSignal *)configOptions:(NSKeyValueObservingOptions)options {
    @synchronized (self) {
        _options = options;
    }
    return self;
}
- (void)subscribNext:(GXKVOSignalBlock)nextBlock {
    @synchronized (self) {
        _block = [nextBlock copy];
    }
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
    GXKVOSignalBlock block;
    id observer;
    id target;
    @synchronized (self) {
        block = self.block;
        observer = self.observer;
        target = self.weakTarget;
    }
    if (block == nil || target == nil) return;
    block(target, observer, change);
}
- (void)dealloc {
    NSLog(@"GXKVOSignal dealloc!");
    [self.weakTarget removeObserver:self forKeyPath:self.keyPath];
}

@end
