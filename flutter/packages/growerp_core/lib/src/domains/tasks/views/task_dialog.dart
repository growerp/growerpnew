/*
 * This GrowERP software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 * 
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 * 
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */

import 'package:growerp_models/growerp_models.dart';

import '../../../../growerp_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskDialog extends StatefulWidget {
  final Task task;
  const TaskDialog(this.task, {super.key});
  @override
  TaskDialogState createState() => TaskDialogState();
}

class TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  late TaskStatus _status;
  late TaskBloc taskBloc;

  @override
  void initState() {
    super.initState();
    _status = widget.task.status ?? TaskStatus.planning;
    _nameController.text = widget.task.taskName;
    taskBloc = context.read<TaskBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Dialog(
            key: const Key('TaskDialog'),
            insetPadding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: BlocListener<TaskBloc, TaskState>(
                listener: (context, state) async {
                  switch (state.status) {
                    case TaskBlocStatus.success:
                      HelperFunctions.showMessage(
                          context,
                          '${widget.task.taskId.isEmpty ? "Add" : "Update"} successfull',
                          Colors.green);
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      break;
                    case TaskBlocStatus.failure:
                      HelperFunctions.showMessage(
                          context, 'Error: ${state.message}', Colors.red);
                      break;
                    default:
                      const Text("????");
                  }
                },
                child: popUp(
                    context: context,
                    child: _showForm(isPhone(context)),
                    title: '${widget.task.taskType} Information',
                    height: 400,
                    width: 400))));
  }

  Widget _showForm(isPhone) {
    return Center(
        child: Form(
            key: _formKey,
            child: ListView(key: const Key('listView'), children: <Widget>[
              Center(
                  child: Text(
                      "Task${widget.task.taskId.isEmpty ? "New" : widget.task.taskId}",
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold))),
              const SizedBox(height: 30),
              TextFormField(
                key: const Key('name'),
                decoration:
                    InputDecoration(labelText: '${widget.task.taskType} Name'),
                controller: _nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a ${widget.task.taskType} name?';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<TaskStatus>(
                key: const Key('statusDropDown'),
                decoration: const InputDecoration(labelText: 'Status'),
                hint: const Text('Status'),
                value: _status,
                validator: (value) => value == null ? 'field required' : null,
                items: TaskStatus.values
                    .map((taskStatus) => DropdownMenuItem<TaskStatus>(
                          value: taskStatus,
                          child: Text(taskStatus.name),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _status = newValue!;
                  });
                },
                isExpanded: true,
              ),
              const SizedBox(height: 20),
              Row(children: [
                Visibility(
                    visible: widget.task.taskId.isNotEmpty,
                    child: ElevatedButton(
                        key: const Key('TimeEntries'),
                        child: const Text('TimeEntries'),
                        onPressed: () async {
                          await showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext context) {
                                return BlocProvider.value(
                                    value: taskBloc,
                                    child: TimeEntryListDialog(
                                        widget.task.taskId,
                                        widget.task.timeEntries));
                              });
                        })),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton(
                        key: const Key('update'),
                        child: Text(
                            widget.task.taskId.isEmpty ? 'Create' : 'Update'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            taskBloc.add(TaskUpdate(
                              widget.task.copyWith(
                                taskId: widget.task.taskId,
                                taskName: _nameController.text,
                                status: _status,
                              ),
                            ));
                          }
                        }))
              ]),
            ])));
  }
}
