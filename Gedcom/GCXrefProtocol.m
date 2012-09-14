//
//  GCXrefProtocol.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 16/05/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCXrefProtocol.h"
#import "GCContext_internal.h"

//example URL xref://4E7DDC24-FD65-4A48-B2B2-DC88112BCD3A/@F977@

// via http://funwithobjc.tumblr.com/post/3478903440/how-i-do-my-singletons
__attribute__((constructor)) static void register_protocol() {
    [NSURLProtocol registerClass:[GCXrefProtocol class]];
}

__attribute__((destructor)) static void unregister_protocol() {
    [NSURLProtocol unregisterClass:[GCXrefProtocol class]];
}

@implementation GCXrefProtocol

#pragma mark NSURLProtocol overrides

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return [request.URL.scheme isEqualToString:@"xref"];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    NSURLRequest *request = [self request];
    
    GCContext *context = [GCContext contextsByName][request.URL.host];
    NSString *xref = request.URL.path;
    
    [context activateXref:xref];
}

- (void)stopLoading
{
    return; //not actually loading anything
}

@end
