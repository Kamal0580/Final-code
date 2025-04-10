import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

//This line defines a new class called HomePage that extends StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  }); //const HomePage({super.key});: This is the constructor for the HomePage

  @override
  // This method is responsible for creating the mutable state for the HomePage
  State<HomePage> createState() => _HomePageState();
} //=> _HomePageState();: This is a shorthand syntax for returning an instance of the _HomePageState

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore db =
      FirebaseFirestore.instance; //new firestore instance

  //// Creating a TextEditingController to manage the input from a TextField
  final TextEditingController nameController =
      TextEditingController(); //captures textform input
  //// Initializing a list to hold tasks, where each task is represented as a map
  final List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks(); //// This starts loading the tasks from the database right when the widget is created.
  }

  //Fetches tasks from the firestore and update local task list
  Future<void> fetchTasks() async {
    //// This line fetches the tasks from the database, sorted by when they were added
    final snapshot = await db.collection('tasks').orderBy('timestamp').get();

    setState(() {
      // Clear the current list of tasks to start fresh
      tasks.clear();
      // Add all the new tasks from the snapshot to the tasks list
      tasks.addAll(
        // Create a map for each document with its ID, name, and completion status
        snapshot.docs.map(
          (doc) => {
            'id': doc.id, // Get the document ID
            'name': doc.get('name'), // Get the task name from the document
            'completed':
                doc.get('completed') ??
                false, // Get the completion status, default to false if not set
          },
        ),
      );
    });
  }

  //Function that adds new tasks to local state & firestore database
  Future<void> addTask() async {
    final taskName = nameController.text.trim();

    // Check if the task name is not empty
    if (taskName.isNotEmpty) {
      // Create a new task object with the name, completed status, and timestamp
      final newTask = {
        'name': taskName, // The name of the task
        'completed': false, // The task is not completed initially
        'timestamp':
            FieldValue.serverTimestamp(), // Set the timestamp to the current time
      };

      //docRef gives us the insertion id of the task from the database
      final docRef = await db.collection('tasks').add(newTask);

      //Adding tasks locally
      setState(() {
        tasks.add({'id': docRef.id, ...newTask});
      });
      // Clear the text input field after adding the task
      nameController.clear();
    }
  }

  //Updates the completion status of the task in Firestore & locally
  Future<void> updateTask(int index, bool completed) async {
    // Get the task from the local list using the provided index
    final task = tasks[index];
    // Update the task's completion status in the Firestore database
    await db.collection('tasks').doc(task['id']).update({
      'completed': completed, // Set the completed status to the new value
    });

    setState(() {
      // Update the local task's completed status
      tasks[index]['completed'] = completed;
    });
  }

  //Delete the task locally & in the Firestore
  Future<void> removeTasks(int index) async {
    // Get the task from the local list using the provided index
    final task = tasks[index];

    // Delete the task from the Firestore database
    await db.collection('tasks').doc(task['id']).delete();
    // Remove the task from the local task list
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Create a basic material design layout
      appBar: AppBar(
        backgroundColor: Colors.blue, // Set the app bar color to blue
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceEvenly, // Space out the title elements evenly
          children: [
            // Display the logo image
            Expanded(child: Image.asset('assets/rdplogo.png', height: 80)),
            // Display the title text
            const Text(
              'Daily Planner',
              style: TextStyle(
                fontFamily: 'Caveat', // Set the font style for the title
                fontSize: 32, // Set the font size for the title
                color: Colors.white, // Set the text color to white
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Expand this section to take up available space
          Expanded(
            // Allow scrolling if the content is too long
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Display the calendar
                  TableCalendar(
                    calendarFormat:
                        CalendarFormat
                            .month, // Show the calendar in month format

                    focusedDay:
                        DateTime.now(), // Set the currently focused day to today
                    firstDay: DateTime(
                      2025,
                    ), // Set the first day of the calendar
                    lastDay: DateTime(2026), // Set the last day of the calendar
                  ),
                  // Build the task list using the provided tasks, removeTasks, and updateTask functions
                  buildTaskList(tasks, removeTasks, updateTask),
                ],
              ),
            ),
          ),
          buildAddTaskSection(nameController, addTask),
        ],
      ),
      drawer: Drawer(), // Add a drawer for navigation (currently empty)
    );
  }
}

//Build the section for adding tasks
Widget buildAddTaskSection(nameController, addTask) {
  return Container(
    decoration: const BoxDecoration(color: Colors.white),
    child: Padding(
      padding: const EdgeInsets.all(12.0), // Add padding around the container
      child: Row(
        children: [
          // Expand this section to take available space
          Expanded(
            child: Container(
              child: TextField(
                maxLength: 32, // Limit the input length to 32 characters
                controller:
                    nameController, // Use the provided controller for the text field
                decoration: const InputDecoration(
                  labelText: 'Add Task', // Set the label for the text field
                  border:
                      OutlineInputBorder(), // Add a border around the text field
                ),
              ),
            ),
          ),
          ElevatedButton(
            // Button to add the task
            onPressed: addTask, //Adds tasks when pressed
            child: Text('Add Task'), // Set the button text
          ),
        ],
      ),
    ),
  );
}

//Widget that displays the task item on the UI
Widget buildTaskList(tasks, removeTasks, updateTask) {
  return ListView.builder(
    shrinkWrap: true, // Allow the list to take only the space it needs
    physics: const NeverScrollableScrollPhysics(),
    itemCount: tasks.length, // Set the number of items in the list
    itemBuilder: (context, index) {
      final task = tasks[index]; // Get the task at the current index
      final isEven =
          index % 2 == 0; // Check if the index is even for alternating colors

      return Padding(
        // Add padding around each list item
        padding: EdgeInsets.all(1.0),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ), // Round the corners of the tile
          tileColor:
              isEven
                  ? Colors.blue
                  : Colors.green, // Alternate colors for even and odd tasks
          leading: Icon(
            task['completed']
                ? Icons.check_circle
                : Icons
                    .circle_outlined, // Show a check or circle icon based on completion status
          ),
          title: Text(
            task['name'],
            style: TextStyle(
              decoration: task['completed'] ? TextDecoration.lineThrough : null,
              fontSize: 22, // Set the font size for the task name
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min, // Minimize the size of the row
            children: [
              // Checkbox to mark the task as completed
              Checkbox(
                value: task['completed'],
                onChanged:
                    (value) => updateTask(
                      index,
                      value!,
                    ), // Set the checkbox value based on completion status
              ),
              IconButton(
                icon: Icon(Icons.delete), // Show a delete icon
                onPressed:
                    () => removeTasks(
                      index,
                    ), // When the icon is pressed, call the removeTasks function with the current task's index
              ),
            ],
          ),
        ),
      );
    },
  );
}