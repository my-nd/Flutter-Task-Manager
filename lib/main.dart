import 'package:task_manager/show_task_list_page.dart';
import 'package:task_manager/add_new_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(MyApp());

class TaskType {
  String name;
  Icon icon;

  TaskType({required this.name, required this.icon});
}

class Task {
  String title;
  String description;
  TaskType type;
  DateTime? dueDate;
  bool isFavorite;

  Task({required this.title, this.description = '', required this.type, this.dueDate, this.isFavorite = false});

  void changeTitle(String title) {
    this.title = title;
  }

  void changeDate(DateTime date) {
    dueDate = date;
  }

  void addToFavorites() {
    isFavorite = true;
  }

  void removeFromFavorites() {
    isFavorite = false;
  }
  
  void changeDescription(String description) {
    this.description = description;
  }

  void changeType(TaskType newType) {
    type = newType;
  }

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task List',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 0, 0)),
        ),
        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          textTheme: GoogleFonts.montserratTextTheme()
        ),
        themeMode: ThemeMode.dark,
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

  List<TaskType> _types = [
    TaskType(name: 'email', icon: Icon(Icons.email_rounded)),
    TaskType(name: 'phone', icon: Icon(Icons.phone_rounded)),
    TaskType(name: 'meeting', icon: Icon(Icons.meeting_room_rounded)),
  ];

  List<Task> _tasks = [
    Task(title: 'Send resumé', type: TaskType(name: 'email', icon: Icon(Icons.email_rounded)), dueDate: DateTime(2023, 6, 3, 17, 50)),
    Task(title: 'Call company', type: TaskType(name: 'email', icon: Icon(Icons.email_rounded)), dueDate: DateTime(2023, 5, 20, 13, 7)),
    Task(title: 'Kick-off', type: TaskType(name: 'phone', icon: Icon(Icons.phone_rounded)), dueDate: DateTime(2023, 6, 3, 17, 50)),
  ];

  List<Task> _completedTasks = [];

  

  List<Task> get tasks => _tasks;
  List<Task> get completedTasks => _completedTasks;
  List<TaskType> get types => _types;

  void replaceTypes() {
    for (int i = 0; i < _tasks.length; i++) {
      _tasks[i].changeType(_types[i]);
    }
  }

  void addTask(Task newTask) {
    _tasks.add(newTask);
    notifyListeners();
  }

  void addNewList(TaskType type) {
    _types.add(type);
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.contains(task) ? _tasks.remove(task) : _completedTasks.remove(task);
    notifyListeners();
  }

  void addToFavorites(Task task) {
    task.addToFavorites();
    notifyListeners();
  }

  void removeFromFavorites(Task task) {
    task.removeFromFavorites();
    notifyListeners();
  }

  void addToCompleted(Task task) {
    _tasks.remove(task);
    _completedTasks.add(task);
    notifyListeners();
  }

  void removeFromCompleted(Task task) {
    _completedTasks.remove(task);
    _tasks.add(task);
    notifyListeners();
  }

  void changeTaskTitle(Task task, String newTitle) {
    task.changeTitle(newTitle);
  }

  void changeTaskDescription(Task task, String newDesc) {
    task.changeDescription(newDesc);
  }

  void changeTaskDate(Task task, DateTime date) {
    task.changeDate(date);
    notifyListeners();
  }

  void changeTaskType(Task task, TaskType newType) {
    task.changeType(newType);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool hasBeenReplaced = false;

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ModalContent()
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    if (!hasBeenReplaced) {
      appState.replaceTypes();
      setState(() {
        hasBeenReplaced = true;
      });
    }

    return DefaultTabController(
      length: appState.types.length+2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Task Manager'),
          centerTitle: true,
          bottom:
            TabBar(
              indicatorColor: Colors.blue,
              isScrollable: true,
              labelPadding: EdgeInsets.symmetric(horizontal: 25),
              tabs: [
                Tab(icon: Icon(Icons.star_rounded)),
                Tab(text: 'All Tasks'),
                for (var type in appState.types)
                  Tab(text: type.name),
              ],
            ),
        ),
        body: TabBarView(
          children: [
            ShowTaskListPage('favorites'),
            ShowTaskListPage('todo'),
            for(var type in appState.types)
              ShowTaskListPage(type.name)
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked ,
        floatingActionButton: FloatingActionButton(
          shape: CircleBorder(),
          onPressed: (_showBottomSheet),
          child: Icon(Icons.add_rounded),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 60,
          shape: CircularNotchedRectangle(),
          notchMargin: 8.0,
          clipBehavior: Clip.antiAlias,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.menu_rounded),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddNewListPage())
                  );
                },
                child: Text('+ New List'),
              )
            ],
          ),
        ),
      )
    );
  }
}


class ModalContent extends StatefulWidget {

  //final TextEditingController controller;
  const ModalContent({super.key});

