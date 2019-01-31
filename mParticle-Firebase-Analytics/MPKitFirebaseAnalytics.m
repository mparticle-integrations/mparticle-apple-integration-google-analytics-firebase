//
//  MPKitFirebaseAnalytics.m
//
//  Copyright 2018 mParticle, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MPKitFirebaseAnalytics.h"
#import "Firebase.h"

@interface MPKitFirebaseAnalytics()

@property (nonatomic, strong, readwrite) FIROptions *firebaseOptions;

@end

@implementation MPKitFirebaseAnalytics

#pragma mark Static Methods

+ (NSNumber *)kitCode {
    return @(MPKitInstanceFirebaseAnalytics);
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"FirebaseAnalytics" className:@"MPKitFirebaseAnalytics"];
    [MParticle registerExtension:kitRegister];
}


- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark MPKitInstanceProtocol methods
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    _configuration = configuration;
    
    if ([FIRApp defaultApp] == nil) {
        static dispatch_once_t FirebasePredicate;
        
        dispatch_once(&FirebasePredicate, ^{
            NSString *googleAppId = configuration[googleAppIDKey];
            NSString *gcmSenderId = configuration[senderID];
            
            FIROptions *options = [[FIROptions alloc] initWithGoogleAppID:googleAppId GCMSenderID:gcmSenderId];
            
            self.firebaseOptions = options;
            [FIRApp configureWithOptions:options];
            
            self->_started = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            });
        });
    } else {
        _started = YES;
    }

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (id const)providerKitInstance {
    return [self started] ? self : nil;
}

- (MPKitExecStatus *)logCommerceEvent:(MPCommerceEvent *)commerceEvent {
    if ([FIRApp defaultApp] == nil) {
        if (self.firebaseOptions != nil) {
            [FIRApp configureWithOptions:self.firebaseOptions];
        } else {
            return [self execStatus:MPKitReturnCodeFail];
        }
    }
    
    NSDictionary<NSString *, id> *parameters = [[NSMutableDictionary alloc] init];
    
    switch (commerceEvent.action) {
        case MPCommerceEventActionAddToCart: {
            for (MPProduct *product in commerceEvent.products) {
                parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:product withValue:nil];
                
                [FIRAnalytics logEventWithName:kFIREventAddToCart
                                    parameters:parameters];
            }
        }
            break;
            
        case MPCommerceEventActionRemoveFromCart: {
            for (MPProduct *product in commerceEvent.products) {
                parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:product withValue:nil];
                
                [FIRAnalytics logEventWithName:kFIREventRemoveFromCart
                                    parameters:parameters];
            }
        }
            break;
            
        case MPCommerceEventActionAddToWishList: {
            for (MPProduct *product in commerceEvent.products) {
                parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:product withValue:nil];

                [FIRAnalytics logEventWithName:kFIREventAddToWishlist
                                    parameters:parameters];
            }
        }
            break;
            
        case MPCommerceEventActionCheckout: {
            NSNumber *value = @0;
            for (MPProduct *product in commerceEvent.products) {
                value = @([value doubleValue] + [product.price doubleValue]);
            }
            parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:nil withValue:value];

            [FIRAnalytics logEventWithName:kFIREventBeginCheckout
                                parameters:parameters];
        }
            break;
            
        case MPCommerceEventActionCheckoutOptions: {
            parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:nil withValue:nil];

            [FIRAnalytics logEventWithName:kFIREventSetCheckoutOption
                                parameters:parameters];
        }
            break;
            
        case MPCommerceEventActionClick: {
            for (MPProduct *product in commerceEvent.products) {
                if (product.sku) {
                    [FIRAnalytics logEventWithName:kFIREventSelectContent
                                        parameters:@{
                                                     kFIRParameterContentType: @"product",
                                                     kFIRParameterItemID: product.sku
                                                     }];
                }
            }
        }
            break;
            
        case MPCommerceEventActionViewDetail: {
            if (commerceEvent.products.count > 1) {
                parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:commerceEvent.products[0] withValue:nil];

                [FIRAnalytics logEventWithName:kFIREventViewItemList
                                    parameters:parameters];
            }
            
            for (MPProduct *product in commerceEvent.products) {
                parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:product withValue:nil];

                [FIRAnalytics logEventWithName:kFIREventViewItem
                                    parameters:parameters];
            }
        }
            break;
            
        case MPCommerceEventActionPurchase: {
            NSNumber *value = @0;
            for (MPProduct *product in commerceEvent.products) {
                value = @([value doubleValue] + [product.price doubleValue]);
            }
            
            parameters = [self getParameterForCommerceEvent:commerceEvent andProduct:nil withValue:value];

            [FIRAnalytics logEventWithName:kFIREventEcommercePurchase
                                parameters:parameters];
        }
            break;
            
        case MPCommerceEventActionRefund: {
            NSNumber *value = @0;
            for (MPProduct *product in commerceEvent.products) {
                value = @([value doubleValue] + [product.price doubleValue]);
            }
            
            [FIRAnalytics logEventWithName:kFIREventPurchaseRefund
                                parameters:@{
                                             kFIRParameterCurrency: commerceEvent.currency,
                                             kFIRParameterValue: value,
                                             kFIRParameterTransactionID: commerceEvent.transactionAttributes.transactionId
                                             }];
        }
            break;
            
        default:
            break;
    }
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    if (![FIRApp defaultApp] && self.firebaseOptions != nil) {
        [FIRApp configureWithOptions:self.firebaseOptions];
    } else {
        return [self execStatus:MPKitReturnCodeFail];
    }
    
    if (![FIRApp defaultApp] || !event || !event.name) return [self execStatus:MPKitReturnCodeFail];

    [FIRAnalytics setScreenName:event.name screenClass:nil];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    if ([FIRApp defaultApp] == nil) {
        if (self.firebaseOptions != nil) {
            [FIRApp configureWithOptions:self.firebaseOptions];
        } else {
            return [self execStatus:MPKitReturnCodeFail];
        }
    }
    
    if (![FIRApp defaultApp] || !event || !event.name) return [self execStatus:MPKitReturnCodeFail];
    
    [FIRAnalytics logEventWithName:event.name
                        parameters:event.info];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    if ([FIRApp defaultApp] == nil) {
        if (self.firebaseOptions != nil) {
            [FIRApp configureWithOptions:self.firebaseOptions];
        } else {
            return [self execStatus:MPKitReturnCodeFail];
        }
    }
    
    [FIRAnalytics setUserID:user.userId.stringValue];
    [self logUserAttributes:user.userAttributes];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    if ([FIRApp defaultApp] == nil) {
        if (self.firebaseOptions != nil) {
            [FIRApp configureWithOptions:self.firebaseOptions];
        } else {
            return [self execStatus:MPKitReturnCodeFail];
        }
    }
    
    [FIRAnalytics setUserID:user.userId.stringValue];
    [self logUserAttributes:user.userAttributes];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    if ([FIRApp defaultApp] == nil) {
        if (self.firebaseOptions != nil) {
            [FIRApp configureWithOptions:self.firebaseOptions];
        } else {
            return [self execStatus:MPKitReturnCodeFail];
        }
    }
    
    [FIRAnalytics setUserID:user.userId.stringValue];
    [self logUserAttributes:user.userAttributes];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onLogoutComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    if ([FIRApp defaultApp] == nil) {
        if (self.firebaseOptions != nil) {
            [FIRApp configureWithOptions:self.firebaseOptions];
        } else {
            return [self execStatus:MPKitReturnCodeFail];
        }
    }
    
    [FIRAnalytics setUserID:nil];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (void)logUserAttributes:(NSDictionary<NSString *, id> *)userAttributes {
    if ([FIRApp defaultApp] == nil) {
        if (self.firebaseOptions != nil) {
            [FIRApp configureWithOptions:self.firebaseOptions];
        } else {
            return;
        }
    }
    
    NSArray *userAttributesKeys = userAttributes.allKeys;
    for (NSString *attributeKey in userAttributesKeys) {
        [FIRAnalytics setUserPropertyString:userAttributes[attributeKey] forName:attributeKey];
    }
}

