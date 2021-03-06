//
//  Tori+Authenticate.swift
//  
//
//  Created by Ethan Lipnik on 6/9/21.
//

import Foundation

extension Tori {
    func authorizationHeader(for method: String = "GET", url: URL, parameters: [String: Any], isMediaUpload: Bool) -> String {
        var authorizationParameters = [String: Any]()
        authorizationParameters["oauth_version"] = "1.0"
        authorizationParameters["oauth_signature_method"] =  "HMAC-SHA1"
        authorizationParameters["oauth_consumer_key"] = credentials!.consumerKey
        authorizationParameters["oauth_timestamp"] = String(Int(Date().timeIntervalSince1970))
        authorizationParameters["oauth_nonce"] = UUID().uuidString
        if let accessToken = tokenCredentials?.accessToken {
            authorizationParameters["oauth_token"] = accessToken
        }
        
        for (key, value) in parameters where key.hasPrefix("oauth_") {
            authorizationParameters.updateValue(value, forKey: key)
        }
        
        let combinedParameters = authorizationParameters +| parameters
        
        let finalParameters = isMediaUpload ? authorizationParameters : combinedParameters
        
        authorizationParameters["oauth_signature"] = self.oauthSignature(for: method, url: url, parameters: finalParameters)
        
        let authorizationParameterComponents = authorizationParameters.urlEncodedQueryString(using: .utf8).components(separatedBy: "&").sorted()
        
        var headerComponents = [String]()
        for component in authorizationParameterComponents {
            let subcomponent = component.components(separatedBy: "=")
            if subcomponent.count == 2 {
                headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
            }
        }
        
        return "OAuth " + headerComponents.joined(separator: ", ")
    }
    
    func oauthSignature(for method: String = "GET", url: URL, parameters: [String: Any]) -> String {
        let tokenSecret = tokenCredentials?.accessTokenSecret.urlEncodedString() ?? ""
        let encodedConsumerSecret = credentials!.consumerSecret.urlEncodedString()
        let signingKey = "\(encodedConsumerSecret)&\(tokenSecret)"
        let parameterComponents = parameters.urlEncodedQueryString(using: .utf8).components(separatedBy: "&").sorted()
        let parameterString = parameterComponents.joined(separator: "&")
        let encodedParameterString = parameterString.urlEncodedString()
        let encodedURL = url.absoluteString.urlEncodedString()
        let signatureBaseString = "\(method)&\(encodedURL)&\(encodedParameterString)"
        
        let key = signingKey.data(using: .utf8)!
        let msg = signatureBaseString.data(using: .utf8)!
        let sha1 = HMAC.sha1(key: key, message: msg)!
        return sha1.base64EncodedString(options: [])
    }
}

extension Dictionary {

    func filter(_ predicate: (Element) -> Bool) -> Dictionary {
        var filteredDictionary = Dictionary()
        for element in self where predicate(element) {
            filteredDictionary[element.key] = element.value
        }
        return filteredDictionary
    }

    var queryString: String {
        var parts = [String]()

        for (key, value) in self {
            let query: String = "\(key)=\(value)"
            parts.append(query)
        }

        return parts.joined(separator: "&")
    }

    func urlEncodedQueryString(using encoding: String.Encoding) -> String {
        var parts = [String]()

        for (key, value) in self {
            let keyString = "\(key)".urlEncodedString()
            let valueString = "\(value)".urlEncodedString(keyString == "status")
            let query: String = "\(keyString)=\(valueString)"
            parts.append(query)
        }

        return parts.joined(separator: "&")
    }
    
    func stringifiedDictionary() -> Dictionary<String, String> {
        var dict = [String: String]()
        for (key, value) in self {
            dict[String(describing: key)] = String(describing: value)
        }
        return dict
    }
    
}

extension String {

    internal func indexOf(_ sub: String) -> Int? {
        guard let range = self.range(of: sub), !range.isEmpty else {
            return nil
        }
        return self.distance(from: self.startIndex, to: range.lowerBound)
    }

