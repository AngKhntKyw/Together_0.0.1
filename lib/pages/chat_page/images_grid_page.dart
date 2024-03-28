import 'package:chat_app/services/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class ImagesGridPage extends StatelessWidget {
  final List<AssetEntity> assetList;
  final ScrollController scrollController;
  final String chatRoomId;

  const ImagesGridPage({
    super.key,
    required this.scrollController,
    required this.assetList,
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      itemCount: assetList.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
      itemBuilder: (context, index) {
        AssetEntity assetEntity = assetList[index];
        if (assetEntity.type == AssetType.image) {
          return Padding(
            padding: const EdgeInsets.all(1),
            child: InkWell(
              onTap: () async {
                Navigator.pop(context);
                await ChatServices.convertImageAssetEntityToFile(
                    assetEntity, chatRoomId);
              },
              child: AssetEntityImage(
                assetEntity,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(250),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(1),
            child: InkWell(
              onTap: () async {
                Navigator.pop(context);
                await ChatServices.convertVideoAssetEntityToFile(
                    assetEntity, chatRoomId);
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: AssetEntityImage(
                        assetEntity,
                        isOriginal: false,
                        thumbnailSize: const ThumbnailSize.square(250),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          );
                        },
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child:
                            Icon(Icons.video_collection, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
