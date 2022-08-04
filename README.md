# Flutter-ClickToRun, A User-Friendly Running Tracker App
<img src="https://github.com/Coeeter/flutter-clicktorun/blob/master/android/app/src/main/ic_launcher-playstore.png?raw=true" align="left" width="200">
Flutter-ClickToRun is an application built using the Flutter framework with firebase as the backend. This application is being created for my modules in my studies at Temasek Polytechnic to show my proficiency in Flutter devolopment.
<br clear="left"/>

## The Dependencies used to build Flutter ClickToRun are:
- charts_flutter for drawing graphs
- firebase dependencies to access firebase services such as firebase_core, cloud_firestore, firebase_auth and firebase_storage
- flutter_slidable for slidable deleting widgets
- font_awesome_flutter to be able to use Font Awesome icons in my Flutter app
- google_maps_flutter to be able to display the run of user
- image_picker to be able to get images from the user
- location to be able to track the location of the user
- shimmer to be able to use the shimmer animation when my widgets are loading
- uuid for unique ids for my data

## The features Flutter ClickToRun has to offer are:
- User authentication using Firebase Authentication
- Collected details of user and storing in firestore
- Tracking runs using a foreground service
- Able to create, retrieve and delete runs from Firebase Firestore
- Dark Mode compatible
- Upload and delete profile pictures
- Able to show graphs to show data of the run
- An Explore page, where Users can share their runs to other users
- A following page to only see posts from users you follow
- A profile page, where users can see other users runs posted, following and followers

## Installation:
If you want to try using the app, you can clone it from https://github.com/Coeeter/flutter-clicktorun.git using android studio. When running the app ensure you add the line below by using your own Google Maps API key to the `local.properties` file in the `android` folder
```properties
GOOGLE_MAPS_API_KEY = YOUR_API_KEY
```
