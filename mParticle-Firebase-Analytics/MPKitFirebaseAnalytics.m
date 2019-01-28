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
#import "Firebase.h";

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
    MPKitExecStatus *execStatus = [self execStatus:MPKitReturnCodeSuccess];
    
    switch (commerceEvent.action) {
        case MPCommerceEventActionAddToCart: {
            for (MPProduct *product in commerceEvent.products) {
                [FIRAnalytics logEventWithName:kFIREventAddToCart
                                    parameters:@{
                                                 kFIRParameterQuantity: product.quantity,
                                                 kFIRParameterItemID: product.sku,
                                                 kFIRParameterItemName: product.name,
                                                 kFIRParameterItemCategory: product.category,
                                                 kFIRParameterValue: product.price,
                                                 kFIRParameterPrice: product.price,
                                                 kFIRParameterCurrency: commerceEvent.currency
                                                 }];
            }
        }
            break;
            
        case MPCommerceEventActionRemoveFromCart: {
            for (MPProduct *product in commerceEvent.products) {
                [FIRAnalytics logEventWithName:kFIREventRemoveFromCart
                                    parameters:@{
                                                 kFIRParameterQuantity: product.quantity,
                                                 kFIRParameterItemID: product.sku,
                                                 kFIRParameterItemName: product.name,
                                                 kFIRParameterItemCategory: product.category,
                                                 kFIRParameterValue: product.price,
                                                 kFIRParameterPrice: product.price,
                                                 kFIRParameterCurrency: commerceEvent.currency
                                                 }];
            }
        }
            break;
            
        case MPCommerceEventActionAddToWishList: {
            for (MPProduct *product in commerceEvent.products) {
                [FIRAnalytics logEventWithName:kFIREventAddToWishlist
                                    parameters:@{
                                                 kFIRParameterQuantity: product.quantity,
                                                 kFIRParameterItemID: product.sku,
                                                 kFIRParameterItemName: product.name,
                                                 kFIRParameterItemCategory: product.category,
                                                 kFIRParameterValue: product.price,
                                                 kFIRParameterPrice: product.price,
                                                 kFIRParameterCurrency: commerceEvent.currency
                                                 }];
            }
        }
            break;
            
        case MPCommerceEventActionCheckout: {
            NSNumber *value = @0;
            for (MPProduct *product in commerceEvent.products) {
                value = @([value doubleValue] + [product.price doubleValue]);
            }

            [FIRAnalytics logEventWithName:kFIREventBeginCheckout
                                parameters:@{
                                             kFIRParameterValue: value,
                                             kFIRParameterCurrency: commerceEvent.currency,
                                             kFIRParameterItemID: commerceEvent.transactionAttributes.transactionId
                                             }];
        }
            break;
            
        case MPCommerceEventActionCheckoutOptions: {
            [FIRAnalytics logEventWithName:kFIREventSetCheckoutOption
                                parameters:@{
                                             kFIRParameterCheckoutStep: @(commerceEvent.checkoutStep),
                                             kFIRParameterCheckoutOption: commerceEvent.checkoutOptions
                                             }];
        }
            break;
            
        case MPCommerceEventActionClick: {
            for (MPProduct *product in commerceEvent.products) {
                [FIRAnalytics logEventWithName:kFIREventSelectContent
                                    parameters:@{
                                                 kFIRParameterContentType: @"product",
                                                 kFIRParameterItemID: product.sku
                                                 }];
            }
        }
            break;
            
        case MPCommerceEventActionViewDetail: {
            if (commerceEvent.products.count > 1) {
                [FIRAnalytics logEventWithName:kFIREventViewItemList
                                    parameters:@{
                                                 kFIRParameterItemCategory: commerceEvent.products[0].category
                                                 }];
            }
            
            for (MPProduct *product in commerceEvent.products) {
                [FIRAnalytics logEventWithName:kFIREventViewItem
                                    parameters:@{
                                                 kFIRParameterItemID: product.sku,
                                                 kFIRParameterItemName: product.name,
                                                 kFIRParameterItemCategory: product.category,
                                                 kFIRParameterPrice: product.price,
                                                 kFIRParameterQuantity: product.quantity,
                                                 kFIRParameterCurrency: commerceEvent.currency,
                                                 kFIRParameterValue: product.price
                                                 }];
            }
        }
            break;
            
        case MPCommerceEventActionPurchase: {
            NSNumber *value = @0;
            for (MPProduct *product in commerceEvent.products) {
                value = @([value doubleValue] + [product.price doubleValue]);
            }
            
            [FIRAnalytics logEventWithName:kFIREventEcommercePurchase
                                parameters:@{
                                             kFIRParameterCurrency: commerceEvent.currency,
                                             kFIRParameterValue: value,
                                             kFIRParameterTransactionID: commerceEvent.transactionAttributes.transactionId,
                                             kFIRParameterTax: commerceEvent.transactionAttributes.tax,
                                             kFIRParameterShipping: commerceEvent.transactionAttributes.shipping,
                                             kFIRParameterCoupon: commerceEvent.transactionAttributes.couponCode
                                             }];
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
    
    return execStatus;
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    if (![FIRApp defaultApp] || !event || event.name) return [self execStatus:MPKitReturnCodeFail];

    [FIRAnalytics setScreenName:event.name screenClass:nil];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    if (![FIRApp defaultApp] || !event) return [self execStatus:MPKitReturnCodeFail];
    
    [FIRAnalytics logEventWithName:event.name
                        parameters:event.info];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    [FIRAnalytics setUserID:user.userId.stringValue];
    [self logUserIdentities:request.userIdentities];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    [FIRAnalytics setUserID:user.userId.stringValue];
    [self logUserIdentities:request.userIdentities];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    [FIRAnalytics setUserID:user.userId.stringValue];
    [self logUserIdentities:request.userIdentities];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onLogoutComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    [FIRAnalytics setUserID:nil];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (void)logUserIdentities:(NSDictionary<NSNumber *, NSString *> *)userIdentities {
    NSArray *userIdentityKeys = userIdentities.allKeys;
    for (NSNumber *identityKey in userIdentityKeys) {
        NSString *propertyName;
        
        switch (identityKey.integerValue) {
            case MPUserIdentityOther:
                propertyName = @"other";
                break;
            case MPUserIdentityCustomerId:
                propertyName = @"customerid";
                break;
            case MPUserIdentityFacebook:
                propertyName = @"facebook";
                break;
            case MPUserIdentityTwitter:
                propertyName = @"twitter";
                break;
            case MPUserIdentityGoogle:
                propertyName = @"google";
                break;
            case MPUserIdentityMicrosoft:
                propertyName = @"microsoft";
                break;
            case MPUserIdentityYahoo:
                propertyName = @"yahoo";
                break;
            case MPUserIdentityAlias:
                propertyName = @"alias";
                break;
            case MPUserIdentityFacebookCustomAudienceId:
                propertyName = @"facebookcustom";
                break;
            case MPUserIdentityOther2:
                propertyName = @"other2";
                break;
            case MPUserIdentityOther3:
                propertyName = @"other3";
                break;
            case MPUserIdentityOther4:
                propertyName = @"other4";
                break;
                
            default:
                break;
        }
        [FIRAnalytics setUserPropertyString:userIdentities[identityKey] forName:propertyName];
    }
}

@end