  @override
  State<StatefulWidget> createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isDescriptionVisible = false;
  bool _isStarPressed = false;
  bool _hasDate = false;
  bool _hasType = false;
  bool _isFormValid = false;

  String name = '';
  String description = '';
  DateTime date = DateTime.now();
  late TaskType type;

  Icon iconToDisplay = Icon(Icons.filter_frames_rounded, color: Color.fromARGB(255, 131, 73, 232),);

  Widget _showAvailableIcons() {
    final appState = Provider.of<MyAppState>(context, listen: true);

    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: PopupMenuButton<TaskType>(
        itemBuilder: (BuildContext context) => appState.types.map((type) {
          return PopupMenuItem<TaskType>(
            value: type,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 30.0),
                  child: type.icon,
                ),
                Text(type.name, style: TextStyle(color: Colors.white),)
              ],
            ),
          );
        }).toList(),
        position: PopupMenuPosition.under,
        onSelected: (TaskType selectedType) {
          setState(() {
            type = selectedType;
            _hasType = true;
            iconToDisplay = Icon(selectedType.icon.icon, color: Color.fromARGB(255, 131, 73, 232),);
          });
        },
        child: iconToDisplay,
      ),
    );
  }

  void _showModalDate() async {
    final DateTime? pickedDate = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(child: DatePickerModal(selectedDate: date,));
      }
    );

    if (pickedDate != null) {
      date = pickedDate;
      _hasDate = true;
    }
  }

  void _saveForm(BuildContext context) {
    _formKey.currentState!.save();

    final appState = Provider.of<MyAppState>(context, listen: false);
    late Task newTask;

    newTask = Task(title: name, type: type);

    if (_hasDate) {
      newTask.changeDate(date);
    }

    if (description != '') {
      newTask.changeDescription(description);
    }

    if (_isStarPressed) {
      newTask.addToFavorites();
    }

    appState.addTask(newTask);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom
      ),
      child: SizedBox(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 5),
                  hintText: 'Enter task name...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  _isFormValid = value.isNotEmpty;
                },
                onSaved: (value) {
                  setState(() {
                    name = value!;
                  });
                },
              ),
              Visibility(
                visible: _isDescriptionVisible,
                child: TextFormField(
                  autofocus: true,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 25, right: 25, top: 0, bottom: 0),
                    hintText: 'Enter task description...',
                    border: InputBorder.none,
                  ),
                  onSaved: (value) {
                    setState(() {
                      description = value!;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    IconButton(
                      color: const Color.fromARGB(255, 131, 73, 232),
                      onPressed: () {
                        setState(() {
                          _isDescriptionVisible = !_isDescriptionVisible;
                        });
                      },
                      icon: Icon(Icons.menu_rounded)
                    ),
                    IconButton(
                      color: const Color.fromARGB(255, 131, 73, 232),
                      onPressed: () {
                        setState(() {
                          _isStarPressed = !_isStarPressed;
                        });
                      },
                      icon: _isStarPressed ? Icon(Icons.star_rounded) : Icon(Icons.star_border_rounded)
                    ),
                    IconButton(
                      color: const Color.fromARGB(255, 129, 72, 227),
                      onPressed: (_showModalDate),
                      icon: Icon(Icons.calendar_month_rounded),
                    ),
                    _showAvailableIcons(),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: TextButton(
                        onPressed: _isFormValid && _hasType ? () => _saveForm(context) : null,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

class DatePickerModal extends StatefulWidget {

  final DateTime selectedDate;
  
  DatePickerModal({Key? key, required this.selectedDate});

  @override
  State<StatefulWidget> createState() => _DatePickerModal();
}

class _DatePickerModal extends State<DatePickerModal> {

  int _expandedIndex = 0;

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 55),
                    child: Text(
                      'Date and time',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final dateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
                  Navigator.of(context).pop(dateTime);
                },
                child: Text('Save'),
              )
            ],
          ),
        ),
        ExpansionPanelList(
          elevation: 0,
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              if (!isExpanded) {
                _expandedIndex = panelIndex;
              } else {
                _expandedIndex = -1;
              }
            });
          },
          children: [
            ExpansionPanel(
              canTapOnHeader: true,
              backgroundColor: Color.fromARGB(255,37,35,42),
              headerBuilder: (context, isExpanded) {
                return ListTile(
                    title: Text('Select date', style: TextStyle(color: Colors.white),),
                );
              },
              body: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime(2015),
                lastDate: DateTime(2030),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              ),
              isExpanded: _expandedIndex == 0,
            ),
            ExpansionPanel(
              canTapOnHeader: true,
              backgroundColor: Color.fromARGB(255,37,35,42),
              headerBuilder: (context, isExpanded) {
                return ListTile(
                    title: Text('Select time', style: TextStyle(color: Colors.white),),
                  );
              },
              body: SizedBox(
                height: 200,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (time) {
                    _selectedTime = time;
                  },
                ),
              ),
              isExpanded: _expandedIndex == 1,
            )
          ],
        ),
      ],
    );
  }

}