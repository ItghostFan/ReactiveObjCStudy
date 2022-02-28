//
//  ReactiveObjCStudyTests.m
//  ReactiveObjCStudyTests
//
//  Created by ItghostFan on 2022/2/20.
//

#import <XCTest/XCTest.h>

#import <ReactiveObjC/ReactiveObjC.h>

@interface ReactiveObjCStudyTests : XCTestCase

@end

@implementation ReactiveObjCStudyTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testStartEagerlyWithScheduler {
    XCTestExpectation *expectation = [XCTestExpectation new];
    // MARK: startEagerlyWithScheduler操作的特点是，把Signal的触发放到特定线程，并把信号转换成RACReplaySubject。
    NSString *selector = NSStringFromSelector(@selector(startEagerlyWithScheduler:block:));
    RACSignal *signal = [RACSignal startEagerlyWithScheduler:RACScheduler.mainThreadScheduler block:^(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:[NSString stringWithFormat:@"RACSignal %@ 1!", selector]];
        [subscriber sendNext:[NSString stringWithFormat:@"RACSignal %@ 2!", selector]];
        [subscriber sendNext:[NSString stringWithFormat:@"RACSignal %@ 3!", selector]];
        [subscriber sendNext:[NSString stringWithFormat:@"RACSignal %@ 4!", selector]];
        [subscriber sendCompleted];
    }];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"%@", x);
        } completed:^{
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectations:@[expectation] timeout:20.0f];
}

- (void)testStartLazilyWithScheduler {
    XCTestExpectation *expectation = [XCTestExpectation new];
    // MARK: startLazilyWithScheduler操作的特点是，把Signal的触发放到特定线程，并把信号转换成RACReplaySubject。
    NSString *selector = NSStringFromSelector(@selector(startLazilyWithScheduler:block:));
    RACSignal *signal = [RACSignal startLazilyWithScheduler:RACScheduler.mainThreadScheduler block:^(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:[NSString stringWithFormat:@"RACSignal %@ 1!", selector]];
        [subscriber sendNext:[NSString stringWithFormat:@"RACSignal %@ 2!", selector]];
        [subscriber sendNext:[NSString stringWithFormat:@"RACSignal %@ 3!", selector]];
        [subscriber sendNext:[NSString stringWithFormat:@"RACSignal %@ 4!", selector]];
        [subscriber sendCompleted];
    }];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"%@", x);
        } completed:^{
            [expectation fulfill];
        }];
    });
    
    [self waitForExpectations:@[expectation] timeout:20.0f];
}

- (void)testBind {
    // MARK: Bind操作的特点是，把A的Value交给B使用。
    NSString *selector = NSStringFromSelector(@selector(bind:));
    RACSignal<__kindof NSString *> *signal = [RACSignal return:[NSString stringWithFormat:@"RACSignal A %@", selector]];
    [[signal bind:^{
        return ^(NSString * _Nullable value, BOOL *stop){
            return [RACSignal return:[value stringByAppendingString:@" RACSignal B"]];
        };
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    } completed:^{
    }];
}

- (void)testFlattenMap {
    // MARK: flattenMap操作的特点是，把A的Value交给B使用。
    NSString *selector = NSStringFromSelector(@selector(flattenMap:));
    RACSignal<__kindof NSString *> *signal = [RACSignal return:[NSString stringWithFormat:@"RACSignal A %@", selector]];
    [[signal flattenMap:^__kindof RACSignal * _Nullable(__kindof NSString * _Nullable value) {
        return [RACSignal return:[value stringByAppendingString:@" RACSignal B"]];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    } completed:^{
    }];
    
}

- (void)testFlatten {
    // MARK: flatten 将多个信号
    NSString *selector = NSStringFromSelector(@selector(flatten));
    RACSignal<__kindof NSString *> *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:[RACSignal return:[NSString stringWithFormat:@"RACSignal %@ 1", selector]]];
        [subscriber sendNext:[RACSignal return:[NSString stringWithFormat:@"RACSignal %@ 2", selector]]];
        [subscriber sendNext:[RACSignal return:[NSString stringWithFormat:@"RACSignal %@ 3", selector]]];
        [subscriber sendNext:[RACSignal return:[NSString stringWithFormat:@"RACSignal %@ 4", selector]]];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
    [signal.flatten subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@", x);
    } completed:^{
    }];
}

@end
