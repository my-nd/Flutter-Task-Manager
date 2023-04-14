import 'package:task_manager/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:task_manager/task_details_page.dart';

enum Actions {
  done,
  undone,
  favorites,
  delete
}

class ShowTaskListPage extends StatefulWidget {
  final String taskTypeName;

  ShowTaskListPage(this.taskTypeName);

  @override
  State<StatefulWidget> createState() => _ShowTaskListPage();
}

class _ShowTaskListPage extends State<ShowTaskListPage> {
  

  
  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();

    var tasks = List<Task>.from(appState.tasks);
    var completed = List<Task>.from(appState.completedTasks);

    switch (widget.taskTypeName) {
      case 'favorites':
        tasks.retainWhere((task) => task.isFavorite);
        completed.retainWhere((task) => task.isFavorite);
        break;
      case 'todo': break;
      default:
        tasks.retainWhere((task) => task.type.name == widget.taskTypeName);
        completed.retainWhere((task) => task.type.name == widget.taskTypeName);
        break;
    }

    void onDismissed(int index, Actions action) {
      final task = tasks[index];

      switch (action) {
        case Actions.done:
          appState.addToCompleted(task);
          break;
        case Actions.favorites:
          if (!task.isFavorite) {
            appState.addToFavorites(task);
          } else {
            appState.removeFromFavorites(task);
          }
          break;
        case Actions.delete:
          appState.removeTask(task);
          break;
        default: break;
      }
    }

    void onUndoneTask(int index, Actions action) {
      final task = appState.completedTasks[index];

      switch (action) {
        case Actions.undone:
          appState.removeFromCompleted(task);
          break;
        case Actions.delete:
          appState.removeTask(task);
          break;
        default: break;
      }
    }

    Widget buildTaskListTile(Task task) {
      var hasDate = false;
      var weekDay = '';
      var day = -1;
      var month = -1;

      var hour = '';
      var minute = '';

      if (task.dueDate != null) {
        hasDate = true;

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

      }

      return ListTile(
        contentPadding: EdgeInsets.only(left: 25, right: 5),
        title: Text(task.title, style: TextStyle(color: Colors.white),),
        leading: task.type.icon,
        trailing: Visibility(
          visible: hasDate,
          child: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Text('$weekDay, $day/$month, $hour:$minute', style: TextStyle(color: Colors.white),),
          ),
        ),
        onTap: () async {
          TaskType? newType = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => TaskDetailsPage(task))
          );
          if (newType != null) {
            setState(() {
              appState.changeTaskType(task, newType);
            });
          }
        },
      );
    }

    Widget taskList;
  
    if (tasks.isEmpty) {
      taskList = Center(child: Text('No tasks added to this list.', style: TextStyle(color: Colors.white),));
    }
    else {
      taskList =  ListView.builder(
        shrinkWrap: true,
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          var task = tasks[index];

          return Slidable(
            key: Key(task.title),
            startActionPane: ActionPane(
              motion: BehindMotion(),
              dismissible: DismissiblePane(
                onDismissed: () => onDismissed(index, Actions.delete)
              ),
              children: [
                SlidableAction(
                  backgroundColor: Colors.red,
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  onPressed: (context) => onDismissed(index, Actions.delete),
                )
              ]
            ),
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              dismissible: DismissiblePane(
                onDismissed: () => onDismissed(index, Actions.done)
              ),
              children: [
                SlidableAction(
                  backgroundColor: Color.fromARGB(255, 214, 195, 20),
                  icon: tasks[index].isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  onPressed: (context) => onDismissed(index, Actions.favorites)
                ),
                SlidableAction(
                  backgroundColor: Colors.blue,
                  icon: Icons.done_rounded,
                  onPressed: (context) => onDismissed(index, Actions.done)
                ),
              ]
            ),
            child: buildTaskListTile(task) 
          );
        }
      );
    }    

    if (appState.completedTasks.isNotEmpty) {
      taskList =
        Column(
          children: [
            Flexible(child: taskList),
            Flexible(
              child: ExpansionTile(
                title: Text('Completed' , style: TextStyle(color: Colors.white),),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: completed.length,
                    itemBuilder: ((context, index) {
                      var completedTask = completed[index];
            
                      return Slidable(
                        key: Key(completedTask.title),
                        startActionPane: ActionPane(
                          motion: BehindMotion(),
                          dismissible: DismissiblePane(
                            onDismissed: () => onUndoneTask(index, Actions.delete)
                          ),
                          children: [
                            SlidableAction(
                              backgroundColor: Colors.red,
                              icon: Icons.delete_rounded,
                              onPressed: (context) => onUndoneTask(index, Actions.delete)
                            )
                          ]
                        ),
                        endActionPane: ActionPane(
                          motion: DrawerMotion(),
                          dismissible: DismissiblePane(
                            onDismissed: () => onUndoneTask(index, Actions.undone)
                          ),
                          children: [
                            SlidableAction(
                              backgroundColor: Color.fromARGB(255, 28,  27,31),
                              label: 'Undone',
                              onPressed: (context) => onUndoneTask(index, Actions.undone)
                            )
                          ]
                        ),
                        child: ListTile(
                          title: Text(completedTask.title, style: TextStyle(color: Colors.white),),
                          leading: Icon(Icons.done_rounded, color: Colors.blue,),
                        )
                      );
                    })
                  )
                ],
              ),
            )
          ]
        );
    }

    return taskList;
  }
}