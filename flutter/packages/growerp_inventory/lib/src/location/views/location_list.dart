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

import '../location.dart';
import '../widgets/widgets.dart';

class LocationList extends StatefulWidget {
  const LocationList({super.key});

  @override
  LocationListState createState() => LocationListState();
}

class LocationListState extends State<LocationList> {
  final _scrollController = ScrollController();
  final _horizontalController = ScrollController();
  late LocationBloc _locationBloc;
  List<Location> locations = <Location>[];
  late Authenticate authenticate;
  late int limit;
  String? searchString;

  @override
  void initState() {
    super.initState();
    _locationBloc = context.read<LocationBloc>()..add(const LocationFetch());
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    limit = (MediaQuery.of(context).size.height / 100).round();
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        switch (state.status) {
          case LocationStatus.failure:
            return Center(
                child: Text('failed to fetch locations: ${state.message}'));
          case LocationStatus.success:
            locations = state.locations;

            Widget tableView() {
              if (locations.isEmpty)
                return Center(
                    heightFactor: 20,
                    child: Text("no locations found",
                        textAlign: TextAlign.center));
              // get table data formatted for tableView
              var (
                List<List<TableViewCell>> tableViewCells,
                List<double> fieldWidths,
                double? rowHeight
              ) = get2dTableData<Location>(
                getItemFieldNames,
                getItemFieldWidth,
                state.locations,
                getItemFieldContent,
                getRowActionButtons: getRowActionButtons,
                getRowHeight: getRowHeight,
                context: context,
                bloc: _locationBloc,
              );
              return TableView.builder(
                diagonalDragBehavior: DiagonalDragBehavior.free,
                verticalDetails:
                    ScrollableDetails.vertical(controller: _scrollController),
                horizontalDetails: ScrollableDetails.horizontal(
                    controller: _horizontalController),
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
                                              return BlocProvider.value(
                                                  value: _locationBloc,
                                                  child: LocationDialog(
                                                      locations[index - 1]));
                                            }))
                          }),
                pinnedRowCount: 1,
              );
            }

            return Scaffold(
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                      key: const Key("search"),
                      heroTag: "btn1",
                      onPressed: () async {
                        // find findoc id to show
                        Location location = await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              // search separate from finDocBloc
                              return BlocProvider.value(
                                  value:
                                      context.read<DataFetchBloc<Locations>>(),
                                  child: SearchLocationList());
                            });
                        // show detail page
                        await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              return BlocProvider.value(
                                  value: _locationBloc,
                                  child: LocationDialog(location));
                            });
                      },
                      child: const Icon(Icons.search)),
                  SizedBox(height: 10),
                  FloatingActionButton(
                      key: const Key("addNew"),
                      onPressed: () async {
                        await showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (BuildContext context) {
                              return BlocProvider.value(
                                  value: _locationBloc,
                                  child: LocationDialog(Location()));
                            });
                      },
                      tooltip: 'Add New',
                      child: const Icon(Icons.add)),
                ],
              ),
              body: tableView(),

              /*
                
                RefreshIndicator(
                    onRefresh: (() async =>
                        _locationBloc.add(const LocationFetch(refresh: true))),
                    child: ListView.builder(
                      key: const Key('listView'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: state.hasReachedMax
                          ? state.locations.length + 1
                          : state.locations.length + 2,
                      controller: _scrollController,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Column(children: [
                            LocationListHeader(locationBloc: _locationBloc),
                            const Divider(),
                            Visibility(
                                visible: state.locations.isEmpty,
                                child: const Center(
                                    heightFactor: 20,
                                    child: Text("No locations found",
                                        textAlign: TextAlign.center)))
                          ]);
                        }
                        index--;
                        return index >= state.locations.length
                            ? const BottomLoader()
                            : Dismissible(
                                key: const Key('locationItem'),
                                direction: DismissDirection.startToEnd,
                                child: LocationListItem(
                                    location: state.locations[index],
                                    index: index,
                                    isPhone: isPhone));
                      },
                    ))
  */
            );
          default:
            return const Center(child: LoadingIndicator());
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) _locationBloc.add(LocationFetch(limit: limit));
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }
}
