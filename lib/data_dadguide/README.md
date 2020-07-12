### Development

Run this command to autogen `tables.g.dart` on save:
 
 ```bash
flutter packages pub run build_runner watch
 ```

### Basic procedures for adding a new table

* Create the table definition here
* Add the table entry to the UseMoor annotation
* Modify `update_task.dart` to retrieve updates for the table

### Deployment of new table

Not sure exactly how this will work at the moment. Possibly we will just force
a full database download on update.
