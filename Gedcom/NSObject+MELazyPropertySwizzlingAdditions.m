//
//  NSObject+MELazyPropertySwizzlingAdditions.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 24/04/13.
//  Copyright (c) 2013 Mikkel Eide Eriksen. All rights reserved.
//

#import "NSObject+MELazyPropertySwizzlingAdditions.h"
#import <objc/runtime.h>
#import <string.h>

@implementation NSObject (MELazyPropertySwizzlingAdditions)

+ (void)setupLazyProperties
{
    const size_t prefixLen = strlen(lazyPrefix);
    
    Class cls = [self class];
    
    int unsigned numMethods;
    Method *methods = class_copyMethodList(cls, &numMethods);
    for (int i = 0; i < numMethods; i++) {
        SEL lazySel = method_getName(methods[i]);
        const char *lazySelName = sel_getName(lazySel);
        
        if (strncmp(lazyPrefix, lazySelName, prefixLen) != 0) {
            continue;
        }
        
        //NSLog(@"%s", lazySelName);
        
        size_t tmpSize = (strlen(lazySelName)-prefixLen)+1;
        
        char *getterName = calloc(tmpSize, sizeof(char));
        strncpy(getterName, lazySelName+prefixLen, tmpSize);
        getterName[0] = getterName[0] + 32; // lowercase first char
        
        char *ivarName = calloc(tmpSize+1, sizeof(char));
        strncpy(ivarName+1, getterName, tmpSize);
        ivarName[0] = '_';
        
        tmpSize = strlen(lazySelName);
        char *tokenName = calloc(tmpSize+5, sizeof(char));
        strncpy(tokenName, lazySelName, tmpSize);
        strncpy(tokenName+tmpSize, "Token", 5);
        
        SEL getterSel = sel_registerName(getterName);
        
        Ivar ivar = class_getInstanceVariable(cls, ivarName);
        
        NSString *tokenKey = [NSString stringWithCString:tokenName encoding:NSASCIIStringEncoding];
        
        Method lazyGetter = class_getInstanceMethod(cls, lazySel);
        Method origGetter = class_getInstanceMethod(cls, getterSel);
        
        IMP lazyIMP = method_getImplementation(lazyGetter);
        IMP origIMP = method_getImplementation(origGetter);
        
        IMP newIMP = imp_implementationWithBlock(^(id _s) {
            dispatch_once_t *token = [_s tokenForKey:tokenKey];
            
            dispatch_once(token, ^{
                if (!object_getIvar(_s, ivar)) {
                    object_setIvar(_s, ivar, lazyIMP(_s, lazySel));
                }
            });
            
            return origIMP(_s, getterSel);
        });
        
        method_setImplementation(origGetter, newIMP);
    }
}

static char tokenDict;

- (dispatch_once_t *)tokenForKey:(NSString *)key
{
    NSMapTable *dict = objc_getAssociatedObject(self, &tokenDict);
    if (!dict) {
        dict = [NSMapTable mapTableWithKeyOptions:NSMapTableCopyIn valueOptions:NSMapTableObjectPointerPersonality];
        
        objc_setAssociatedObject(self, &tokenDict, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    dispatch_once_t *token = (dispatch_once_t *)[[dict objectForKey:key] pointerValue];
    
    if (!token) {
        dispatch_once_t *t = calloc(1, sizeof(dispatch_once_t));
        NSValue *val = [NSValue value:&t withObjCType:@encode(dispatch_once_t *)];
        [dict setObject:val forKey:key];
        token = t;
    }
    
    //NSLog(@"%p : %@ : %p", self, key, token);
    
    return token;
}

@end
