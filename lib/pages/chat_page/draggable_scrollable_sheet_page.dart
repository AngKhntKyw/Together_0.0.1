import 'package:chat_app/pages/chat_page/images_grid_page.dart';
import 'package:chat_app/services/media_services.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class DraggableScrollableSheetPage extends StatefulWidget {
  final String chatRoomId;
  const DraggableScrollableSheetPage({super.key, required this.chatRoomId});

  @override
  State<DraggableScrollableSheetPage> createState() =>
      _DraggableScrollableSheetPageState();
}

class _DraggableScrollableSheetPageState
    extends State<DraggableScrollableSheetPage> {
  final GlobalKey _sheetKey = GlobalKey();
  double _sheetHeight = 0.0;
  bool showDropDownButton = false;

  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetList = [];
  List<AssetEntity> selectedAssetList = [];

  @override
  void initState() {
    MediaServices().loadAlbums(RequestType.common).then((value) {
      setState(() {
        albumList = value;
        selectedAlbum = value[0];
      });
      MediaServices().loadAssets(selectedAlbum!).then((value) {
        setState(() {
          assetList = value;
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Listener(
      onPointerMove: (PointerMoveEvent pointerMoveEvent) {
        _checkSheetSize();
      },
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              _sheetHeight = constraints.maxHeight;
              return DraggableScrollableSheet(
                key: _sheetKey,
                initialChildSize: 0.5,
                shouldCloseOnMinExtent: true,
                maxChildSize: 1,
                minChildSize: 0.5,
                expand: false,
                snapAnimationDuration: const Duration(milliseconds: 500),
                builder: (context, scrollController) {
                  return Container(
                    padding: !showDropDownButton
                        ? const EdgeInsets.only(
                            top: 8, bottom: 8, right: 8, left: 8)
                        : const EdgeInsets.only(
                            top: 58, bottom: 8, right: 8, left: 8),

                    // Grid Images
                    child: ImagesGridPage(
                      scrollController: scrollController,
                      assetList: assetList,
                      chatRoomId: widget.chatRoomId,
                    ),
                  );
                },
              );
            },
          ),

          //
          showDropDownButton
              ? AnimatedSize(
                  duration: const Duration(milliseconds: 100),
                  alignment: Alignment.topCenter,
                  curve: Curves.decelerate,
                  child: Container(
                    width: size.width,
                    height: 50,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: DropdownButton<AssetPathEntity>(
                      icon: null,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      isDense: true,
                      isExpanded: true,
                      value: selectedAlbum,
                      items: albumList.map((e) {
                        return DropdownMenuItem(
                            value: e,
                            child: Text(
                              // ignore: deprecated_member_use
                              "${e.name}  (${e.assetCount})",
                              style: const TextStyle(fontSize: 14),
                            ));
                      }).toList(),
                      onChanged: (AssetPathEntity? value) {
                        setState(() {
                          selectedAlbum = value;
                        });
                        MediaServices()
                            .loadAssets(selectedAlbum!)
                            .then((value) {
                          setState(() {
                            assetList = value;
                          });
                        });
                      },
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  void _checkSheetSize() {
    final RenderBox renderBox =
        _sheetKey.currentContext!.findRenderObject() as RenderBox;
    final double currentHeight = renderBox.size.height;

    if (currentHeight == _sheetHeight * 0.5) {
      setState(() {
        showDropDownButton = false;
      });
    } else if (currentHeight == _sheetHeight * 1) {
      setState(() {
        showDropDownButton = true;
      });
    }
  }
}
