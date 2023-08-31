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

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:growerp_core/growerp_core.dart';

import '../../../../growerp_order_accounting.dart';

class GlAccountDialog extends StatefulWidget {
  final GlAccount glAccount;
  const GlAccountDialog(this.glAccount, {super.key});
  @override
  GlAccountDialogState createState() => GlAccountDialogState();
}

class GlAccountDialogState extends State<GlAccountDialog> {
  final _formKeyGlAccount = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountCodeController = TextEditingController();
  final _classSearchBoxController = TextEditingController();
  final _typeSearchBoxController = TextEditingController();
  bool? debitSelected;
  AccountClass? classSelected;
  AccountType? typeSelected;
  late GlAccountBloc _glAccountBloc;

  @override
  void initState() {
    super.initState();
    _glAccountBloc = context.read<GlAccountBloc>()
      ..add(const AccountTypesFetch())
      ..add(const AccountClassesFetch());
    if (widget.glAccount.glAccountId != null) {
      _accountCodeController.text = widget.glAccount.accountCode ?? '';
      _accountNameController.text = widget.glAccount.accountName ?? '';
      debitSelected = widget.glAccount.isDebit;
      classSelected = widget.glAccount.accountClass;
      typeSelected = widget.glAccount.accountType;
    }
  }

  @override
  Widget build(BuildContext context) {
    int columns = ResponsiveBreakpoints.of(context).isMobile ? 1 : 2;
    return BlocListener<GlAccountBloc, GlAccountState>(
        listenWhen: (previous, current) =>
            previous.status == GlAccountStatus.glAccountLoading,
        listener: (context, state) async {
          switch (state.status) {
            case GlAccountStatus.success:
              Navigator.of(context).pop();
              break;
            case GlAccountStatus.failure:
              HelperFunctions.showMessage(
                  context, 'Error: ${state.message}', Colors.red);
              break;
            default:
              const Text("????");
          }
        },
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Dialog(
                key: const Key('GlAccountDialog'),
                insetPadding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: popUp(
                    context: context,
                    title:
                        "GlAccount #${widget.glAccount.glAccountId ?? " New"}",
                    width: columns.toDouble() * 350,
                    height: 600 / columns.toDouble(),
                    child: BlocBuilder<GlAccountBloc, GlAccountState>(
                        builder: (context, state) {
                      switch (state.status) {
                        case GlAccountStatus.failure:
                          return const FatalErrorForm(
                              message: 'server connection problem');
                        case GlAccountStatus.success:
                          return _glAccountForm(state);
                        default:
                          return const Center(
                              child: CircularProgressIndicator());
                      }
                    })))));
  }

  Widget _glAccountForm(state) {
    List<Widget> widgets = [
      TextFormField(
        key: const Key('id'),
        decoration: const InputDecoration(labelText: 'GlAccount Id'),
        controller: _accountCodeController,
        validator: (value) {
          return value!.isEmpty ? 'Please enter a glAccount Id?' : null;
        },
      ),
      TextFormField(
        key: const Key('name'),
        decoration: const InputDecoration(labelText: 'GlAccount Name'),
        controller: _accountNameController,
        validator: (value) {
          return value!.isEmpty ? 'Please enter a glAccount name?' : null;
        },
      ),
      if (widget.glAccount.glAccountId != null)
        BinaryRadioButton(
            isDebit: debitSelected,
            canUpdate: false,
            onValueChanged: (debitSelected) {}),
      DropdownSearch<AccountClass>(
        key: const Key('classesDropDown'),
        selectedItem: classSelected,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Account Class'),
            controller: _classSearchBoxController,
          ),
          title: popUp(
            context: context,
            title: 'Account Class',
            height: 50,
          ),
        ),
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Class',
            hintText: "Account Class",
          ),
        ),
        itemAsString: (AccountClass? u) => "${u!.description}",
        onChanged: (AccountClass? newValue) {
          classSelected = newValue;
        },
        items: state.accountClasses,
        validator: (value) => value == null ? 'field required' : null,
      ),
      DropdownSearch<AccountType>(
        key: const Key('typesDropDown'),
        selectedItem: typeSelected,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Account Type'),
            controller: _typeSearchBoxController,
          ),
          title: popUp(
            context: context,
            title: 'Account Type',
            height: 50,
          ),
        ),
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Type',
            hintText: "Account Type",
          ),
        ),
        itemAsString: (AccountType? u) => "${u!.description}",
        onChanged: (AccountType? newValue) {
          typeSelected = newValue;
        },
        items: state.accountTypes,
        validator: (value) => value == null ? 'field required' : null,
      ),
      ElevatedButton(
          key: const Key('update'),
          child:
              Text(widget.glAccount.glAccountId == null ? 'Create' : 'Update'),
          onPressed: () {
            if (_formKeyGlAccount.currentState!.validate()) {
              _glAccountBloc.add(GlAccountUpdate(GlAccount(
                glAccountId: widget.glAccount.glAccountId,
                accountName: _accountNameController.text,
                accountCode: _accountCodeController.text,
                accountClass: classSelected,
                accountType: typeSelected,
              )));
            }
          }),
    ];

    List<Widget> rows = [];
    List<Widget> column = [];
    if (!ResponsiveBreakpoints.of(context).isMobile) {
      // change list in two columns
      for (var i = 0; i < widgets.length; i++) {
        rows.add(Row(
          children: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(10), child: widgets[i++])),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: i < widgets.length ? widgets[i] : Container()))
          ],
        ));
      }
    } else {
      for (var i = 0; i < widgets.length; i++) {
        column.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: widgets[i],
        ));
      }
    }

    return Form(
      key: _formKeyGlAccount,
      child: SingleChildScrollView(
          key: const Key('listView'),
          padding: const EdgeInsets.all(20),
          child: Column(children: rows.isEmpty ? column : rows)),
    );
  }
}
