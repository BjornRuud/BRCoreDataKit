# BRCoreDataKit

A minimalistic Core Data stack for iOS, and an assortment of categories that make life with Core Data easier.

## Usage

First create a managed object model. Make sure entity names are the same as class names, then generate classes for all entities. In the following example there is an entity called ```Book``` with a ```title``` property.

```objective-c
BRCoreDataStack *stack =
    [[BRCoreDataStack alloc] initWithName:@"Library" completion:NULL];
// Set as default stack. This enables you to use category methods that omit
// the context parameter.
[BRCoreDataStack setDefaultStack:stack];

// Don't use the stack before it's initialized. Observe stack.isInitialized,
// use the completion block, or listen for the notification to know when
// initialization is done.
NSArray *books = [Book objectsWhere:@"title BEGINSWITH[cd] 'b'"];
```

## Data Migration

Migration is automatic and done progressively from one model version to the next. There is only one requirement: all model versions must be named in such a way that they can be sorted alphanumerically in the same order as the version progression.

Light migration is always attempted first, and if that fails heavy migration is attempted. For heavy migration to work all required mapping models must be located in the main bundle.
