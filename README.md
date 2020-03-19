# Notifier

### TODO Frontend:
* Create Register User using cc-userId, append ```@iitk.ac.in``` automatically (Registering User should create a document in users collection)
* Create LogIn system
* Save the userId upon login
* Keep the User Logged In
* Implement LogOut
* Implement Admin Type 1 and 2
* If sntsecy, Allow elevatePersons (Type 2)
* If ```user.admin=True```, allow Type 1
* Allow Creating Posts
* Allow Updating Linked Posts (access from posts field of the document in persons collection)
* Allow Deleting Linked Posts (accessed in the same way as above)
* Deal with the Notifications received on creating a new post: Every time a new post is created, the app will get a notification, having the post ```id```, ```type```, ```title``` and ```message```, the title and message should be displayed. The other details of the post need to be fetched from the firestore collection ```snt``` using the ```id``` and saved locally. ```type:creation```
* Deal with the Notifications received on updating a new post: On an update, you will get the same data, repeate the entire process as earlier. ```type:update```
* Deal with the Notifications received on deleting a new post: On a delete, just delete the post stored locally using the ```id```. ```type:delete```
* For Type 2 interface, allow erasing all posts and people at once.
* For Type 2 interface, allow adding of new People as Coordinators and Managers
