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
- [X] Sort the addressbook and add the helper on the right
- [X] Normalize number when added user
- [ ] Matching and moving friend who are already on 42 to the top of the friend list
- [ ] In app notification handling
- [ ] Showing only the lates location of the user

## To-Do Backend ##
- [ ] Validating Phone number
- [ ] Expiration of location after 42 mins
- [ ] Checking for dupe object
-- User can not follow the other user twice
-- User can not checkin withing 0.2 mi of the previous checkin for 5 mins (to prevent annoyance) 

## Future Feature List ##
- [ ] `Ask Friend` Button
- [ ] `My Story` Feature
