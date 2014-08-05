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

#pragma mark - Synchronous query methods

+ (id)objectInContext:(NSManagedObjectContext *)context
              options:(NSDictionary *)options
                where:(id)predicate, ...;

+ (id)objectInContext:(NSManagedObjectContext *)context
                where:(id)predicate, ...;

+ (id)objectWhere:(id)predicate, ...;

+ (id)objectInContext:(NSManagedObjectContext *)context
               withID:(NSManagedObjectID *)objectID;

+ (id)objectWithID:(NSManagedObjectID *)objectID;

+ (NSArray *)objectsInContext:(NSManagedObjectContext *)context
                      options:(NSDictionary *)options
                        where:(id)predicate, ...;

+ (NSArray *)objectsInContext:(NSManagedObjectContext *)context
                        where:(id)predicate, ...;

+ (NSArray *)objectsWhere:(id)predicate, ...;

#pragma mark - Asynchronous query methods

+ (void)objectInContext:(NSManagedObjectContext *)context
                  where:(NSPredicate *)predicate
                options:(NSDictionary *)options
             completion:(void (^)(id object))completion;

+ (void)objectInContext:(NSManagedObjectContext *)context
                  where:(NSPredicate *)predicate
             completion:(void (^)(id object))completion;

+ (void)objectWhere:(NSPredicate *)predicate
         completion:(void (^)(id object))completion;

+ (void)objectInContext:(NSManagedObjectContext *)context
                 withID:(NSManagedObjectID *)objectID
             completion:(void (^)(id object))completion;

+ (void)objectWithID:(NSManagedObjectID *)objectID
          completion:(void (^)(id object))completion;

+ (void)objectsInContext:(NSManagedObjectContext *)context
                   where:(NSPredicate *)predicate
                 options:(NSDictionary *)options
              completion:(void (^)(NSArray *objects))completion;

+ (void)objectsInContext:(NSManagedObjectContext *)context
                   where:(NSPredicate *)predicate
              completion:(void (^)(NSArray *objects))completion;

+ (void)objectsWhere:(NSPredicate *)predicate
          completion:(void (^)(NSArray *objects))completion;

@end
