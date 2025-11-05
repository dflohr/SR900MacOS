/***********************************************************************
  IPWorks BLE 2024 for macOS and iOS
  Copyright (c) 2025 /n software inc.
************************************************************************/

#import <Foundation/Foundation.h>


//VALUEFORMATS
#define VF_UNDEFINED                                       0

#define VF_BOOLEAN                                         1

#define VF_2BIT                                            2

#define VF_NIBBLE                                          3

#define VF_UINT_8                                          4

#define VF_UINT_12                                         5

#define VF_UINT_16                                         6

#define VF_UINT_24                                         7

#define VF_UINT_32                                         8

#define VF_UINT_48                                         9

#define VF_UINT_64                                         10

#define VF_UINT_128                                        11

#define VF_SINT_8                                          12

#define VF_SINT_12                                         13

#define VF_SINT_16                                         14

#define VF_SINT_24                                         15

#define VF_SINT_32                                         16

#define VF_SINT_48                                         17

#define VF_SINT_64                                         18

#define VF_SINT_128                                        19

#define VF_FLOAT_32                                        20

#define VF_FLOAT_64                                        21

#define VF_SFLOAT                                          22

#define VF_FLOAT                                           23

#define VF_DUINT_16                                        24

#define VF_UTF_8STR                                        25

#define VF_UTF_16STR                                       26

#define VF_STRUCT                                          27

#ifndef NS_SWIFT_NAME
#define NS_SWIFT_NAME(x)
#endif

@protocol IPWorksBLEBLEClientDelegate <NSObject>
@optional
- (void)onAdvertisement:(NSString*)serverId :(NSString*)name :(int)RSSI :(int)txPower :(NSString*)serviceUuids :(NSString*)servicesWithData :(NSString*)solicitedServiceUuids :(int)manufacturerCompanyId :(NSData*)manufacturerData :(BOOL)isConnectable :(BOOL)isScanResponse NS_SWIFT_NAME(onAdvertisement(_:_:_:_:_:_:_:_:_:_:_:));

- (void)onConnected:(int)statusCode :(NSString*)description NS_SWIFT_NAME(onConnected(_:_:));

- (void)onDisconnected:(int)statusCode :(NSString*)description NS_SWIFT_NAME(onDisconnected(_:_:));

- (void)onDiscovered:(int)gattType :(NSString*)serviceId :(NSString*)characteristicId :(NSString*)descriptorId :(NSString*)uuid :(NSString*)description NS_SWIFT_NAME(onDiscovered(_:_:_:_:_:_:));

- (void)onError:(int)errorCode :(NSString*)description NS_SWIFT_NAME(onError(_:_:));

- (void)onLog:(int)logLevel :(NSString*)message :(NSString*)logType NS_SWIFT_NAME(onLog(_:_:_:));

- (void)onPairingRequest:(NSString*)serverId :(int)pairingKind :(NSString**)pin :(int*)accept NS_SWIFT_NAME(onPairingRequest(_:_:_:_:));

- (void)onServerUpdate:(NSString*)name :(NSString*)changedServices NS_SWIFT_NAME(onServerUpdate(_:_:));

- (void)onStartScan:(NSString*)serviceUuids NS_SWIFT_NAME(onStartScan(_:));

- (void)onStopScan:(int)errorCode :(NSString*)errorDescription NS_SWIFT_NAME(onStopScan(_:_:));

- (void)onSubscribed:(NSString*)serviceId :(NSString*)characteristicId :(NSString*)uuid :(NSString*)description NS_SWIFT_NAME(onSubscribed(_:_:_:_:));

- (void)onUnsubscribed:(NSString*)serviceId :(NSString*)characteristicId :(NSString*)uuid :(NSString*)description NS_SWIFT_NAME(onUnsubscribed(_:_:_:_:));

- (void)onValue:(NSString*)serviceId :(NSString*)characteristicId :(NSString*)descriptorId :(NSString*)uuid :(NSString*)description :(NSData*)value NS_SWIFT_NAME(onValue(_:_:_:_:_:_:));

- (void)onWriteResponse:(NSString*)serviceId :(NSString*)characteristicId :(NSString*)descriptorId :(NSString*)uuid :(NSString*)description NS_SWIFT_NAME(onWriteResponse(_:_:_:_:_:));

@end

