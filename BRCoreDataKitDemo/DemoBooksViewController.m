//
//  BRTDemoBooksViewController.m
//  BRToolkit
//
//  Created by Bjørn Olav Ruud on 03.09.13.
//  Copyright (c) 2013 Bjørn Olav Ruud. All rights reserved.
//

#import "DemoBooksViewController.h"
#import "Model.h"

@implementation DemoBooksViewController
{
    NSFetchedResultsController *_fetchBooksController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    BRCoreDataStack *dataStack = [BRCoreDataStack defaultStack];

    void (^bookLoad)() = ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadBooks];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self coreDataInitialized];
            });
        });
    };

    if (!dataStack.isInitialized) {
        __weak NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        id observer = [nc addObserverForName:BRCoreDataStackInitializedNotification object:dataStack queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [nc removeObserver:observer];
            bookLoad();
        }];
    } else {
        bookLoad();
    }
}

#pragma mark - Private Methods

- (void)coreDataInitialized
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:[Book entityName]];
    NSSortDescriptor *alphaSort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [fetch setSortDescriptors:@[alphaSort]];
    _fetchBooksController = [[NSFetchedResultsController alloc]
                             initWithFetchRequest:fetch
                             managedObjectContext:[BRCoreDataStack defaultStack].mainQueueContext
                             sectionNameKeyPath:nil
                             cacheName:@"BookCache"];
    [self reloadData];
}

- (void)loadBooks
{
    NSURL *jsonURL = [[NSBundle mainBundle] URLForResource:@"Books" withExtension:@"json"];
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:jsonURL] options:0 error:&error];
    NSAssert(result, @"Failed to read %@: %@", [jsonURL absoluteString], [error localizedDescription]);

    NSManagedObjectContext *context = [BRCoreDataStack defaultStack].privateQueueContext;
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:[Book entityName]];
    NSArray *books = result[@"Books"];
    for (NSDictionary *book in books) {
        error = nil;
        NSString *title = [book valueForKey:@"Title"];
        NSString *author = [book valueForKey:@"Author"];

        NSPredicate *titlePred = [NSPredicate predicateWithFormat:@"title LIKE %@", title];
        [fetch setPredicate:titlePred];
        NSArray *objects = [context executeFetchRequest:fetch error:&error];
        if (!objects) {
            NSLog(@"Fetch book failed: %@", [error localizedDescription]);
            continue;
        }
        Book *book = [objects lastObject];
        if (!book) {
            book = [[Book alloc] initWithContext:context];
        }
        book.title = title;
        book.author = author;
    }
    NSError *saveError = nil;
    BOOL saved = [context save:&saveError];
    NSAssert(saved, @"Save books failed: %@", [saveError localizedDescription]);
}

- (void)reloadData
{
    NSError *error = nil;
    if (![_fetchBooksController performFetch:&error]) {
        NSLog(@"Fetch data failed: %@", [error localizedDescription]);
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_fetchBooksController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = _fetchBooksController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"BookCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    Book *book = [_fetchBooksController objectAtIndexPath:indexPath];
    cell.textLabel.text = book.title;
    cell.detailTextLabel.text = book.author;

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = _fetchBooksController.sections[section];
    return sectionInfo.name;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _fetchBooksController.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [_fetchBooksController sectionForSectionIndexTitle:title atIndex:index];
}

@end
