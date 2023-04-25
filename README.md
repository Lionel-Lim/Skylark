# Skylark

<p align="center">  <img src="https://raw.githubusercontent.com/Lionel-Lim/Skylark/main/src/panorama%200.png" width="230" alt="Skylark description"> <img src="https://raw.githubusercontent.com/Lionel-Lim/Skylark/main/src/panorama%201.png" width="230" alt="Skylark description"> 
<br>
<img src="https://raw.githubusercontent.com/Lionel-Lim/Skylark/main/src/panorama%202.png" width="230" alt="Skylark description"> 
<img src="https://raw.githubusercontent.com/Lionel-Lim/Skylark/main/src/panorama%203.png" width="230" alt="Skylark description">  
<img src="https://raw.githubusercontent.com/Lionel-Lim/Skylark/main/src/panorama%204.png" width="230" alt="Skylark description"> <br>  </p>

Skylark is a mobile application that helps users identify and discover unknown places around them by searching Google Maps. When a user points their mobile phone at a place of interest, the app searches for all places within eyesight and a certain radius, allowing the user to sort the results by distance or popularity. Developed using Flutter, Skylark is compatible with both Android and iOS devices.

## Contents
- [Skylark](#skylark)
  - [Contents](#contents)
  - [Getting Started](#getting-started)
    - [Installation](#installation)
  - [Dependencies](#dependencies)
  - [Usage](#usage)
  - [Demo](#demo)
  - [Contact](#contact)

## Getting Started

To get started with the Skylark application, you will need to have Flutter installed on your system. If you don't have it already, you can follow the instructions provided in the [official Flutter documentation](https://flutter.dev/docs/get-started/install).


### Installation

1. Clone the repository:

```bash
git clone https://github.com/Lionel-Lim/Skylark.git
```

2. Change directory to the project folder:

```bash
cd skylark
```

3. Add a Google Maps API Key:

```bash
cd assets
mkdir Keys
nano APIKey.json
```
- APIKey.json
```
[
	{
		"GoogleMaps":"YOUR-API-KEY"
	}
]
```
- Please also visit [google_maps_flutter](https://pub.dev/packages/google_maps_flutter).

1. Install the [dependencies](#dependencies):

```bash
flutter pub get
```

5. Run the application:

```bash
flutter run
```

## Dependencies

The following dependencies are used in the Skylark application:
```
  google_maps_flutter: ^2.2.3
  geolocator: ^9.0.2
  smooth_compass: ^2.0.2
  http: ^0.13.5
  maps_toolkit: ^2.0.1
  cached_network_image: ^3.2.3
  marquee: ^2.2.3
  flutter_compass: "^0.7.0"
  flutter_native_splash: ^2.2.19
  flutter_launcher_icons: "^0.13.1"
```

## Usage
	
<p align="center">  <img src="https://raw.githubusercontent.com/Lionel-Lim/Skylark/main/src/pic2.png" width="250" alt="1. Point your mobile phone at a place of interest.">  <br>  <em>1. Point your mobile phone at a place of interest and tap "Search" button.</em> <br> <em>Change the search radius by pressing the arrow buttons.</em>  </p>

<p align="center">  <img src="https://raw.githubusercontent.com/Lionel-Lim/Skylark/main/src/search3.png" width="250" alt="2. Browse the search result.">  <br>  <em>2. Browse the search result.</em>  </p>

<p align="center">  <img src="https://raw.githubusercontent.com/Lionel-Lim/Skylark/main/src/search1.png" width="250" alt="3. Sort the result by distance or popularity">  <br>  <em>3. Sort the result by distance or popularity.</em>  </p>

<p align="center">  <img src="https://raw.githubusercontent.com/Lionel-Lim/Skylark/main/src/detail1.png" width="250" alt="4. Tap the top-right corner button to see more details.">  <br>  <em>4. Tap the top-right corner button to see more details.</em>  </p>

## Demo
<p align="center"> 
<img src="https://raw.githubusercontent.com/Lionel-Lim/Skylark/main/src/demo.gif" width="250" alt="Application demo"></p>
https://github.com/Lionel-Lim/Skylark/blob/main/src/demo.gif

## Contact
If you have any questions or suggestions, please feel free to reach out to the project maintainer:

- Name: _Dongyoung Lim_
- Email: _limdongyoung@naver.com_
- GitHub: [@Lionel-Lim](https://github.com/Lionel-Lim)
