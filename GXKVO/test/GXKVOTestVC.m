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
@property (nonatomic, strong) NSString *myName;

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
    self.myName = @"change age";
}
- (IBAction)removeNameObserver:(id)sender {
    GXRemoveObserve(self.person, name);
}
- (IBAction)removeAgeObserver:(id)sender {
    GXRemoveObserve(self.person, age);
}
- (IBAction)addNamageObserver:(id)sender {
    [GXObserve(self.person, name) subscribNext:^(id value, id newValue) {
        NSLog(@"sgx >> NSKeyValueObservingOptionNew %@ %@",value,newValue);// 这里循环引用了.
    }];
}
- (IBAction)addAgeObserver:(id)sender {
    [GXObserve(self, myName) subscribNext:^(id value, id newValue) {
        NSLog(@"sgx >> NSKeyValueObservingOptionNew %@, %@",value,newValue);
    }];
}
- (IBAction)addSharedObserve:(id)sender {
    [GXObserve([GXKVOTestModelShare shared], country) subscribNext:^(id value, id newValue) {
        NSLog(@"sgx >> NSKeyValueObservingOptionNew %@",newValue);
    }];
}
- (IBAction)changeSharedProperty:(id)sender {
    [GXKVOTestModelShare shared].country = @"change shared country";
}

- (void)dealloc {
    NSLog(@"GXKVOTestVC dealloc!");
}

@end
