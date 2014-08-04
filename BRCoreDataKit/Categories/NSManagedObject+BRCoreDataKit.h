//
//  NSManagedObject+BRCoreDataKit.h
//  BRCoreDataKit
//
//  Created by Bjørn Olav Ruud on 04.08.14.
//  Copyright (c) 2014 Bjørn Olav Ruud. All rights reserved.
//

#import <CoreData/CoreData.h>

FOUNDATION_EXPORT NSString * const BRCoreDataKitQueryOptionBatchSize;
FOUNDATION_EXPORT NSString * const BRCoreDataKitQueryOptionLimit;
FOUNDATION_EXPORT NSString * const BRCoreDataKitQueryOptionOffset;
FOUNDATION_EXPORT NSString * const BRCoreDataKitQueryOptionSortDescriptors;

@interface NSManagedObject (BRCoreDataKit)

+ (NSString *)entityName;

- (id)initWithContext:(NSManagedObjectContext *)context;

@end

@interface NSManagedObject (BRCoreDataKitQuery)

#pragma mark - Asynchronous query methods

+ (void)objectWhere:(NSPredicate *)predicate
            options:(NSDictionary *)options
          inContext:(NSManagedObjectContext *)context
         completion:(void (^)(id object))completion;

+ (void)objectWhere:(NSPredicate *)predicate
            options:(NSDictionary *)options
         completion:(void (^)(id object))completion;

+ (void)objectWhere:(NSPredicate *)predicate
         completion:(void (^)(id object))completion;

+ (void)objectWithID:(NSManagedObjectID *)objectID
           inContext:(NSManagedObjectContext *)context
          completion:(void (^)(id object))completion;

+ (void)objectWithID:(NSManagedObjectID *)objectID
          completion:(void (^)(id object))completion;

+ (void)objectsWhere:(NSPredicate *)predicate
             options:(NSDictionary *)options
           inContext:(NSManagedObjectContext *)context
          completion:(void (^)(NSArray *objects))completion;

+ (void)objectsWhere:(NSPredicate *)predicate
             options:(NSDictionary *)options
          completion:(void (^)(NSArray *objects))completion;

+ (void)objectsWhere:(NSPredicate *)predicate
          completion:(void (^)(NSArray *objects))completion;

@end
