import 'package:cached_network_image/cached_network_image.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class AttachmentsPage extends StatefulWidget {
  final List<Map<String, String>> attachments;
  final Map<String, String> openAt;

  const AttachmentsPage({
    Key key,
    @required this.attachments,
    @required this.openAt,
  }) : super(key: key);

  @override
  _AttachmentsPageState createState() => _AttachmentsPageState();
}

class _AttachmentsPageState extends State<AttachmentsPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              CarouselSlider(
                initialPage: widget.attachments.indexOf(widget.openAt),
                height: 480.0,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                items: widget.attachments
                    .map(
                      (attachment) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              attachment["name"],
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  .copyWith(fontSize: 24.0),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          utils.isImageAttachment(attachment["url"])
                              ? CachedNetworkImage(
                                  imageUrl: attachment["url"],
                                  imageBuilder: (context, imageProvider) =>
                                      ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Container(
                                        height: 354,
                                        child: PhotoView(
                                          imageProvider: imageProvider,
                                          backgroundDecoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor),
                                          minScale:
                                              PhotoViewComputedScale.contained *
                                                  1.0,
                                          maxScale: 1.0,
                                        )),
                                  ),
                                )
                              : GestureDetector(
                                  child: Container(
                                    color: Colors.white10,
                                    height: 354,
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        CircleAvatar(
                                          child: Icon(
                                            MdiIcons.fileDocument,
                                            size: 48,
                                            color: Colors.white70,
                                          ),
                                          radius: 44,
                                          backgroundColor: Colors.white10,
                                        ),
                                        SizedBox(height: 24.0),
                                        Text(
                                          'Click here to download the file',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () async {
                                    if (await canLaunch(attachment['url']))
                                      launch(attachment['url']);
                                  },
                                ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );
}
