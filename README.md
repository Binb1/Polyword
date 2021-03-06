<h1 align="center">
  <br>
  <a href="http://www.amitmerchant.com/electron-markdownify"><img src="https://raw.githubusercontent.com/Binb1/Polyword/master/Ressources/Polyword.png" alt="Polyword" width="200"></a>
  <br><br>
  Polyword
  <br><br>
  <p align="center">
  <a href="https://itunes.apple.com/fr/app/polyword/id1299707282?l=en&mt=8">
    <img alt="Download on the App Store" title="App Store" src="http://i.imgur.com/0n2zqHD.png" width="140">
  </a>
  </p>
</h1>

## Description

Polyword helps you translate and learning words in new languages by just taking pictures of various things, such as objects or places!

It is an essential app when going abroad!

Polyword also provides a fun and innovative way to improve your vocabulary in different languages!
Learning new useful words this way will help you remember them later.

More than 30 languages are available.

## Demo

![screenshot](https://raw.githubusercontent.com/Binb1/Polyword/master/Ressources/demo00.gif)

## Technology used

Polyword is based on several technologies:

- <img src="https://raw.githubusercontent.com/Binb1/Polyword/master/Ressources/core-ml-icon.png" width="50"> [Object detection](https://developer.apple.com/documentation/coreml): To detect objects, I used Apple CoreML technology
- <img src="https://raw.githubusercontent.com/Binb1/Polyword/master/Ressources/microsoft-azure-icon.png" width="50"> [Word translation](https://azure.microsoft.com/en-us/): To translate words between several languages, I used the Microsoft Azure Text Translator API

## How to build the project ⚙️

```bash
# Clone this repository
$ git clone https://github.com/Binb1/Polyword.git

# Go into the repository
$ cd Polyword

# Install the pods
$ pod install
```

Now you can open the app in Xcode<br>

![screenshot](https://raw.githubusercontent.com/Binb1/Polyword/master/Ressources/ReadmeTuto01.png)

You will notice that the Constants.swift file is missing.

### Constants.swift

The Constants.swift file contains all the keys that our application is going to need.
You can create a new Constants.swift file and put this key in it:
* ocpKey: Your Microsoft Azure Text Translator API Key

```swift
//Microsoft Azure part
let ocpKey = YOUR_MICROSOFT_AZURE_TEXT_TRANSLATOR_KEY
```

### ML Model

For this project I used the Mlmodel called Resnet50.
<br>You just need to [download](https://developer.apple.com/machine-learning/) it and drag & drop it in the folder called MLModel.

### Good to go!

Now that everything is setup, you can build and launch the project!
Have fun!

## App Status

The official Polyword app is currently available!

## Awesome ressources

To build this app I used several tutorials and tips:

* Three great articles
  * https://hackernoon.com/swift-how-to-add-in-app-purchases-in-your-ios-app-c1dc2fc82319
  * https://medium.com/@rizwanm/https-medium-com-rizwanm-swift-camera-part-1-c38b8b773b2
  * https://medium.com/@craiggrummitt/size-classes-in-interface-builder-in-xcode-8-74f20a541195
* Two awesome websites full of great tutorials:
  * https://www.raywenderlich.com
  * http://nshipster.com

## Credits 👍

- [Flaticon](https://www.flaticon.com): The website that provided the earth, flash and gears icons
