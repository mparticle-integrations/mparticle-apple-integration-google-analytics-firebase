#import <XCTest/XCTest.h>
#import "MPKitFirebaseAnalytics.h"

@interface mParticle_Firebase_AnalyticsTests : XCTestCase

@end

@implementation mParticle_Firebase_AnalyticsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testStarted {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{googleAppIDKey:@"1:338209672096:ios:57235e7ff821ba85", senderID:@"338209672096"}];
    XCTAssertTrue(exampleKit.started);
}

@end
