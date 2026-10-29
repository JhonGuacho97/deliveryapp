import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/src/bloc/socket_bloc.dart';
import 'package:delivery_app/src/provider/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class _Socket extends Mock implements io.Socket {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Socket socket;
  late SocketBloc bloc;
  late Map<String, dynamic> options;
  late void Function(dynamic) onLocation;
  setUp(() async {
    SharedPreferences.setMockInitialValues({'token': 'fixture-session'});
    await PreferencesProvider().init();
    socket = _Socket();
    when(() => socket.connected).thenReturn(true);
    when(() => socket.connect()).thenReturn(socket);
    when(() => socket.on('l', any())).thenAnswer((invocation) {
      onLocation = invocation.positionalArguments[1];
      return () {};
    });
    bloc = SocketBloc.connection(
      socketFactory: (_, configuration) {
        options = configuration;
        return socket;
      },
    );
  });
  tearDown(() => bloc.disposeStreams());

  test('uses the NestJS Socket.IO endpoint and current credentials', () {
    bloc.connect(7);
    expect(options['path'], '/socket.io');
    expect(options['forceNew'], isTrue);
    expect(options['extraHeaders'], {
      'auth': 'fixture-session',
      'iduserdeliverymen': '7',
    });
    bloc.connect(7);
    verify(() => socket.connect()).called(1);
  });
  test('validates coordinates before publishing locations', () async {
    bloc.connect(7);
    final received = <LatLng>[];
    final subscription = bloc.stream.listen(received.add);
    onLocation(null);
    onLocation(['invalid', 3]);
    onLocation([100, 500]);
    onLocation([-0.2, -78.5]);
    await Future<void>.delayed(Duration.zero);
    expect(received, [const LatLng(-0.2, -78.5)]);
    await subscription.cancel();
  });
  test('closing disposes the transport and allows a fresh connection', () {
    bloc.connect(7);
    bloc.close();
    expect(bloc.connected(), isFalse);
    verify(() => socket.dispose()).called(1);
    bloc.connect(8);
    expect(options['extraHeaders']['iduserdeliverymen'], '8');
  });
}
