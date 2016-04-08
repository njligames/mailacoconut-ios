//
//  PayPalInitializer.m
//  mailacoconut-ios
//
//  Created by James Folk on 4/6/16.
//  Copyright © 2016 NJLIGames Ltd. All rights reserved.
//

#import "PayPalInitializer.h"
#import "PayPalMobile.h"

@implementation PayPalInitializer

+(void)init:(NSString*)productionID sandbox:(NSString*)sandboxID
{
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : productionID,
                                                           PayPalEnvironmentSandbox : sandboxID}];
}

@end
