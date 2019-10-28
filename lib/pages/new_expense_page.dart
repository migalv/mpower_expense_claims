import 'dart:io';

import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/new_expense_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  TextEditingController _descriptionController;
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
              // _buildDropdown(
              //     "Aproved by",
              //     'Someone',
              //     _expenseClaimBloc.selectedCategory,
              //     categories,
              //     _expenseClaimBloc.selectCategory),
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
                builder: (context, snapshot) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xfff1f1f1),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: snapshot.data,
                          items: countries,
                          onChanged: _expenseClaimBloc.selectCountry,
                          isExpanded: true,
                          hint: Text('Select the country of issue'),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 5.0),
              Text(
                state.hasError ? state.errorText : '',
                style: TextStyle(color: primaryErrorColor, fontSize: 12.0),
              ),
            ],
          ),
        ),
      );

  Widget _buildCategory() => StreamBuilder(
      stream: _expenseClaimBloc.selectedCategory,
      builder: (context, snapshot) {
        return FormField<String>(
          validator: _expenseClaimBloc.categoryValidator,
          builder: (FormFieldState<String> state) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildFieldLabel('Category'),
                Container(
                  height: 48.0,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _buildChipListItems(snapshot?.data)),
                ),
                SizedBox(height: 5.0),
                Text(
                  state.hasError ? state.errorText : '',
                  style: TextStyle(color: primaryErrorColor, fontSize: 12.0),
                ),
              ],
            ),
          ),
        );
      });

  List<Widget> _buildChipListItems(String selectedCategory) {
    List<Widget> list = [
      Container(
        width: 16.0,
      ),
    ];

    list.addAll(categories.map((category) {
      String selected = selectedCategory ?? '';

      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ActionChip(
          label: Text(
            category.label,
            style: Theme.of(context).textTheme.body2.copyWith(
                color:
                    category.label == selected ? Colors.white : Colors.black38),
          ),
          avatar: Icon(
            category.icon,
            size: 16.0,
            color: category.label == selected ? Colors.white : Colors.black26,
          ),
          backgroundColor:
              category.label == selected ? Colors.blue : Color(0xfff1f1f1),
          onPressed: () {
            _expenseClaimBloc.selectCategory(category.label);
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
              SizedBox(height: 5.0),
              Text(
                state.hasError ? state.errorText : '',
                style: TextStyle(color: primaryErrorColor, fontSize: 12.0),
              ),
            ],
          ),
        ),
      );

  Widget _buildDescription() => FormField(validator: (String description) {
        if (description == null)
          return "Description must be at least 5 characters long";
        if (description.length < 5)
          return "Description must be at least 5 characters long";
        return null;
      }, builder: (FormFieldState state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              SizedBox(height: 5.0),
              Text(
                state.hasError ? state.errorText : '',
                style: TextStyle(color: primaryErrorColor, fontSize: 12.0),
              ),
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
                builder: (context, snapshot) {
                  String selected = snapshot.data ?? 'Euro';

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
                                suffixIcon: Icon(
                                  selected == 'Euro'
                                      ? FontAwesomeIcons.euroSign
                                      : selected == 'Dolar'
                                          ? FontAwesomeIcons.dollarSign
                                          : FontAwesomeIcons.dollarSign,
                                  size: 16.0,
                                  color: Colors.black38,
                                ),
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
                                      suffixIcon: Icon(
                                        selected == 'Euro'
                                            ? FontAwesomeIcons.euroSign
                                            : selected == 'Dolar'
                                                ? FontAwesomeIcons.dollarSign
                                                : FontAwesomeIcons.dollarSign,
                                        size: 16.0,
                                        color: Colors.black38,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  state.hasError ? state.errorText : '',
                                  style: TextStyle(
                                      color: primaryErrorColor, fontSize: 12.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 16.0,
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: snapshot?.data ?? 'Euro',
                              items: currencies,
                              onChanged: _expenseClaimBloc.selectCurrency,
                              isExpanded: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        ),
      );

  Widget _buildFieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
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
                SizedBox(height: 5.0),
                Text(
                  state.hasError ? state.errorText : '',
                  style: TextStyle(color: primaryErrorColor, fontSize: 12.0),
                ),
                _expenseClaimBloc.multipleAttachments
                    ? _buildButton(
                        'ADD ATTACHMENTS', () => _selectAttachments())
                    : Container(),
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

List<DropdownMenuItem<String>> countries =
    ['Spain', 'Switzerland', 'Zambia', 'Togo', 'Cameroon', 'China', 'Other']
        .map((countryName) => DropdownMenuItem(
              child: Text(countryName),
              value: countryName,
            ))
        .toList();
List<ExpenseCategory> categories = [
  ExpenseCategory(icon: Icons.directions_car, label: 'Transport'),
  ExpenseCategory(icon: Icons.fastfood, label: 'Food'),
  ExpenseCategory(icon: Icons.attach_money, label: 'Other'),
];
List<DropdownMenuItem<String>> currencies = ['Euro', 'Dollars']
    .map((currency) => DropdownMenuItem(
          child: Text(currency),
          value: currency,
        ))
    .toList();

class ExpenseCategory {
  final IconData icon;
  final String label;

  ExpenseCategory({@required this.icon, @required this.label});
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
