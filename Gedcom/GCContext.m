//
//  GCContext.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 28/03/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCContext_internal.h"

#import "GedcomCharacterSetHelpers.h"
#import "GedcomErrors.h"

#import "GCContext+GCKeyValueAdditions.h"
#import "GCContext+GCTransactionAdditions.h"

#import "GCNodeParser.h"
#import "GCNode.h"
#import "GCTag.h"

#import "GCCharacterSetAttribute.h"
#import "GCHeaderEntity+GCObjectAdditions.h"

#import "GCContextDelegate.h"

#import "GCGedcomLoadingAdditions.h"
#import "GCGedcomAccessAdditions.h"
#import "GCTagAccessAdditions.h"

#import "GCObject+GCKeyValueAdditions.h"

@interface GCTrailerEntity : GCEntity //empty class to match trailer objects
@end
@implementation GCTrailerEntity
@end

@interface NSMapTable (GCSubscriptAdditions)

- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)object forKeyedSubscript:(id)key;

@end

@implementation NSMapTable (GCSubscriptAdditions)

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(id)key
{
    return [self setObject:object forKey:key];
}

@end

@implementation GCContext {
	NSMapTable *_xrefToRecordMap;
    NSMapTable *_recordToXrefMap;
    
    NSOperationQueue *_mainQueue;
    
    NSUInteger _importCount;
}

__strong static NSMapTable *_contextsByName = nil;
__strong static NSArray *_rootKeys = nil;

+ (void)initialize
{
    _contextsByName = [NSMapTable strongToWeakObjectsMapTable];
    _rootKeys = @[ @"families", @"individuals", @"multimedias", @"notes", @"repositories", @"sources", @"submitters" ];
}

- (instancetype)init
{
	self = [super init];
	
	if (self) {
        _name = [[NSUUID UUID] UUIDString];
        
        _xrefToRecordMap = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                 valueOptions:(NSMapTableObjectPointerPersonality | NSMapTableWeakMemory)];
        
        _recordToXrefMap = [NSMapTable mapTableWithKeyOptions:(NSMapTableObjectPointerPersonality | NSMapTableWeakMemory)
                                                 valueOptions:NSMapTableStrongMemory];
        
        _families = [NSMutableArray array];
        _individuals = [NSMutableArray array];
        _multimedias = [NSMutableArray array];
        _notes = [NSMutableArray array];
        _repositories = [NSMutableArray array];
        _sources = [NSMutableArray array];
        _submitters = [NSMutableArray array];
        
        _customEntities = [NSMutableArray array];
        
        _mainQueue = [[NSOperationQueue alloc] init];
        
        _importCount = 0;
        
        _undoManager = [[NSUndoManager alloc] init];
        [_undoManager setGroupsByEvent:NO];
        
        @synchronized (_contextsByName) {
            _contextsByName[_name] = self;
        }
	}
	
	return self;
}

+ (id)context
{
	return [[self alloc] init];
}

+ (NSDictionary *)contextsByName
{
    @synchronized (_contextsByName) {
        return [_contextsByName copy];
    }
}

#pragma mark GCNodeParser delegate methods

- (void)parser:(GCNodeParser *)parser willParseCharacterCount:(NSUInteger)characterCount
{
    
}

- (void)parser:(GCNodeParser *)parser didParseNode:(GCNode *)node
{
    [_mainQueue addOperationWithBlock:^{
        GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
        
        NSParameterAssert(tag);
        
        if (tag.objectClass != [GCTrailerEntity class]) {
            GCObject *obj = [tag.objectClass newWithGedcomNode:node inContext:self];
            NSParameterAssert(obj.context == self);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_delegate && [_delegate respondsToSelector:@selector(context:didUpdateEntityCount:)]) {
                [_delegate context:self didUpdateEntityCount:++_importCount];
            }
        });
    }];
}

- (void)parser:(GCNodeParser *)parser didParseNodesWithCount:(NSUInteger)nodeCount
{
    [_mainQueue setSuspended:NO];
}

#pragma mark Loading nodes into a context

