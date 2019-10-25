import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/new_expense_claim_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/widgets/dropdown_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

// TODO: MAKE JUMPING FROM FIELD TO FIELD

class NewExpenseClaimPage extends StatefulWidget {
  NewExpenseClaimPage();

  @override
  _NewExpenseClaimPageState createState() => _NewExpenseClaimPageState();
}

class _NewExpenseClaimPageState extends State<NewExpenseClaimPage> {
  // Bloc
  NewExpenseClaimBloc _expenseClaimBloc;

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    _expenseClaimBloc = Provider.of<NewExpenseClaimBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle;

    switch (_expenseClaimBloc.expenseType) {
      case ExpenseType.EXPENSE_CLAIM:
        appBarTitle = "Expense claim form";
        break;
      case ExpenseType.INVOICE:
        appBarTitle = "Invoice form";
        break;
    }

    return Scaffold(
      key: _scaffoldKey,
      body: _buildBody(),
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: <Widget>[
          FlatButton(
            onPressed: () => _validateAndUpload(),
            child: Text('DONE'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() => Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            _buildDropdown(
              "Country",
              _expenseClaimBloc.selectedCountry,
              countries,
              _expenseClaimBloc.selectCountry,
            ),
            _buildDropdown(
              "Category",
              _expenseClaimBloc.selectedCategory,
              categories,
              _expenseClaimBloc.selectCategory,
            ),
            _expenseClaimBloc.expenseType == ExpenseType.EXPENSE_CLAIM
                ? _buildDateField(
                    "Date of expense",
                    _expenseClaimBloc.expenseDate,
                    _expenseClaimBloc.selectExpenseDate,
                  )
                : Container(height: 0.0, width: 0.0),
            _expenseClaimBloc.expenseType == ExpenseType.INVOICE
                ? _buildDateField(
                    "Date of the invoice",
                    _expenseClaimBloc.invoiceDate,
                    _expenseClaimBloc.selectInvoiceDate,
                  )
                : Container(),
            _expenseClaimBloc.expenseType == ExpenseType.INVOICE
                ? _buildDateField(
                    "Due date for payment",
                    _expenseClaimBloc.invoiceDate,
                    _expenseClaimBloc.selectInvoiceDate,
                  )
                : Container(),
            _buildTextField(
              "Description",
              _descriptionController,
              _descriptionFocusNode,
              validator: _descriptionValidator,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildNumberField(
                    "Gross",
                    _grossController,
                    _grossFocusNode,
                    isRequired: true,
                  ),
                ),
                Expanded(
                  child: _buildDropdown(
                    "Currency",
                    _expenseClaimBloc.selectedCurrency,
                    currencies,
                    _expenseClaimBloc.selectCurrency,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildNumberField(
                    "Net",
                    _netController,
                    _netFocusNode,
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
            _buildDropdown(
              "Aproved by",
              _expenseClaimBloc.selectedApprovedBy,
              approvedBys,
              _expenseClaimBloc.selectApprovedBy,
            ),
            _buildAttachmentsTile(),
          ],
        ),
      );

  Widget _buildDropdown(String label, Stream stream,
          List<DropdownMenuItem<String>> items, Function selectFunction) =>
      Column(
        children: <Widget>[
          _buildFieldLabel(label),
          StreamBuilder<String>(
              stream: stream,
              builder: (context, snapshot) {
                return DropdownFormField(
                  validator: _dropdownValidator,
                  value: snapshot.data,
                  items: items,
                  onChanged: selectFunction,
                );
              }),
        ],
      );

  Widget _buildDateField(
          String label, Stream stream, Function selectFunction) =>
      Column(
        children: <Widget>[
          _buildFieldLabel(label),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder<Object>(
                stream: stream,
                builder: (context, snapshot) {
                  return DateTimeField(
                    initialValue: DateTime.now(),
                    format: DateFormat("yyyy-MM-dd"),
                    onShowPicker: (context, currentValue) async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2015),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: currentValue ?? DateTime.now(),
                      );
                      selectFunction(date);
                      return date;
                    },
                    validator: (date) => date == null ? "Select a date" : null,
                  );
                }),
          ),
        ],
      );

  Widget _buildTextField(
          String label, TextEditingController controller, FocusNode focusNode,
          {String Function(String) validator}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextFormField(
          validator: validator,
          controller: controller,
          autocorrect: true,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: label,
            // TODO: REVIEW FIELD STYLE
          ),
        ),
      );

  Widget _buildNumberField(
          String label, TextEditingController controller, FocusNode focusNode,
          {bool isRequired = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextFormField(
          validator: (number) {
            if (isRequired) {
              if (number == null)
                return "Please enter a number";
              else if (double.tryParse(number) <= 0.0)
                return "Please enter a valid number";
            }
            return null;
          },
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: label,
            // TODO: REVIEW FIELD STYLE
          ),
        ),
      );

  Widget _buildFieldLabel(String label) => Text(
        label, // TODO: REVIEW LABEL STYLE
        style: Theme.of(context).textTheme.subhead,
      );

  Widget _buildAttachmentsTile() => StreamBuilder<Map<String, File>>(
      stream: _expenseClaimBloc.attachments,
      initialData: Map<String, File>(),
      builder: (context, attachmentsSnapshot) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
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

  // Form Validators
  String _dropdownValidator(String value) =>
      value == null ? "Select an option" : null;
  String _descriptionValidator(String description) =>
      description.length < 5 ? "5 characters minimum" : null;

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

List<DropdownMenuItem<String>> categories = ['Transport', 'Food', 'Other']
    .map((categoryName) => DropdownMenuItem(
          child: Text(categoryName),
          value: categoryName,
        ))
    .toList();

List<DropdownMenuItem<String>> currencies = ['USD', 'EUR', 'GBP']
    .map((currency) => DropdownMenuItem(
          child: Text(currency),
          value: currency,
        ))
    .toList();

List<DropdownMenuItem<String>> approvedBys = ['Miguel', 'Sergio', 'Alejandro']
    .map((approvedBy) => DropdownMenuItem(
          child: Text(approvedBy),
          value: approvedBy,
        ))
    .toList();
