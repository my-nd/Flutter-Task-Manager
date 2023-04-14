import 'package:flutter/cupertino.dart';
import 'package:task_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskDetailsPage extends StatefulWidget {
  final Task task;

  TaskDetailsPage(this.task);

  @override
  State<StatefulWidget> createState() => _TaskDetailsPage();
}

class _TaskDetailsPage extends State<TaskDetailsPage> {

  var weekDay = '';
  var day = -1;
  var month = -1;

  var hour = '';
  var minute = '';


  late TextEditingController _titleController, _descrController;
  

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task.title);
    _descrController = TextEditingController(text: widget.task.description);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    var selectedType = widget.task.type;


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(selectedType),
          icon: Icon(Icons.arrow_back_ios_rounded, color: Color.fromARGB(255, 143, 95, 255),),
        ),
        title: Text('Edit task', style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            color: Color.fromARGB(255, 143, 95, 255),
            icon: widget.task.isFavorite ? Icon(Icons.star_rounded) : Icon(Icons.star_outline_rounded),
            onPressed: () {
              setState(() {
                widget.task.isFavorite ?
                  appState.removeFromFavorites(widget.task) :
                  widget.task.isFavorite = !widget.task.isFavorite;

              });
            },
          ),
          SizedBox(width: 5,),
          IconButton(
            color: Color.fromARGB(255, 143, 95, 255),
            icon: Icon(Icons.delete_rounded),
            onPressed: () {
              setState(() {
                appState.removeTask(widget.task);
                Navigator.of(context).pop();
              });
            },
          ),
          SizedBox(width: 15),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<TaskType>(
              value: widget.task.type, 
              alignment: AlignmentDirectional.bottomStart,
              icon: Icon(Icons.arrow_downward, color: const Color.fromARGB(255, 143, 95, 255),),
              iconSize: 10, 
              elevation: 16, 
              style: TextStyle(color: const Color.fromARGB(255, 143, 95, 255)),
              onChanged: (TaskType? newValue) {
                setState(() {
                  widget.task.type = newValue!;
                  selectedType = newValue;
                  appState.changeTaskType(widget.task, selectedType);
                });
              },
              underline: Container(),
              items: appState.types.map<DropdownMenuItem<TaskType>>((TaskType value) {
                return DropdownMenuItem<TaskType>(
                  value: value,
                  child: Text(value.name),
                );
              }).toList(),
            ),
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white, fontSize: 30),
              decoration: InputDecoration(
                hintText: 'Enter title',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    widget.task.title = value;
                    appState.changeTaskTitle(widget.task, value);
                  });
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Icon(Icons.description_outlined),
                  ),
                  Flexible(
                    child: TextField(
                      controller: _descrController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          widget.task.description = value;
                          appState.changeTaskDescription(widget.task, value);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.calendar_month_outlined),
                ),
                widget.task.dueDate == null ? TextButton(
                  onPressed: () {},
                  child: Text('Add date and time'),
                ) : _showDateTimeChip(context),
              ],
            )
          ],
        ),
      ),
    );
  }

  GestureDetector _showDateTimeChip(BuildContext context) {
    Task task = widget.task;

    switch(task.dueDate!.weekday) {
      case 1:
        weekDay = 'mon';
        break;
      case 2:
        weekDay = 'tue';
        break;
      case 3:
        weekDay = 'wed';
        break;
      case 4:
        weekDay = 'thu';
        break;
      case 5:
        weekDay = 'fri';
        break;
      case 6:
        weekDay = 'sat';
        break;
      case 7:
          weekDay = 'sun';
        break;
      default: break;
    }
    
    day = task.dueDate!.day;
    month = task.dueDate!.month;

    if (task.dueDate!.hour < 10) {
      hour = '0${task.dueDate!.hour}';
    } else {
      hour = '${task.dueDate!.hour}';
    }

    if(task.dueDate!.minute < 10) {
      minute = '0${task.dueDate!.minute}';
    } else {
      minute = '${task.dueDate!.minute}';
    }

    return GestureDetector(
      onTap: () {
        _showDateChange(context);
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          chipTheme: ChipThemeData(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          ),
        ),
        child: Chip(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          label: Text('$weekDay, $day/$month, $hour:$minute', style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }

  void _showDateChange(BuildContext context) async {
    final DateTime? pickedDate = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(child: DatePicker(selectedDate: widget.task.dueDate!));
      }
    );

    if (pickedDate != null) {
      setState(() {
        widget.task.dueDate = pickedDate;
        Provider.of<MyAppState>(context, listen: false).changeTaskDate(widget.task, pickedDate);
      });
    }
  }

}

class DatePicker extends StatefulWidget {

  final DateTime selectedDate;
  
  DatePicker({Key? key, required this.selectedDate});

  @override
  State<StatefulWidget> createState() => _DatePicker();
}

class _DatePicker extends State<DatePicker> {

  int _expandedIndex = 0;

  late DateTime _selectedDate;
  late DateTime _selectedTime;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.selectedDate;
    _selectedTime = widget.selectedDate;
  }

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
                initialDate: _selectedDate,
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
                  initialDateTime: _selectedDate,
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