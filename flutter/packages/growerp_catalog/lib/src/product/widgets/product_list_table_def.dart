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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growerp_core/growerp_core.dart';
import 'package:growerp_models/growerp_models.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../blocs/product_bloc.dart';

TableData getTableData(Bloc bloc, String classificationId, BuildContext context,
    Product item, int index) {
  String currencyId = context
      .read<AuthBloc>()
      .state
      .authenticate!
      .company!
      .currency!
      .currencyId!;
  List<TableRowContent> rowContent = [];
  bool isPhone = isAPhone(context);
  if (isPhone) {
    rowContent.add(TableRowContent(
        name: ' ',
        width: 15,
        value: CircleAvatar(
          key: const Key('productItem'),
          child: item.image != null
              ? Image.memory(
                  item.image!,
                  height: 100,
                )
              : Text(item.productName![0]),
        )));
  }

  rowContent.add(TableRowContent(
      name: 'Id',
      width: isPhone ? 15 : 8,
      value: Text(item.pseudoId, key: Key('id$index'))));

  rowContent.add(TableRowContent(
      name: 'Name',
      width: isPhone ? 35 : 20,
      value: Text("${item.productName}", key: Key('name$index'))));

  rowContent.add(TableRowContent(
      name: 'Price',
      width: 15,
      value: Text(item.price.currency(currencyId: currencyId),
          key: Key('price$index'), textAlign: TextAlign.center)));

  if (classificationId != 'AppHotel') {
    if (!isPhone) {
      rowContent.add(TableRowContent(
          name: 'Category',
          width: 15,
          value: Text(
              "${item.categories.isEmpty ? '0' : item.categories.length > 1 ? item.categories.length : item.categories[0].categoryName}",
              key: Key('categoryName$index'),
              textAlign: TextAlign.center)));
    }
  }
  if (!isPhone && classificationId == 'AppHotel') {
    rowContent.add(TableRowContent(
        name: '#Units',
        width: 15,
        value: Text(item.assetCount != null ? item.assetCount.toString() : '0',
            key: Key('assetCount$index'), textAlign: TextAlign.center)));
  }

  if (!isPhone) {
    rowContent.add(TableRowContent(
        name: classificationId != 'AppHotel'
            ? "Nbr Of Assets"
            : "Number of Units",
        width: 15,
        value: Text(item.assetCount != null ? item.assetCount.toString() : '0',
            key: Key('assetCount$index'), textAlign: TextAlign.center)));
  }

  rowContent.add(TableRowContent(
      name: '',
      width: 10,
      value: IconButton(
        key: Key('delete$index'),
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.delete_forever),
        onPressed: () {
          bloc.add(ProductDelete(item.copyWith(image: null)));
        },
      )));

  return TableData(rowHeight: isPhone ? 40 : 20, rowContent: rowContent);
}

// general settings
var padding = const SpanPadding(trailing: 5, leading: 5);
SpanDecoration? getBackGround(BuildContext context, int index) {
  return index == 0
      ? SpanDecoration(color: Theme.of(context).colorScheme.tertiaryContainer)
      : null;
}
