import 'package:IDKitImageNote/IDKitImageNoteGenerator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

Builder imageSourceNoteBilder(BuilderOptions options) =>
    LibraryBuilder(IDKitImageNoteGenerator());
