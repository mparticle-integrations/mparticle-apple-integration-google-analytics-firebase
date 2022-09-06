#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif
#if SWIFT_PACKAGE
    @import Firebase;
#else
    #if __has_include(<FirebaseCore/FirebaseCore.h>)
        #import <FirebaseCore/FirebaseCore.h>
        #import <FirebaseAnalytics/FIRAnalytics.h>
    #else
        #import "FirebaseCore/FirebaseCore.h"
        #import "FirebaseAnalytics/FIRAnalytics.h"
    #endif
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
static NSString * _Nonnull const kMPFIRUserIdFieldKey = @"userIdField";
