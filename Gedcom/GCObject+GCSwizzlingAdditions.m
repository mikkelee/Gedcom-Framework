//
//  GCObject+GCSwizzlingAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 23/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCObject+GCSwizzlingAdditions.h"

#import "GCTagAccessAdditions.h"

#import <objc/runtime.h>

@implementation GCObject (GCSwizzlingAdditions)

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    @synchronized (self) {
        Class cls = [self class];
        
        NSBundle *frameworkBundle = [NSBundle bundleForClass:cls];
        
        NSString *formatString = [frameworkBundle localizedStringForKey:@"Undo %@"
                                                                  value:@"Undo %@"
                                                                  table:@"Misc"];
        
        NSString *selName = NSStringFromSelector(sel);
        
        //NSLog(@"%@ selName: %@", [self className], selName);
        
        BOOL didResolve = NO;
        
        if ([selName hasPrefix:@"insertObject"]) {
            
            // indexed mutable object insert
            
            NSString *propType = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:16] substringFromIndex:15] lowercaseString], [[selName substringFromIndex:16] substringToIndex:[selName length]-(16+8)]];
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propType];
            
            if ([[cls validPropertyTypes] containsObject:propType] && [cls allowsMultipleOccurrencesOfPropertyType:propType]) {
                
                NSString *reverseSelName = [NSString stringWithFormat:@"removeObjectFrom%@%@AtIndex:", [[propType substringToIndex:1] uppercaseString], [propType substringFromIndex:1]];
                SEL reverseSel = NSSelectorFromString(reverseSelName);
                
                //NSLog(@"**** Swizzling %@ :: %@/%@ (%@ / %@) ****", cls, selName, reverseSelName, propType, ivarName);
                
                Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
                
                // creating fake method first, so I can call it below for the undo manager:
                IMP imp = imp_implementationWithBlock(^(GCObject *_s, id newObj, NSUInteger index) { return; });
                class_addMethod(cls, sel, imp, "v@:@I");
                
                imp = imp_implementationWithBlock(^(GCObject *_s, id newObj, NSUInteger index) {
                    NSMutableArray *_ivar = object_getIvar(_s, ivar);
                    
                    if ([newObj valueForKey:@"describedObject"] == _s) {
                        return;
                    }
                    
                    if (!_s->_isBuildingFromGedcom) {
                        NSUndoManager *uM = [_s valueForKey:@"undoManager"];
                        @synchronized (uM) {
                            [uM beginUndoGrouping];
                            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_s methodSignatureForSelector:reverseSel]];
                            [invocation setSelector:reverseSel];
                            [invocation setTarget:[uM prepareWithInvocationTarget:_s]];
                            [invocation setArgument:&index atIndex:2];
                            [invocation invoke];
                            [uM setActionName:[NSString stringWithFormat:formatString, [_s valueForKey:@"localizedType"]]];
                            [uM endUndoGrouping];
                        }
                    }
                    
                    if ([newObj valueForKey:@"describedObject"]) {
                        [((GCObject *)[newObj valueForKey:@"describedObject"]).mutableProperties removeObject:newObj];
                    }
                    
                    [newObj setValue:_s forKey:@"describedObject"];
                    
                    [_ivar insertObject:newObj atIndex:index];
                });
                
                Method method = class_getInstanceMethod(cls, sel);
                
                method_setImplementation(method, imp);
                
                didResolve = YES;
            }
            
        } else if ([selName hasPrefix:@"removeObjectFrom"]) {
            
            // indexed mutable object remove
            
            NSString *propType = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:17] substringFromIndex:16] lowercaseString], [[selName substringFromIndex:17] substringToIndex:[selName length]-(17+8)]];
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propType];
            
            if ([[cls validPropertyTypes] containsObject:propType] && [cls allowsMultipleOccurrencesOfPropertyType:propType]) {
                
                NSString *reverseSelName = [NSString stringWithFormat:@"insertObject:in%@%@AtIndex:", [[propType substringToIndex:1] uppercaseString], [propType substringFromIndex:1]];
                SEL reverseSel = NSSelectorFromString(reverseSelName);
                
                //NSLog(@"**** Swizzling %@ :: %@/%@ (%@ / %@) ****", cls, selName, reverseSelName, propType, ivarName);
                
                Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
                
                // creating fake method first, so I can call it below for the undo manager:
                IMP imp = imp_implementationWithBlock(^(GCObject *_s, NSUInteger index) { return; });
                class_addMethod(cls, sel, imp, "v@:I");
                
                imp = imp_implementationWithBlock(^(GCObject *_s, NSUInteger index) {
                    NSMutableArray *_ivar = object_getIvar(_s, ivar);
                    
                    if (!_s->_isBuildingFromGedcom) {
                        NSUndoManager *uM = [_s valueForKey:@"undoManager"];
                        @synchronized (uM) {
                            [uM beginUndoGrouping];
                            id obj = _ivar[index];
                            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_s methodSignatureForSelector:reverseSel]];
                            [invocation setSelector:reverseSel];
                            [invocation setTarget:[uM prepareWithInvocationTarget:_s]];
                            [invocation setArgument:&obj atIndex:2];
                            [invocation setArgument:&index atIndex:3];
                            [invocation invoke];
                            [uM setActionName:[NSString stringWithFormat:formatString, [_s valueForKey:@"localizedType"]]];
                            [uM endUndoGrouping];
                        }
                    }
                    
                    [((GCObject *)_ivar[index]) setValue:nil forKey:@"describedObject"];
                    
                    [_ivar removeObjectAtIndex:index];
                });
                
                Method method = class_getInstanceMethod(cls, sel);
                
                method_setImplementation(method, imp);
                
                didResolve = YES;
            }
            
        } else if ([selName hasPrefix:@"objectIn"]) {
            
            // indexed mutable object get
            
            NSString *propType = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:9] substringFromIndex:8] lowercaseString], [[selName substringFromIndex:9] substringToIndex:[selName length]-(9+8)]];
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propType];
            
            Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
            
            if ([[cls validPropertyTypes] containsObject:propType] && [cls allowsMultipleOccurrencesOfPropertyType:propType]) {
                
                //NSLog(@"**** Swizzling %@ :: %@ (%@) ****", cls, selName, propType);
                
                IMP imp = imp_implementationWithBlock(^(GCObject *_s, NSUInteger index) {
                    return [object_getIvar(_s, ivar) objectAtIndex:index];
                });
                
                didResolve = class_addMethod(cls, sel, imp, "@@:I");
            }
            
        } else if ([selName hasPrefix:@"countOf"]) {
            
            // indexed mutable count
            
            NSString *propType = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:8] substringFromIndex:7] lowercaseString], [selName substringFromIndex:8]];
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propType];
            
            Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
            
            if ([[cls validPropertyTypes] containsObject:propType] && [cls allowsMultipleOccurrencesOfPropertyType:propType]) {
                
                //NSLog(@"**** Swizzling %@ :: %@ (%@) ****", cls, selName, propType);
                
                IMP imp = imp_implementationWithBlock(^(GCObject *_s) {
                    return [object_getIvar(_s, ivar) count];
                });
                
                didResolve = class_addMethod(cls, sel, imp, "I@:");
            }
            
        } else if ([selName hasPrefix:@"set"]) {
            
            // single setter
            
            NSString *propType = [NSString stringWithFormat:@"%@%@", [[[selName substringToIndex:4] substringFromIndex:3] lowercaseString], [selName substringFromIndex:4]];
            propType = [propType substringToIndex:[propType length]-1];
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propType];
            
            if ([[cls validPropertyTypes] containsObject:propType] && ![cls allowsMultipleOccurrencesOfPropertyType:propType]) {
                
                //NSLog(@"**** Swizzling %@ :: %@ (%@ / %@) ****", cls, selName, propType, ivarName);
                
                Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
                
                // creating fake method first, so I can call it below for the undo manager:
                IMP imp = imp_implementationWithBlock(^(id _s, id newObj) { return; });
                class_addMethod(cls, sel, imp, "v@:@");
                
                imp = imp_implementationWithBlock(^(GCObject *_s, id newObj) {
                    id _ivar = object_getIvar(_s, ivar);
                    
                    if (!_s->_isBuildingFromGedcom) {
                        NSUndoManager *uM = [_s valueForKey:@"undoManager"];
                        @synchronized (uM) {
                            [uM beginUndoGrouping];
                            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_s methodSignatureForSelector:sel]];
                            [invocation setSelector:sel];
                            [invocation setTarget:[uM prepareWithInvocationTarget:_s]];
                            [invocation setArgument:&_ivar atIndex:2];
                            [invocation invoke];
                            [uM setActionName:[NSString stringWithFormat:formatString, [_s valueForKey:@"localizedType"]]];
                            [uM endUndoGrouping];
                        }
                    }
                    
                    if (_ivar) {
                        [_ivar setValue:nil forKey:@"describedObject"];
                    }
                    
                    [[newObj valueForKeyPath:@"describedObject.mutableProperties"] removeObject:newObj];
                    
                    [newObj setValue:_s forKey:@"describedObject"];
                    
                    NSParameterAssert(!newObj || [newObj valueForKey:@"describedObject"] == _s);
                    
                    object_setIvar(_s, ivar, newObj);
                    
                    //NSLog(@"!!swizz called!! ::: %@ : %@ ::: %@ => %@", cls, selName, _ivar, object_getIvar(_s, ivar));
                });
                
                Method method = class_getInstanceMethod(cls, sel);
                
                method_setImplementation(method, imp);
                
                didResolve = YES;
            }
            
            
        } else {
            
            // getter
            
            NSString *propType = selName;
            NSString *ivarName = [NSString stringWithFormat:@"_%@", propType];
            
            Ivar ivar = class_getInstanceVariable(self, [ivarName cStringUsingEncoding:NSASCIIStringEncoding]);
            
            if ([[cls validPropertyTypes] containsObject:propType]) {
                
                //NSLog(@"**** Swizzling %@ :: %@ (%@ / %@) ****", cls, selName, propType, ivarName);
                
                IMP imp = imp_implementationWithBlock(^(GCObject *_s) {
                    //NSLog(@"!!swizz called!! ::: %@ : %@ ::: => %@", cls, selName, object_getIvar(_s, ivar));
                    
                    return object_getIvar(_s, ivar);
                });
                
                didResolve = class_addMethod(cls, sel, imp, "@@:");
            }
        }
        
        if (didResolve) {
            //NSLog(@"%@ -> added %@", [self className], selName);
            
            return YES;
        } else {
            return [super resolveInstanceMethod:sel];
        }
    }
}

@end
