import 'dart:convert';
import 'dart:io';

const String _sourceDir = 'lib/media/svg';
const String _targetDir = 'assets/media/coin_icons';
const String _mappingPath = 'assets/media/coin_icons/_mapping.json';

void main(List<String> args) {
  final apply = args.contains('--apply');
  final dryRun = args.contains('--dry-run');

  if (apply && dryRun) {
    stderr.writeln('Use either --dry-run or --apply, not both.');
    exitCode = 64;
    return;
  }

  final shouldApply = apply;
  _run(shouldApply: shouldApply);
}

void _run({required bool shouldApply}) {
  final source = Directory(_sourceDir);
  if (!source.existsSync()) {
    stderr.writeln('Source directory not found: $_sourceDir');
    exitCode = 1;
    return;
  }

  final target = Directory(_targetDir);
  if (!target.existsSync() && shouldApply) {
    target.createSync(recursive: true);
  }

  final pngFiles = source
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.toLowerCase().endsWith('.png'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final usedNames = <String>{};
  if (target.existsSync()) {
    for (final entry in target.listSync().whereType<File>()) {
      usedNames.add(_normalizeSlashes(entry.uri.pathSegments.last));
    }
  }

  final mapping = <String, String>{};
  final plans = <_CopyPlan>[];

  for (final file in pngFiles) {
    final originalName = file.uri.pathSegments.last;
    final normalizedBase = _normalizedBaseName(originalName);
    final finalName = _dedupeName(normalizedBase, usedNames);
    usedNames.add(finalName);

    final fromPath = _normalizeSlashes(file.path);
    final toPath = '$_targetDir/$finalName';
    mapping[fromPath] = toPath;
    plans.add(_CopyPlan(fromPath: fromPath, toPath: toPath));
  }

  stdout.writeln(
    shouldApply
        ? 'Applying ${plans.length} media normalization operations...'
        : 'Dry run: ${plans.length} media normalization operations.',
  );

  for (final plan in plans) {
    stdout.writeln('${shouldApply ? "COPY" : "PLAN"} ${plan.fromPath} -> ${plan.toPath}');
    if (shouldApply) {
      File(plan.toPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(File(plan.fromPath).readAsBytesSync());
    }
  }

  if (shouldApply) {
    final mappingFile = File(_mappingPath)
      ..createSync(recursive: true)
      ..writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(mapping),
      );
    stdout.writeln('Mapping file written: ${_normalizeSlashes(mappingFile.path)}');
  } else {
    stdout.writeln('Dry run only. Mapping file not written.');
  }
}

String _normalizedBaseName(String fileName) {
  final lower = fileName.toLowerCase();
  final withoutExt = lower.endsWith('.png')
      ? lower.substring(0, lower.length - 4)
      : lower;

  var strippedLeading = withoutExt.replaceFirst(RegExp(r'^\d+[\s._-]*'), '');
  strippedLeading = strippedLeading.trim();
  if (strippedLeading.isEmpty) {
    strippedLeading = 'coin_icon';
  }

  var snake = strippedLeading.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  snake = snake.replaceAll(RegExp(r'_+'), '_');
  snake = snake.replaceAll(RegExp(r'^_+|_+$'), '');
  if (snake.isEmpty) {
    snake = 'coin_icon';
  }
  return '$snake.png';
}

String _dedupeName(String baseName, Set<String> used) {
  if (!used.contains(baseName)) return baseName;

  final dot = baseName.lastIndexOf('.');
  final stem = dot == -1 ? baseName : baseName.substring(0, dot);
  final ext = dot == -1 ? '' : baseName.substring(dot);

  var i = 2;
  while (true) {
    final candidate = '${stem}_$i$ext';
    if (!used.contains(candidate)) {
      return candidate;
    }
    i++;
  }
}

String _normalizeSlashes(String value) => value.replaceAll('\\', '/');

class _CopyPlan {
  const _CopyPlan({required this.fromPath, required this.toPath});

  final String fromPath;
  final String toPath;
}
