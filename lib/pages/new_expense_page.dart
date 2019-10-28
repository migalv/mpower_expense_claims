import 'dart:io';

import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/new_expense_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/country_model.dart';
import 'package:expense_claims_app/models/currency_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/user_model.dart';
import 'package:expense_claims_app/respository.dart';
import 'package:expense_claims_app/widgets/dropdown_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

// TODO: MAKE JUMPING FROM FIELD TO FIELD

class NewExpensePage extends StatefulWidget {
  NewExpensePage();

  @override
  _NewExpensePageState createState() => _NewExpensePageState();
}

class _NewExpensePageState extends State<NewExpensePage> {
  // Bloc
  NewExpenseBloc _expenseClaimBloc;

  // Text Controllers
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _grossController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  TextEditingController _netController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

  // Focus Nodes
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _grossFocusNode = FocusNode();
  FocusNode _netFocusNode = FocusNode();

  // Keys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _grossController.clear();
    _netController.clear();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _expenseClaimBloc = Provider.of<NewExpenseBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() => Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 2 / 3),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            new BoxShadow(
              color: Colors.black12,
              offset: new Offset(0, -2),
              blurRadius: 2.0,
            )
          ],
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              _buildTitle(),
              _buildCountry(),
              _buildCategory(),
              _expenseClaimBloc.expenseType == ExpenseType.EXPENSE_CLAIM
                  ? _buildDate("Date", _expenseClaimBloc.expenseDate,
                      _expenseClaimBloc.selectExpenseDate)
                  : Container(height: 0.0, width: 0.0),
              _expenseClaimBloc.expenseType == ExpenseType.INVOICE
                  ? _buildDate("Date", _expenseClaimBloc.invoiceDate,
                      _expenseClaimBloc.selectInvoiceDate)
                  : Container(),
              _expenseClaimBloc.expenseType == ExpenseType.INVOICE
                  ? _buildDate("Due date", _expenseClaimBloc.invoiceDate,
                      _expenseClaimBloc.selectInvoiceDate)
                  : Container(),
              _buildDescription(),
              _buildCost(),
              _buildApproverTile(),
              _buildAttachmentsTile(),
              _buildDoneButton(),
            ],
          ),
        ),
      );

  Widget _buildTitle() => Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 0.0, top: 16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'New expense',
                style: Theme.of(context).textTheme.title,
              ),
            ),
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );

  Widget _buildCountry() => FormField(
        validator: _expenseClaimBloc.countryValidator,
        builder: (FormFieldState state) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildFieldLabel('Country'),
              StreamBuilder<String>(
                stream: _expenseClaimBloc.selectedCountry,
                builder: (context, selectedCountrySnapshot) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xfff1f1f1),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButtonHideUnderline(
                        child: StreamBuilder<List<Country>>(
                            stream: repository.countries,
                            initialData: <Country>[],
                            builder: (context, countriesSnapshot) {
                              return DropdownButton<String>(
                                value: selectedCountrySnapshot.data,
                                items: countriesSnapshot.data
                                    .where((country) => country.hidden == false)
                                    .map((country) => DropdownMenuItem(
                                          child: Text(country.name),
                                          value: country.id,
                                        ))
                                    .toList(),
                                onChanged: _expenseClaimBloc.selectCountry,
                                isExpanded: true,
                                hint: Text('Select the country of issue'),
                              );
                            }),
                      ),
                    ),
                  );
                },
              ),
              _buildErrorFormLabel(state),
            ],
          ),
        ),
      );

  Widget _buildCategory() => StreamBuilder(
      stream: _expenseClaimBloc.selectedCategory,
      builder: (context, selectedCategorySnapshot) {
        return FormField<String>(
          validator: _expenseClaimBloc.categoryValidator,
          builder: (FormFieldState<String> state) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildFieldLabel('Category'),
                StreamBuilder(
                    stream: repository.categories,
                    initialData: <Category>[],
                    builder: (context, categoriesSnapshot) {
                      return Container(
                        height: 48.0,
                        child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _buildChipListItems(
                                selectedCategorySnapshot?.data,
                                categoriesSnapshot?.data ?? [])),
                      );
                    }),
                _buildErrorFormLabel(state),
              ],
            ),
          ),
        );
      });

  List<Widget> _buildChipListItems(
      String selectedCategory, List<Category> categories) {
    List<Widget> list = [
      Container(
        width: 16.0,
      ),
    ];

    list.addAll(categories
        .where((category) => category.hidden == false)
        .map((category) {
      String selected = selectedCategory ?? '';

      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ActionChip(
          label: Text(
            category.name,
            style: Theme.of(context).textTheme.body2.copyWith(
                color: category.id == selected ? Colors.white : Colors.black38),
          ),
          avatar: category.icon != null
              ? Icon(
                  category.icon,
                  size: 16.0,
                  color:
                      category.id == selected ? Colors.white : Colors.black26,
                )
              : null,
          backgroundColor:
              category.id == selected ? Colors.blue : Color(0xfff1f1f1),
          onPressed: () {
            _expenseClaimBloc.selectCategory(category.id);
          },
        ),
      );
    }).toList());

    return list;
  }

  Widget _buildDate(String label, ValueObservable<DateTime> stream,
          Function selectFunction) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FormField(
          validator: (date) => _expenseClaimBloc.dateValidator(stream),
          builder: (FormFieldState state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildFieldLabel(label),
              GestureDetector(
                onTap: () async {
                  DateTime selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  selectFunction(selectedDate);
                },
                child: StreamBuilder<DateTime>(
                    stream: stream,
                    builder: (context, dateSnapshot) {
                      return Container(
                        height: 48.0,
                        decoration: BoxDecoration(
                          color: Color(0xfff1f1f1),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                dateSnapshot?.data != null
                                    ? DateFormat('EEE d MMM, yyyy')
                                        .format(dateSnapshot?.data)
                                    : "Select a date",
                                style: dateSnapshot?.data == null
                                    ? Theme.of(context)
                                        .textTheme
                                        .subhead
                                        .copyWith(color: Colors.black54)
                                    : Theme.of(context).textTheme.subhead,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: Colors.black38,
                              size: 20.0,
                            )
                          ],
                        ),
                      );
                    }),
              ),
              _buildErrorFormLabel(state),
            ],
          ),
        ),
      );

  Widget _buildDescription() => FormField(validator: (String description) {
        if (description == null || ((description?.length ?? 0) < 5))
          return "Description must be at least 5 characters long";
        return null;
      }, builder: (FormFieldState state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Color(0xfff1f1f1),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 120.0),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      child: TextFormField(
                        controller: _descriptionController,
                        maxLines: null,
                        autocorrect: true,
                        focusNode: _descriptionFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Enter a description of the expense...',
                          border: InputBorder.none,
                        ),
                        onChanged: (descr) => state.didChange(descr),
                      ),
                    ),
                  ),
                ),
              ),
              _buildErrorFormLabel(state),
            ],
          ),
        );
      });

  Widget _buildCost() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildFieldLabel('Cost'),
            StreamBuilder<String>(
                stream: _expenseClaimBloc.selectedCurrency,
                builder: (context, selectedCurrencySnapshot) {
                  String selected = selectedCurrencySnapshot?.data;

                  return Container(
                    height: 72.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: Color(0xfff1f1f1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            child: TextFormField(
                              controller: _netController,
                              focusNode: _netFocusNode,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: 'Net',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 16.0,
                        ),
                        Expanded(
                          child: FormField(
                            validator: (value) => value == null || value == ""
                                ? "Enter an amount"
                                : null,
                            builder: (FormFieldState state) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xfff1f1f1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: TextFormField(
                                    controller: _grossController,
                                    focusNode: _grossFocusNode,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      WhitelistingTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      hintText: 'Gross',
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) =>
                                        state.didChange(value),
                                  ),
                                ),
                                _buildErrorFormLabel(state),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 16.0,
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: StreamBuilder<List<Currency>>(
                                stream: repository.currencies,
                                initialData: <Currency>[],
                                builder: (context, currenciesSnapshot) {
                                  return DropdownButton<String>(
                                    hint: Text("Currency"),
                                    value: selectedCurrencySnapshot?.data,
                                    items: currenciesSnapshot.data
                                        .where(
                                          (currency) =>
                                              currency.hidden == false,
                                        )
                                        .map(
                                          (currency) => DropdownMenuItem(
                                            child: Text(currency.iso),
                                            value: currency.id,
                                          ),
                                        )
                                        .toList(),
                                    onChanged: _expenseClaimBloc.selectCurrency,
                                    isExpanded: true,
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        ),
      );

  Widget _buildApproverTile() => StreamBuilder(
        stream: repository.approvers,
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) =>
            (snapshot?.data?.isEmpty ?? false)
                ? Text("You don't have any approvers")
                : DropdownButtonHideUnderline(
                    child: StreamBuilder<User>(
                      stream: _expenseClaimBloc.selectedApprover,
                      builder: (context, snapshot) {
                        return DropdownButton<User>(
                          hint: Text("Select who will approve your Expense"),
                          value: snapshot?.data,
                          items: repository.approvers.value
                              .map(
                                (User user) => DropdownMenuItem(
                                  child: Text(user.name),
                                  value: user,
                                ),
                              )
                              .toList(),
                          onChanged: _expenseClaimBloc.selectApprover,
                          isExpanded: true,
                        );
                      },
                    ),
                  ),
      );

  Widget _buildFieldLabel(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          label,
          style: Theme.of(context).textTheme.subtitle,
        ),
      );

  Widget _buildAttachmentsTile() => StreamBuilder<Map<String, File>>(
      stream: _expenseClaimBloc.attachments,
      initialData: Map<String, File>(),
      builder: (context, attachmentsSnapshot) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FormField(
            validator: (_) => _expenseClaimBloc.attachmentsValidator(),
            builder: (FormFieldState state) => Column(
              children: <Widget>[
                _buildAttachmentList(attachmentsSnapshot.data),
                _buildErrorFormLabel(state),
                _expenseClaimBloc.multipleAttachments
                    ? _buildButton(
                        'ADD ATTACHMENTS', () => _selectAttachments())
                    : Container(),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        );
      });

  Widget _buildAttachmentList(Map<String, File> attachments) {
    List<Widget> list = [Container(height: 4.0)];

    attachments.forEach((String name, File attachment) {
      list.add(ListTile(
        contentPadding: EdgeInsets.all(0.0),
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: attachment == null
                ? Icon(
                    MdiIcons.tag,
                    color: Colors.black26,
                  )
                : Container(
                    height: 40.0, width: 48.0, child: Image.file(attachment))),
        title: Text(
          name,
          style: Theme.of(context).textTheme.body1,
        ),
        trailing: IconButton(
          icon: Icon(attachment == null ? MdiIcons.imagePlus : Icons.delete),
          onPressed: () {
            if (attachment == null)
              _selectAttachments(name: name);
            else
              _expenseClaimBloc.removeAttachment(name);
          },
        ),
      ));
    });

    return Column(
      children: list,
    );
  }

  Widget _buildButton(String label, Function onPressed) => Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            OutlineButton(
                padding: EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 12.0),
                borderSide: BorderSide(width: 0.5, color: Color(0xFFCCCCCC)),
                highlightColor: Colors.grey.withAlpha(10),
                splashColor: Color(0xFFEEEEEE),
                child: Text(label),
                onPressed: () => onPressed()),
          ],
        ),
      );

  Widget _buildDoneButton() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: FlatButton(
          padding: EdgeInsets.all(14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: Colors.blue,
          child: Text(
            'Done',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () => _validateAndUpload(),
        ),
      );

  Widget _buildErrorFormLabel(FormFieldState state) => state.hasError
      ? Column(
          children: <Widget>[
            SizedBox(height: 5.0),
            Text(
              state.errorText,
              style: TextStyle(color: primaryErrorColor, fontSize: 12.0),
            ),
          ],
        )
      : Container();

  void _selectAttachments({String name}) async {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                child: Text(
                  'Select source',
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                ),
              ),
            ],
          ),
          ListTile(
            title: Text('Camera'),
            leading: Icon(Icons.camera_alt),
            onTap: () async {
              Navigator.pop(context);
              File attachment = await pickImageFromCamera();
              if (attachment != null)
                _expenseClaimBloc.addAttachment(name, attachment);
            },
          ),
          ListTile(
            title: Text('Storage'),
            leading: Icon(Icons.photo_library),
            onTap: () async {
              Navigator.pop(context);
              File attachment =
                  await ImagePicker.pickImage(source: ImageSource.gallery);
              if (attachment != null)
                _expenseClaimBloc.addAttachment(name, attachment);
            },
          ),
        ],
      ),
    );
  }

  Future<File> pickImageFromCamera() async {
    PermissionStatus permissionStatus =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    if (permissionStatus != PermissionStatus.granted)
      await PermissionHandler().requestPermissions([PermissionGroup.camera]);

    try {
      return await ImagePicker.pickImage(source: ImageSource.camera);
    } on PlatformException catch (_) {
      return null;
    }
  }

  void _validateAndUpload() {
    if (_formKey.currentState.validate()) {
      _expenseClaimBloc.uploadNewExpenseClaim(
        _descriptionController.text,
        _grossController.text,
        stringNet: _netController.text,
      );
      Navigator.pop(context);
    }
  }
}

