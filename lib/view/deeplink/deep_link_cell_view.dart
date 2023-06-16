import 'package:device_info_tool/data/model/url_record.dart';
import 'package:flutter/material.dart';

class DeepLinkCellView extends StatelessWidget {
  UrlModel urlModel;
  Function(UrlModel) onClickUrl;
  Function(UrlModel) onClickDeleteUrl;
  Function(UrlModel) onClickCopyUrl;

  DeepLinkCellView(
      {required this.urlModel,
      required this.onClickUrl,
      required this.onClickDeleteUrl,
      required this.onClickCopyUrl,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 45,
        child: InkWell(
          onTap: () {
            onClickUrl.call(urlModel);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                    child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(urlModel.url),
                )),
                IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      onClickCopyUrl.call(urlModel);
                    }),
                IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      onClickDeleteUrl.call(urlModel);
                    })
              ],
            ),
          ),
        ));
  }
}
