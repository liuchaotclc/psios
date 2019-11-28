//
//  PSCodable
//  PSIos
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// 

@protocol PSCoder;
@protocol PSDecoder;

@protocol PSCoding <NSObject>

@required

- (void) updateWithPSDecoder:(id<PSDecoder>)decoder deep:(BOOL)deep;
- (void) encodeWithPSCoder:(id<PSCoder>)coder deep:(BOOL)deep;

@end