    internal subscript (r: Range<Int>) -> Substring {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return self[startIndex..<endIndex]
        }
    }
    

    func urlEncodedString(_ encodeAll: Bool = false) -> String {
        var allowedCharacterSet: CharacterSet = .urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        if !encodeAll {
            allowedCharacterSet.insert(charactersIn: "[]")
        }
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
    }

    var queryStringParameters: Dictionary<String, String> {
        var parameters = Dictionary<String, String>()

        let scanner = Scanner(string: self)

        var key: String?
        var value: String?

        while !scanner.isAtEnd {
            key = scanner.scanUpToString("=")
            _ = scanner.scanString("=")

            value = scanner.scanUpToString("&")
            _ = scanner.scanString("&")

            if let key = key, let value = value {
                parameters.updateValue(value, forKey: key)
            }
        }
        
        return parameters
    }
}

public struct HMAC {
    
    internal static func sha1(key: Data, message: Data) -> Data? {
        var key = key.rawBytes
        let message = message.rawBytes
        
        // key
        if key.count > 64 {
            key = SHA1(Data(bytes: key)).calculate()
        }
        
        if (key.count < 64) {
            key = key + [UInt8](repeating: 0, count: 64 - key.count)
        }
        
        //
        var opad = [UInt8](repeating: 0x5c, count: 64)
        for (idx, _) in key.enumerated() {
            opad[idx] = key[idx] ^ opad[idx]
        }
        var ipad = [UInt8](repeating: 0x36, count: 64)
        for (idx, _) in key.enumerated() {
            ipad[idx] = key[idx] ^ ipad[idx]
        }
        
        let ipadAndMessageHash = SHA1(Data(bytes: (ipad + message))).calculate()
        let finalHash = SHA1(Data(bytes: opad + ipadAndMessageHash)).calculate()
        let mac = finalHash

        return Data(bytes: mac)

    }

}

extension Data {
    
    var rawBytes: [UInt8] {
        return [UInt8](self)
    }
    
    init(bytes: [UInt8]) {
        self.init(bytes)
    }
    
}

struct SHA1 {
    
    private var message: [UInt8]
    
    fileprivate let h: [UInt32] = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0]
    
    init(_ message: Data) {
        self.message = message.rawBytes
    }
    init(_ message: [UInt8]) {
        self.message = message
    }
    
    /// Common part for hash calculation. Prepare header data.
    func prepare(_ message: [UInt8], _ blockSize: Int, _ allowance: Int) -> [UInt8] {
        var tmpMessage = message
        
        // Step 1. Append Padding Bits
        tmpMessage.append(0x80) // append one bit (Byte with one bit) to message
        // append "0" bit until message length in bits ??? 448 (mod 512)
        var msgLength = tmpMessage.count
        var counter = 0
        
        while msgLength % blockSize != (blockSize - allowance) {
            counter += 1
            msgLength += 1
        }
        
        tmpMessage += [UInt8](repeating: 0, count: counter)
        
        return tmpMessage
    }
    
    func calculate() -> [UInt8] {
        var tmpMessage = self.prepare(self.message, 64, 64 / 8)
        
        // hash values
        var hh = h
        
        // append message length, in a 64-bit big-endian integer. So now the message length is a multiple of 512 bits.
        tmpMessage += (self.message.count * 8).bytes(64 / 8)
        
        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 512 / 8 // 64
        for chunk in BytesSequence(data: tmpMessage, chunkSize: chunkSizeBytes) {
            // break chunk into sixteen 32-bit words M[j], 0 ??? j ??? 15, big-endian
            // Extend the sixteen 32-bit words into eighty 32-bit words:
            var M: [UInt32] = [UInt32](repeating: 0, count: 80)
            for x in 0..<M.count {
                switch x {
                case 0...15:
                    
                    let memorySize = MemoryLayout<UInt32>.size
                    let start = chunk.startIndex + (x * memorySize)
                    let end = start + memorySize
                    let le = chunk[start..<end].toUInt32
                    M[x] = le.bigEndian
                default:
                    M[x] = rotateLeft(M[x-3] ^ M[x-8] ^ M[x-14] ^ M[x-16], n: 1)
                }
            }
            
            var A = hh[0], B = hh[1], C = hh[2], D = hh[3], E = hh[4]
            
            // Main loop
            for j in 0...79 {
                var f: UInt32 = 0
                var k: UInt32 = 0
                
                switch j {
                case 0...19:
                    f = (B & C) | ((~B) & D)
                    k = 0x5A827999
                case 20...39:
                    f = B ^ C ^ D
                    k = 0x6ED9EBA1
                case 40...59:
                    f = (B & C) | (B & D) | (C & D)
                    k = 0x8F1BBCDC
                case 60...79:
                    f = B ^ C ^ D
                    k = 0xCA62C1D6
                default:
                    break
                }
                
                let temp = (rotateLeft(A, n: 5) &+ f &+ E &+ M[j] &+ k) & 0xffffffff
                E = D
                D = C
                C = rotateLeft(B, n: 30)
                B = A
                A = temp
                
            }
            
            hh[0] = (hh[0] &+ A) & 0xffffffff
            hh[1] = (hh[1] &+ B) & 0xffffffff
            hh[2] = (hh[2] &+ C) & 0xffffffff
            hh[3] = (hh[3] &+ D) & 0xffffffff
            hh[4] = (hh[4] &+ E) & 0xffffffff
        }
        
        // Produce the final hash value (big-endian) as a 160 bit number:
        var result = [UInt8]()
        result.reserveCapacity(hh.count / 4)
        hh.forEach {
            let item = $0.bigEndian
            result += [UInt8(item & 0xff), UInt8((item >> 8) & 0xff), UInt8((item >> 16) & 0xff), UInt8((item >> 24) & 0xff)]
        }
        
        return result
    }
    
    private func rotateLeft(_ v: UInt32, n: UInt32) -> UInt32 {
        return ((v << n) & 0xFFFFFFFF) | (v >> (32 - n))
    }
    
}

