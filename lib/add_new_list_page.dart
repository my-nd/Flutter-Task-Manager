import 'package:task_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewListPage extends StatefulWidget {
  AddNewListPage({Key? key}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => _AddNewListPage();  
}

class _AddNewListPage extends State<AddNewListPage> {
  final TextEditingController _textController = TextEditingController();

  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _textController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(context, ),
          icon: Icon(Icons.arrow_back_ios_rounded),
        ),
        title: Text('Create new list'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: _isButtonEnabled ? () {
              TaskType newType = TaskType(name: _textController.text, icon: Icon(Icons.question_mark_rounded));
              appState.addNewList(newType);
              Navigator.of(context).pop();
            } : null
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          TextField(
            controller: _textController,
            autofocus: true,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              hintText: 'Enter list name...',
              border: UnderlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
