//
//  GXKVOTestControllerVC.m
//  GXKVO
//
//  Created by sgx on 2019/8/14.
//  Copyright © 2019 sgx. All rights reserved.
//

#import "GXKVOTestControllerVC.h"
#import "KVOController.h"
#import "GXKVOTestModelShare.h"

@interface GXKVOTestControllerVC ()

@end

@implementation GXKVOTestControllerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)addObserveForShared:(id)sender {
    [self.KVOController observe:[GXKVOTestModelShare shared] keyPath:@"country" options:NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSKeyValueChangeKey,id> * _Nonnull change) {
        NSLog(@"sgx >>> ");
    }];
}
- (IBAction)changeObserveProperty:(id)sender {
    [GXKVOTestModelShare shared].country = [NSString stringWithFormat:@"sgx  >> %@",[GXKVOTestModelShare shared].country];
}


@end
