import 'package:cached_network_image/cached_network_image.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/pages/attachments_page.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:timeago/timeago.dart' as timeago;

class ExpenseTile extends StatefulWidget {
  final Expense expense;

  const ExpenseTile({Key key, this.expense}) : super(key: key);

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
                      utils.buildCategoryIcon(
                        repository.getCategoryWithId(widget.expense.category),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: Text(
                                widget.expense.description,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.title,
                                maxLines: 1,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(top: 14.0),
                                  child: Text(
                                    timeago.format(widget.expense.date),
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(fontSize: 12.0),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.topRight,
                                    height: 32.0,
                                    margin: EdgeInsets.fromLTRB(
                                        8.0, 6.0, 12.0, 12.0),
                                    child: FittedBox(
                                      child: Chip(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: Colors.white24,
                                        label: Text(
                                          '${widget.expense.gross ?? ''} ${repository.getCurrencyWithId(widget.expense.currency)?.symbol ?? ''}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subhead
                                              .copyWith(
                                                color: secondaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 12.0),
                        alignment: Alignment.center,
                        child: RotationTransition(
                          turns: _rotateAnimation,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizeTransition(
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
                                          .getCountryWithId(
                                              widget.expense.country)
                                          ?.name ??
                                      ""),
                            ),
                          ],
                        ),
                        Container(height: 12.0),
                        Row(
                          children: <Widget>[
                            Expanded(
                                child: _buildSection('Net cost',
                                    widget.expense.net.toStringAsFixed(2))),
                            widget.expense.vat != -1.0
                                ? Expanded(
                                    child: _buildSection('VAT',
                                        '${widget.expense.vat.toString()} %'))
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
                ),
              ],
            ),
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

  Widget _buildAttachmentsRow() {
    String previewAttachmentUrl = widget.expense.attachments.first["url"];
    int numAttachments = widget.expense.attachments.length;
    if (previewAttachmentUrl == null) return Container();
    return Row(
      children: <Widget>[
        Text(
          "Attachments",
          style: Theme.of(context)
              .textTheme
              .body2
              .copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 16.0),
        CachedNetworkImage(
          imageUrl: previewAttachmentUrl,
          imageBuilder: (context, imageProvider) => GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AttachmentsPage(attachments: widget.expense.attachments),
              ),
            ),
            child: Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image(
                    image: imageProvider,
                    height: 48.0,
                  ),
                ),
                numAttachments > 1
                    ? Positioned(
                        right: 2.0,
                        top: 2.0,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            numAttachments.toString(),
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Container(),
              ],
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
        ),
        Expanded(child: Container()),
      ],
    );
  }

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
}
