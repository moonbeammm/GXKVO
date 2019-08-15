//
//  NSObject+GXKVOWrapper.h
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXKVOSignal.h"
#import "GXKVOMacro.h"

NS_ASSUME_NONNULL_BEGIN

//#define GXObserve(TARGET, KEYPATH) \
//    ({ \
//        __weak id weakTarget = (TARGET); \
//        [weakTarget addObserver:self keyPath:@keypath(TARGET, KEYPATH)]; \
//    })
//
//#define GXRemoveObserve(TARGET, KEYPATH) \
//    ({ \
//        __weak id weakTarget = (TARGET); \
//        [weakTarget removeObserver:self keyPath:@keypath(TARGET, KEYPATH)]; \
//    })

@interface NSObject (GXKVOWrapper)

//- (GXKVOSignal *)addObserver:(NSObject *)observer keyPath:(NSString *)keyPath;
//- (void)removeObserver:(NSObject *)observer keyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
