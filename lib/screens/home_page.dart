import 'dart:nativewrappers/_internal/vm/lib/ffi_patch.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  //creat an empty list of maps which represent our tasks
  final List<Map<String, dynamic>> tasks = [];
  // Create a variable that captures the input of a text input
  final TextEditingController taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: Image.asset('assets/rdplogo.png', height: 80)),
            Text(
              'RDP Daily Planner',
              style: TextStyle(
                fontFamily: 'Caveat',
                color: Colors.white,
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: CalendarFormat.month,
            focusedDay: DateTime.now(),
            firstDay: DateTime(2025),
            lastDay: DateTime(2026),
          ),
        ],
      ),
      drawer: Drawer(),
    );
  }
}

//Build the section for adding tasks
Widget buildAddTaskSection(nameController, addTask) {
  return Row(
    children: [
      Container(
        child: TextField(
          maxLength: 32,
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Add Task',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      ElevatedButton(onPressed: null, child: Text('Add Task')),
    ],
  );
}
