//
//  ImportContactsOperation.m
//  42
//
//  Created by Ilter Canberk on 7/24/14.
//  Copyright (c) 2014 Appcubator. All rights reserved.
//

#import "ImportContactsOperation.h"
#import "Store.h"

@interface ImportContactsOperation ()
@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, strong) Store* store;
@property (nonatomic, strong) NSManagedObjectContext* context;
@end


@implementation ImportContactsOperation
{
    
}

- (id)initWithStore:(Store*)store fileName:(NSString*)name
{
    self = [super init];
    if(self) {
        self.store = store;
        self.fileName = name;
    }
    return self;
}


- (void)main
{
    // TODO: can we use new in the name? I think it's bad style, any ideas for a better name?
    self.context = [self.store newPrivateContext];
    self.context.undoManager = nil;
    
    [self.context performBlockAndWait:^
     {
         [self import];
     }];
}

@end
