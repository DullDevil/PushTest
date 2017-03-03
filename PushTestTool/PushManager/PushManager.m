
#import <Security/SecureTransport.h>
#import "PushManager.h"
#import "GCDAsyncSocket.h"

@interface PushManager ()<GCDAsyncSocketDelegate> {
	GCDAsyncSocket *_socket;
	NSData *_pkcs12Data;
	NSString *_password;
}

@end

@implementation PushManager
#pragma mark - life cycle
- (instancetype)init {
	self = [super init];
	if (self) {
		_socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
		
	}
	return self;
}

#pragma mark - GCDAsyncSocketDelegate
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
	[self configTLS];
}
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
	if ([self.pushDelegate respondsToSelector:@selector(APNSDidDisconnected)]) {
		[self.pushDelegate APNSDidDisconnected];
	}
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
	if ([self.pushDelegate respondsToSelector:@selector(sendSucceed)]) {
		[self.pushDelegate sendSucceed];
	}
}

#pragma mark - events
- (void)connectAPNSWithPkcs12Data:(NSData *)pkcs12Data password:(NSString *)password {
	_pkcs12Data = pkcs12Data;
	_password = password;
	[_socket connectToHost:@"gateway.sandbox.push.apple.com" onPort:2195 error:nil];
}

- (void)disconnectAPNS {
	[_socket disconnect];
}

- (void)sendWithToken:(NSString *)token pushMessage:(NSString *)pushMessage {
	NSString *formateToken = [self formateToken:token];
	NSData *pushData = [self creatPushDataWithToken:formateToken pushMessage:pushMessage];
	[_socket writeData:pushData withTimeout:20 tag:100];
}

-(void)configTLS{
	NSDictionary *sslSetting = [self prepareSSLSettingsWithPkcs12Data:_pkcs12Data passwordString:_password];
	if (!sslSetting) {
		[_socket disconnect];
		return;
	}
	[_socket startTLS:sslSetting];
	if ([self.pushDelegate respondsToSelector:@selector(APNSDidConnected)]) {
		[self.pushDelegate APNSDidConnected];
	}
}

- (NSData *)creatPushDataWithToken:(NSString *)token pushMessage:(NSString *)pushMessage {

	NSMutableData *deviceToken = [NSMutableData data];
	unsigned value;
	NSScanner *scanner = [NSScanner scannerWithString:token];
	while(![scanner isAtEnd]) {
		[scanner scanHexInt:&value];
		value = htonl(value);
		[deviceToken appendBytes:&value length:sizeof(value)];
	}
	
	// Create C input variables.
	char *deviceTokenBinary = (char *)[deviceToken bytes];
	char *payloadBinary = (char *)[pushMessage UTF8String];
	size_t payloadLength = strlen(payloadBinary);
	
	// Define some variables.
	uint8_t command = 0;
	char message[8000]; //限定值
	char *pointer = message;
	uint16_t networkTokenLength = htons(32);
	uint16_t networkPayloadLength = htons(payloadLength);
	
	// Compose message.
	memcpy(pointer, &command, sizeof(uint8_t));
	pointer += sizeof(uint8_t);
	memcpy(pointer, &networkTokenLength, sizeof(uint16_t));
	pointer += sizeof(uint16_t);
	memcpy(pointer, deviceTokenBinary, 32);
	pointer += 32;
	memcpy(pointer, &networkPayloadLength, sizeof(uint16_t));
	pointer += sizeof(uint16_t);
	memcpy(pointer, payloadBinary, payloadLength);
	pointer += payloadLength;
	return [NSData dataWithBytes:message length:(pointer - message)];
}

- (NSString *)formateToken:(NSString *)token {
	if (token.length == 64) {
		NSMutableString *formateToken = [NSMutableString string];
		for (NSInteger index = 0; index < 8; index ++ ) {
			NSRange range  = NSMakeRange(index * 8, 8);
			NSString *subString = [token substringWithRange:range];
			[formateToken appendString:subString];
			if (index < 7) {
				[formateToken appendString:@" "];
			}
		}
		return formateToken;
	}
	return token;
}

#pragma mark - setter && getter
- (NSDictionary *)prepareSSLSettingsWithPkcs12Data:(NSData *)pkcs12Data passwordString:(NSString *)passwordString{
	NSMutableDictionary *sslSettings = [[NSMutableDictionary alloc] init];
	if (!pkcs12Data) {
		return nil;
	}
	CFDataRef inPKCS12Data = (CFDataRef)CFBridgingRetain(pkcs12Data);
	CFStringRef password = (__bridge CFStringRef)(passwordString);
	const void *keys[] = { kSecImportExportPassphrase };
	const void *values[] = { password };
	CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
	
	CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
	
	OSStatus securityError = SecPKCS12Import(inPKCS12Data, options, &items);
	CFRelease(options);
	CFRelease(password);
	
	if(securityError != errSecSuccess) {
		return nil;
	}
	CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
	SecIdentityRef myIdent = (SecIdentityRef)CFDictionaryGetValue(identityDict,
																  kSecImportItemIdentity);
	
	SecIdentityRef  certArray[1] = { myIdent };
	CFArrayRef myCerts = CFArrayCreate(NULL, (void *)certArray, 1, NULL);
	
	[sslSettings setObject:(id)CFBridgingRelease(myCerts) forKey:(NSString *)kCFStreamSSLCertificates];
	[sslSettings setObject:@"gateway.sandbox.push.apple.com" forKey:(NSString *)kCFStreamSSLPeerName];
	return sslSettings;
}

- (BOOL)isConnected {
	return _socket.isConnected;
}
@end