@interface IPWorksBLEBLEClient : NSObject {
  @public void* m_pObj;
  @public CFMutableArrayRef m_rNotifiers;
  __unsafe_unretained id <IPWorksBLEBLEClientDelegate> m_delegate;
  BOOL m_raiseNSException;
  BOOL m_delegateHasAdvertisement;

  BOOL m_delegateHasConnected;

  BOOL m_delegateHasDisconnected;

  BOOL m_delegateHasDiscovered;

  BOOL m_delegateHasError;

  BOOL m_delegateHasLog;

  BOOL m_delegateHasPairingRequest;

  BOOL m_delegateHasServerUpdate;

  BOOL m_delegateHasStartScan;

  BOOL m_delegateHasStopScan;

  BOOL m_delegateHasSubscribed;

  BOOL m_delegateHasUnsubscribed;

  BOOL m_delegateHasValue;

  BOOL m_delegateHasWriteResponse;

}

+ (IPWorksBLEBLEClient*)bleclient;

- (id)init;
- (void)dealloc;

- (NSString*)lastError;
- (int)lastErrorCode;
- (int)eventErrorCode;

@property (nonatomic,readwrite,assign,getter=delegate,setter=setDelegate:) id <IPWorksBLEBLEClientDelegate> delegate;
- (id <IPWorksBLEBLEClientDelegate>)delegate;
- (void) setDelegate:(id <IPWorksBLEBLEClientDelegate>)anObject;

  /* Events */

- (void)onAdvertisement:(NSString*)serverId :(NSString*)name :(int)RSSI :(int)txPower :(NSString*)serviceUuids :(NSString*)servicesWithData :(NSString*)solicitedServiceUuids :(int)manufacturerCompanyId :(NSData*)manufacturerData :(BOOL)isConnectable :(BOOL)isScanResponse NS_SWIFT_NAME(onAdvertisement(_:_:_:_:_:_:_:_:_:_:_:));

- (void)onConnected:(int)statusCode :(NSString*)description NS_SWIFT_NAME(onConnected(_:_:));

- (void)onDisconnected:(int)statusCode :(NSString*)description NS_SWIFT_NAME(onDisconnected(_:_:));

- (void)onDiscovered:(int)gattType :(NSString*)serviceId :(NSString*)characteristicId :(NSString*)descriptorId :(NSString*)uuid :(NSString*)description NS_SWIFT_NAME(onDiscovered(_:_:_:_:_:_:));

- (void)onError:(int)errorCode :(NSString*)description NS_SWIFT_NAME(onError(_:_:));

- (void)onLog:(int)logLevel :(NSString*)message :(NSString*)logType NS_SWIFT_NAME(onLog(_:_:_:));

- (void)onPairingRequest:(NSString*)serverId :(int)pairingKind :(NSString**)pin :(int*)accept NS_SWIFT_NAME(onPairingRequest(_:_:_:_:));

- (void)onServerUpdate:(NSString*)name :(NSString*)changedServices NS_SWIFT_NAME(onServerUpdate(_:_:));

- (void)onStartScan:(NSString*)serviceUuids NS_SWIFT_NAME(onStartScan(_:));

- (void)onStopScan:(int)errorCode :(NSString*)errorDescription NS_SWIFT_NAME(onStopScan(_:_:));

- (void)onSubscribed:(NSString*)serviceId :(NSString*)characteristicId :(NSString*)uuid :(NSString*)description NS_SWIFT_NAME(onSubscribed(_:_:_:_:));

- (void)onUnsubscribed:(NSString*)serviceId :(NSString*)characteristicId :(NSString*)uuid :(NSString*)description NS_SWIFT_NAME(onUnsubscribed(_:_:_:_:));

- (void)onValue:(NSString*)serviceId :(NSString*)characteristicId :(NSString*)descriptorId :(NSString*)uuid :(NSString*)description :(NSData*)value NS_SWIFT_NAME(onValue(_:_:_:_:_:_:));

- (void)onWriteResponse:(NSString*)serviceId :(NSString*)characteristicId :(NSString*)descriptorId :(NSString*)uuid :(NSString*)description NS_SWIFT_NAME(onWriteResponse(_:_:_:_:_:));

  /* Properties */

@property (nonatomic,readwrite,assign,getter=RuntimeLicense,setter=setRuntimeLicense:) NSString* RuntimeLicense NS_SWIFT_NAME(RuntimeLicense);
- (NSString*)RuntimeLicense;
- (void)setRuntimeLicense:(NSString*)newRuntimeLicense;

