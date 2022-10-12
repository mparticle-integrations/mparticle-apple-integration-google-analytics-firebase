#import <XCTest/XCTest.h>
#import "MPKitFirebaseAnalytics.h"
#import "Firebase.h"

@interface FIRApp()
+ (void)resetApps;
@end

@interface MPKitFirebaseAnalytics()
- (NSString *)standardizeNameOrKey:(NSString *)nameOrKey forEvent:(BOOL)forEvent;
- (NSString *)getEventNameForCommerceEvent:(MPCommerceEvent *)commerceEvent parameters:(NSDictionary<NSString *, id> *)parameters;
- (NSDictionary<NSString *, id> *)getParameterForCommerceEvent:(MPCommerceEvent *)commerceEvent;
@end

@interface mParticle_Firebase_AnalyticsTests : XCTestCase
@end

@implementation mParticle_Firebase_AnalyticsTests

- (void)setUp {
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] resourcePath];
    NSString *filePath = [bundlePath stringByAppendingPathComponent:@"GoogleService-Info.plist"];
    FIROptions *options = [[FIROptions alloc] initWithContentsOfFile:filePath];
    [FIRApp configureWithOptions:options];
}

- (void)tearDown {
    [FIRApp resetApps];
}

- (void)testStarted {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];
    
    XCTAssertTrue(exampleKit.started);
}

- (void)testLogCommerceEvent {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];

    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];
    XCTAssertTrue(execStatus.success);
}

- (void)testLogCommerceEventPurchase {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];

    MPProduct *product = [[MPProduct alloc] initWithName:@"Tardis" sku:@"9who" quantity:@1 price:@42.0];
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionPurchase product:product];
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];

    XCTAssertTrue(execStatus.success);
}

- (void)testLogCommerceEventImpression {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];

    MPProduct *product = [[MPProduct alloc] initWithName:@"Tardis" sku:@"9who" quantity:@1 price:@42.0];
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithImpressionName:@"suggested products list" product:product];
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];

    XCTAssertTrue(execStatus.success);
}

- (void)testLogCommerceEventPromotion {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];

    MPPromotion *promotion = [[MPPromotion alloc] init];
    promotion.promotionId = @"my_promo_1";
    promotion.creative = @"sale_banner_1";
    promotion.name = @"App-wide 50% off sale";
    promotion.position = @"dashboard_bottom";

    MPPromotionContainer *container = [[MPPromotionContainer alloc] initWithAction:MPPromotionActionView promotion:promotion];

    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithPromotionContainer:container];
    
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];

    XCTAssertTrue(execStatus.success);
}

- (void)testLogEvent {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];

    MPEvent *event = [[MPEvent alloc] initWithName:@"example" type:MPEventTypeOther];
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];

    XCTAssertTrue(execStatus.success);
}

- (void)testLogEventWithNilEvent {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];

    MPEvent *event = nil;
    MPKitExecStatus *execStatus = [exampleKit logBaseEvent:event];

    XCTAssertFalse(execStatus.success);
}

- (void)testSanitization {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event name" forEvent:YES], @"event_name");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event_name " forEvent:YES], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event  name " forEvent:YES], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event - name " forEvent:YES], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event name" forEvent:NO], @"event_name");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event_name " forEvent:NO], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event  name " forEvent:NO], @"event_name_");
    XCTAssertEqualObjects([exampleKit standardizeNameOrKey:@"event - name " forEvent:NO], @"event_name_");
}

- (void)testCommerceEventCheckoutOptions {
    MPKitFirebaseAnalytics *exampleKit = [[MPKitFirebaseAnalytics alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{}];

    // Test fallback when not using 
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    NSDictionary<NSString *, id> *parameters = [exampleKit getParameterForCommerceEvent:event];
    NSString *eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventSetCheckoutOption, eventName);

    // Test kFIREventAddShippingInfo
    event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    [event addCustomFlag:kFIREventAddShippingInfo withKey:kMPFIRCommerceEventType];
    eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventAddShippingInfo, eventName);

    // Test kFIREventAddPaymentInfo
    event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    [event addCustomFlag:kFIREventAddPaymentInfo withKey:kMPFIRCommerceEventType];
    eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventAddPaymentInfo, eventName);

    // Test both (defaults to kFIREventAddShippingInfo)
    event = [[MPCommerceEvent alloc] initWithAction:MPCommerceEventActionCheckoutOptions];
    [event addCustomFlags:@[kFIREventAddShippingInfo, kFIREventAddPaymentInfo] withKey:kMPFIRCommerceEventType];
    eventName = [exampleKit getEventNameForCommerceEvent:event parameters:parameters];
    XCTAssertEqualObjects(kFIREventAddShippingInfo, eventName);
}

@end
