//
//  BRCoreDataStack.m
//  BRCoreDataKit
//
//  Created by Bjørn Olav Ruud on 04.08.14.
//  Copyright (c) 2014 Bjørn Olav Ruud. All rights reserved.
//

#import "BRCoreDataStack.h"

NSString * const BRCoreDataStackErrorDomain = @"net.bjornruud.BRCoreDataStack";
NSString * const BRCoreDataStackInitializedNotification = @"BRCoreDataStackInitializedNotification";

static BRCoreDataStack *_defaultStack = nil;

@interface BRCoreDataStack ()

@property (nonatomic, readwrite) BOOL isInitialized;

@end

@implementation BRCoreDataStack

#pragma mark - Class methods

+ (BRCoreDataStack *)defaultStack
{
    return _defaultStack;
}

+ (void)setDefaultStack:(BRCoreDataStack *)stack
{
    _defaultStack = stack;
}

#pragma mark - Lifecycle

- (instancetype)initWithModelURL:(NSURL *)modelURL
                        storeURL:(NSURL *)storeURL
                      completion:(void (^)(NSError *error))completion
{
    self = [super init];
    if (self) {
        // Do CoreData setup asynchronously since attaching a persistent store to a coordinator
        // might trigger migration, which can take some time depending on its complexity.
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            DLog(@"Begin Core Data setup");
            dispatch_queue_t mainQueue = dispatch_get_main_queue();

            NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
            if (!mom) {
                if (completion) {
                    dispatch_async(mainQueue, ^{
                        NSString *message = NSLocalizedString(@"Failed to initialize managed object model %@", nil);
                        message = [NSString stringWithFormat:message, [modelURL absoluteString]];
                        completion([self errorWithMessage:message]);
                    });
                }
                return;
            }
            DLog(@"Managed Object Model initialized");

            NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
            if (!psc) {
                if (completion) {
                    dispatch_async(mainQueue, ^{
                        NSString *message = NSLocalizedString(@"Failed to initialize persistent store coordinator", nil);
                        completion([self errorWithMessage:message]);
                    });
                }
                return;
            }
            DLog(@"Persistent Store Coordinator initialized");

            NSError *error = nil;
            NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                         configuration:nil
                                                                   URL:storeURL
                                                               options:nil
                                                                 error:&error];
            if (!store) {
                if (completion) {
                    dispatch_async(mainQueue, ^{
                        completion(error);
                    });
                }
                return;
            }
            DLog(@"Persistent store added to coordinator");

            // Setup contexts
            _persistentStoreCoordinator = psc;
            _mainQueueContext = [self contextWithConcurrencyType:NSMainQueueConcurrencyType];
            _privateQueueContext = [self contextWithConcurrencyType:NSPrivateQueueConcurrencyType];
            DLog(@"Contexts initialized");

            // Start observing context saves
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(processContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];

            // Finalize on main thread
            dispatch_async(mainQueue, ^{
                self.isInitialized = YES;
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:BRCoreDataStackInitializedNotification object:self];
                DLog(@"End Core Data setup");
                if (completion) {
                    completion(nil);
                }
            });
        });
    }

    return self;
}

- (instancetype)initWithName:(NSString *)name
                  completion:(void (^)(NSError *error))completion
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:name withExtension:@"momd"];
    NSURL *storeURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    storeURL = [storeURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", name]];

    return [self initWithModelURL:modelURL storeURL:storeURL completion:completion];
}

- (void)dealloc
{
    if (self.isInitialized) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    }
}

#pragma mark - Public methods

- (NSManagedObjectContext *)contextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];

    return context;
}

#pragma mark - Private methods

- (NSError *)errorWithMessage:(NSString *)message
{
    return [NSError errorWithDomain:BRCoreDataStackErrorDomain
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

#pragma mark - Context save handler

- (void)processContextDidSaveNotification:(NSNotification *)notification
{
    NSManagedObjectContext *sender = [notification object];
    // Only handle contexts that use the persistent store coordinator for this object
    if ([sender persistentStoreCoordinator] != _persistentStoreCoordinator) {
        return;
    }
    // Don't merge from same context
    NSManagedObjectContext *mainContext = sender != _mainQueueContext ? _mainQueueContext : nil;
    NSManagedObjectContext *privateContext = sender != _privateQueueContext ? _privateQueueContext : nil;
    [mainContext performBlock:^{
        [mainContext mergeChangesFromContextDidSaveNotification:notification];
    }];
    [privateContext performBlock:^{
        [privateContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

@end