@property (nonatomic,readonly,assign,getter=VERSION) NSString* VERSION NS_SWIFT_NAME(VERSION);
- (NSString*)VERSION;

@property (nonatomic,readwrite,assign,getter=raiseNSException,setter=setRaiseNSException:) BOOL raiseNSException NS_SWIFT_NAME(raiseNSException);
- (BOOL)raiseNSException NS_SWIFT_NAME(raiseNSException());
- (void)setRaiseNSException:(BOOL)newRaiseNSException NS_SWIFT_NAME(setRaiseNSException(_:));

@property (nonatomic,readwrite,assign,getter=activeScanning,setter=setActiveScanning:) BOOL activeScanning NS_SWIFT_NAME(activeScanning);

- (BOOL)activeScanning NS_SWIFT_NAME(activeScanning());
- (void)setActiveScanning :(BOOL)newActiveScanning NS_SWIFT_NAME(setActiveScanning(_:));

@property (nonatomic,readwrite,assign,getter=characteristic,setter=setCharacteristic:) NSString* characteristic NS_SWIFT_NAME(characteristic);

- (NSString*)characteristic NS_SWIFT_NAME(characteristic());
- (void)setCharacteristic :(NSString*)newCharacteristic NS_SWIFT_NAME(setCharacteristic(_:));

@property (nonatomic,readwrite,assign,getter=characteristicCount,setter=setCharacteristicCount:) int characteristicCount NS_SWIFT_NAME(characteristicCount);

- (int)characteristicCount NS_SWIFT_NAME(characteristicCount());
- (void)setCharacteristicCount :(int)newCharacteristicCount NS_SWIFT_NAME(setCharacteristicCount(_:));

- (BOOL)characteristicCanSubscribe:(int)characteristicIndex NS_SWIFT_NAME(characteristicCanSubscribe(_:));

- (NSString*)characteristicDescription:(int)characteristicIndex NS_SWIFT_NAME(characteristicDescription(_:));

- (int)characteristicFlags:(int)characteristicIndex NS_SWIFT_NAME(characteristicFlags(_:));

- (NSString*)characteristicId:(int)characteristicIndex NS_SWIFT_NAME(characteristicId(_:));

- (NSString*)characteristicUserDescription:(int)characteristicIndex NS_SWIFT_NAME(characteristicUserDescription(_:));
- (void)setCharacteristicUserDescription:(int)characteristicIndex :(NSString*)newCharacteristicUserDescription NS_SWIFT_NAME(setCharacteristicUserDescription(_:_:));

- (NSString*)characteristicUuid:(int)characteristicIndex NS_SWIFT_NAME(characteristicUuid(_:));

- (int)characteristicValueExponent:(int)characteristicIndex NS_SWIFT_NAME(characteristicValueExponent(_:));

- (int)characteristicValueFormat:(int)characteristicIndex NS_SWIFT_NAME(characteristicValueFormat(_:));

- (int)characteristicValueFormatCount:(int)characteristicIndex NS_SWIFT_NAME(characteristicValueFormatCount(_:));

- (int)characteristicValueFormatIndex:(int)characteristicIndex NS_SWIFT_NAME(characteristicValueFormatIndex(_:));
- (void)setCharacteristicValueFormatIndex:(int)characteristicIndex :(int)newCharacteristicValueFormatIndex NS_SWIFT_NAME(setCharacteristicValueFormatIndex(_:_:));

- (NSString*)characteristicValueUnit:(int)characteristicIndex NS_SWIFT_NAME(characteristicValueUnit(_:));

@property (nonatomic,readonly,assign,getter=descriptorCount) int descriptorCount NS_SWIFT_NAME(descriptorCount);

- (int)descriptorCount NS_SWIFT_NAME(descriptorCount());

- (NSString*)descriptorDescription:(int)descriptorIndex NS_SWIFT_NAME(descriptorDescription(_:));

- (NSString*)descriptorId:(int)descriptorIndex NS_SWIFT_NAME(descriptorId(_:));

- (NSString*)descriptorUuid:(int)descriptorIndex NS_SWIFT_NAME(descriptorUuid(_:));

@property (nonatomic,readonly,assign,getter=scanning) BOOL scanning NS_SWIFT_NAME(scanning);

- (BOOL)scanning NS_SWIFT_NAME(scanning());

