import 'dart:core';
import 'dart:io';
import 'dart:convert';


Codec<String, String> stringToBase64 = utf8.fuse(base64);
void main(List<String> args) async {
  var location = Platform.script.toString();
  var isNewFlutter = location.contains(".snapshot");
  if (isNewFlutter) {
    var sp = Platform.script.toFilePath();
    var sd = sp.split(Platform.pathSeparator);
    sd.removeLast();
    var scriptDir = sd.join(Platform.pathSeparator);
    var packageConfigPath = [scriptDir, '..', '..', '..', 'package_config.json']
        .join(Platform.pathSeparator);
    var jsonString = File(packageConfigPath).readAsStringSync();
    Map<String, dynamic> packages = jsonDecode(jsonString);
    var packageList = packages["packages"];
    String? zoomFileUri;
    for (var package in packageList) {
      if (package["name"] == "flutter_zoom_sdk") {
        zoomFileUri = package["rootUri"];
        break;
      }
    }
    if (zoomFileUri == null) {
      //print("flutter_zoom_sdk package not found!");
      return;
    }
    location = zoomFileUri;
  }
  if (Platform.isWindows) {
    location = location.replaceFirst("file:///", "");
  } else {
    location = location.replaceFirst("file://", "");
  }
  if (!isNewFlutter) {
    location = location.replaceFirst("/bin/unzip_zoom_sdk.dart", "");
  }

  await checkAndDownloadSDK(location);

  //print('Complete');
}

Future<void> checkAndDownloadSDK(String location) async {
  var iosSDKFile = location +
      '/ios/MobileRTC.xcframework/ios-arm64_armv7/MobileRTC.framework/MobileRTC';
  bool exists = await File(iosSDKFile).exists();

  if (!exists) {
    await downloadFile(
        Uri.parse(
            stringToBase64.decode('aHR0cHM6Ly9lZHVrZW15YXBwLnMzLmFwLXNvdXRoLTEuYW1hem9uYXdzLmNvbS96b29tX3Nkay9pb3MvYXJtNjQvTW9iaWxlUlRD')),
        iosSDKFile);
  }

  var iosSimulateSDKFile = location +
      '/ios/MobileRTC.xcframework/ios-i386_x86_64-simulator/MobileRTC.framework/MobileRTC';
  exists = await File(iosSimulateSDKFile).exists();

  if (!exists) {
    await downloadFile(
        Uri.parse(
            stringToBase64.decode('aHR0cHM6Ly9lZHVrZW15YXBwLnMzLmFwLXNvdXRoLTEuYW1hem9uYXdzLmNvbS96b29tX3Nkay9pb3MveDg2L01vYmlsZVJUQw==')),
        iosSimulateSDKFile);
  }

  var androidCommonLibFile = location + '/android/libs/commonlib.aar';
  exists = await File(androidCommonLibFile).exists();
  if (!exists) {
    await downloadFile(
        Uri.parse(
            stringToBase64.decode('aHR0cHM6Ly9lZHVrZW15YXBwLnMzLmFwLXNvdXRoLTEuYW1hem9uYXdzLmNvbS96b29tX3Nkay9jb21tb25saWIuYWFy')),
        androidCommonLibFile);
  }
  var androidRTCLibFile = location + '/android/libs/mobilertc.aar';
  exists = await File(androidRTCLibFile).exists();
  if (!exists) {
     await downloadFile(
        Uri.parse(
            stringToBase64.decode('aHR0cHM6Ly9lZHVrZW15YXBwLnMzLmFwLXNvdXRoLTEuYW1hem9uYXdzLmNvbS96b29tX3Nkay9tb2JpbGVydGMuYWFy')),
        androidRTCLibFile);
  }
}

Future<void> downloadFile(Uri uri, String savePath) async {
 // print('Download ${uri.toString()} to $savePath');
  File destinationFile = await File(savePath).create(recursive: true);

  final request = await HttpClient().getUrl(uri);
  final response = await request.close();
  await response.pipe(destinationFile.openWrite());
}
