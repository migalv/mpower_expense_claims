import 'package:cached_network_image/cached_network_image.dart';
import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/new_expense_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/pages/attachments_page.dart';
import 'package:expense_claims_app/pages/new_expense_page.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:expense_claims_app/widgets/tile_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class ExpenseTile extends StatefulWidget {
  final Expense expense;
  final GlobalKey scaffoldKey;

  const ExpenseTile({
    Key key,
    @required this.expense,
    @required this.scaffoldKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final Animatable<double> _sizeTween = Tween<double>(begin: 0.0, end: 1.0),
      _rotationTween = Tween<double>(begin: 0.0, end: 0.5);
  Animation<double> _sizeAnimation, _rotateAnimation;
  bool _isExpanded = false;
  Offset _tapPosition;

  bool get _isEditable =>
      widget.expense.status.value == ExpenseStatus.WAITING &&
      widget.expense.createdBy == repository.currentUserId;

  @override
  initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _sizeAnimation = _sizeTween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _rotateAnimation = _rotationTween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: _toggleExpand,
        onLongPress: _isEditable ? _onLongPress : null,
        onLongPressStart: (details) =>
            setState(() => _tapPosition = details.globalPosition),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white10,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Column(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width),
                  child: Row(
                    children: <Widget>[
                      TileIcon(
                        iconData: widget.expense.status.icon,
                        backgroundColor: widget.expense.status.color,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildDescription(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _buildExpenseDate(),
                                _buildCostChip(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildRotatingArrow(),
                    ],
                  ),
                ),
                _buildExpandableInfo(),
              ],
            ),
          ),
        ),
      );

  Widget _buildDescription() => Padding(
        padding: EdgeInsets.only(top: 16.0),
        child: Text(
          widget.expense.description,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.title,
          maxLines: 1,
        ),
      );

  Widget _buildExpenseDate() => Padding(
        padding: EdgeInsets.only(top: 14.0),
        child: Text(
          timeago.format(widget.expense.date),
          style: Theme.of(context).textTheme.body1.copyWith(fontSize: 12.0),
        ),
      );

  Widget _buildCostChip() => Expanded(
        child: Container(
          alignment: Alignment.topRight,
          height: 32.0,
          margin: EdgeInsets.fromLTRB(8.0, 6.0, 12.0, 12.0),
          child: FittedBox(
            child: Chip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: Colors.white24,
              label: Text(
                '${widget.expense.gross ?? ''} ${repository.getCurrencyWithId(widget.expense.currency)?.symbol ?? ''}',
                style: Theme.of(context).textTheme.subhead.copyWith(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                    ),
              ),
            ),
          ),
        ),
      );

  Widget _buildRotatingArrow() => Container(
        margin: EdgeInsets.only(right: 12.0),
        alignment: Alignment.center,
        child: RotationTransition(
          turns: _rotateAnimation,
          child: Icon(
            Icons.keyboard_arrow_down,
          ),
        ),
      );

  Widget _buildExpandableInfo() => SizeTransition(
        axisAlignment: 0.0,
        axis: Axis.vertical,
        sizeFactor: _sizeAnimation,
        child: Padding(
          padding: EdgeInsets.fromLTRB(72.0, 0.0, 16.0, 16.0),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: _buildSection(
                        'Approved by', widget.expense.approvedByName),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: _buildSection(
                        'Country',
                        repository
                                .getCountryWithId(widget.expense.country)
                                ?.name ??
                            ""),
                  ),
                ],
              ),
              Container(height: 12.0),
              Row(
                children: <Widget>[
                  Expanded(
                      child: _buildSection(
                          'Net cost', widget.expense.net.toStringAsFixed(2))),
                  widget.expense.vat != -1.0
                      ? Expanded(
                          child: _buildSection(
                              'VAT', '${widget.expense.vat.toString()} %'))
                      : Container(),
                ],
              ),
              Container(height: 12.0),
              Row(
                children: <Widget>[
                  Expanded(
                      child: _buildSection(
                          'Description', widget.expense.description)),
                ],
              ),
              widget.expense.attachments.isNotEmpty
                  ? Container(height: 12.0)
                  : Container(),
              _buildAttachmentsRow(),
            ],
          ),
        ),
      );

  Widget _buildSection(String title, String desc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .body2
                .copyWith(fontWeight: FontWeight.bold),
          ),
          Container(
            height: 4.0,
          ),
          Text(
            desc ?? '',
            style: Theme.of(context)
                .textTheme
                .body2
                .copyWith(fontWeight: FontWeight.normal),
          ),
        ],
      );

  Widget _buildAttachmentsRow() => Container(
        height: (widget.expense?.attachments?.isNotEmpty ?? false) ? 48.0 : 0.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: widget.expense.attachments
              .map(
                (attachment) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: attachment['url'] == null
                      ? Container()
                      : utils.isImageAttachment(attachment['url'])
                          ? _buildImageAttachment(attachment)
                          : _buildFileAttachment(attachment),
                ),
              )
              .toList(),
        ),
      );

  //
  // METHODS
  _toggleExpand() {
    _isExpanded = !_isExpanded;

    switch (_sizeAnimation.status) {
      case AnimationStatus.completed:
        _controller.reverse();
        break;
      case AnimationStatus.dismissed:
        _controller.forward();
        break;
      case AnimationStatus.reverse:
      case AnimationStatus.forward:
        break;
    }
  }

  /// Function triggered when the user long presses the tile
  void _onLongPress() {
    final String expenseType =
        widget.expense is ExpenseClaim ? 'expense' : 'invoice';
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    showMenu(
      position: RelativeRect.fromRect(
          _tapPosition & Size(0, 0), Offset.zero & overlay.size),
      context: context,
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: "Edit $expenseType",
          child: Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.pen,
                size: 16,
              ),
              SizedBox(width: 16.0),
              Text("Edit $expenseType"),
            ],
          ),
        ),
        PopupMenuItem(
          value: "Delete $expenseType",
          child: Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.trash,
                size: 16,
              ),
              SizedBox(width: 16.0),
              Text("Delete $expenseType"),
            ],
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomLeft: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
      )),
    ).then(
      (selectedValue) {
        if (selectedValue == null) return;

        if (selectedValue.contains('Delete'))
          _deleteExpense(context);
        else if (selectedValue.contains('Edit')) _editExpense(context);
      },
    );
  }

  Widget _buildImageAttachment(Map attachment) => CachedNetworkImage(
        imageUrl: attachment['url'],
        imageBuilder: (context, imageProvider) => GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AttachmentsPage(
                attachments: widget.expense.attachments,
                openAt: attachment,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image(
              image: imageProvider,
              height: 48.0,
            ),
          ),
        ),
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Tooltip(
          message: "Could not find attachments",
          child: Row(
            children: <Widget>[
              Icon(Icons.error),
              SizedBox(width: 4.0),
              Text("Not found"),
            ],
          ),
        ),
      );

  Widget _buildFileAttachment(Map attachment) => GestureDetector(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  MdiIcons.fileDocument,
                  size: 18,
                ),
                Container(
                  height: 6,
                ),
                Text(
                  '${attachment['name']} File',
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
          ),
        ),
        onTap: () async {
          if (await canLaunch(attachment['url'])) launch(attachment['url']);
        },
      );

  void _deleteExpense(BuildContext context) async {
    String string = widget.expense is ExpenseClaim ? "expense" : "invoice";
    bool delete = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              "Delete " + string,
              style: Theme.of(context).textTheme.title,
            ),
            content: Text(
              "Are you sure to delete this " + string + "?",
              style: Theme.of(context).textTheme.subtitle,
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
                  "Delete",
                ),
                onPressed: () => Navigator.of(context).pop(true),
                color: secondaryColor,
                textColor: black60,
              ),
            ],
          ),
        ) ??
        false;

    if (delete) {
      repository.deleteExpense(widget.expense);
      utils.showSnackbar(
        scaffoldKey: widget.scaffoldKey,
        message: "Expense claim deleted sucessfully",
      );
    }
  }

  void _editExpense(BuildContext context) {
    utils.push(
      context,
      BlocProvider<NewExpenseBloc>(
        initBloc: (_, b) =>
            b ??
            NewExpenseBloc(
              expenseType: widget.expense is ExpenseClaim
                  ? ExpenseType.EXPENSE_CLAIM
                  : ExpenseType.INVOICE,
              expenseToBeEdited: widget.expense,
            ),
        child: NewExpensePage(),
        onDispose: (_, b) => b.dispose(),
      ),
    );
  }
}
