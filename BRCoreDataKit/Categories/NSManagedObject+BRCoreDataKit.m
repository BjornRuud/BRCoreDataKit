//
//  NSManagedObject+BRCoreDataKit.m
//  BRCoreDataKit
//
//  Created by Bjørn Olav Ruud on 04.08.14.
//  Copyright (c) 2014 Bjørn Olav Ruud. All rights reserved.
//

#import "BRCoreDataStack.h"
#import "NSManagedObject+BRCoreDataKit.h"

NSString * const BRCoreDataKitQueryOptionBatchSize = @"BRCoreDataKitQueryOptionBatchSize";
NSString * const BRCoreDataKitQueryOptionLimit = @"BRCoreDataKitQueryOptionLimit";
NSString * const BRCoreDataKitQueryOptionOffset = @"BRCoreDataKitQueryOptionOffset";
NSString * const BRCoreDataKitQueryOptionSortDescriptors = @"BRCoreDataKitQueryOptionSortDescriptors";

@implementation NSManagedObject (BRCoreDataKit)

+ (NSString *)entityName
{
    return NSStringFromClass(self);
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:[[self class] entityName] inManagedObjectContext:context];
    return [self initWithEntity:entity insertIntoManagedObjectContext:context];
}

@end

#pragma mark - Asynchronous query methods

@implementation NSManagedObject (BRCoreDataKitQuery)

// Private helper to configure fetch requests
+ (void)configureFetch:(NSFetchRequest *)fetch
         withPredicate:(NSPredicate *)predicate
               options:(NSDictionary *)options
{
    NSNumber *batchSize = options[BRCoreDataKitQueryOptionBatchSize];
    NSNumber *limit = options[BRCoreDataKitQueryOptionLimit];
    NSNumber *offset = options[BRCoreDataKitQueryOptionOffset];
    NSArray *sorts = options[BRCoreDataKitQueryOptionSortDescriptors];

    [fetch setPredicate:predicate];
    [fetch setSortDescriptors:sorts];
    if (batchSize) {
        [fetch setFetchBatchSize:[batchSize unsignedIntegerValue]];
    }
    if (limit) {
        [fetch setFetchLimit:[limit unsignedIntegerValue]];
    }
    if (offset) {
        [fetch setFetchOffset:[offset unsignedIntegerValue]];
    }
}

+ (void)objectWhere:(NSPredicate *)predicate
            options:(NSDictionary *)options
          inContext:(NSManagedObjectContext *)context
         completion:(void (^)(id object))completion
{
    NSAssert(predicate, @"Predicate required");
    NSAssert(context, @"Context required");
    NSAssert(completion, @"Completion block required");

    NSMutableDictionary *optionsWithLimit = [NSMutableDictionary dictionaryWithDictionary:options];
    optionsWithLimit[BRCoreDataKitQueryOptionLimit] = @1;

    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    [self configureFetch:fetch withPredicate:predicate options:optionsWithLimit];

    [context performBlock:^{
        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:fetch error:&error];
        if (!objects) {
            DLog(@"Fetch failed: %@", [error localizedDescription]);
        }
        id object = [objects count] ? objects[0] : nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(object);
        });
    }];
}

+ (void)objectWhere:(NSPredicate *)predicate
            options:(NSDictionary *)options
         completion:(void (^)(id object))completion
{
    [self objectWhere:predicate options:options inContext:[BRCoreDataStack defaultStack].privateQueueContext completion:completion];
}

+ (void)objectWhere:(NSPredicate *)predicate
         completion:(void (^)(id object))completion
{
    [self objectWhere:predicate options:nil completion:completion];
}

+ (void)objectWithID:(NSManagedObjectID *)objectID
           inContext:(NSManagedObjectContext *)context
          completion:(void (^)(id object))completion
{
    NSAssert(objectID, @"ObjectID required");
    NSAssert(context, @"Context required");
    NSAssert(completion, @"Completion block required");

    [context performBlock:^{
        id object = [context objectWithID:objectID];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(object);
        });
    }];
}

+ (void)objectWithID:(NSManagedObjectID *)objectID
          completion:(void (^)(id object))completion
{
    [self objectWithID:objectID inContext:[BRCoreDataStack defaultStack].privateQueueContext completion:completion];
}

+ (void)objectsWhere:(NSPredicate *)predicate
             options:(NSDictionary *)options
           inContext:(NSManagedObjectContext *)context
          completion:(void (^)(NSArray *objects))completion
{
    NSAssert(predicate, @"Predicate required");
    NSAssert(context, @"Context required");
    NSAssert(completion, @"Completion block required");

    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    [self configureFetch:fetch withPredicate:predicate options:options];

    [context performBlock:^{
        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:fetch error:&error];
        if (!objects) {
            DLog(@"Fetch failed: %@", [error localizedDescription]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(objects);
        });
    }];
}

+ (void)objectsWhere:(NSPredicate *)predicate
             options:(NSDictionary *)options
          completion:(void (^)(NSArray *objects))completion
{
    [self objectsWhere:predicate options:options inContext:[BRCoreDataStack defaultStack].privateQueueContext completion:completion];
}

+ (void)objectsWhere:(NSPredicate *)predicate
          completion:(void (^)(NSArray *objects))completion
{
    [self objectsWhere:predicate options:nil completion:completion];
}

@end
