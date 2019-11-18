import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:photo_view/photo_view.dart';

class AttachmentsPage extends StatefulWidget {
  final List<Map<String, String>> attachments;

  const AttachmentsPage({Key key, @required this.attachments})
      : super(key: key);

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
                height: 480.0,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                items: widget.attachments
                    .map((attachment) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  attachment["name"],
                                  style: Theme.of(context)
                                      .textTheme
                                      .title
                                      .copyWith(fontSize: 24.0),
                                ),
                              ),
                              SizedBox(height: 16.0),
                              CachedNetworkImage(
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
                              ),
                            ]))
                    .toList(),
              ),
            ],
          ),
        ),
      );
}
