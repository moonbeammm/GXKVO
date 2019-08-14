//
//  GXKVOTestVC.m
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import "GXKVOTestVC.h"
#import "GXKVOTestModel.h"
#import "GXKVO.h"

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
    [[GXObserve(self.person, name) configOptions:NSKeyValueObservingOptionInitial] subscribNext:^(GXKVOTestModel *target, id observer, NSDictionary *change) {
        NSLog(@"sgx >> NSKeyValueObservingOptionNew %@ %@",target.name,self.person);// 这里循环引用了.
    }];
}
- (IBAction)addAgeObserver:(id)sender {
    [[GXObserve(self.person, age) configOptions:NSKeyValueObservingOptionNew] subscribNext:^(GXKVOTestModel *target, GXKVOTestVC * observer, NSDictionary *change) {
        NSLog(@"sgx >> NSKeyValueObservingOptionNew %@, %@",target.age,observer.person);
    }];
}

- (void)dealloc {
    NSLog(@"GXKVOTestVC dealloc!");
}

@end
