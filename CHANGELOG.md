## [3.11.0]
- Bump `share_plus` to ^12.0.1: on iOS 26 the share sheet didn't open on iPhones
- Pass `sharePositionOrigin` on every share, so sharing works on iPads too

## [3.10.0]
- Bump dependencies

## [3.9.1]
- Added `quickShareAction` property. This action will be called on long press on share button. It has AliceHttpCall as argument and should be used to handle share action. By default it will share cURL command.

## [3.9.0]
- Bump dependencies

## [3.8.0]
- Bump dependencies

## [3.7.0]
- Breaking change: - removed `darkTheme` property from the constructor. `Theme.of(context).brightness` is used instead

## [3.6.0]
- Returned `http` package support
- Added `customColors` property for colors customization
- Bumped dependencies

## [3.5.1]
- Removed `http` package due to conflicts with old packages

## [3.5.0]
- Bump dependencies

## [3.4.1]
- Upgraded dependencies

## [3.4.0]
- Upgraded dependencies

## [3.3.0]
- Incremented the Flutter SDK version to 3.7.0

## 3.2.0

* Upgraded dependencies

## 3.1.0

* Flutter 3.0 support

## 3.0.3

* Fix null check

## 3.0.2

* Added queryParameters in curl

## 3.0.1

* Updated dependencies

## 3.0.0

* Release 3.0.0

## 3.0.0-dev.2

* Fixed null-safety issues

## 3.0.0-dev.1

* Added null-safety

## 2.0.0

* Updated dependencies

## 1.0.2

* Fix problem with dependencies.

## 1.0.1

* Showing full path of request inside list.
* Sharing all logs as file.

## 1.0.0

* Initial release. Removed all network libraries except dio. Removed save to file functionality.
