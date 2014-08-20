//
//  NSManagedObject+BRCoreDataKit.m
//  BRCoreDataKit
//
//  Created by Bjørn Olav Ruud on 04.08.14.
//  Copyright (c) 2014 Bjørn Olav Ruud. All rights reserved.
//

#import "BRCoreDataStack.h"
#import "BRDebug.h"
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

#pragma mark - Synchronous query methods

+ (id)objectInContext:(NSManagedObjectContext *)context
              options:(NSDictionary *)options
                where:(id)predicate
            arguments:(va_list)args
{
    NSMutableDictionary *optionsWithLimit = [NSMutableDictionary dictionaryWithDictionary:options];
    optionsWithLimit[BRCoreDataKitQueryOptionLimit] = @1;
    NSArray *objects = [self objectsInContext:context options:optionsWithLimit where:predicate arguments:args];

    return [objects firstObject];
}

+ (id)objectInContext:(NSManagedObjectContext *)context
              options:(NSDictionary *)options
                where:(id)predicate, ...
{
    va_list args;
    va_start(args, predicate);
    id object = [self objectInContext:context options:options where:predicate arguments:args];
    va_end(args);
    return object;
}

+ (id)objectInContext:(NSManagedObjectContext *)context
                where:(id)predicate, ...
{
    va_list args;
    va_start(args, predicate);
    id object = [self objectInContext:context options:nil where:predicate arguments:args];
    va_end(args);
    return object;
}

+ (id)objectWhere:(id)predicate, ...
{
    va_list args;
    va_start(args, predicate);
    id object = [self objectInContext:[BRCoreDataStack defaultStack].privateQueueContext options:nil where:predicate arguments:args];
    va_end(args);
    return object;
}


+ (id)objectInContext:(NSManagedObjectContext *)context
               withID:(NSManagedObjectID *)objectID
{
    NSAssert(objectID, @"ObjectID required");
    NSAssert(context, @"Context required");

    __block id object = nil;
    [context performBlockAndWait:^{
        object = [context objectWithID:objectID];
    }];

    return object;
}

+ (id)objectWithID:(NSManagedObjectID *)objectID
{
    return [self objectInContext:[BRCoreDataStack defaultStack].privateQueueContext withID:objectID ];
}

+ (NSArray *)objectsInContext:(NSManagedObjectContext *)context
                      options:(NSDictionary *)options
                        where:(id)predicate
                    arguments:(va_list)args
{
    NSAssert(context, @"Context required");
    NSAssert(predicate, @"Predicate required");
    NSPredicate *pred = nil;
    if ([predicate isKindOfClass:[NSPredicate class]]) {
        pred = predicate;
    } else if ([predicate isKindOfClass:[NSString class]]) {
        pred = [NSPredicate predicateWithFormat:predicate arguments:args];
    } else {
        NSAssert(NO, @"Predicate must be NSPredicate or NSString");
    }

    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    [self configureFetch:fetch withPredicate:pred options:options];

    __block NSArray *objects = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objects = [context executeFetchRequest:fetch error:&error];
        if (!objects) {
            DLog(@"Fetch failed: %@", [error localizedDescription]);
        }
    }];

    return objects;
}

+ (NSArray *)objectsInContext:(NSManagedObjectContext *)context
                      options:(NSDictionary *)options
                        where:(id)predicate, ...
{
    va_list args;
    va_start(args, predicate);
    NSArray *objects = [self objectsInContext:context options:options where:predicate arguments:args];
    va_end(args);
    return objects;
}

+ (NSArray *)objectsInContext:(NSManagedObjectContext *)context
                        where:(id)predicate, ...
{
    va_list args;
    va_start(args, predicate);
    NSArray *objects = [self objectsInContext:context options:nil where:predicate arguments:args];
    va_end(args);
    return objects;
}

+ (NSArray *)objectsWhere:(id)predicate, ...
{
    va_list args;
    va_start(args, predicate);
    NSArray *objects = [self objectsInContext:[BRCoreDataStack defaultStack].privateQueueContext options:nil where:predicate arguments:args];
    va_end(args);
    return objects;
}

#pragma mark - Asynchronous query methods

+ (void)objectInContext:(NSManagedObjectContext *)context
                  where:(NSPredicate *)predicate
                options:(NSDictionary *)options
             completion:(void (^)(id object))completion
{
    NSMutableDictionary *optionsWithLimit = [NSMutableDictionary dictionaryWithDictionary:options];
    optionsWithLimit[BRCoreDataKitQueryOptionLimit] = @1;

    [self objectsInContext:context where:predicate options:optionsWithLimit completion:^(NSArray *objects) {
        id object = [objects firstObject];
        completion(object);
    }];
}

+ (void)objectInContext:(NSManagedObjectContext *)context
                  where:(NSPredicate *)predicate
             completion:(void (^)(id object))completion
{
    [self objectInContext:context where:predicate options:nil completion:completion];
}

+ (void)objectWhere:(NSPredicate *)predicate
         completion:(void (^)(id object))completion
{
    [self objectInContext:[BRCoreDataStack defaultStack].privateQueueContext where:predicate options:nil completion:completion];
}

+ (void)objectInContext:(NSManagedObjectContext *)context
                 withID:(NSManagedObjectID *)objectID
             completion:(void (^)(id object))completion
{
    NSAssert(context, @"Context required");
    NSAssert(objectID, @"ObjectID required");
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
    [self objectInContext:[BRCoreDataStack defaultStack].privateQueueContext withID:objectID completion:completion];
}

+ (void)objectsInContext:(NSManagedObjectContext *)context
                   where:(NSPredicate *)predicate
                 options:(NSDictionary *)options
              completion:(void (^)(NSArray *objects))completion
{
    NSAssert(context, @"Context required");
    NSAssert(predicate, @"Predicate required");
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

+ (void)objectsInContext:(NSManagedObjectContext *)context
                   where:(NSPredicate *)predicate
              completion:(void (^)(NSArray *objects))completion
{
    [self objectsInContext:context where:predicate options:nil completion:completion];
}

+ (void)objectsWhere:(NSPredicate *)predicate
          completion:(void (^)(NSArray *objects))completion
{
    [self objectsInContext:[BRCoreDataStack defaultStack].privateQueueContext where:predicate options:nil completion:completion];
}

@end