@property (nonatomic,readonly,assign,getter=serverId) NSString* serverId NS_SWIFT_NAME(serverId);

- (NSString*)serverId NS_SWIFT_NAME(serverId());

@property (nonatomic,readonly,assign,getter=serverName) NSString* serverName NS_SWIFT_NAME(serverName);

- (NSString*)serverName NS_SWIFT_NAME(serverName());

@property (nonatomic,readwrite,assign,getter=service,setter=setService:) NSString* service NS_SWIFT_NAME(service);

- (NSString*)service NS_SWIFT_NAME(service());
- (void)setService :(NSString*)newService NS_SWIFT_NAME(setService(_:));

@property (nonatomic,readonly,assign,getter=serviceCount) int serviceCount NS_SWIFT_NAME(serviceCount);

- (int)serviceCount NS_SWIFT_NAME(serviceCount());

- (NSString*)serviceDescription:(int)serviceIndex NS_SWIFT_NAME(serviceDescription(_:));

- (NSString*)serviceId:(int)serviceIndex NS_SWIFT_NAME(serviceId(_:));

- (NSString*)serviceIncludedSvcIds:(int)serviceIndex NS_SWIFT_NAME(serviceIncludedSvcIds(_:));

- (NSString*)serviceParentSvcIds:(int)serviceIndex NS_SWIFT_NAME(serviceParentSvcIds(_:));

- (NSString*)serviceUuid:(int)serviceIndex NS_SWIFT_NAME(serviceUuid(_:));

@property (nonatomic,readwrite,assign,getter=timeout,setter=setTimeout:) int timeout NS_SWIFT_NAME(timeout);

- (int)timeout NS_SWIFT_NAME(timeout());
- (void)setTimeout :(int)newTimeout NS_SWIFT_NAME(setTimeout(_:));

  /* Methods */

- (BOOL)checkCharacteristicSubscribed:(int)index NS_SWIFT_NAME(checkCharacteristicSubscribed(_:));

- (NSString*)config:(NSString*)configurationString NS_SWIFT_NAME(config(_:));

- (void)connect:(NSString*)serverId NS_SWIFT_NAME(connect(_:));

- (void)disconnect NS_SWIFT_NAME(disconnect());

- (void)discover:(NSString*)serviceUuids :(NSString*)characteristicUuids :(BOOL)discoverDescriptors :(NSString*)includedByServiceId NS_SWIFT_NAME(discover(_:_:_:_:));

- (void)discoverCharacteristics:(NSString*)serviceId :(NSString*)characteristicUuids NS_SWIFT_NAME(discoverCharacteristics(_:_:));

- (void)discoverDescriptors:(NSString*)serviceId :(NSString*)characteristicId NS_SWIFT_NAME(discoverDescriptors(_:_:));

- (void)discoverServices:(NSString*)serviceUuids :(NSString*)includedByServiceId NS_SWIFT_NAME(discoverServices(_:_:));

- (void)doEvents NS_SWIFT_NAME(doEvents());

- (void)postValue:(NSString*)serviceId :(NSString*)characteristicId :(NSData*)value NS_SWIFT_NAME(postValue(_:_:_:));

- (NSData*)queryCharacteristicCachedVal:(int)index NS_SWIFT_NAME(queryCharacteristicCachedVal(_:));

- (NSData*)queryDescriptorCachedVal:(int)index NS_SWIFT_NAME(queryDescriptorCachedVal(_:));

- (NSData*)readValue:(NSString*)serviceId :(NSString*)characteristicId :(NSString*)descriptorId NS_SWIFT_NAME(readValue(_:_:_:));

- (void)select:(NSString*)serviceId :(NSString*)characteristicId NS_SWIFT_NAME(select(_:_:));

- (void)startScanning:(NSString*)serviceUuids NS_SWIFT_NAME(startScanning(_:));

- (void)stopScanning NS_SWIFT_NAME(stopScanning());

- (void)subscribe:(NSString*)serviceId :(NSString*)characteristicId NS_SWIFT_NAME(subscribe(_:_:));

- (void)unsubscribe:(NSString*)serviceId :(NSString*)characteristicId NS_SWIFT_NAME(unsubscribe(_:_:));

- (void)writeValue:(NSString*)serviceId :(NSString*)characteristicId :(NSString*)descriptorId :(NSData*)value NS_SWIFT_NAME(writeValue(_:_:_:_:));

@end

