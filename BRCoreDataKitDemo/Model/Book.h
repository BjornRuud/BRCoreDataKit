//
//  Book.h
//  BRCoreDataKit
//
//  Created by Bjørn Olav Ruud on 05.08.14.
//  Copyright (c) 2014 Bjørn Olav Ruud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * publisher;
@property (nonatomic, retain) NSString * title;

@end
