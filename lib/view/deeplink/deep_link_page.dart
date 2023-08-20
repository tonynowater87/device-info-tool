import 'package:device_info_tool/common/dialogs.dart';
import 'package:device_info_tool/data/model/url_record.dart';
import 'package:device_info_tool/view/deeplink/deep_link_cell_view.dart';
import 'package:device_info_tool/view/deeplink/deep_link_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DeepLinkPage extends StatefulWidget {
  const DeepLinkPage({Key? key}) : super(key: key);

  @override
  State<DeepLinkPage> createState() => _DeepLinkPageState();
}

class _DeepLinkPageState extends State<DeepLinkPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _textEditingController;
  final GlobalKey _containerKey = GlobalKey();
  AnimationController? _animationController;
  Animation<double>? _animation;
  OverlayEntry? _overlayEntry;
  AnimationStatusListener? _snackbarAnimationStatusListener;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _textEditingController = TextEditingController();
    _textEditingController.addListener(() {
      if (_textEditingController.value.text.isEmpty) {
        context.read<DeepLinkCubit>().load("");
      }
    });
    context.read<DeepLinkCubit>().load(_textEditingController.text);

    _snackbarAnimationStatusListener = (status) {
      if (status == AnimationStatus.completed) {
        _animationController?.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    };
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _animation = CurveTween(curve: Curves.fastLinearToSlowEaseIn)
        .animate(_animationController!);
  }

  @override
  void deactivate() {
    _scrollController.dispose();
    _animationController
      ?..removeStatusListener(_snackbarAnimationStatusListener!)
      ..dispose();
    _overlayEntry?.remove();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    var state = context.watch<DeepLinkCubit>().state;
    if (state is DeepLinkLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (state is DeepLinkLoaded) {
      return Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(children: [
                TextField(
                  controller: _textEditingController,
                  autocorrect: false,
                  onTapOutside: (pointer) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onEditingComplete: () {},
                  onChanged: (textChanged) {
                    context.read<DeepLinkCubit>().load(textChanged);
                  },
                  onSubmitted: (text) {
                    _openUrl();
                  },
                  decoration: InputDecoration(
                      labelText: "Enter The Deep Link",
                      hintText: "deep-link://, https://",
                      errorText: state.errorString,
                      errorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                              color: CupertinoColors.systemRed,
                              style: BorderStyle.solid)),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: !state.isTextFieldEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _textEditingController.clear();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      border: const OutlineInputBorder()),
                )
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () {
                    _openUrl();
                  },
                  child: Text('OPEN',
                      style: TextStyle(
                          fontWeight: state.isTextFieldEmpty
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: state.isTextFieldEmpty
                              ? Colors.grey
                              : Colors.blue)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Visibility(
                visible: state.urls.isNotEmpty,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('HISTORY',
                            style: Theme.of(context).textTheme.bodyLarge),
                        TextButton(
                          onPressed: () {
                            showConfirmDialog(
                                context,
                                'Are you sure to clear all history?',
                                null,
                                null,
                                null, () {
                              context.read<DeepLinkCubit>().deleteAll();
                            });
                          },
                          child: const Text(
                            'CLEAR ALL',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Visibility(
                  key: _containerKey,
                  visible: state.urls.isNotEmpty,
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return DeepLinkCellView(
                        urlModel: state.urls[index],
                        onClickUrl: (UrlModel urlModel) {
                          _textEditingController.text = urlModel.url;
                          context.read<DeepLinkCubit>().load(urlModel.url);
                        },
                        onClickCopyUrl: (UrlModel urlModel) {
                          RenderBox renderBox = (_containerKey.currentContext!
                              .findRenderObject() as RenderBox);
                          Offset position =
                              renderBox.localToGlobal(Offset.zero);
                          var translateY = index * 46.5;
                          var positionY = _scrollController.position.pixels;
                          translateY -= positionY;
                          var positionAnchorTranslate =
                              position.translate(0, translateY);

                          showCopyToast(positionAnchorTranslate, urlModel.url);
                          context.read<DeepLinkCubit>().copy(urlModel.url);
                        },
                        onClickDeleteUrl: (UrlModel urlModel) {
                          context.read<DeepLinkCubit>().deleteById(urlModel.id);
                        },
                      );
                    },
                    itemCount: state.urls.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        height: 1.5,
                        color: CupertinoColors.activeBlue.withAlpha(100),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      throw Exception("not expected state: $state");
    }
  }

  Future<void> _openUrl() async {
    var url = _textEditingController.text;
    if (url.isEmpty) {
      return;
    }
    var canResolve = await context.read<DeepLinkCubit>().open(url);
    if (!canResolve) {
      Fluttertoast.showToast(msg: "No app found for：$url");
    }
  }

  showCopyToast(Offset positionAnchor, String url) {
    _animationController
        ?.removeStatusListener(_snackbarAnimationStatusListener!);
    _animationController?.reset();

    if (_overlayEntry?.mounted == true) {
      _overlayEntry?.remove();
    }

    _overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
        left: positionAnchor.dx,
        top: positionAnchor.dy - 1.5,
        child: FadeTransition(
          opacity: _animation!,
          child: Container(
            width: MediaQuery.of(context).size.width - 16,
            decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 16.0),
              child: Center(
                child: RichText(
                  text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: CupertinoColors.white),
                      children: [
                        const TextSpan(text: "Copy "),
                        TextSpan(
                            text: url,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.white)),
                        const TextSpan(text: " Successfully"),
                      ]),
                ),
              ),
            ),
          ),
        ),
      );
    });

    Overlay.of(context).insert(_overlayEntry!);

    _animationController?.addStatusListener(_snackbarAnimationStatusListener!);
    _animationController?.forward();
  }
}
