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
  bool areIconsVisible = false;

  late Icon selectedIcon;

  final List<Icon> icons = [
    Icon(Icons.email_rounded),
    Icon(Icons.phone_rounded),
    Icon(Icons.meeting_room_rounded),
    Icon(Icons.nature_people_rounded),
    Icon(Icons.map_outlined),
    Icon(Icons.home_rounded),
    Icon(Icons.pets_rounded),
    Icon(Icons.code_rounded),
    Icon(Icons.coffee),
    Icon(Icons.landscape_rounded),
    Icon(Icons.beach_access_rounded),
    Icon(Icons.book_outlined),
    Icon(Icons.question_mark_rounded),
    Icon(Icons.markunread_mailbox_outlined),
    Icon(Icons.masks_rounded),
    Icon(Icons.music_note_rounded),
    Icon(Icons.waves_rounded),
    Icon(Icons.wb_cloudy_rounded),
    Icon(Icons.wb_incandescent_rounded),
    Icon(Icons.wifi),
    Icon(Icons.chat_rounded),
    Icon(Icons.contact_page_rounded),
    Icon(Icons.emergency_rounded),
    Icon(Icons.health_and_safety_rounded),
    Icon(Icons.healing_rounded),
    Icon(Icons.school_rounded),
    Icon(Icons.single_bed_rounded),
    Icon(Icons.carpenter_rounded),
    Icon(Icons.directions_bus_rounded),
    Icon(Icons.baby_changing_station_rounded),
    Icon(Icons.cookie_rounded),
    Icon(Icons.monetization_on_rounded),
    Icon(Icons.palette_rounded),
    Icon(Icons.photo_camera_rounded),
    Icon(Icons.restaurant_rounded),
    Icon(Icons.shopping_cart_rounded),
  ];

  @override
  void initState() {
    super.initState();
    selectedIcon = Icon(Icons.question_mark_rounded);
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
              setState(() {
                TaskType newType = TaskType(name: _textController.text, icon: selectedIcon);
                appState.addNewList(newType);
                Navigator.of(context).pop();
              });
            } : null
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          TextField(
            controller: _textController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              hintText: 'Enter list name...',
              border: UnderlineInputBorder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              child: areIconsVisible ? Text('Hide icons') : Text('Show icons'),
              onPressed: () {
                setState(() {
                  areIconsVisible = !areIconsVisible;
                });
              },
            ),
          ),
          Visibility(
            visible: areIconsVisible,
            child: Expanded(
              child: SingleChildScrollView(
                child: GridView.count(
                  shrinkWrap: true, 
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  children: List.generate(icons.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIcon = icons[index];
                          areIconsVisible = false;
                        });
                      },
                      child: icons[index]
                    );
                  }),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
