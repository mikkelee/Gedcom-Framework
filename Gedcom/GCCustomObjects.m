//
//  GCCustomObjects.m
//  Gedcom
//
//  Created by Mikkel Eide Eriksen on 18/09/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "GCCustomObjects.h"

#import "GCTag.h"

@implementation GCCustomEntity

+ (GCTag *)gedTag
{
	return [GCTag tagWithClassName:@"tagWithClassName"];
}

@end

@implementation GCCustomAttribute

+ (GCTag *)gedTag
{
	return [GCTag tagWithClassName:@"GCCustomAttribute"];
}

@end

@implementation GCCustomRelationship

+ (GCTag *)gedTag
{
	return [GCTag tagWithClassName:@"GCCustomRelationship"];
}

@end
