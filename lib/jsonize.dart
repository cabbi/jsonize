/// Jsonize package.
library jsonize;

export 'src/jsonize.dart';
export 'src/clonable.dart';

class JsonizeException implements Exception {
  final String context;
  final String msg;

  const JsonizeException(this.context, this.msg);

  @override
  String toString() => '[$context] $msg';
}
