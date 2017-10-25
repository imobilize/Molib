import Foundation
import CryptoSwift

extension Data {
    
    
    func AESEncryptWithKey(key: String) -> Data? {

        var encryptedData: Data? = nil

        do {
            let aes = try AES(key: key, iv: "driwssapdrowssap") // aes128
            let ciphertext = try aes.encrypt(Array(self))
            encryptedData = Data(ciphertext)
        } catch {}

        return encryptedData
    }
    
    func AESDecryptWithKey(key: String) -> Data? {

        var decryptedData: Data? = nil

        do {
            let aes = try AES(key: key, iv: "driwssapdrowssap") // aes128
            let ciphertext = try aes.decrypt(Array(self))
            decryptedData = Data(ciphertext)
        } catch { }

        return decryptedData
    }
}
