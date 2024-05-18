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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growerp_core/growerp_core.dart';
import 'package:growerp_models/growerp_models.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../findoc.dart';

class FinDocList extends StatefulWidget {
  const FinDocList({
    super.key,
    this.sales = true,
    this.docType = FinDocType.unknown,
    this.onlyRental = false,
    this.status,
    this.additionalItemButtonName,
    this.additionalItemButtonRoute,
    this.journalId,
  });

  final bool sales;
  final FinDocType docType;
  final bool onlyRental;
  final String? status;
  final String? additionalItemButtonName;
  final String? additionalItemButtonRoute;
  final String? journalId;

  @override
  FinDocListState createState() => FinDocListState();
}

/*
extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
*/
class FinDocListState extends State<FinDocList> {
  final _scrollController = ScrollController();
  List<FinDoc> finDocs = <FinDoc>[];
  int? tab;
  late int limit;
  late String entityName;
  late bool isPhone;
  bool hasReachedMax = false;
  late FinDocBloc _finDocBloc;
  late final ScrollController _verticalController = ScrollController();
  late final ScrollController _horizontalController = ScrollController();
  List<List<TableViewCell>> tableViewRows = [];
  late String classificationId;

  @override
  void initState() {
    super.initState();
    classificationId = context.read<String>();
    entityName =
        classificationId == 'AppHotel' && widget.docType == FinDocType.order
            ? 'Reservation'
            : widget.docType.toString();
    _scrollController.addListener(_onScroll);
    switch (widget.docType) {
      case FinDocType.order:
        widget.sales
            ? _finDocBloc = context.read<SalesOrderBloc>() as FinDocBloc
            : _finDocBloc = context.read<PurchaseOrderBloc>() as FinDocBloc;
        break;
      case FinDocType.invoice:
        widget.sales
            ? _finDocBloc = context.read<SalesInvoiceBloc>() as FinDocBloc
            : _finDocBloc = context.read<PurchaseInvoiceBloc>() as FinDocBloc;
        break;
      case FinDocType.payment:
        widget.sales
            ? _finDocBloc = context.read<SalesPaymentBloc>() as FinDocBloc
            : _finDocBloc = context.read<PurchasePaymentBloc>() as FinDocBloc;
        break;
      case FinDocType.shipment:
        widget.sales
            ? _finDocBloc = context.read<OutgoingShipmentBloc>() as FinDocBloc
            : _finDocBloc = context.read<IncomingShipmentBloc>() as FinDocBloc;
        break;
      case FinDocType.transaction:
        _finDocBloc = context.read<TransactionBloc>() as FinDocBloc;
        break;
      default:
    }
    _finDocBloc.add(const FinDocFetch(limit: 15));
  }

