//
//  Store.h
//  42
//
//  Created by Ilter Canberk on 7/24/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Store : NSObject

@property (nonatomic,strong,readonly) NSManagedObjectContext* mainManagedObjectContext;

- (void)saveContext;
- (NSManagedObjectContext*)newPrivateContext;

@end
