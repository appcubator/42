//
//  ImportContactsOperation.h
//  42
//
//  Created by Ilter Canberk on 7/24/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Store.h"

@interface ImportContactsOperation : NSOperation

- (id)initWithStore:(Store*)store;
@property (nonatomic) float progress;
@property (nonatomic, copy) void (^progressCallback) (float);

@end
