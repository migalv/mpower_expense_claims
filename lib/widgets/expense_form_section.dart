import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expense_form_section_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/country_model.dart';
import 'package:expense_claims_app/models/currency_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/user_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class ExpenseFormSection extends StatefulWidget {
  final ScrollController _scrollController;
  final Function _onBackPressed;

  ExpenseFormSection({
    @required ScrollController scrollController,
    @required Function onBackPressed,
  })  : _scrollController = scrollController,
        _onBackPressed = onBackPressed;

  @override
  _ExpenseFormSectionState createState() => _ExpenseFormSectionState();
}

class _ExpenseFormSectionState extends State<ExpenseFormSection> {
  // Bloc
  ExpenseFormSectionBloc _expenseClaimBloc;

  // Text Controllers
  final _descriptionController = TextEditingController();
  final _grossController =
      MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.');

  // Keys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    _expenseClaimBloc = Provider.of<ExpenseFormSectionBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: _buildBody());

  Widget _buildBody() => Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(8.0, 24.0, 8.0, 24.0),
          shrinkWrap: true,
          controller: widget._scrollController,
          children: <Widget>[
            _buildTitle(),
            _buildCountry(),
            _buildCategory(),
            _buildDate("Date", _expenseClaimBloc.expenseDate,
                _expenseClaimBloc.selectExpenseDate),
            _expenseClaimBloc.expenseType == ExpenseType.INVOICE
                ? _buildDate("Due date", _expenseClaimBloc.selectedDueDate,
                    _expenseClaimBloc.selectDueDate,
                    lastDate: DateTime(2030))
                : Container(),
            _buildDescription(),
            _buildCost(),
            _buildApproverTile(),
            _buildAttachmentsTile(),
            _buildButtons(),
          ],
        ),
      );

  Widget _buildTitle() => Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
          children: <Widget>[
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0),
                child: Icon(
                  FontAwesomeIcons.chevronLeft,
                  size: 20.0,
                ),
              ),
              onTap: widget._onBackPressed,
            ),
            Text(
              'New ' +
                  (_expenseClaimBloc.expenseType == ExpenseType.EXPENSE_CLAIM
                      ? "expense claim"
                      : "invoice"),
              style: Theme.of(context).textTheme.title,
            ),
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
              StreamBuilder<Country>(
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
                              return DropdownButton<Country>(
                                value: selectedCountrySnapshot.data,
                                items: countriesSnapshot.data
                                    .where((country) => country.hidden == false)
                                    .map((country) => DropdownMenuItem<Country>(
                                          child: Text(country.name),
                                          value: country,
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
              category.id == selected ? secondaryColor : Color(0xfff1f1f1),
          onPressed: () {
            _expenseClaimBloc.selectCategory(category.id);
          },
          pressElevation: 4.0,
          tooltip: category.eg ?? "",
        ),
      );
    }).toList());

    return list;
  }

  Widget _buildDate(String label, ValueObservable<DateTime> stream,
          Function selectFunction,
          {DateTime lastDate}) =>
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
                    lastDate: lastDate ?? DateTime.now(),
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

  Widget _buildDescription() => Container(
        margin: EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 24.0),
        constraints: BoxConstraints(maxHeight: 120.0),
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            reverse: true,
            child: TextFormField(
              controller: _descriptionController,
              maxLines: null,
              autocorrect: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                hintText: 'Enter a description of the expense...',
              ),
              validator: (String description) {
                if (description == null || ((description?.length ?? 0) < 5))
                  return "Description must be at least 5 characters long";
                return null;
              },
            ),
          ),
        ),
      );

  Widget _buildCost() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildFieldLabel('Cost'),
            StreamBuilder<String>(
              stream: _expenseClaimBloc.selectedCurrency,
              builder: (context, selectedCurrencySnapshot) => Container(
                height: 72.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _grossController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          hintText: 'Gross',
                        ),
                        validator: (value) => value == null || value == ""
                            ? "Enter an amount"
                            : null,
                      ),
                    ),
                    Container(
                      width: 16.0,
                    ),
                    Expanded(
                      child: FormField(
                        validator: _expenseClaimBloc.vatValidator,
                        builder: (FormFieldState state) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            DropdownButtonHideUnderline(
                              child: StreamBuilder<Country>(
                                  stream: _expenseClaimBloc.selectedCountry,
                                  builder: (context, selectedCountrySnapshot) {
                                    return StreamBuilder<Object>(
                                        stream: _expenseClaimBloc.selectedVat,
                                        builder:
                                            (context, selectedVatSnapshot) {
                                          return DropdownButton<double>(
                                            hint: Text("VAT"),
                                            value: selectedVatSnapshot?.data,
                                            items: selectedCountrySnapshot
                                                    ?.data?.vatOptions
                                                    ?.map(
                                                      (vat) => DropdownMenuItem(
                                                        child: Text(
                                                            vat.toString() +
                                                                "%"),
                                                        value: vat,
                                                      ),
                                                    )
                                                    ?.toList() ??
                                                [],
                                            onChanged:
                                                _expenseClaimBloc.selectVat,
                                            isExpanded: true,
                                          );
                                        });
                                  }),
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
                      child: FormField(
                        validator: _expenseClaimBloc.currencyValidator,
                        builder: (FormFieldState state) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            DropdownButtonHideUnderline(
                              child: StreamBuilder<List<Currency>>(
                                  stream: repository.currencies,
                                  initialData: <Currency>[],
                                  builder: (context, currenciesSnapshot) {
                                    return DropdownButton<String>(
                                      hint: Text("Currency"),
                                      value: selectedCurrencySnapshot?.data,
                                      items: currenciesSnapshot.data
                                          .where((currency) =>
                                              currency.hidden == false)
                                          .map(
                                            (currency) => DropdownMenuItem(
                                              child: Text(currency.iso),
                                              value: currency.id,
                                            ),
                                          )
                                          .toList(),
                                      onChanged:
                                          _expenseClaimBloc.selectCurrency,
                                      isExpanded: true,
                                    );
                                  }),
                            ),
                            _buildErrorFormLabel(state),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildApproverTile() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FormField(
          validator: _expenseClaimBloc.approvedByValidator,
          builder: (FormFieldState state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildFieldLabel("Approver"),
              StreamBuilder(
                stream: repository.approvers,
                initialData: <User>[],
                builder: (BuildContext context,
                        AsyncSnapshot<List<User>> itemsSnapshot) =>
                    DropdownButtonHideUnderline(
                  child: StreamBuilder<String>(
                    stream: _expenseClaimBloc.selectedApprover,
                    builder: (context, selectedApproverSnapshot) =>
                        DropdownButton<String>(
                      hint: Text("Select who will approve your Expense"),
                      value: selectedApproverSnapshot?.data,
                      items: itemsSnapshot.data
                          .map((User user) => DropdownMenuItem(
                              child: Text(user.name), value: user.id))
                          .toList(),
                      onChanged: _expenseClaimBloc.selectApprover,
                      isExpanded: true,
                    ),
                  ),
                ),
              ),
              _buildErrorFormLabel(state),
            ],
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

  Widget _buildButtons() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                padding: EdgeInsets.all(14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: secondaryLightColor,
                child: Text(
                  'Create Template',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () => _validateAndUpload(),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: FlatButton(
                padding: EdgeInsets.all(14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: secondaryLightColor,
                child: Text(
                  'Create ' +
                      (_expenseClaimBloc.expenseType ==
                              ExpenseType.EXPENSE_CLAIM
                          ? "Expense"
                          : "Invoice"),
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                onPressed: () => _validateAndUpload(),
              ),
            ),
          ],
        ),
      );

  Widget _buildErrorFormLabel(FormFieldState state) => state.hasError
      ? Column(
          children: <Widget>[
            SizedBox(height: 5.0),
            AutoSizeText(
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
      _expenseClaimBloc.uploadNewExpense(
        _descriptionController.text,
        _grossController.text,
      );
      Navigator.pop(context);
    }
  }
}
