<h1 align="center">
  <br>
  <a href="http://www.amitmerchant.com/electron-markdownify"><img src="https://raw.githubusercontent.com/Binb1/Polyword/master/Ressources/Polyword.png" alt="Polyword" width="200"></a>
  <br><br>
  Polyword
  <br>
</h1>

## Description

Polyword helps you translating and learning words in new languages by just taking pictures of various things, such as objects or places!

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
- <img src="https://raw.githubusercontent.com/Binb1/Polyword/master/Ressources/admob-icon.png" width="50">  [Ads](https://www.google.com/admob/): To display ads, I used AdMob by google
- <img src="https://raw.githubusercontent.com/Binb1/Polyword/master/Ressources/firebase-icon.png" width="50"> [Analytics](https://firebase.google.com): It is not display on this repository, but the Polyword app that you can download on the app store features some analytics tools. I used google [firebase](https://firebase.google.com) to easily implement analytics in my app.

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
You can create a new Constants.swift file and put those different keys in it:
* ocpKey: Your Microsoft Azure Text Translator API Key
* CONSUMABLE_PURCHASE_PRODUCT_ID: The name of your in-app purchase product
* PRODUCT_ID: Your in-app purchase identifier
* adMobAppID: Your adMobAppID account identifier
* firstAdID: Your ad identifier from your adMobAppId

```swift
//Microsoft Azure part
let ocpKey = YOUR_MICROSOFT_AZURE_TEXT_TRANSLATOR_KEY

//Disable ad purchase part
let CONSUMABLE_PURCHASE_PRODUCT_ID = THE_NAME_OF_YOUR_IN_APP_PURCHASE_PRODUCT
let PRODUCT_ID = YOUR_IN_APP_PURCHASE_IDENTIFIER

//Ad setup part
let adMobAppID = YOUR_ADMOBAPPID_ACCOUNT_IDENTIFIER
let firstAdID = YOUR_AD_IDENTIFIER_FROM_YOUR_ADMOBAAPPID
```

### ML Model

For this project I used the Mlmodel called Resnet50.
<br>You just need to [download](https://developer.apple.com/machine-learning/) it and drag & drop it in the folder called MLModel.

### Good to go!

Now that everything is setup, you can build and launch the project!
Have fun!

## Download

You can download the official Polyword in the app store directly: Coming Soon

## Credits 👍

- [Flaticon](https://www.flaticon.com): The website that provided the earth, flash and gears icons