  @override
  Widget build(BuildContext context) {
    limit = (MediaQuery.of(context).size.height / 100).round();
    isPhone = isAPhone(context);
    Widget finDocsPage() {
      if (finDocs.isEmpty)
        return Center(
            heightFactor: 20,
            child: Text(
                widget.journalId != null
                    ? "no journal entries found"
                    : "no (${widget.docType == FinDocType.transaction ? 'unposted' : 'open'})"
                        "${widget.docType == FinDocType.shipment ? "${widget.sales ? 'outgoing' : 'incoming'} " : "${widget.docType == FinDocType.transaction ? '' : widget.sales ? 'sales' : 'purchase'} "}"
                        "${entityName}s found!",
                textAlign: TextAlign.center));
/*      return Column(children: [
        widget.docType == FinDocType.transaction
            ? FinDocListHeaderTrans(
                isPhone: isPhone,
                sales: widget.sales,
                docType: widget.docType,
                finDocBloc: _finDocBloc)
            : Container(),
*/
      var (
        List<List<TableViewCell>> tableViewCells,
        List<double> fieldWidths,
        double? rowHeight
      ) = get2dTableData<FinDoc>(
        getItemFieldNames,
        getItemFieldWidth,
        finDocs,
        getItemFieldContent,
        getRowActionButtons: getRowActionButtons,
        getRowHeight: getRowHeight,
        context: context,
      );
      return TableView.builder(
        diagonalDragBehavior: DiagonalDragBehavior.free,
        verticalDetails:
            ScrollableDetails.vertical(controller: _verticalController),
        horizontalDetails:
            ScrollableDetails.horizontal(controller: _horizontalController),
        cellBuilder: (context, vicinity) =>
            tableViewCells[vicinity.row][vicinity.column],
        columnBuilder: (index) => index >= tableViewCells[0].length
            ? null
            : TableSpan(
                padding: padding,
                backgroundDecoration: getBackGround(context, index),
                extent: FixedTableSpanExtent(fieldWidths[index]),
              ),
        pinnedColumnCount: 1,
        rowBuilder: (index) => index >= tableViewCells.length
            ? null
            : TableSpan(
                padding: padding,
                backgroundDecoration: getBackGround(context, index),
                extent: FixedTableSpanExtent(rowHeight!),
                recognizerFactories: <Type, GestureRecognizerFactory>{
                    TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                            TapGestureRecognizer>(
                        () => TapGestureRecognizer(),
                        (TapGestureRecognizer t) => t.onTap = () => showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              return BlocProvider.value(
                                  value: context.read<FinDocBloc>(),
                                  child: widget.onlyRental == true
                                      ? ReservationDialog(
                                          finDoc: finDocs[index],
                                          original: finDocs[index])
                                      : FinDocDialog(finDocs[index]));
                            }))
                  }),
        pinnedRowCount: 1,
      );
    }

    return Builder(builder: (BuildContext context) {
      //
      // used in the blocConsumer below
      listener(context, state) {
        if (state.status == FinDocStatus.failure) {
          HelperFunctions.showMessage(context, '${state.message}', Colors.red);
        }
        if (state.status == FinDocStatus.success) {
          HelperFunctions.showMessage(
              context, '${state.message}', Colors.green);
        }
      }

      builder(context, state) {
        switch (state.status) {
          case FinDocStatus.failure:
            return Center(
                child: ElevatedButton(
                    onPressed: () =>
                        _finDocBloc.add(const FinDocFetch(refresh: true)),
                    child: const Text('Press here to continue')));
          case FinDocStatus.success:
            finDocs = state.finDocs;
            hasReachedMax = state.hasReachedMax;

            // if rental (hotelroom) need to show checkin/out orders
            if (widget.onlyRental && widget.status != null) {
              if (widget.status == FinDocStatusVal.created.toString()) {
                finDocs = state.finDocs
                    .where((FinDoc el) =>
                        el.items[0].rentalFromDate != null &&
                        el.status.toString() == widget.status &&
                        el.items[0].rentalFromDate!
                            .isSameDate(CustomizableDateTime.current))
                    .toList();
              }
              if (widget.status == FinDocStatusVal.approved.toString()) {
                finDocs = state.finDocs
                    .where((FinDoc el) =>
                        el.items[0].rentalThruDate != null &&
                        el.status.toString() == widget.status &&
                        el.items[0].rentalThruDate!
                            .isSameDate(CustomizableDateTime.current))
                    .toList();
              }
            } else if (widget.onlyRental == true) {
              finDocs = state.finDocs
                  .where((el) => el.items[0].rentalFromDate != null)
                  .toList();
            }

            return Scaffold(
                floatingActionButton: ![FinDocType.shipment]
                        .contains(widget.docType)
                    ? FloatingActionButton(
                        key: const Key("addNew"),
                        onPressed: () async {
                          await showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext context) {
                                return BlocProvider.value(
                                    value: _finDocBloc,
                                    child: widget.docType == FinDocType.payment
                                        ? PaymentDialog(
                                            finDoc: FinDoc(
                                                sales: widget.sales,
                                                docType: widget.docType))
                                        : FinDocDialog(FinDoc(
                                            sales: widget.sales,
                                            docType: widget.docType)));
                              });
                        },
                        tooltip: 'Add New',
                        child: const Icon(Icons.add))
                    : null,
                body: finDocsPage());
          default:
            return const Center(child: CircularProgressIndicator());
        }
      }

      // finally create the BlocConsumer
      if (widget.docType == FinDocType.order) {
        if (widget.sales) {
          return BlocConsumer<SalesOrderBloc, FinDocState>(
              listener: listener, builder: builder);
        }
        return BlocConsumer<PurchaseOrderBloc, FinDocState>(
            listener: listener, builder: builder);
      }
      if (widget.docType == FinDocType.invoice) {
        if (widget.sales) {
          return BlocConsumer<SalesInvoiceBloc, FinDocState>(
              listener: listener, builder: builder);
        }
        return BlocConsumer<PurchaseInvoiceBloc, FinDocState>(
            listener: listener, builder: builder);
      }
      if (widget.docType == FinDocType.payment) {
        if (widget.sales) {
          return BlocConsumer<SalesPaymentBloc, FinDocState>(
              listener: listener, builder: builder);
        }
        return BlocConsumer<PurchasePaymentBloc, FinDocState>(
            listener: listener, builder: builder);
      }
      if (widget.docType == FinDocType.shipment) {
        if (widget.sales) {
          return BlocConsumer<OutgoingShipmentBloc, FinDocState>(
              listener: listener, builder: builder);
        }
        return BlocConsumer<IncomingShipmentBloc, FinDocState>(
            listener: listener, builder: builder);
      }
      // Transaction
      return BlocConsumer<TransactionBloc, FinDocState>(
          listener: listener, builder: builder);
    });
  }

/*
  FinDocListItem getFinDocListItem(
      int index, bool isPhone, BuildContext context) {
    return FinDocListItem(
      finDoc: finDocs[index],
      docType: widget.docType,
      index: index,
      isPhone: isPhone,
      sales: widget.sales,
      onlyRental: widget.onlyRental,
      additionalItemButton: widget.additionalItemButtonName != null &&
              widget.additionalItemButtonRoute != null
          ? TextButton(
              key: Key('addButton$index'),
              child: Text(widget.additionalItemButtonName!),
              onPressed: () async {
                await Navigator.pushNamed(
                    context, widget.additionalItemButtonRoute!,
                    arguments: finDocs[index]);
              },
            )
          : null,
    );
  }

  FinDocListItemTrans getFinDocListItemTrans(
      int index, bool isPhone, BuildContext context) {
    return FinDocListItemTrans(
      finDoc: finDocs[index],
      docType: widget.docType,
      index: index,
      isPhone: isPhone,
      sales: widget.sales,
      onlyRental: widget.onlyRental,
      additionalItemButton: widget.additionalItemButtonName != null &&
              widget.additionalItemButtonRoute != null
          ? TextButton(
              key: Key('addButton$index'),
              child: Text(widget.additionalItemButtonName!),
              onPressed: () async {
                await Navigator.pushNamed(
                    context, widget.additionalItemButtonRoute!,
                    arguments: finDocs[index]);
              },
            )
          : null,
    );
  }
*/
  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) _finDocBloc.add(FinDocFetch(limit: limit));
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
