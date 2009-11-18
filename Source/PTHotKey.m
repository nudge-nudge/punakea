//
//  PTHotKey.m
//  Protein
//
//  Created by Quentin Carnicelli on Sat Aug 02 2003.
//  Updated by Joel Levin in August 2009 for Snow Leopard/64-bit
//  Copyright (c) 2003 Quentin D. Carnicelli. All rights reserved.
//

#import "PTHotKey.h"

#import "PTHotKeyCenter.h"
#import "PTKeyCombo.h"


@implementation PTHotKey

@synthesize identifier = mIdentifier;
@synthesize name = mName;
@synthesize target = mTarget;
@synthesize action = mAction;
@synthesize associatedID = mAssociatedID;

@dynamic keyCombo;

- (id)init
{
	return [self initWithIdentifier: nil keyCombo: nil];
}


- (id)initWithIdentifier: (id)identifier keyCombo: (PTKeyCombo*)combo
{
	self = [super init];
	
	if( self )
	{
		self.identifier = identifier;
		self.keyCombo = combo;
	}
	
	return self;
}

- (void)dealloc
{
	self.identifier = nil;
	self.name = nil;
	
	[mKeyCombo release];
	
	[super dealloc];
}

- (NSString*)description
{
	return [NSString stringWithFormat: @"<%@: %@, %@>", NSStringFromClass( [self class] ), self.identifier, self.keyCombo];
}

#pragma mark -

- (void)setKeyCombo: (PTKeyCombo*)combo
{
	if( combo == nil )
		combo = [PTKeyCombo clearKeyCombo];	

	[combo retain];
	[mKeyCombo release];
	mKeyCombo = combo;
}

- (PTKeyCombo*)keyCombo
{
	return mKeyCombo;
}

- (void)invoke
{
	[mTarget performSelector: mAction withObject: self];
}

@end
