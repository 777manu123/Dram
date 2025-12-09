import 'dart:io';

void main() {
  Process.run('flutter', ['pub', 'get']).then((result) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  });
}
