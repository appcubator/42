#42#

42 is a mobile app that makes location-sharing fun and non-creepy.

Users can share their locations with their subscribers and the locations stays valid for 42 minutes or less.

42 also let's them see their friends around and ask privately ask about their locations.


##Architecture ##

We use Parse as our backend. It provides a schema-less database and a push notification server. We use native Obj-c for the iOS application to better utilize location and map APIs as well as the push notifications.


## Filestructure ##

XCode has the concept of Workspaces. When developing, you are supposed to work on `42.xcworkspace`

* `/42` - has all the iOS files
* `/42cloud` - has the javascript that ParseCloud runs. [ParseCloudDocs here](https://parse.com/docs/cloud_code_guide)
* `/Pods` - has the third party iOS modules we are using. (like node_modules) Modules can be added or removed through Podfile
* `/42Tests` - has all the non-existant tests


## To-Do ##

- [ ] Validating Phone number
- [ ] Expiration of location
- [ ] `Ask Friend` Button
- [ ] Matching and moving friend who are already on 42 to the top of the friend list