// Copyright (c) 2017, HEFE. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:intl_helper/msg_item.dart';
import 'package:intl_helper/relative_path_converter.dart';
import 'package:path/path.dart' as path;
import 'package:args/args.dart';

const String intlPackage = 'package:intl';
const String intlUse = 'Intl.message';

RelativePathConverter rpc;
List<String> includeIntlFiles = new List();
Set<String> _messages = new Set(); // use for detect duplicate message
List<MsgItem> messageItems = new List();

main(List<String> args) {

  rpc = new RelativePathConverter('lib');

  ArgParser parser = new ArgParser();
  parser.addOption(
      'arb-output', abbr: 'a', defaultsTo: 'arb');
  parser.addOption(
      'intl-output', abbr: 'i', defaultsTo: 'lib${path.separator}intl');

  ArgResults result = parser.parse(args);
  String arbOutputArg = result['arb-output'];
  String intlOutputArg = result['intl-output'];

  String currentDir = Directory.current.path + path.separator + 'lib';
  Directory d = new Directory(currentDir);
  if(d.existsSync()) {
    List<FileSystemEntity> fileList = d.listSync(recursive: true);
    fileList.forEach((fse) {
      if(isContentsIntl(fse.path)) {
        includeIntlFiles.add(fse.path);
      }
    });

    if(includeIntlFiles.isEmpty) {
      print('There is no dart files call the "Intl.message()" method.');
    } else {
      print('There are ${includeIntlFiles.length} '
          'dart files call the "Intl.message()" method ("$currentDir")');
    }

    genExtractCommendFile(arbOutputArg);
    genGenerateCommendFile(intlOutputArg);
  } else {
    stderr.write('The directory "$currentDir" is not exists.');
  }
  d = null;

  genReport();
}

bool isContentsIntl(String filePath) {
  if(filePath.endsWith('.dart')) {
    File f = new File(filePath);
    String fileContent = f.readAsStringSync();
    bool isContainsIntl = false;

    fileContent = fileContent.replaceAll(new RegExp('[\n\r\t ]'),'');

    RegExp regExp = new RegExp('Intl.message\\([\'\"](.*?)[\'\"]');
    regExp.allMatches(fileContent).forEach((Match m){
      isContainsIntl = true;

      MsgItem msg = new MsgItem()
        ..desc = m.group(1)
        ..fromDartFile = filePath;
      messageItems.add(msg);

      bool addSuccess = _messages.add(msg.desc);
      if(!addSuccess) {
        msg.isDuplicate = true;
      }
    });
    f = null;
    return isContainsIntl;
  } else {
    return false;
  }
}

void genReport() {
  messageItems.forEach((msg){
    if(msg.isDuplicate)
      print('Found a duplicate message "${msg.desc}" in "${rpc.convert(msg.fromDartFile)}".');
  });
}

void genExtractCommendFile(String outputDir) {
  StringBuffer sb = new StringBuffer();
  sb.write('pub run intl_translation:extract_to_arb --output-dir=$outputDir ');
  includeIntlFiles.forEach((filePath) => sb.write('${rpc.convert(filePath)} '));
  File commandFile = new File(
      Directory.current.path + path.separator + 'ih_intl_extract' + getFileExt());
  commandFile.writeAsStringSync(sb.toString());
  commandFile = null;
}

void genGenerateCommendFile(String outputDir) {
  StringBuffer sb = new StringBuffer();
  sb.write('pub run intl_translation:generate_from_arb --output-dir=$outputDir ');
  includeIntlFiles.forEach((filePath) => sb.write('${rpc.convert(filePath)} '));
  sb.write('/* your arb files */');

  File commandFile = new File(
      Directory.current.path + path.separator + 'ih_intl_generate' + getFileExt());
  commandFile.writeAsStringSync(sb.toString());
  commandFile = null;
}

String getFileExt() {
  if(Platform.isWindows) {
    return '.bat';
  } else {
    return '.sh';
  }
}