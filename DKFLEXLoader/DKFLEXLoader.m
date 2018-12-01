//
//  DKFLEXLoader.m
//  UICatalog
//
//  Created by Danylo Kostyshyn on 8/2/14.
//  Copyright (c) 2014 f. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKFLEXLoader.h"
#import "FLEXManager.h"

@interface DKFLEXLoader ()

@end

@implementation DKFLEXLoader

__attribute__((constructor))
static void initializer(void)
{
	NSLog(@"libFLEX initializer");
}

__attribute__((destructor))
static void finalizer(void)
{
	NSLog(@"libFLEX finalizer");
}

@end
