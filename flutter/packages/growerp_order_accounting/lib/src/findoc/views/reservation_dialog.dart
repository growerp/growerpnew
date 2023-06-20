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
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:growerp_core/growerp_core.dart';
import '../findoc.dart';

class ReservationDialog extends StatelessWidget {
  final FinDoc finDoc;
  final FinDoc? original;
  const ReservationDialog({Key? key, required this.finDoc, this.original})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>(
        create: (context) => UserBloc(
            CompanyUserAPIRepository(
                context.read<AuthBloc>().state.authenticate!.apiKey!),
            Role.customer),
        child: ReservationForm(finDoc: finDoc, original: original));
  }
}

class ReservationForm extends StatefulWidget {
  /// original order
  final FinDoc? original;

  /// extracted single item order
  final FinDoc finDoc;
  const ReservationForm({super.key, required this.finDoc, this.original});
  @override
  ReservationDialogState createState() => ReservationDialogState();
}

class ReservationDialogState extends State<ReservationForm> {
  final _userSearchBoxController = TextEditingController();
  late FinDocBloc _finDocBloc;
  late UserBloc _userBloc;
  User? _selectedUser;
  bool loading = false;
  late ProductBloc _productBloc;
  Product? _selectedProduct;
  late DateTime _selectedDate;
  List<String> rentalDays = [];
  late String classificationId;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _productSearchBoxController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedUser = widget.finDoc.otherUser;
    _finDocBloc = context.read<FinDocBloc>();
    _userBloc = context.read<UserBloc>();
    _userBloc.add(const UserFetch());
    _productBloc = context.read<ProductBloc>();
    _productBloc.add(const ProductFetch());
    if (widget.finDoc.items.isNotEmpty) {
      _selectedProduct = Product(
          productId: widget.finDoc.items[0].productId!,
          productName: widget.finDoc.items[0].description);
      _priceController.text = widget.finDoc.items[0].price.toString();
      _quantityController.text = widget.finDoc.items[0].quantity.toString();
      _selectedDate = widget.finDoc.items[0].rentalFromDate!;
      _daysController.text = widget.finDoc.items[0].rentalThruDate!
          .difference(widget.finDoc.items[0].rentalFromDate!)
          .inDays
          .toString();
    } else {
      _quantityController.text = "1";
      _daysController.text = "1";
      _selectedDate = CustomizableDateTime.current;
    }
    classificationId = GlobalConfiguration().get("classificationId");
  }

  @override
  Widget build(BuildContext context) {
    APIRepository repos = context.read<APIRepository>();

    return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
                onTap: () {},
                child: Dialog(
                    key: const Key('ReservationDialog'),
                    insetPadding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: BlocListener<FinDocBloc, FinDocState>(
                        listener: (context, state) async {
                          switch (state.status) {
                            case FinDocStatus.success:
                              HelperFunctions.showMessage(
                                  context,
                                  '${widget.finDoc.idIsNull() ? "Add" : "Update"} successfull',
                                  Colors.green);
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              if (!mounted) return;
                              Navigator.of(context).pop();
                              break;
                            case FinDocStatus.failure:
                              HelperFunctions.showMessage(context,
                                  'Error: ${state.message}', Colors.red);
                              break;
                            default:
                              const Text("????");
                          }
                        },
                        child: SizedBox(
                            height: 600,
                            width: 400,
                            child: _addRentalItemDialog(repos)))))));
  }

  Widget _addRentalItemDialog(repos) {
    bool whichDayOk(DateTime day) {
      var formatter = DateFormat('yyyy-MM-dd');
      String date = formatter.format(day);
      if (rentalDays.contains(date)) return false;
      return true;
    }

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: CustomizableDateTime.current,
        lastDate: CustomizableDateTime.current.add(const Duration(days: 356)),
        selectableDayPredicate: whichDayOk,
      );
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
      }
    }

    return Center(
        child: popUp(
            context: context,
            height: 750,
            width: 400,
            title: widget.finDoc.orderId == null
                ? (classificationId == 'AppHotel'
                    ? "New Reservation"
                    : "New order")
                : (classificationId == 'AppHotel'
                        ? "Reservation #"
                        : "Order #") +
                    widget.finDoc.orderId!,
            child: Form(
                key: _formKey,
                child: ListView(key: const Key('listView'), children: <Widget>[
                  BlocBuilder<UserBloc, UserState>(builder: (context, state) {
                    switch (state.status) {
                      case UserStatus.failure:
                        return const FatalErrorForm(
                            message: 'server connection problem');
                      case UserStatus.success:
                        return DropdownSearch<User>(
                          selectedItem: _selectedUser,
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              autofocus: true,
                              controller: _userSearchBoxController,
                            ),
                            menuProps: MenuProps(
                                borderRadius: BorderRadius.circular(20.0)),
                            title: popUp(
                              context: context,
                              title: 'Select customer',
                              height: 50,
                            ),
                          ),
                          dropdownSearchDecoration: const InputDecoration(
                            labelText: 'Customer',
                          ),
                          key: const Key('customer'),
                          itemAsString: (User? u) =>
                              "${u!.firstName} ${u.lastName}, ${u.company!.name}",
                          items: state.users,
                          filterFn: (user, filter) {
                            _userBloc.add(UserFetch(searchString: filter));
                            return true;
                          },
                          onChanged: (User? newValue) {
                            setState(() {
                              _selectedUser = newValue;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'field required' : null,
                        );
                      default:
                        return const Center(child: CircularProgressIndicator());
                    }
                  }),
                  const SizedBox(height: 20),
                  BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, productState) {
                    switch (productState.status) {
                      case ProductStatus.failure:
                        return const FatalErrorForm(
                            message: 'server connection problem');
                      case ProductStatus.success:
                        return BlocBuilder<FinDocBloc, FinDocState>(
                            builder: (context, state) {
                          switch (state.status) {
                            case FinDocStatus.failure:
                              return const FatalErrorForm(
                                  message: 'server connection problem');
                            case FinDocStatus.success:
                              rentalDays = state.occupancyDates;
                              return DropdownSearch<Product>(
                                selectedItem: _selectedProduct,
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    autofocus: true,
                                    controller: _productSearchBoxController,
                                  ),
                                  menuProps: MenuProps(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  title: popUp(
                                    context: context,
                                    title:
                                        "Select ${classificationId == 'AppHotel' ? 'room type' : 'product'}",
                                    height: 50,
                                  ),
                                ),
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: classificationId == 'AppHotel'
                                      ? 'Room Type'
                                      : 'Product',
                                ),
                                key: const Key('product'),
                                itemAsString: (Product? u) =>
                                    "${u!.productName}",
                                items: productState.products,
                                filterFn: (user, filter) {
                                  _productBloc.add(ProductFetch(
                                      searchString: filter,
                                      assetClassId:
                                          classificationId == 'AppHotel'
                                              ? 'Hotel Room'
                                              : ''));
                                  return true;
                                },
                                onChanged: (Product? newValue) async {
                                  _selectedProduct = newValue;
                                  _priceController.text =
                                      (newValue!.price ?? newValue.listPrice)
                                          .toString();
                                  _finDocBloc.add(FinDocGetRentalOccupancy(
                                      newValue.productId));
                                  while (!whichDayOk(_selectedDate)) {
                                    _selectedDate = _selectedDate
                                        .add(const Duration(days: 1));
                                  }
                                  setState(() {
                                    _selectedDate = _selectedDate;
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'field required' : null,
                              );
                            default:
                              return const Center(
                                  child: CircularProgressIndicator());
                          }
                        });
                      default:
                        return const Center(child: CircularProgressIndicator());
                    }
                  }),
                  const SizedBox(height: 20),
                  TextFormField(
                    key: const Key('price'),
                    decoration:
                        const InputDecoration(labelText: 'Price/Amount'),
                    controller: _priceController,
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter Price or Amount?';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                        child: Center(
                            child: Text(
                      "${_selectedDate.toLocal()}".split(' ')[0],
                      key: const Key('date'),
                    ))),
                    ElevatedButton(
                      key: const Key('setDate'),
                      onPressed: () => selectDate(context),
                      child: const Text(' Update Begindate'),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                        child: TextFormField(
                      key: const Key('quantity'),
                      decoration:
                          const InputDecoration(labelText: 'Number of days'),
                      controller: _daysController,
                    )),
                    const SizedBox(width: 10),
                    Expanded(
                        child: TextFormField(
                      key: const Key('nbrOfRooms'),
                      decoration:
                          const InputDecoration(labelText: 'Number of rooms'),
                      controller: _quantityController,
                    )),
                  ]),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                        child: ElevatedButton(
                      key: const Key('cancel'),
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )),
                    const SizedBox(width: 20),
                    Expanded(
                        child: ElevatedButton(
                            key: const Key('update'),
                            child: Text(widget.finDoc.orderId == null
                                ? 'Create'
                                : 'Update'),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                FinDoc newFinDoc = widget.finDoc.copyWith(
                                    otherUser: _selectedUser,
                                    otherCompany: _selectedUser?.company);
                                FinDocItem newItem = FinDocItem(
                                    productId: _selectedProduct!.productId,
                                    itemType:
                                        ItemType(itemTypeId: 'ItemRental'),
                                    price: Decimal.parse(_priceController.text),
                                    description: _selectedProduct!.productName,
                                    rentalFromDate: _selectedDate,
                                    rentalThruDate: _selectedDate.add(Duration(
                                        days: int.parse(_daysController.text))),
                                    quantity: _quantityController.text.isEmpty
                                        ? Decimal.parse('1')
                                        : Decimal.parse(
                                            _quantityController.text));
                                if (widget.original?.orderId == null) {
                                  newFinDoc =
                                      newFinDoc.copyWith(items: [newItem]);
                                } else {
                                  List<FinDocItem> newItemList =
                                      List.of(widget.original!.items);
                                  int index = newItemList.indexWhere(
                                      (element) =>
                                          element.itemSeqId ==
                                          newItem.itemSeqId);
                                  newItemList[index] = newItem;
                                  newFinDoc =
                                      newFinDoc.copyWith(items: newItemList);
                                }
                                context
                                    .read<FinDocBloc>()
                                    .add(FinDocUpdate(newFinDoc));
                              }
                            }))
                  ]),
                ]))));
  }
}
