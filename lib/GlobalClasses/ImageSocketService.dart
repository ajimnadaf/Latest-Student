import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';

class SocketResult {
  final bool success;
  final int errorCode;
  final String message;

  SocketResult({
    required this.success,
    required this.errorCode,
    required this.message,
  });
}

class ImageSocketService {
  static Future<SocketResult> sendImage({
    required String ip,
    required int port,
    required int type,
    required String imagePath,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    const int mtu = 512;

    Socket? socket;
    RandomAccessFile? raf;

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return SocketResult(
          success: false,
          errorCode: 404,
          message: 'Image not found',
        );
      }

      final imgLen = await file.length();

      socket = await Socket.connect(ip, port, timeout: timeout);

      // Send TLV header
      socket.add(_int32(type));
      socket.add(_int32(imgLen));
      await socket.flush();

      // Send image bytes
      raf = await file.open();
      int sent = 0;

      while (sent < imgLen) {
        final remaining = imgLen - sent;
        final chunkSize = remaining > mtu ? mtu : remaining;

        final chunk = await raf.read(chunkSize);
        socket.add(chunk);
        sent += chunk.length;
      }

      await socket.flush();

      // 🔴 READ SERVER RESPONSE
      final responseBytes = await _readResponse(socket);

      // 🔴 PARSE RESPONSE (TLV-like)
      return _parseServerResponse(responseBytes);
    } catch (e) {
      return SocketResult(
        success: false,
        errorCode: -1,
        message: e.toString(),
      );
    } finally {
      await raf?.close();
      socket?.destroy();
    }
  }

  // ================= HELPERS =================

  static Uint8List _int32(int value) {
    final b = ByteData(4);
    b.setInt32(0, value, Endian.big);
    return b.buffer.asUint8List();
  }

  static Future<Uint8List> _readResponse(Socket socket) async {
    final buffer = BytesBuilder();
    final completer = Completer<Uint8List>();

    socket.listen(
      (data) => buffer.add(data),
      onDone: () => completer.complete(buffer.toBytes()),
      onError: (e) => completer.completeError(e),
      cancelOnError: true,
    );

    return completer.future;
  }

  /// Equivalent of Java handleerror()
  static SocketResult _parseServerResponse(Uint8List data) {
    if (data.length < 4) {
      return SocketResult(
        success: false,
        errorCode: -2,
        message: 'Invalid server response',
      );
    }

    final bd = ByteData.sublistView(data);
    final errorCode = bd.getInt32(0, Endian.big);

    if (errorCode == 0) {
      return SocketResult(
        success: true,
        errorCode: 0,
        message: 'Image uploaded successfully',
      );
    } else {
      return SocketResult(
        success: false,
        errorCode: errorCode,
        message: 'Server error: $errorCode',
      );
    }
  }
}