-(NSDictionary<NSString *, id> *)getParameterForCommerceEvent:(MPCommerceEvent *)commerceEvent andProduct:(MPProduct *)product withValue:(NSNumber *)value {
    NSMutableDictionary<NSString *, id> *parameters = [[NSMutableDictionary alloc] init];
    
    if (product.quantity) {
        [parameters setObject:product.quantity forKey:kFIRParameterQuantity];
    }
    if (product.sku) {
        [parameters setObject:product.sku forKey:kFIRParameterItemID];
    }
    if (product.name) {
        [parameters setObject:product.name forKey:kFIRParameterItemName];
    }
    if (product.category) {
        [parameters setObject:product.category forKey:kFIRParameterItemCategory];
    }
    if (product.price) {
        [parameters setObject:product.price forKey:kFIRParameterValue];
        [parameters setObject:product.price forKey:kFIRParameterPrice];
    }
    if (commerceEvent.currency) {
        [parameters setObject:commerceEvent.currency forKey:kFIRParameterCurrency];
    }
    if (value) {
        [parameters setObject:value forKey:kFIRParameterValue];
    }
    if (commerceEvent.checkoutStep) {
        [parameters setObject:@(commerceEvent.checkoutStep) forKey:kFIRParameterCheckoutStep];
    }
    if (commerceEvent.checkoutOptions) {
        [parameters setObject:commerceEvent.checkoutOptions forKey:kFIRParameterCheckoutOption];
    }
    if (commerceEvent.transactionAttributes.transactionId) {
        [parameters setObject:commerceEvent.transactionAttributes.transactionId forKey:kFIRParameterTransactionID];
    }
    if (commerceEvent.transactionAttributes.tax) {
        [parameters setObject:commerceEvent.transactionAttributes.tax forKey:kFIRParameterTax];
    }
    if (commerceEvent.transactionAttributes.shipping) {
        [parameters setObject:commerceEvent.transactionAttributes.shipping forKey:kFIRParameterShipping];
    }
    if (commerceEvent.transactionAttributes.couponCode) {
        [parameters setObject:commerceEvent.transactionAttributes.couponCode forKey:kFIRParameterCoupon];
    }

    return parameters;
}

@end
