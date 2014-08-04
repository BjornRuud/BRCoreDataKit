//
//  BRDebug.m
//  BRCoreDataKit
//
//  Created by Bjørn Olav Ruud on 05.08.14.
//  Copyright (c) 2014 Bjørn Olav Ruud. All rights reserved.
//

#import "BRDebug.h"

#ifdef DEBUG

void DLog(NSString *message, ...) {
    va_list args;
    va_start(args, message);
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithFormat:message arguments:args]);
    va_end(args);
}

void ALog(NSString *message, ...) {
    va_list args;
    va_start(args, message);
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithFormat:message arguments:args]);
    [[NSAssertionHandler currentHandler]
     handleFailureInFunction:[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]
     file:[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding]
     lineNumber:__LINE__
     description:@"%@", [[NSString alloc] initWithFormat:message arguments:args]];
    va_end(args);
}

#else

void DLog(NSString *message, ...) {}

void ALog(NSString *message, ...) {
    va_list args;
    va_start(args, message);
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [[NSString alloc] initWithFormat:message arguments:args]);
    va_end(args);
}

#endif
