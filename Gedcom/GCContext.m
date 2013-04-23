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

#import "GCNodeParser.h"
#import "GCNode.h"
#import "GCTag.h"

#import "GCCharacterSetAttribute.h"
#import "GCHeaderEntity+GCObjectAdditions.h"

#import "GCContextDelegate.h"

#import "GCGedcomLoadingAdditions.h"
#import "GCGedcomAccessAdditions.h"

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
    
    dispatch_group_t _group;
    dispatch_group_t _sensitiveGroup;
    dispatch_queue_t _queue;
    dispatch_queue_t _sensitiveQueue;
    dispatch_semaphore_t _groupSemaphore;
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
        
        _xrefToRecordMap = [NSMapTable strongToWeakObjectsMapTable];
        _recordToXrefMap = [NSMapTable weakToStrongObjectsMapTable];
        
        _families = [NSMutableArray array];
        _individuals = [NSMutableArray array];
        _multimedias = [NSMutableArray array];
        _notes = [NSMutableArray array];
        _repositories = [NSMutableArray array];
        _sources = [NSMutableArray array];
        _submitters = [NSMutableArray array];
        
        _customEntities = [NSMutableArray array];
        
        _group = dispatch_group_create();
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"dk.kildekort.Gedcom.context.%@", _name] UTF8String], DISPATCH_QUEUE_SERIAL);
        
        _sensitiveGroup = dispatch_group_create();
        _sensitiveQueue = dispatch_queue_create([[NSString stringWithFormat:@"dk.kildekort.Gedcom.context.%@.sensitive", _name] UTF8String], DISPATCH_QUEUE_SERIAL);
        
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
    // set up a wait
    _groupSemaphore = dispatch_semaphore_create(0);
    dispatch_group_async(_sensitiveGroup, _sensitiveQueue, ^{
        dispatch_semaphore_wait(_groupSemaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"GO");
    });
}

- (void)parser:(GCNodeParser *)parser didParseNode:(GCNode *)node
{
    GCTag *tag = [GCTag rootTagWithCode:node.gedTag];
    
    NSParameterAssert(tag);
    
    dispatch_group_async(_group, _queue, ^{
        if (tag.objectClass != [GCTrailerEntity class]) {
            GCObject *obj = [tag.objectClass newWithGedcomNode:node inContext:self];
            NSParameterAssert(obj.context == self);
        }
    });
}

- (void)parser:(GCNodeParser *)parser didParseNodesWithCount:(NSUInteger)nodeCount
{
    dispatch_group_async(_group, _queue, ^{
        NSLog(@"didParseNodesWithCount: %ld", nodeCount);
        
        // signal done:
        dispatch_semaphore_signal(_groupSemaphore);
    });
}

- (void)_defer:(void (^)())block
{
    dispatch_group_async(_sensitiveGroup, _sensitiveQueue, block);
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
    clock_t start = clock();
#endif
    
    BOOL result = [nodeParser parseString:gedString error:error];
    
    dispatch_group_wait(_group, DISPATCH_TIME_FOREVER);
    dispatch_group_wait(_sensitiveGroup, DISPATCH_TIME_FOREVER);
    
#ifdef DEBUGLEVEL
    NSLog(@"parsed %ld entities - Time: %f seconds", [self.entities count], ((double) (clock() - start)) / CLOCKS_PER_SEC);
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
// TODO: Add some property to all added root entities (like a note or whatever?) (provide as option)
{
    context = [context copy];
    
    [self beginTransaction];
    
    BOOL succeeded = YES; //TODO
    
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
        
        _group = dispatch_group_create();
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"dk.kildekort.Gedcom.context.%@", _name] UTF8String], DISPATCH_QUEUE_SERIAL);
        
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
    NSParameterAssert(xref);
    NSParameterAssert(record);
    NSParameterAssert(!_xrefToRecordMap[xref]);
    
    //NSLog(@"%p: setting xref %@ on %p", self, xref, entity);
    
    // clear previously set xref, if any:
    @synchronized (_recordToXrefMap) {
        @synchronized (_xrefToRecordMap) {
            if (_recordToXrefMap[record]) {
                [_xrefToRecordMap removeObjectForKey:_recordToXrefMap[record]];
                [_recordToXrefMap removeObjectForKey:record];
            }
        }
    }
    
    // update maps:
    @synchronized (_xrefToRecordMap) {
        _xrefToRecordMap[xref] = record;
    }
    @synchronized (_recordToXrefMap) {
        _recordToXrefMap[record] = xref;
    }
}

- (NSString *)_xrefForRecord:(GCRecord *)record
{
    NSParameterAssert(record);
    NSParameterAssert(record.gedTag.code);
    
    NSString *xref = nil;
    
    @synchronized (_recordToXrefMap) {
        xref = _recordToXrefMap[record];
    }
    
    if (!xref) {
        @synchronized (_xrefToRecordMap) {
            int i = 0;
            do {
                xref = [NSString stringWithFormat:@"@%@%d@", record.gedTag.code, ++i];
            } while (_xrefToRecordMap[xref]);
            
            [self _setXref:xref forRecord:record];
        }
    }
    
    //NSLog(@"%p: found %@ for %p in %@", self, xref, entity, _entityToXrefMap);
    
    return xref;
}

- (GCRecord *)_recordForXref:(NSString *)xref create:(BOOL)create withClass:(Class)aClass
{
    id record;
    
    @synchronized (_xrefToRecordMap) {
        record = _xrefToRecordMap[xref];
    }
    
    if (record) {
        //NSLog(@"Found existing: %@ > %p", xref, record);
        NSParameterAssert([record isKindOfClass:aClass]);
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

- (void)_clearXrefs
{
    @synchronized (_xrefToRecordMap) {
        _xrefToRecordMap = [NSMapTable strongToWeakObjectsMapTable];
    }
    @synchronized (_recordToXrefMap) {
        _recordToXrefMap = [NSMapTable weakToStrongObjectsMapTable];
    }
}

- (void)_renumberXrefs
{
    [self _clearXrefs];
    for (GCRecord *record in self.entities) {
        //TODO only get actual records
        (void)[self _xrefForRecord:record];
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

- (NSArray *)gedcomNodes
{
	NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:[self.entities count]];
	
    if (!self.header) {
        self.header = [GCHeaderEntity defaultHeaderInContext:self];
    }
    
    @synchronized (self) {
        for (GCRecord *record in self.entities) {
            [nodes addObject:record.gedcomNode];
        }
	}
    
    [nodes addObject:[GCNode nodeWithTag:@"TRLR" value:nil]];
    
	return nodes;
}

- (NSString *)gedcomString
{
    NSMutableArray *gedcomStrings = [NSMutableArray array];
    
    for (GCNode *node in self.gedcomNodes) {
        [gedcomStrings addObjectsFromArray:node.gedcomLines];
    }
    
    return [gedcomStrings componentsJoinedByString:@"\n"];
}

- (NSData *)gedcomData
{
    GCFileEncoding useEncoding = self.fileEncoding;
    
    NSParameterAssert(useEncoding != GCUnknownFileEncoding);
    NSParameterAssert(useEncoding != GCANSELFileEncoding);
    
    return [self.gedcomString dataUsingEncoding:useEncoding];
}

@end

#pragma mark -

@implementation GCContext (GCTransactionAdditions)

- (void)beginTransaction
{
    [_undoManager beginUndoGrouping];
}

- (void)rollback
{
    [_undoManager endUndoGrouping];
    [_undoManager undoNestedGroup];
}

- (void)commit
{
    [_undoManager endUndoGrouping];
}

@end