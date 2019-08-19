//
//  GXKVOTestVC.m
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import "GXKVOTestVC.h"
#import "GXKVOTestModel.h"
#import "GXKVOTestModelShare.h"
#import "GXKVOSignal.h"

@interface GXKVOTestVC ()

@property (nonatomic, strong) GXKVOTestModel *person;

@end

@implementation GXKVOTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person = [GXKVOTestModel new];
    self.person.name = @"old";
    self.person.age = @"0";
}
- (IBAction)releaseperson:(id)sender {
    self.person = nil;
}
- (IBAction)changeName:(id)sender {
    self.person.name = @"change name";
}
- (IBAction)changeAge:(id)sender {
    self.person.age = @"change age";
}
- (IBAction)removeNameObserver:(id)sender {
    GXRemoveObserve(self.person, name);
}
- (IBAction)removeAgeObserver:(id)sender {
    GXRemoveObserve(self.person, age);
}
- (IBAction)addNamageObserver:(id)sender {
    [[GXObserve(self.person, name) configOptions:NSKeyValueObservingOptionInitial] subscribNext:^(GXKVOTestModel *target, GXKVOTestVC * observer, NSDictionary *change) {
        NSLog(@"sgx >> NSKeyValueObservingOptionNew %@ %@",target.name,observer.person);// 这里循环引用了.
    }];
}
- (IBAction)addAgeObserver:(id)sender {
    [[GXObserve(self.person, age) configOptions:NSKeyValueObservingOptionNew] subscribNext:^(GXKVOTestModel *target, GXKVOTestVC * observer, NSDictionary *change) {
        NSLog(@"sgx >> NSKeyValueObservingOptionNew %@, %@",target.age,observer.person);
    }];
}
- (IBAction)addSharedObserve:(id)sender {
    [GXObserve([GXKVOTestModelShare shared], country) subscribNext:^(GXKVOTestModelShare * target, id  _Nonnull observer, NSDictionary * _Nonnull change) {
        NSLog(@"sgx >> NSKeyValueObservingOptionNew %@",target.country);
    }];
}
- (IBAction)changeSharedProperty:(id)sender {
    [GXKVOTestModelShare shared].country = @"change shared country";
}

- (void)dealloc {
    NSLog(@"GXKVOTestVC dealloc!");
}

@end
