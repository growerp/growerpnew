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

// ignore_for_file: exhaustive_cases
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growerp_core/growerp_core.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:growerp_models/growerp_models.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../company.dart';
import '../widgets/widgets.dart';

class CompanyList extends StatefulWidget {
  const CompanyList({required this.role, super.key});
  final Role? role;

  @override
  CompanyListState createState() => CompanyListState();
}

class CompanyListState extends State<CompanyList> {
  final _scrollController = ScrollController();
  final _horizontalController = ScrollController();
  final double _scrollThreshold = 200.0;
  late CompanyBloc _companyBloc;
  List<Company> companies = const <Company>[];
  bool showSearchField = false;
  String searchString = '';
  bool isLoading = false;
  bool hasReachedMax = false;
  late bool isPhone;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    switch (widget.role) {
      case Role.supplier:
        _companyBloc = context.read<CompanySupplierBloc>() as CompanyBloc
          ..add(const CompanyFetch());
        break;
      case Role.customer:
        _companyBloc = context.read<CompanyCustomerBloc>() as CompanyBloc
          ..add(const CompanyFetch());
        break;
      case Role.lead:
        _companyBloc = context.read<CompanyLeadBloc>() as CompanyBloc
          ..add(const CompanyFetch());
        break;
      default:
        _companyBloc = context.read<CompanyBloc>()..add(const CompanyFetch());
    }
  }

  @override
  Widget build(BuildContext context) {
    isPhone = ResponsiveBreakpoints.of(context).isMobile;
    return Builder(builder: (BuildContext context) {
      Widget tableView() {
        if (companies.isEmpty) {
          return const Center(
              heightFactor: 20,
              child: Text("no users found", textAlign: TextAlign.center));
        }
        // get table data formatted for tableView
        var (
          List<List<TableViewCell>> tableViewCells,
          List<double> fieldWidths,
          double? rowHeight
        ) = get2dTableData<Company>(getTableData,
            bloc: _companyBloc,
            classificationId: 'AppAdmin',
            context: context,
            items: companies);
        return TableView.builder(
          diagonalDragBehavior: DiagonalDragBehavior.free,
          verticalDetails:
              ScrollableDetails.vertical(controller: _scrollController),
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
                      TapGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                                  TapGestureRecognizer>(
                              () => TapGestureRecognizer(),
                              (TapGestureRecognizer t) =>
                                  t.onTap = () => showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return index > companies.length
                                            ? const BottomLoader()
                                            : Dismissible(
                                                key: const Key('locationItem'),
                                                direction:
                                                    DismissDirection.startToEnd,
                                                child: BlocProvider.value(
                                                    value: _companyBloc,
                                                    child: CompanyDialog(
                                                        companies[index - 1])));
                                      }))
                    }),
          pinnedRowCount: 1,
        );
      }

      blocListener(context, state) {
        if (state.status == CompanyStatus.failure) {
          HelperFunctions.showMessage(context, '${state.message}', Colors.red);
        }
        if (state.status == CompanyStatus.success) {
          HelperFunctions.showMessage(
              context, '${state.message}', Colors.green);
        }
      }

      blocBuilder(context, state) {
        if (state.status == CompanyStatus.failure) {
          return FatalErrorForm(
              message: "Could not load ${widget.role.toString()}s!");
        }
        if (state.status == CompanyStatus.success) {
          isLoading = false;
          companies = state.companies;
          hasReachedMax = state.hasReachedMax;
          return Scaffold(
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                      key: const Key("search"),
                      heroTag: "btn1",
                      onPressed: () async {
                        // find findoc id to show
                        await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              // search separate from finDocBloc
                              return BlocProvider.value(
                                  value:
                                      context.read<DataFetchBloc<Companies>>(),
                                  child: const SearchCompanyList());
                            }).then((value) async =>
                            // show detail page
                            await showDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return BlocProvider.value(
                                      value: _companyBloc,
                                      child: CompanyDialog(value));
                                }));
                      },
                      child: const Icon(Icons.search)),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                      key: const Key("addNew"),
                      onPressed: () async {
                        await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              return BlocProvider.value(
                                  value: _companyBloc,
                                  child: CompanyDialog(Company(
                                    role: widget.role,
                                  )));
                            });
                      },
                      tooltip: 'Add New',
                      child: const Icon(Icons.add)),
                ],
              ),
              body: tableView());
        }
        isLoading = true;
        return const LoadingIndicator();
      }

      switch (widget.role) {
        case Role.lead:
          return BlocConsumer<CompanyLeadBloc, CompanyState>(
              listener: blocListener, builder: blocBuilder);
        case Role.customer:
          return BlocConsumer<CompanyCustomerBloc, CompanyState>(
              listener: blocListener, builder: blocBuilder);
        case Role.supplier:
          return BlocConsumer<CompanySupplierBloc, CompanyState>(
              listener: blocListener, builder: blocBuilder);
        default:
          return BlocConsumer<CompanyBloc, CompanyState>(
              listener: blocListener, builder: blocBuilder);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll > 0 && maxScroll - currentScroll <= _scrollThreshold) {
      _companyBloc.add(CompanyFetch(searchString: searchString));
    }
  }
}
