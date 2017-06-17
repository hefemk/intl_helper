class RelativePathConverter {

  final String _pathStartWith;

  RelativePathConverter(this._pathStartWith);

  String convert(String path) {
    if(path != null && path.isNotEmpty) {
      int startIdx = path.indexOf(_pathStartWith);
      if(startIdx > -1) {
        return path.substring(startIdx);
      } else {
        return path;
      }
    }
    return null;
  }

}