- (BOOL)parseData:(NSData *)data error:(NSError **)error
{
    GCParameterAssert([self.entities count] == 0);
    
    GCFileEncoding fileEncoding = encodingForData(data);
    
    GCNodeParser *nodeParser = [[GCNodeParser alloc] init];
    nodeParser.delegate = self;
    
    NSString *gedString = nil;
    
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    
    if (fileEncoding == GCUnknownFileEncoding) {
        if (error != NULL) {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: [frameworkBundle localizedStringForKey:@"Could not determine encoding for the file."
                                                                                                   value:@"Could not determine encoding for the file."
                                                                                                   table:@"Errors"]
                                       };
            *error = [NSError errorWithDomain:GCErrorDomain
                                         code:GCUnhandledFileEncodingError
                                     userInfo:userInfo];
        }
        return NO;
    } else if (fileEncoding == GCANSELFileEncoding) {
        gedString = stringFromANSELData(data);
    } else {
        gedString = [[NSString alloc] initWithData:data encoding:fileEncoding];
    }
    
#ifdef DEBUGLEVEL
    NSDate *start = [NSDate date];
#endif
    
    BOOL result = [nodeParser parseString:gedString error:error];
    
    [_mainQueue waitUntilAllOperationsAreFinished];
    
#ifdef DEBUGLEVEL
    NSTimeInterval timeInterval = fabs([start timeIntervalSinceNow]);
    NSLog(@"parsed %ld entities - Time: %f seconds", [self.entities count], timeInterval);
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(context:didParseNodesWithEntityCount:)]) {
            [_delegate context:self didParseNodesWithEntityCount:[self.entities count]];
        }
    });
    
    return result;
}

- (BOOL)readContentsOfFile:(NSString *)path error:(NSError **)error
{
    return [self parseData:[NSData dataWithContentsOfFile:path] error:error];
}

- (BOOL)readContentsOfURL:(NSURL *)url error:(NSError **)error
{
    return [self parseData:[NSData dataWithContentsOfURL:url] error:error];
}

#pragma mark Saving a context

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile error:(NSError **)error
{
    NSData *dataToWrite = self.gedcomData;
    
    NSDataWritingOptions options = 0;
    
    options |= useAuxiliaryFile ? NSDataWritingAtomic : 0;
    
    return [dataToWrite writeToFile:path options:options error:error];
}

#pragma mark Getting entities by URL

+ (GCEntity *)recordForURL:(NSURL *)url
{
    NSParameterAssert([url.scheme isEqualToString:@"xref"]);
    
    GCContext *context = [GCContext contextsByName][url.host];
    
    return [context _recordForXref:[url.path lastPathComponent] create:NO withClass:nil];
}

#pragma mark Merging contexts

- (BOOL)mergeContext:(GCContext *)context error:(NSError **)error
{
    context = [context copy];
    
    [self beginTransaction];
    
    BOOL succeeded = YES; //TODO
    
    [self _sortByXrefs];
    [context _sortByXrefs];
    
    [self _clearXrefs]; //TODO undo?
    
    for (NSString *rootKey in _rootKeys) {
        id entity = nil;
        // can't enumerate as they are being removed when adding to the new...
        while ( [context[rootKey] count] > 0 && (entity = context[rootKey][0]) ) {
            [self _addEntity:entity];
        }
    }
    
    if (!succeeded) {
        [self rollback];
        *error = [NSError errorWithDomain:GCErrorDomain code:GCMergeFailedError userInfo:@{}]; //TODO
    } else {
        [self commit];
        [self _renumberXrefs];
    }
    
    return succeeded;
}

#pragma mark Equality

- (BOOL)isEqualTo:(GCObject *)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self.gedcomString isEqualToString:object.gedcomString];
}

#pragma mark NSCopying conformance

- (id)copyWithZone:(NSZone *)zone
{
    // deep copy
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
}

