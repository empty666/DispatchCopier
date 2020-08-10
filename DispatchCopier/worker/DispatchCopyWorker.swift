//
//  DispatchCopyWorker.swift
//  DispatchCopier
//
//  Created by BK Lee on 2020/08/10.
//  Copyright © 2020 BK Lee. All rights reserved.
//

import Cocoa

class DispatchCopyWorker: NSObject {
    
    var readChannel: DispatchIO?
    var writeChannel: DispatchIO?
    
    static let Shared: DispatchCopyWorker = DispatchCopyWorker.init();
    
    private override init() {}
    
    var isCancel: Bool = false;
    
    /// Start File Copy With DispatchIO
    func startCopy(targetPath: String, destPath: String) {
        
        self.isCancel = false;
        
        let _targetPath = NSString(string: targetPath);
        let _destPath = NSString(string: destPath);
        
        self.readChannel = DispatchIO(type: .stream,
                                      path: _targetPath.utf8String!,
                                      oflag: O_RDONLY,
                                      mode: 0,
                                      queue: .global(qos: .background),
                                      cleanupHandler: { readErr in
                                        // Execute once Close Channel.
                                        if readErr == 0 {
                                            print("Complete Clean Read Channel");
                                        } else {
                                            print("Failed to Read File. Error Code : \(readErr)");
                                        }
        });
        
        self.writeChannel = DispatchIO(type: .stream,
                                       path: _destPath.utf8String!,
                                       oflag: (O_RDWR | O_CREAT | O_APPEND),
                                       mode: (S_IWUSR | S_IRGRP | S_IRUSR | S_IROTH),
                                       queue: .global(qos: .background),
                                       cleanupHandler: { writeErr in
                                        // Execute once Close Channel
                                        if writeErr == 0 {
                                            print("Complete Clean Write Channel");
                                        } else {
                                            print("Failed to Write File. Error Code : \(writeErr)");
                                        }
        });
        
        DispatchQueue.global(qos: .background).async {
         
            self.readChannel?.read(offset: 4096,
                                   length: Int.max,
                                   queue: DispatchQueue.global(qos: .background),
                                   ioHandler: { (readDone, readData, rdChaErr) in
                                    
                                    if readDone {
                                        // Complete File Read
                                        self.readChannel?.close(flags: .stop);
                                    }
                                    
                                    if let _readData = readData {
                                        
                                        if !_readData.isEmpty {
                                            
                                            guard self.isCancel == false else {
                                                print("Job Cancelled");
                                                
                                                do {
                                                    try FileManager.default.removeItem(atPath: destPath);
                                                } catch {
                                                    print("Failed to Remove Dest File : \(error.localizedDescription)");
                                                }
                                                
                                                self.readChannel?.close(flags: .stop);
                                                self.writeChannel?.close(flags: .stop);
                                                
                                                return ;
                                            }
                                             
                                            self.writeChannel?.write(offset: 0,
                                                                     data: _readData,
                                                                     queue: DispatchQueue.global(qos: .background),
                                                                     ioHandler: { (writeDone, writeData, writeErr) in
                                                                        
                                                                        if !writeDone {
                                                                            print("Faeild to Write File. Error Code : \(writeErr)");
                                                                            self.writeChannel?.close();
                                                                        }
                                            });
                                        }
                                    }
                                    
                                    print("read end point");
            });
            
        }
    }
    
    /// Stop Current Copy Job
    func stopCopy() {
        self.isCancel = true;
    }

}
