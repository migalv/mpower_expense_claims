import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expense_form_section_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/cost_center_groups_model.dart';
import 'package:expense_claims_app/models/country_model.dart';
import 'package:expense_claims_app/models/currency_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/user_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:expense_claims_app/widgets/custom_form_field.dart';
import 'package:expense_claims_app/widgets/error_form_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class ExpenseFormSection extends StatefulWidget {
  final ScrollController _scrollController;
  final Function _onBackPressed, _onDonePressed;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  ExpenseFormSection({
    @required ScrollController scrollController,
    @required Function onBackPressed,
    @required Function onDonePressed,
    @required GlobalKey<ScaffoldState> scaffoldKey,
  })  : _scrollController = scrollController,
        _onBackPressed = onBackPressed,
        _onDonePressed = onDonePressed,
        _scaffoldKey = scaffoldKey;

  @override
  _ExpenseFormSectionState createState() => _ExpenseFormSectionState();
}

class _ExpenseFormSectionState extends State<ExpenseFormSection> {
  // Bloc
  ExpenseFormSectionBloc _expenseClaimBloc;

  // Keys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _templateFormKey = GlobalKey<FormState>();

  @override
  void didChangeDependencies() {
    _expenseClaimBloc = Provider.of<ExpenseFormSectionBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => Form(
        key: _formKey,
        child: StreamBuilder<int>(
            initialData: 0,
            stream: _expenseClaimBloc.expenseTypeStream,
            builder: (context, snapshot) {
              if (snapshot.data == null) return Container();

              ExpenseType expenseType = ExpenseType.values[snapshot.data];

              return SingleChildScrollView(
                controller: widget._scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    children: <Widget>[
                      _buildTitle(expenseType),
                      _buildCountry(),
                      _buildTemplateNameField(),
                      _buildCategory(),
                      _buildDescription(),
                      _expenseClaimBloc.editingTemplate
                          ? Container()
                          : _buildDate("Date", _expenseClaimBloc.expenseDate,
                              _expenseClaimBloc.selectExpenseDate),
                      expenseType == ExpenseType.EXPENSE_CLAIM
                          ? Container()
                          : _expenseClaimBloc.editingTemplate
                              ? Container()
                              : _buildDate(
                                  "Due date",
                                  _expenseClaimBloc.selectedDueDate,
                                  _expenseClaimBloc.selectDueDate,
                                  lastDate: DateTime(2030)),
                      _buildCost(),
                      _buildCostCenterTile(),
                      _expenseClaimBloc.editingTemplate
                          ? Container()
                          : _buildreceiptNumberField(),
                      _buildApproverTile(),
                      _expenseClaimBloc.editingTemplate
                          ? Container(
                              height: 16,
                            )
                          : _buildAttachmentsTile(),
                      _buildButtons(expenseType),
                    ],
                  ),
                ),
              );
            }),
      );

  Widget _buildTitle(ExpenseType expenseType) {
    String title = "";
    if (_expenseClaimBloc.editingTemplate)
      title = "Edit template";
    else {
      switch (expenseType) {
        case ExpenseType.EXPENSE_CLAIM:
          title = "New expense claim";
          break;
        case ExpenseType.INVOICE:
          title = "New invoice";
          break;
      }
    }

    return Container(
      height: 56,
      alignment: Alignment.topCenter,
      child: Row(
        children: <Widget>[
          IconButton(
            padding: EdgeInsets.only(left: 16),
            icon: Icon(FontAwesomeIcons.arrowLeft),
            iconSize: 16.0,
            onPressed: widget._onBackPressed,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.title,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateNameField() => _expenseClaimBloc.editingTemplate
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildFieldLabel("Template name"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextFormField(
                controller: _expenseClaimBloc.templateNameController,
                maxLines: 1,
                autocorrect: true,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter the name of the template',
                ),
              ),
            ),
          ],
        )
      : Container();

  Widget _buildCountry() => StreamBuilder<Country>(
        stream: _expenseClaimBloc.selectedCountry,
        builder: (context, selectedCountrySnapshot) => FormField(
          validator: _expenseClaimBloc.countryValidator,
          builder: (FormFieldState state) => Container(
            margin: EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: CustomFormField(
              child: DropdownButtonHideUnderline(
                child: StreamBuilder<List<Country>>(
                  stream: repository.countries,
                  initialData: <Country>[],
                  builder: (context, countriesSnapshot) =>
                      DropdownButton<Country>(
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
                  ),
                ),
              ),
              state: state,
            ),
          ),
        ),
      );

  Widget _buildCategory() => StreamBuilder(
        stream: _expenseClaimBloc.selectedCategory,
        builder: (context, selectedCategorySnapshot) => FormField<String>(
          validator: _expenseClaimBloc.categoryValidator,
          builder: (FormFieldState<String> state) => Column(
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
              ErrorFormLabel(state),
            ],
          ),
        ),
      );

  List<Widget> _buildChipListItems(
      String selectedCategory, List<Category> categories) {
    List<Widget> list = [
      Container(
        width: 24.0,
      ),
    ];

    list.addAll(categories
        .where((category) => category.hidden == false)
        .map((category) {
      bool selected = category.id == (selectedCategory ?? '');

      return Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: ActionChip(
          label: Text(
            category.name,
            style: Theme.of(context).textTheme.body2.copyWith(
                color: selected ? Colors.black54 : Colors.white,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal),
          ),
          avatar: category.icon != null
              ? Icon(
                  category.icon,
                  size: 14.0,
                  color: selected ? Colors.black38 : Colors.white54,
                )
              : null,
          backgroundColor: selected ? secondaryColor : formFieldBackgroundColor,
          onPressed: () {
            _expenseClaimBloc.selectCategory(category.id);
          },
          pressElevation: 4.0,
          tooltip: category.eg ?? "",
        ),
      );
    }).toList());

    list.add(Container(
      width: 12.0,
    ));

    return list;
  }

  Widget _buildDate(String label, ValueObservable<DateTime> stream,
          Function selectFunction,
          {DateTime lastDate}) =>
      FormField(
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
                builder: (context, dateSnapshot) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 12),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: CustomFormField(
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
                                    .copyWith(color: Colors.white54)
                                : Theme.of(context).textTheme.subhead,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white54,
                          size: 20.0,
                        )
                      ],
                    ),
                    state: state,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildDescription() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildFieldLabel("Description"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,
                child: TextFormField(
                  controller: _expenseClaimBloc.descriptionController,
                  maxLines: null,
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Enter a description of the expense...',
                  ),
                  validator: (String description) =>
                      description == null || ((description?.length ?? 0) < 5)
                          ? "Description must be at least 5 characters long"
                          : null,
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildCost() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildFieldLabel('Cost'),
          StreamBuilder<String>(
            stream: _expenseClaimBloc.selectedCurrency,
            builder: (context, selectedCurrencySnapshot) => Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _expenseClaimBloc.editingTemplate
                      ? Container()
                      : Expanded(
                          child: TextFormField(
                            controller: _expenseClaimBloc.grossController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Gross',
                              errorMaxLines: 2,
                            ),
                            validator: (value) =>
                                value == null || value == "" || value == '0,00'
                                    ? "Invalid amount"
                                    : null,
                          ),
                        ),
                  _expenseClaimBloc.editingTemplate
                      ? Container()
                      : Container(
                          width: 16.0,
                        ),
                  Expanded(
                    child: FormField(
                      validator: _expenseClaimBloc.vatValidator,
                      builder: (FormFieldState state) =>
                          DropdownButtonHideUnderline(
                        child: StreamBuilder<Country>(
                          stream: _expenseClaimBloc.selectedCountry,
                          builder: (context, selectedCountrySnapshot) =>
                              StreamBuilder(
                                  stream: _expenseClaimBloc.selectedVat,
                                  builder: (context, selectedVatSnapshot) {
                                    List<DropdownMenuItem<double>> items = [
                                      DropdownMenuItem(
                                        child: AutoSizeText(
                                          "No Receipt",
                                          maxLines: 2,
                                        ),
                                        value: -1.0,
                                      ),
                                    ];
                                    if (selectedCountrySnapshot.hasData)
                                      items.addAll(selectedCountrySnapshot
                                          .data.vatOptions
                                          .map(
                                        (vat) => DropdownMenuItem(
                                          child: AutoSizeText(
                                            vat == 0.0
                                                ? "0% or No VAT"
                                                : (vat.toString() + "%"),
                                            maxLines: vat == 0.0 ? 2 : 1,
                                          ),
                                          value: vat,
                                        ),
                                      ));
                                    return Column(
                                      children: <Widget>[
                                        CustomFormField(
                                          child: DropdownButton<double>(
                                            isDense: true,
                                            hint: Text("VAT"),
                                            value: selectedVatSnapshot?.data,
                                            items: items,
                                            onChanged:
                                                _expenseClaimBloc.selectVat,
                                            isExpanded: true,
                                          ),
                                          state: state,
                                        ),
                                      ],
                                    );
                                  }),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 16.0,
                  ),
                  Expanded(
                    child: FormField(
                      validator: _expenseClaimBloc.currencyValidator,
                      builder: (FormFieldState state) => CustomFormField(
                        child: DropdownButtonHideUnderline(
                          child: StreamBuilder<List<Currency>>(
                            stream: repository.currencies,
                            initialData: <Currency>[],
                            builder: (context, currenciesSnapshot) => Container(
                              decoration: BoxDecoration(
                                color: formFieldBackgroundColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              width: double.infinity,
                              child: DropdownButton<String>(
                                hint: Text("Currency"),
                                value: selectedCurrencySnapshot?.data,
                                items: currenciesSnapshot.data
                                    .where(
                                        (currency) => currency.hidden == false)
                                    .map(
                                      (currency) => DropdownMenuItem(
                                        child: Text(currency.iso),
                                        value: currency.id,
                                      ),
                                    )
                                    .toList(),
                                onChanged: _expenseClaimBloc.selectCurrency,
                                isExpanded: true,
                              ),
                            ),
                          ),
                        ),
                        state: state,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildApproverTile() => FormField(
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
                  builder: (context, selectedApproverSnapshot) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 12.0),
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    width: double.infinity,
                    child: CustomFormField(
                      child: DropdownButton<String>(
                        hint: Text("Select who will approve your Expense"),
                        value: selectedApproverSnapshot?.data,
                        items: itemsSnapshot.data
                            .map((User user) => DropdownMenuItem(
                                child: Text(user.name), value: user.id))
                            .toList(),
                        onChanged: _expenseClaimBloc.selectApprover,
                        isExpanded: true,
                      ),
                      state: state,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildCostCenterTile() => FormField(
        validator: _expenseClaimBloc.costCentreValidator,
        builder: (FormFieldState state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildFieldLabel("Cost related to"),
            StreamBuilder(
              stream: repository.costCentresGroups,
              initialData: <CostCentreGroup>[],
              builder: (BuildContext context,
                      AsyncSnapshot<List<CostCentreGroup>> itemsSnapshot) =>
                  DropdownButtonHideUnderline(
                child: StreamBuilder<String>(
                  stream: _expenseClaimBloc.selectedCostCentre,
                  builder: (context, selectedCostCentreSnapshot) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    width: double.infinity,
                    child: CustomFormField(
                      child: DropdownButton<String>(
                        hint: Text("Select what your cost is related to"),
                        value: selectedCostCentreSnapshot?.data,
                        items: itemsSnapshot.data
                            .where((costCentre) => costCentre.hidden == false)
                            .map((CostCentreGroup costCentre) =>
                                DropdownMenuItem(
                                    child: Text(costCentre.name),
                                    value: costCentre.id))
                            .toList(),
                        onChanged: _expenseClaimBloc.selectCostCentre,
                        isExpanded: true,
                      ),
                      state: state,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildreceiptNumberField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          StreamBuilder<int>(
              stream: _expenseClaimBloc.expenseTypeStream,
              initialData: 0,
              builder: (context, snapshot) => _buildFieldLabel(
                  (snapshot.data == 0 ? 'Receipt' : 'Invoice') + ' number')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextFormField(
              controller: _expenseClaimBloc.receiptNumberController,
              maxLines: 1,
              autocorrect: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                hintText: 'Enter the receipt number',
              ),
            ),
          ),
        ],
      );

  Widget _buildFieldLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 32.0, 0.0, 8.0),
        child: Text(
          label,
          style: Theme.of(context).textTheme.subhead.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      );

  Widget _buildAttachmentsTile() => StreamBuilder<Map<String, File>>(
      stream: _expenseClaimBloc.attachments,
      initialData: Map<String, File>(),
      builder: (context, attachmentsSnapshot) {
        return FormField(
          validator: (_) => _expenseClaimBloc.attachmentsValidator(),
          builder: (FormFieldState state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildFieldLabel('Attachments'),
              _buildAttachmentList(attachmentsSnapshot.data),
              Align(alignment: Alignment.center, child: ErrorFormLabel(state)),
              (_expenseClaimBloc.multipleAttachments ?? false)
                  ? Padding(
                      padding: const EdgeInsets.only(right: 24, bottom: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          OutlineButton(
                              borderSide:
                                  BorderSide(width: 0.5, color: Colors.white54),
                              highlightedBorderColor: secondaryColor,
                              child: Text('Add attachments'),
                              onPressed: () => _selectAttachments()),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        );
      });

  Widget _buildAttachmentList(Map<String, File> attachments) {
    List<Widget> list = [];

    attachments.forEach((String name, File attachment) {
      list.add(ListTile(
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: attachment == null
                  ? Icon(
                      name == 'Invoice'
                          ? FontAwesomeIcons.fileInvoiceDollar
                          : Icons.attachment,
                      size: 20,
                      color: Colors.white54,
                    )
                  : Container(
                      height: 40.0, width: 48.0, child: Image.file(attachment)),
            )),
        title: Text(
          name,
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

  Widget _buildButtons(ExpenseType expenseType) => Container(
        margin: EdgeInsets.fromLTRB(24, 0, 24, 48),
        child: (_expenseClaimBloc.editingTemplate ?? false)
            ? FlatButton(
                textColor: secondaryColor,
                child: Text('Save'),
                onPressed: _saveEditing,
              )
            : Column(
                children: <Widget>[
                  FlatButton(
                    textColor: black60,
                    padding: EdgeInsets.all(14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: secondaryColor,
                    child: Text(
                      'Create ' +
                          (expenseType == ExpenseType.EXPENSE_CLAIM
                              ? "expense"
                              : "invoice"),
                    ),
                    onPressed: () => _validateAndUploadExpense(),
                  ),
                  Container(height: 16),
                  Text('or'),
                  FlatButton(
                    textColor: secondaryColor,
                    child: Text('Create and save as template'),
                    onPressed: _createNewTemplate,
                  ),
                ],
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
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
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

  void _createNewTemplate() async {
    bool confirmation = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              "Create template",
              style: Theme.of(context).textTheme.title,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "How do you want to name your new template?",
                  style: Theme.of(context).textTheme.subtitle,
                ),
                SizedBox(height: 8.0),
                TextFormField(
                  key: _templateFormKey,
                  controller: _expenseClaimBloc.templateNameController,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  validator: (templateName) => templateName.length < 3
                      ? "Must be at least 3 characters long"
                      : null,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (templateName) =>
                      Navigator.of(context).pop(true),
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'ex: Taxi Zambia...',
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.button,
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              RaisedButton(
                child: Text(
                  "Create",
                ),
                onPressed: () => Navigator.of(context).pop(true),
                color: secondaryColor,
                textColor: black60,
              ),
            ],
          ),
        ) ??
        false;

    if (confirmation) {
      _validateAndUploadTemplate();
      _validateAndUploadExpense();
    }
  }

  void _saveEditing() {
    _expenseClaimBloc.editTemplate();
    utils.showSnackbar(
      scaffoldKey: widget._scaffoldKey,
      message: "Your Template has been edited successfully.",
      duration: 2,
    );
    widget._onDonePressed();
  }

  void _validateAndUploadTemplate() {
    if (_formKey.currentState.validate()) {
      _expenseClaimBloc.uploadTemplate();
      utils.showSnackbar(
        scaffoldKey: widget._scaffoldKey,
        message: "Your template has been created successfully.",
        duration: 2,
      );
    }
  }

  void _validateAndUploadExpense() {
    if (_formKey.currentState.validate()) {
      _expenseClaimBloc.uploadNewExpense();
      utils.showSnackbar(
        scaffoldKey: widget._scaffoldKey,
        message: "Your expense has been created successfully.",
      );
      widget._onDonePressed();
    } else
      utils.showSnackbar(
        scaffoldKey: widget._scaffoldKey,
        message: "Error. Some information might be incomplete.",
        duration: 2,
        backgroundColor: errorColor,
        textColor: Colors.white,
      );
  }
}
