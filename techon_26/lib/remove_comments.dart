import 'dart:io';

void main() {
  final dir = Directory('c:/Users/Lenovo/OneDrive/Desktop/techon_26/lib');
  
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.endsWith('remove_comments.dart')) {
      final lines = entity.readAsLinesSync();
      final newLines = <String>[];
      
      for (var line in lines) {
        if (line.trimLeft().startsWith('//')) {
          continue;
        }
        newLines.add(line);
      }
      
      entity.writeAsStringSync(newLines.join('\n') + '\n');
    }
  }
  print('Comments removed.');
}