#pragma mark NSCoding conformance

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
    
    if (self) {
        NSString *decodedName = [aDecoder decodeObjectForKey:@"name"];
        
        NSString *key = decodedName;
        int i = 0;
        while (_contextsByName[key]) {
            key = [NSString stringWithFormat:@"%@::%d", decodedName, ++i];
        }
        _name = key;
        _contextsByName[_name] = self;
        
        _xrefToRecordMap = [aDecoder decodeObjectForKey:@"xrefStore"];
        _recordToXrefMap = [aDecoder decodeObjectForKey:@"entityToXref"];
        self.header = [aDecoder decodeObjectForKey:@"header"];
        self.submission = [aDecoder decodeObjectForKey:@"submission"];
        
        _families = [aDecoder decodeObjectForKey:@"families"];
        _individuals = [aDecoder decodeObjectForKey:@"individuals"];
        _multimedias = [aDecoder decodeObjectForKey:@"multimedias"];
        _notes = [aDecoder decodeObjectForKey:@"notes"];
        _repositories = [aDecoder decodeObjectForKey:@"repositories"];
        _sources = [aDecoder decodeObjectForKey:@"sources"];
        _submitters = [aDecoder decodeObjectForKey:@"submitters"];
        
        _customEntities = [aDecoder decodeObjectForKey:@"customEntities"];
        
        _mainQueue = [[NSOperationQueue alloc] init];
        
        _undoManager = [[NSUndoManager alloc] init];
        [_undoManager setGroupsByEvent:NO];
	}
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_xrefToRecordMap forKey:@"xrefStore"];
    [aCoder encodeObject:_recordToXrefMap forKey:@"entityToXref"];
    [aCoder encodeObject:self.header forKey:@"header"];
    [aCoder encodeObject:self.submission forKey:@"submission"];
    
    [aCoder encodeObject:_families forKey:@"families"];
    [aCoder encodeObject:_individuals forKey:@"individuals"];
    [aCoder encodeObject:_multimedias forKey:@"multimedias"];
    [aCoder encodeObject:_notes forKey:@"notes"];
    [aCoder encodeObject:_repositories forKey:@"repositories"];
    [aCoder encodeObject:_sources forKey:@"sources"];
    [aCoder encodeObject:_submitters forKey:@"submitters"];
    
    [aCoder encodeObject:_customEntities forKey:@"customEntities"];
}

#pragma mark Description

//COV_NF_START
- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (name: %@ xrefStore: %@)", [super description], _name, _xrefToRecordMap];
}
//COV_NF_END

#pragma mark Xref handling

- (void)_setXref:(NSString *)xref forRecord:(GCRecord *)record
{
    //NSLog(@"%p: setting xref %@ on %p", self, xref, record);
    
    NSParameterAssert(xref);
    NSParameterAssert(record);
    NSParameterAssert(!_xrefToRecordMap[xref]);
    
    @synchronized (self) {
        [self _removeXrefForRecord:record];
        
        // update map
        _xrefToRecordMap[xref] = record;
        
        // update map
        _recordToXrefMap[record] = xref;
    }
}

- (void)_removeXrefForRecord:(GCRecord *)record
{
    @synchronized (self) {
        // clear previously set xref, if any
        if (_recordToXrefMap[record]) {
            [_xrefToRecordMap removeObjectForKey:_recordToXrefMap[record]];
            [_recordToXrefMap removeObjectForKey:record];
        }
    }
}

- (NSString *)_xrefForRecord:(GCRecord *)record
{
    NSParameterAssert(record);
    NSParameterAssert(record.gedcomCode);
    
    @synchronized (self) {
        NSString *xref = _recordToXrefMap[record];
        
        if (!xref) {
            int i = 0;
            do {
                xref = [NSString stringWithFormat:@"@%@%d@", record.gedcomCode, ++i];
            } while (_xrefToRecordMap[xref]);
            
            [self _setXref:xref forRecord:record];
        }
        
        //NSLog(@"%p: found %@ for %p in %@", self, xref, entity, _entityToXrefMap);
        
        return xref;
    }
}

- (GCRecord *)_recordForXref:(NSString *)xref create:(BOOL)create withClass:(Class)aClass
{
    id record;
    
    @synchronized (self) {
        record = _xrefToRecordMap[xref];
        
        if (record) {
            //NSLog(@"Found existing: %@ > %p", xref, record);
            NSParameterAssert(!aClass || [record isKindOfClass:aClass]);
            return record;
        } else if (create) {
            record = [[aClass alloc] initInContext:self];
            //NSLog(@"Creating new: %@ (%@) > %p", xref, aClass, record);
            [self _setXref:xref forRecord:record];
            return record;
        } else {
            //NSLog(@"NOT creating: %@", xref);
            return nil;
        }
    }
}

