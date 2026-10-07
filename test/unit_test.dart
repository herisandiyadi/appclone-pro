import 'package:flutter_test/flutter_test.dart';

import 'package:appclone_pro/core/engine/cloning_engine.dart';
import 'package:appclone_pro/core/engine/engine_models.dart';
import 'package:appclone_pro/core/engine/virtual_container.dart';
import 'package:appclone_pro/core/security/security_manager.dart';
import 'package:appclone_pro/data/model/clone_app.dart';

void main() {
  group('CloneApp model', () {
    test('create() generates unique ids', () {
      final a = CloneApp.create(packageName: 'com.test', displayName: 'Test', appIconColor: 0xFF0000);
      final b = CloneApp.create(packageName: 'com.test', displayName: 'Test', appIconColor: 0xFF0000);
      expect(a.id, isNot(equals(b.id)));
    });

    test('copyWith() preserves unchanged fields', () {
      final original = CloneApp.create(
        packageName: 'com.whatsapp',
        displayName: 'WA Clone',
        appIconColor: 0xFF25D366,
      );
      final updated = original.copyWith(locked: true);
      expect(updated.locked, isTrue);
      expect(updated.packageName, equals(original.packageName));
    });

    test('toMap/fromMap roundtrip', () {
      final clone = CloneApp.create(
        packageName: 'com.test',
        displayName: 'Test Clone',
        appIconColor: 0xFF123456,
      );
      final map = clone.toMap();
      final restored = CloneApp.fromMap(map);
      expect(restored.id, equals(clone.id));
      expect(restored.packageName, equals(clone.packageName));
      expect(restored.displayName, equals(clone.displayName));
    });
  });

  group('SecurityManager', () {
    final security = SecurityManager.instance;

    test('isPinSet is false before setPin', () {
      expect(security.isPinSet, isFalse);
    });

    test('setPin + verifyPin correct', () {
      security.setPin('1234');
      expect(security.isPinSet, isTrue);
      expect(security.verifyPin('1234'), isTrue);
    });

    test('verifyPin rejects wrong PIN', () {
      security.setPin('1234');
      expect(security.verifyPin('9999'), isFalse);
    });

    test('encryptData/decryptData roundtrip', () {
      const plainText = 'sensitive data 123';
      final enc = security.encryptData(plainText);
      final dec = security.decryptData(enc);
      expect(dec, equals(plainText));
    });
  });

  group('CloningEngine', () {
    final engine = CloningEngine.instance;

    test('createClone emits progress ending with done', () async {
      final clone = CloneApp.create(
        packageName: 'com.test',
        displayName: 'Test',
        appIconColor: 0xFF0000,
      );
      final steps = <CloningStep>[];
      await for (final event in engine.createClone(clone)) {
        steps.add(event.step);
      }
      expect(steps.last, equals(CloningStep.done));
      expect(steps.first, equals(CloningStep.parsing));
    });

    test('launchClone succeeds and updates isRunning', () async {
      final clone = CloneApp.create(
        packageName: 'com.pkg',
        displayName: 'Test',
        appIconColor: 0xFF0000,
      );
      expect(engine.isRunning(clone.id), isFalse);
      final process = await engine.launchClone(clone);
      expect(process, isNotNull);
      expect(engine.isRunning(clone.id), isTrue);
    });
  });

  group('VirtualContainer', () {
    test('starts stopped', () {
      final c = VirtualContainer(cloneId: 'test-1', packageName: 'com.test');
      expect(c.processState, equals(VirtualProcessState.stopped));
    });

    test('launch returns running process', () async {
      final c = VirtualContainer(cloneId: 'test-2', packageName: 'com.test');
      final process = await c.launch();
      expect(process.state, equals(VirtualProcessState.running));
      expect(process.memoryMb, greaterThan(0));
    });

    test('pause compresses memory', () async {
      final c = VirtualContainer(cloneId: 'test-3', packageName: 'com.test');
      await c.launch();
      final memBefore = c.memoryMb;
      await c.pause();
      expect(c.memoryMb, lessThan(memBefore));
      expect(c.processState, equals(VirtualProcessState.paused));
    });
  });
}
