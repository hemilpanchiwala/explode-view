

# <div align="center">Explode View</div>

<p align="center"> <img src="https://github.com/mdg-soc-19/explode-view/blob/master/gif/explode-view.gif?raw=true" height = "500px"/></p>

<div align="center">
<a href="https://flutter.io">
    <img src="https://img.shields.io/badge/Platform-Flutter-yellow.svg"
      alt="Platform" />
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-red.svg"
      alt="License: MIT" />
  </a>
  </div>

<p align="center">A beautiful explosion animation for Flutter</p>

A new open-source Flutter project that enables the developers to quickly enhance the ui of their application and can easily get started with the Flutter animation. The UI has been inspired from Redmi's uninstall application animation shown [here](https://github.com/mdg-soc-19/explode-view/blob/master/gif/explode-view-idea.gif).

This project contains the features of Flutter Animation that are required to complete an amazing Flutter application.

# Index

* [How To Use](#how-to-use)
* [Algorithm](#algorithm)
* [Documentation](#documentation)
* [Bugs/Requests](#bugsrequests)
* [License](#license)


# How To Use
## Let's get this animation
For the explosion animation in the app, user has to simply add the `ExplodeView` as a child in any Widget like Stack and many more.

Example Code: 
```dart
ExplodeView(
      imagePath: 'assets/images/abc.png',	// path where the image is stored
      imagePosFromLeft: 120.0,	// set x-coordinate for image
      imagePosFromRight: 300.0,  // set y-coordinate for image
      );
```
For more info, please refer to the `main.dart` in example.


# Algorithm 
The algorithm used to build this project is as follows:

On clicking the image, the image would shake for some time and will disappear with generation of random particles in that image area and they would scatter farther with fading and upcoming transition and disappear finally on the screen. The colors of the particles are decided by the colors of the pixels of the image which provides the effect of breaking the image into pieces.

For more info, please refer to the `explode_view.dart`.


# Documentation

| Dart attribute                        | Datatype                    | Description                                                  |     Default Value     |
| :------------------------------------ | :-------------------------- | :----------------------------------------------------------- | :-------------------: |
| imagePath                                 | String                  | The string which gives the path to the image.                    |       @required       |
| imagePosFromLeft                             | double             | The distance from the left edge of the screen. |       @required       |
| imagePosFromTop                                | double                      | The distance from the top edge of the screen. |         @required         |

# Bugs/Requests

If you encounter any problems feel free to open an issue. If you feel the library is
missing a feature, please raise a ticket on Github and I'll look into it.
Pull request are also welcome.

# License
ExplodeView is licensed under MIT License. View [license](https://github.com/mdg-soc-19/explode-view/blob/master/explode_view/LICENSE).
