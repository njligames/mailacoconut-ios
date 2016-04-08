//
//  PayPalInitializer.h
//  mailacoconut-ios
//
//  Created by James Folk on 4/6/16.
//  Copyright © 2016 NJLIGames Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayPalInitializer : NSObject

+(void)init:(NSString*)productionID sandbox:(NSString*)sandboxID;
@end
