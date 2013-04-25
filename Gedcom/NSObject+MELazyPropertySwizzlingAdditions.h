//
//  NSObject+MELazyPropertySwizzlingAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 Usage: Call setupLazyProperties in +load.
 
 For each property that you wish to load lazily, implement the following lazy getter:
 
 ```
 - (id)_lazy<PropertyName>
 {
     return <LazyPropertyValue>;
 }
 ```
 
 Additionally, create an ivar:
 
 ```
 @implementation MyClass {
     dispatch_once_t _lazy<PropertyName>Token;
 }
 
 //...
 
 @end
 ```
 
 That's it, you're done. The first time a property is accessed, the _lazy getter is called in to set the ivar. Subsequently, the getters & setters are used as normal.
 
 */

static const char lazyPrefix[] = "_lazy";

@interface NSObject (MELazyPropertySwizzlingAdditions)

+ (void)setupLazyProperties;

@end