// [
// Container(
//   width: 16.0,
// ),
// Chip(
//   label: Text(
//     'Transport',
//     style: Theme.of(context)
//         .textTheme
//         .body2
//         .copyWith(color: Colors.white),
//   ),
//   avatar: Icon(
//     Icons.directions_car,
//     size: 16.0,
//     color: Colors.white,
//   ),
//   backgroundColor: Colors.blue,
// ),
//                   Container(
//                     width: 16.0,
//                   ),
//                   Chip(
//                     backgroundColor: Color(0xfff1f1f1),
//                     label: Text(
//                       'Food',
//                       style: Theme.of(context).textTheme.body2.copyWith(
//                             color: Colors.black38,
//                             fontWeight: FontWeight.normal,
//                           ),
//                     ),
//                     avatar: Icon(
//                       Icons.fastfood,
//                       size: 16.0,
//                       color: Colors.black26,
//                     ),
//                   ),
//                   Container(
//                     width: 16.0,
//                   ),
//                   Chip(
//                     backgroundColor: Color(0xfff1f1f1),
//                     label: Text(
//                       'Other',
//                       style: Theme.of(context).textTheme.body2.copyWith(
//                             color: Colors.black38,
//                             fontWeight: FontWeight.normal,
//                           ),
//                     ),
//                     avatar: Icon(
//                       Icons.attach_money,
//                       size: 16.0,
//                       color: Colors.black26,
//                     ),
//                   ),
//                   Container(
//                     width: 16.0,
//                   ),
//                 ],
