#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
    #import <mParticle_Apple_SDK/mParticle.h>
#elif defined(__has_include) && __has_include(<mParticle_Apple_SDK_NoLocation/mParticle.h>)
    #import <mParticle_Apple_SDK_NoLocation/mParticle.h>
#else
    #import "mParticle.h"
#endif

@interface MPKitFirebaseAnalytics : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;
@property (nonatomic, strong, nullable) MPKitAPI *kitApi;

@end

static NSString * _Nonnull const kMPFIRGoogleAppIDKey = @"firebaseAppId";
static NSString * _Nonnull const kMPFIRSenderIDKey = @"googleProjectNumber";
static NSString * _Nonnull const kMPFIRAPIKey = @"firebaseAPIKey";
static NSString * _Nonnull const kMPFIRProjectIDKey = @"firebaseProjectId";
static NSString * _Nonnull const kMPFIRExternalUserIdentityType = @"userIdField";
static NSString * _Nonnull const kMPFIRShouldHashUserId = @"hashUserId";
static NSString * _Nonnull const kMPFIRForwardRequestsServerSide = @"forwardWebRequestsServerSide";
static NSString * _Nonnull const kMPFIRCommerceEventType = @"Firebase.CommerceEventType";
static NSString * _Nonnull const kMPFIRPaymentType = @"Firebase.PaymentType";
static NSString * _Nonnull const kMPFIRShippingTier = @"Firebase.ShippingTier";
