# BRCoreDataKit

A minimalistic CoreData stack for iOS and OS X, and an assortment of categories that make life with CoreData easier.

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
