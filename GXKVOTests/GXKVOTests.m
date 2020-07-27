//
//  GXKVOTests.m
//  GXKVOTests
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "GXKVOSignal.h"

#import "GXKVOTestModel.h"
#import "GXKVOTestModelShare.h"

@interface GXKVOTestsVC : UIViewController

@property (nonatomic, strong) GXKVOTestModel *person;
@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) GXKVOSignal *signal;

- (void)testNormal;
- (void)testShared;
- (void)testSelf;

@end

@implementation GXKVOTestsVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.person = [GXKVOTestModel new];
    }
    return self;
}

- (void)testNormal {
    [GXObserve(self.person, name) subscribNext:^(id value, id newValue) {
        NSLog(@"\n 监听普通类！ \n old name: %@ \n new name: %@",value,newValue);// 这里循环引用了.
    }];
    
    self.person.name = @"改变了！！";
}

- (void)testShared {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [GXObserve([GXKVOTestModelShare shared], country) subscribNext:^(id value, id newValue) {
        NSLog(@"\n 监听单例的属性！ \n old value: %@ \n new value: %@",value,newValue);// 这里循环引用了.
    }];
    [GXKVOTestModelShare shared].country = @"改变了！！";
}

- (void)testSelf {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    self.signal = GXObserve(self, ownerName);
    [GXObserve(self, ownerName) subscribNext:^(id value, id newValue) {
        NSLog(@"\n 监听自己的属性！ \n old name: %@ \n new name: %@",value,newValue);// 这里循环引用了.
    }];
    
    self.ownerName = @"改变了！！";
}

- (void)dealloc {
    NSLog(@"llllllllllllppppppppppppppp-------------------------------");
}

@end


@interface GXKVOTests : XCTestCase

@property (nonatomic, strong) GXKVOTestsVC *testShareVC;
@property (nonatomic, strong) GXKVOTestsVC *testNormalVC;
@property (nonatomic, strong) GXKVOTestsVC *testSelfVC;

@end

@implementation GXKVOTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
//    self.testShareVC = [GXKVOTestsVC new];
//    self.testNormalVC = [GXKVOTestsVC new];
//    self.testSelfVC = [GXKVOTestsVC new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    __weak GXKVOTestsVC *weakTestShareVC = self.testShareVC;
    __weak GXKVOTestsVC *weakTestNormalVC = self.testNormalVC;
    __weak GXKVOTestsVC *weakTestSelfVC = self.testSelfVC;
    
    self.testShareVC = [GXKVOTestsVC new];
    self.testNormalVC = [GXKVOTestsVC new];
    self.testSelfVC = [GXKVOTestsVC new];
    
    XCTAssertNil(weakTestShareVC);
    XCTAssertNil(weakTestNormalVC);
    XCTAssertNil(weakTestSelfVC);
    
}

// 监听单例的属性。测试是否会内存泄漏。
- (void)testShared {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    self.testShareVC = [GXKVOTestsVC new];
    [self.testShareVC testShared];
}

// 监听普通对象的属性。测试是否会内存泄漏。
- (void)testNormal {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    self.testNormalVC = [GXKVOTestsVC new];
    [self.testNormalVC testNormal];
}

// 监听自己的属性。测试是否会内存泄漏。
- (void)testSelf {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    self.testSelfVC = [GXKVOTestsVC new];
    [self.testSelfVC testSelf];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
