//
//  NSObject+MELazyPropertySwizzlingAdditions.h
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 Usage:
 
 * Include this file and its implementation.
 
 * `#import` this header and call `+setupLazyProperties` in `+initialize` in the classes you want to have lazies.
 
 * For each property that you wish to load lazily, implement the following lazy getter:
 
 ```
 - (id)_lazy<PropertyName>
 {
     return <LazyPropertyValue>;
 }
 ```
 
 That's it, you're done. The first time a property is accessed, the `_lazy` getter is called in to set the ivar before calling the original implementation. Subsequently, a dispatch_once token is used to prevent the `_lazy` getter from running again.
 
 */

static const char lazyPrefix[] = "_lazy";

@interface NSObject (MELazyPropertySwizzlingAdditions)

/**
 
 Performs the setup of the getters by swizzling in the lazy properties to be called just prior to the first call of the normal properties.
 
 */
+ (void)setupLazyProperties;

@end
