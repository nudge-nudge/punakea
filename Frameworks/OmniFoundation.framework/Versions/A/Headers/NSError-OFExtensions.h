// Copyright 2005 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.
//
// $Header: svn+ssh://source.omnigroup.com/Source/svn/Omni/tags/SourceRelease_2005-11-18/OmniGroup/Frameworks/OmniFoundation/OpenStepExtensions.subproj/NSError-OFExtensions.h 69424 2005-10-19 21:59:40Z bungi $

#import <Foundation/NSError.h>

extern NSString *OFUserCancelledActionErrorKey;
extern NSString *OFFileNameAndNumberErrorKey;

@interface NSError (OFExtensions)
- (BOOL)causedByUserCancelling;
@end

extern void _OFError(NSError **error, NSString *bundleIdentifier, const char *name, const char *fileName, unsigned int line, NSString *firstKey, ...);

// It is expected that -DOMNI_BUNDLE_IDENTIFIER=@"com.foo.bar" will be set when building your code.  Build configurations make this easy since you can set it in the target's configuration and then have your Other C Flags have -DOMNI_BUNDLE_IDENTIFIER=@\"$(OMNI_BUNDLE_IDENTIFIER)\" and also use $(OMNI_BUNDLE_IDENTIFIER) in your Info.plist instead of duplicating it.
#define _OFError_(error, bundleIdentifier, name, file, line, ...) _OFError(error, bundleIdentifier, #name, file, line, ## __VA_ARGS__)
#define OFError(error, name, reason) _OFError_(error, OMNI_BUNDLE_IDENTIFIER, name, __FILE__, __LINE__, NSLocalizedDescriptionKey, reason, nil)
#define OFErrorWithInfo(error, name, ...) _OFError_(error, OMNI_BUNDLE_IDENTIFIER, name, __FILE__, __LINE__, ## __VA_ARGS__)

extern void OFErrorWithDomainv(NSError **error, NSString *domain, const char *fileName, unsigned int line, NSString *firstKey, va_list args);
