import 'package:photo_manager/photo_manager.dart';

class MediaServices {
  Future loadAlbums(RequestType requestType) async {
    List<AssetPathEntity> albumList = [];
    albumList = await PhotoManager.getAssetPathList(type: requestType);
    return albumList;
  }

  Future loadAssets(AssetPathEntity selectedAlbum) async {
    List<AssetEntity> assetList = await selectedAlbum.getAssetListRange(
        start: 0,
        // ignore: deprecated_member_use
        end: selectedAlbum.assetCount);
    return assetList;
  }
}
