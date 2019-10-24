import 'dart:io';

import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/new_expense_claim_bloc.dart';
import 'package:expense_claims_app/widgets/dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  TextEditingController _grossController = TextEditingController();
  TextEditingController _netController = TextEditingController();

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
      ),
    );
  }

  Widget _buildBody() => Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            _buildDropdown("Country", _expenseClaimBloc.selectedCountry,
                countries, _expenseClaimBloc.selectCountry),
            _buildDropdown("Category", _expenseClaimBloc.selectedCategory,
                categories, _expenseClaimBloc.selectCategory),
            _expenseClaimBloc.expenseType == ExpenseType.EXPENSE_CLAIM
                ? _buildDateField(
                    "Date of expense",
                    _expenseClaimBloc.expenseDate,
                    _expenseClaimBloc.selectExpenseDate)
                : Container(height: 0.0, width: 0.0),
            _expenseClaimBloc.expenseType == ExpenseType.INVOICE
                ? _buildDateField(
                    "Date of the invoice",
                    _expenseClaimBloc.invoiceDate,
                    _expenseClaimBloc.selectInvoiceDate)
                : Container(),
            _expenseClaimBloc.expenseType == ExpenseType.INVOICE
                ? _buildDateField(
                    "Due date for payment",
                    _expenseClaimBloc.invoiceDate,
                    _expenseClaimBloc.selectInvoiceDate)
                : Container(),
            _buildTextField(
                "Description", _descriptionController, _descriptionFocusNode),
            Row(
              children: <Widget>[
                Expanded(
                    child: _buildNumberField(
                        "Gross", _grossController, _grossFocusNode)),
                Expanded(
                    child: _buildDropdown(
                        "Currency",
                        _expenseClaimBloc.selectedCategory,
                        categories,
                        _expenseClaimBloc.selectCategory)),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child:
                        _buildTextField("Net", _netController, _netFocusNode)),
                Expanded(child: Container()),
              ],
            ),
            _buildDropdown("Aproved by", _expenseClaimBloc.selectedCategory,
                categories, _expenseClaimBloc.selectCategory),
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
                return DropdownField<String>(
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
            child: Container(),
            // DateTimeField(
            //   format: DateFormat("yyyy-MM-dd"),
            //   initialValue: DateTime.now(),
            //   onShowPicker: (context, currentValue) async {
            //     final date = await showDatePicker(
            //       context: context,
            //       firstDate: DateTime(2015),
            //       initialDate: currentValue ?? DateTime.now(),
            //       lastDate: currentValue ?? DateTime.now(),
            //     );
            //     selectFunction(date);
            //     return date;
            //   },
            // ),
          ),
        ],
      );

  Widget _buildTextField(String label, TextEditingController controller,
          FocusNode focusNode) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextFormField(
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

  Widget _buildNumberField(String label, TextEditingController controller,
          FocusNode focusNode) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly,
          ],
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
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              _buildAttachmentList(snapshot.data, _expenseClaimBloc, context),
              _expenseClaimBloc.multipleAttachments
                  ? _buildButton('ADD ATTACHMENTS',
                      () => _selectAttachments(context, _expenseClaimBloc))
                  : Container(),
            ],
          ),
        );
      });

  Widget _buildAttachmentList(Map<String, File> attachments,
      NewExpenseClaimBloc claimExpenseBloc, BuildContext context) {
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
              _selectAttachments(context, claimExpenseBloc, name: name);
            else
              claimExpenseBloc.removeAttachment(name);
          },
        ),
      ));
    });

    return Column(
      children: list,
    );
  }

  void _selectAttachments(
      BuildContext context, NewExpenseClaimBloc newOrderBloc,
      {String name}) async {
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
                newOrderBloc.addAttachment(name, attachment);
            },
          ),
          ListTile(
            title: Text('Storage'),
            leading: Icon(Icons.photo_library),
            onTap: () async {
              Navigator.pop(context);
              // File attachment =
              //     await ImagePicker.pickImage(source: ImageSource.gallery);
              // if (attachment != null)
              //   newOrderBloc.addAttachment(name, attachment);
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
    // PermissionStatus permissionStatus =
    //     await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    // if (permissionStatus != PermissionStatus.granted)
    //   await PermissionHandler().requestPermissions([PermissionGroup.camera]);

    try {
      // return await ImagePicker.pickImage(source: ImageSource.camera);
    } on PlatformException catch (_) {
      return null;
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
