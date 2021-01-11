# SoundDataTrasfer_iOS

This project uses QuietModemKit to transfer data to other devices via sound.


QuietModemKit-library uses liquid SDR to transmit data through sound. This makes it suitable for sending data across a 3.5mm headphone jack or via speaker and mic.

## Screenshots:

![1](https://user-images.githubusercontent.com/22410262/104236637-e20b4780-547c-11eb-89c2-74ed54fbdb73.PNG)
![2](https://user-images.githubusercontent.com/22410262/104236658-e9325580-547c-11eb-9eb1-c538b1b8dd47.PNG)
![3](https://user-images.githubusercontent.com/22410262/104236661-e9caec00-547c-11eb-8384-11e5800017c0.PNG)
![4](https://user-images.githubusercontent.com/22410262/104236664-e9caec00-547c-11eb-9407-959bb910c952.PNG)
![5](https://user-images.githubusercontent.com/22410262/104236667-ea638280-547c-11eb-862e-b75f932e795f.PNG)


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
