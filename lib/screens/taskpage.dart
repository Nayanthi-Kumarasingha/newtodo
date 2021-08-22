import 'package:flutter/material.dart';
import 'package:to_do_list/database_helper.dart';
import 'package:to_do_list/model/task.dart';
import 'package:to_do_list/model/todo.dart';
import 'package:to_do_list/screens/widget.dart';


class Taskpage extends StatefulWidget {

  final Task task;

  Taskpage({@required this.task});

  //const Taskpage({Key? key}) : super(key: key);

  @override
  _TaskpageState createState() => _TaskpageState();
}

class _TaskpageState extends State<Taskpage> {

  Databasehelper _dbHelper = Databasehelper();

  int _taskId = 0;
  String _taskTitle = "";
  String _taskDescription = "";

  FocusNode _titlefocus;
  FocusNode _descriptionfocus;
  FocusNode _todofocus;

  bool contentVisible = false;

  @override
  void initState() {

    if(widget.task != null){
      contentVisible = true;

      _taskTitle = widget.task.title;
      _taskDescription = widget.task.description;
      _taskId = widget.task.id;
    }

    _titlefocus = FocusNode();
    _descriptionfocus = FocusNode();
    _todofocus = FocusNode();

    super.initState();
  }

  @override
  void dispose() {

    _titlefocus.dispose();
    _descriptionfocus.dispose();
    _todofocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 24.0,
                      bottom: 6.0,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Image(
                              image: AssetImage('assets/images/back_arrow_icon.png'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            focusNode: _titlefocus,
                            onSubmitted: (value) async {
                              if(value != ""){
                                if(widget.task == null){
                                  Task _newTask = Task(
                                      title: value
                                  );
                                  _taskId = await _dbHelper.insertTask(_newTask);
                                  setState(() {
                                    contentVisible = true;
                                    _taskTitle = value;
                                  });
                                  print("New task Id $_taskId");
                                } else{
                                  await _dbHelper.updateTaskTitle(_taskId, value);
                                  print("Task Updated");
                                }
                                _descriptionfocus.requestFocus();

                              }
                            },
                            controller: TextEditingController()..text = _taskTitle,
                            decoration: InputDecoration(
                              hintText: "Enter Task Title",
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xfF211551),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: contentVisible,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 12.0,
                      ),
                      child: TextField(
                        focusNode: _descriptionfocus,
                        onSubmitted: (value) async{
                          if(value != ""){
                            if(_taskId != 0){
                              await _dbHelper.updateTaskDescription(_taskId, value);
                              _taskDescription = value;
                            }
                          }
                          _todofocus.requestFocus();
                        },
                        controller: TextEditingController()..text = _taskDescription,
                        decoration: InputDecoration(
                          hintText: "Enter Description",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: contentVisible,
                    child: FutureBuilder(
                      initialData: [],
                      future: _dbHelper.getTodo(_taskId),
                      builder: (context, snapshot) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index){
                              return GestureDetector(
                                onTap: () async {
                                  if(snapshot.data[index].isDone == 0){
                                    await _dbHelper.updateTodoDone(snapshot.data[index].id, 1);
                                  }else{
                                    await _dbHelper.updateTodoDone(snapshot.data[index].id, 0);
                                  }
                                  setState(() {});
                                },
                                child: Todowidget(
                                  text: snapshot.data[index].title,
                                  isDone: snapshot.data[index].isDone == 0 ? false : true,
                                ),
                              );
                            },
                          ),
                        );
                    },
                    ),
                  ),
                  Visibility(
                    visible: contentVisible,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20.0,
                            height: 20.0,
                            margin: EdgeInsets.only(
                              right: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5.0),
                              border: Border.all(
                                color: Color(0xfF003640),
                                width: 1.5,
                              ),
                            ),
                            child: Image(
                              image: AssetImage(
                                'assets/images/check_icon.png',
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              focusNode: _todofocus,
                              controller: TextEditingController()..text = "",
                              onSubmitted: (value) async {
                                if(value != ""){
                                  if(_taskId != 0){
                                    Databasehelper _dbHelper = Databasehelper();
                                    Todo _newTodo = Todo(
                                      title: value,
                                      isDone: 0,
                                      taskId: _taskId,
                                    );
                                    await _dbHelper.insertTodo(_newTodo);
                                    setState(() {});
                                    _todofocus.requestFocus();
                                  }else{
                                    print("Task doesn't exist");
                                  }
                                }

                              },
                              decoration: InputDecoration(
                                hintText: "Enter your todo tasks",
                                border: InputBorder.none,
                              ),

                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
              Visibility(
                visible: contentVisible,
                child: Positioned(
                  bottom: 24.0,
                  right: 24.0,
                  child: GestureDetector(
                    onTap: () async {
                      if(_taskId != 0){
                        await _dbHelper.deleteTask(_taskId);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      height: 60.0,
                      width: 60.0,
                      decoration: BoxDecoration(
                          color: Color(0xfF186d44),
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Image(
                        image: AssetImage('assets/images/delete_icon.png'),
                      ),
                    ),
                  ),
                ),
              ),
            ],

          ),
        ),
      ),
    );
  }
}