- (void)_clearXrefs
{
    @synchronized (self) {
        _xrefToRecordMap = [NSMapTable strongToWeakObjectsMapTable];
        _recordToXrefMap = [NSMapTable weakToStrongObjectsMapTable];
    }
}

- (void)_renumberXrefs
{
    [self _clearXrefs];
    for (id record in self.entities) {
        if ([record isKindOfClass:[GCRecord class]]) {
            (void)[self _xrefForRecord:record];
        }
    }
}

- (void)_sortByXrefs
{
    @synchronized (self) {
        NSComparisonResult (^comp)(id, id) = ^NSComparisonResult(GCRecord *obj1, GCRecord *obj2) {
            NSComparisonResult res = [obj1.xref compare:obj2.xref];
            //NSLog(@"%@ ~ %@ = %ld", obj1.xref, obj2.xref, res);
            return res;
        };
        
        [self.mutableFamilies sortWithOptions:NSSortStable usingComparator:comp];
        [self.mutableIndividuals sortWithOptions:NSSortStable usingComparator:comp];
        [self.mutableMultimedias sortWithOptions:NSSortStable usingComparator:comp];
        [self.mutableNotes sortWithOptions:NSSortStable usingComparator:comp];
        [self.mutableFamilies sortWithOptions:NSSortStable usingComparator:comp];
        [self.mutableRepositories sortWithOptions:NSSortStable usingComparator:comp];
        [self.mutableSources sortWithOptions:NSSortStable usingComparator:comp];
        [self.mutableSubmitters sortWithOptions:NSSortStable usingComparator:comp];
        
        [self _renumberXrefs];
    }
}

#pragma mark Xref link methods

- (void)_activateRecord:(GCRecord *)record
{
    if (_delegate && [_delegate respondsToSelector:@selector(context:didReceiveActionForRecord:)]) {
        [_delegate context:self didReceiveActionForRecord:record];
    }
}

#pragma mark Custom tag methods

- (BOOL)_shouldHandleCustomTag:(GCTag *)tag forNode:(GCNode *)node onObject:(GCObject *)object
{
    if (_delegate && [_delegate respondsToSelector:@selector(context:shouldHandleCustomTag:forNode:onObject:)]) {
        return [_delegate context:self shouldHandleCustomTag:tag forNode:node onObject:object];
    } else {
        return YES;
    }
}

#pragma mark Objective-C properties

- (GCFileEncoding)fileEncoding
{
    NSString *encoding = self.header.characterSet.displayValue;
    
    NSParameterAssert(encoding);
    
    if ([encoding isEqualToString:@"ANSEL"]) {
        return GCANSELFileEncoding;
    } else if ([encoding isEqualToString:@"ASCII"]) {
        return GCASCIIFileEncoding;
    } else if ([encoding isEqualToString:@"UNICODE"]) {
        return GCUTF16FileEncoding;
    } else if ([encoding isEqualToString:@"UTF-8"]) {
        return GCUTF8FileEncoding;
    } else {
        return GCUnknownFileEncoding;
    }
}

- (void)setFileEncoding:(GCFileEncoding)fileEncoding
{
    GCParameterAssert(self.header.characterSet);
    
    NSParameterAssert(fileEncoding != GCUnknownFileEncoding);
    
    NSString *encodingStr;
    
    if (fileEncoding == GCANSELFileEncoding) {
        encodingStr = @"ANSEL";
    } else if (fileEncoding == GCASCIIFileEncoding) {
        encodingStr = @"ASCII";
    } else if (fileEncoding == GCUTF16FileEncoding) {
        encodingStr = @"UNICODE";
    } else {
        NSAssert(false, @"Unhandled file encoding!");
    }
    
    // TODO UTF8?
    
    [self.header addAttributeWithType:@"characterSet" value:encodingStr];
}

@end