# SoundDataTrasfer_iOS

This project uses QuietModemKit to transfer data to other devices via sound.


QuietModemKit-library uses liquid SDR to transmit data through sound. This makes it suitable for sending data across a 3.5mm headphone jack or via speaker and mic.

## Dependencies:
 - Carthage
     - QuietModemKit
 - Swift Package Manager
     - BubbleTransition
   
## Security:

Currently using the following encryption technique from CryptoKit.

ChaChaPoly-An implementation of the ChaCha20-Poly1305 cipher

#### Why ChaChaPoly? - https://blog.cloudflare.com/do-the-chacha-better-mobile-performance-with-cryptography/

RNCryptor is available in the project to test. 

At present key for the ChaChaPoly encryption is in the settings. Planning to move it to keychain later.

## Test cases:

Yet to be written.
