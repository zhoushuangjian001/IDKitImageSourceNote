import 'package:IDKitImageNote/IDKitImageNote.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart'; // BuildStep
import 'dart:io'; // File

class IDKitImageNoteGenerator extends GeneratorForAnnotation<IDKitImageNote> {
  // Code content.
  String _codeContent = "";
  // Pubspec content.
  String _pubspecContent = "";

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    String _explain = "//**************************************************\n"
        "// 如果存在新文件需要更新，建议先执行清除命令:\n"
        "// flutter packages pub run build_runner clean \n"
        "// \n"
        "// 然后执行下列命令重新生成相应的文件:\n"
        "// flutter packages pub run build_runner build --delete-conflicting-outputs \n"
        "//**************************************************";

    // Gets the specified file object.
    var pubspecFile = File("pubspec.yaml");
    // Get the contents of the pubspec.ymal.
    for (var item in pubspecFile.readAsLinesSync()) {
      // Remove manually added resource references from the file.
      if (item.trim() == "assets:") continue;
      if (item.trim().toLowerCase().endsWith(".PNG")) continue;
      if (item.trim().toLowerCase().endsWith(".JPEG")) continue;
      if (item.trim().toLowerCase().endsWith(".JPG")) continue;
      if (item.trim().toLowerCase().endsWith(".SVG")) continue;
      // Filter folder.
      if (item.trim().endsWith("/") && !item.trim().startsWith("path:"))
        continue;
      // Build pubspec content.
      _pubspecContent = "$_pubspecContent\n$item";
    }
    // Remove extra space.
    _pubspecContent = _pubspecContent.trim() + "\n\n  assets:";
    // Get the path of the resource.
    var imagePath = annotation.peek("pathName").stringValue;
    if (!imagePath.endsWith("/")) {
      imagePath += "/";
      // Resource quick reference.
      _pubspecContent = "$_pubspecContent\n    - $imagePath";
    }

    // The name of the newly generated class.
    var className = annotation.peek("className").stringValue;

    // Get resource name to build code.
    _handleSourcePathOfImage(imagePath);

    // Content write to file.
    pubspecFile.writeAsString(_pubspecContent);

    // Return code.
    return "$_explain\n\n"
        "class $className {\n"
        "    $className._();\n"
        "    $_codeContent\n"
        "}\n";
  }

  // Processing of image resource path.
  void _handleSourcePathOfImage(String sourcePath) {
    // Determine whether it is a folder.
    var directory = Directory(sourcePath);
    if (directory == null) throw "$sourcePath isn't a directory.";
    // Traverse the contents under the file.
    for (var file in directory.listSync()) {
      // Get file type.
      var type = file.statSync().type;
      if (type == FileSystemEntityType.directory) {
        // Folder recursion.
        _handleSourcePathOfImage("${file.path}/");
        // Resource quick reference.
        _pubspecContent = "$_pubspecContent\n    - ${file.path}/";
      } else if (type == FileSystemEntityType.file) {
        // Path of file.
        var filePath = file.path;
        var keyName = filePath.trim().toUpperCase();
        // Filtering files that are not pictures.
        if (!keyName.endsWith(".PNG") &&
            !keyName.endsWith(".JPEG") &&
            !keyName.endsWith(".SVG") &&
            !keyName.endsWith(".JPG")) continue;

        // Replace suffix of picture resource.
        var key = keyName
            .replaceAll(RegExp(sourcePath.toUpperCase()), '')
            .replaceAll(RegExp('.PNG'), '')
            .replaceAll(RegExp('.JPEG'), '')
            .replaceAll(RegExp('.SVG'), '')
            .replaceAll(RegExp('.JPG'), '');

        // Code building.
        _codeContent = "$_codeContent\t\t\t\tstatic const $key = '$filePath';";
      }
    }
  }
}
