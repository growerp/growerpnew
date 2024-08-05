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

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growerp_core/growerp_core.dart';
import 'package:growerp_models/growerp_models.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../company.dart';

TableData getTableData(Bloc bloc, String classificationId, BuildContext context,
    Company item, int index,
    {dynamic extra}) {
  bool isPhone = isAPhone(context);
  List<TableRowContent> rowContent = [];

  if (isPhone) {
    rowContent.add(TableRowContent(
      name: 'ShortId',
      width: 10,
      value: CircleAvatar(
        child: item.image != null
            ? Image.memory(item.image!)
            : Text(
                item.pseudoId == null ? '' : item.pseudoId!.lastChar(3),
              ),
      ),
    ));
  }

  rowContent.add(TableRowContent(
    name: 'Id',
    width: isPhone ? 14 : 7,
    value: Text(item.pseudoId ?? '', key: Key('id$index')),
  ));

  if (isPhone) {
    rowContent.add(TableRowContent(
      name: const Text('Company Name\nEmail'),
      width: 55,
      value: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${item.name ?? ''} ",
              textAlign: TextAlign.start, key: Key('name$index')),
          Text(item.email ?? '', key: const Key("companyEmail")),
        ],
      ),
    ));
  }

  if (!isPhone) {
    rowContent.add(TableRowContent(
      name: 'Company Name',
      width: 20,
      value: Text(item.name ?? '', key: Key('id$index')),
    ));
  }

  if (!isPhone) {
    rowContent.add(TableRowContent(
      name: 'Role',
      width: 10,
      value: Text(item.role!.value, key: Key('role$index')),
    ));
  }

  if (!isPhone) {
    rowContent.add(TableRowContent(
      name: 'Email',
      width: 10,
      value: Text(item.email ?? '', key: Key('email$index')),
    ));
  }

  if (!isPhone) {
    rowContent.add(TableRowContent(
      name: 'TelephoneNr',
      width: 10,
      value: Text(item.telephoneNr ?? '', key: Key('telephone$index')),
    ));
  }

  if (!isPhone) {
    rowContent.add(TableRowContent(
      name: 'VAT/SLS',
      width: 10,
      value: Text(
          item.vatPerc != Decimal.parse("0")
              ? item.vatPerc.toString()
              : item.salesPerc.toString(),
          key: Key('perc$index')),
    ));
  }

  rowContent.add(TableRowContent(
    name: '',
    width: 10,
    value: IconButton(
      key: Key("delete$index"),
      icon: const Icon(Icons.delete_forever),
      onPressed: () {
        bloc.add(CompanyDelete(item.copyWith(image: null)));
      },
    ),
  ));

  return TableData(rowHeight: isPhone ? 50 : 20, rowContent: rowContent);
}

// general settings
var padding = const SpanPadding(trailing: 5, leading: 5);
SpanDecoration? getBackGround(BuildContext context, int index) {
  return index == 0
      ? SpanDecoration(color: Theme.of(context).colorScheme.tertiaryContainer)
      : null;
}