private struct BytesSequence<D: RandomAccessCollection>: Sequence where D.Iterator.Element == UInt8, D.Index == Int {
    let data: D
    let chunkSize: Int
    
    func makeIterator() -> AnyIterator<D.SubSequence> {
        var offset = data.startIndex
        return AnyIterator {
            let end = Swift.min(self.chunkSize, self.data.count - offset)
            let result = self.data[offset..<offset + end]
            offset = offset.advanced(by: result.count)
            if !result.isEmpty {
                return result
            }
            return nil
        }
    }
    
}

extension Collection where Self.Iterator.Element == UInt8, Self.Index == Int {
    
    var toUInt32: UInt32 {
        assert(self.count > 3)
        // XXX optimize do the job only for the first one...
        return toUInt32Array()[0]
    }
    
    func toUInt32Array() -> [UInt32] {
        var result = [UInt32]()
        result.reserveCapacity(16)
        for idx in stride(from: self.startIndex, to: self.endIndex, by: MemoryLayout<UInt32>.size) {
            var val: UInt32 = 0
            val |= self.count > 3 ? UInt32(self[idx.advanced(by: 3)]) << 24 : 0
            val |= self.count > 2 ? UInt32(self[idx.advanced(by: 2)]) << 16 : 0
            val |= self.count > 1 ? UInt32(self[idx.advanced(by: 1)]) << 8  : 0
            //swiftlint:disable:next empty_count
            val |= self.count > 0 ? UInt32(self[idx]) : 0
            result.append(val)
        }
        
        return result
    }
}

extension Int {
    
    public func bytes(_ totalBytes: Int = MemoryLayout<Int>.size) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }
    
}

func arrayOfBytes<T>(_ value:T, length: Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (MemoryLayout<T>.size * 8)
    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value
    
    let bytesPointer = valuePointer.withMemoryRebound(to: UInt8.self, capacity: 1) { $0 }
    var bytes = [UInt8](repeating: 0, count: totalBytes)
    for j in 0..<min(MemoryLayout<T>.size,totalBytes) {
        bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
    }
    
    valuePointer.deinitialize(count: 1)
    valuePointer.deallocate()
    
    return bytes
}
