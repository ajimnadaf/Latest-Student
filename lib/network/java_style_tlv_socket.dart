import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:student_app/GlobalClasses/Glb.dart' as Glb;

class JavaStyleTlvSocket {
  late Socket _socket;
  bool skipCompression = false;
  bool _connected = false;

  final BytesBuilder _recvBuffer = BytesBuilder();
  final Completer<void> _connectedCompleter = Completer<void>();

  /// Connect and start a single listener
  Future<void> connect(String ip, int port) async {
    _socket = await Socket.connect(ip, port);
    _connected = true;
    print("Connected to $ip:$port");

    // Start a single listener for the lifetime of the socket
    _socket.listen(
      (data) => _recvBuffer.add(data),
      onDone: () {
        _connected = false;
        print("Socket closed by server");
      },
      onError: (e) {
        _connected = false;
        print("Socket error: $e");
      },
      cancelOnError: true,
    );
  }

  /// Close socket
  void close() {
    if (_connected) {
      _socket.destroy();
      _connected = false;
      print("Socket closed");
    }
  }

  /// Read exactly len bytes from the internal buffer
  Future<Uint8List> _readExact(int len) async {
    final completer = Completer<Uint8List>();

    void tryRead() {
      if (_recvBuffer.length >= len) {
        final data = _recvBuffer.takeBytes().sublist(0, len);
        // keep remaining bytes in buffer
        final remaining = _recvBuffer.takeBytes();
        _recvBuffer.add(remaining);
        completer.complete(data);
      } else {
        // Not enough data yet, wait a bit
        Future.delayed(Duration(milliseconds: 10), tryRead);
      }
    }

    tryRead();
    return completer.future;
  }

  Future<String> sendMessage(
      String ip, int port, String message, int packetType) async {
    String receivedMessage = '';
    try {
      Socket socket = await Socket.connect(ip, port);
      print(
          'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

      // Prepare TLV packet
      Uint8List buffer = Uint8List(8 + message.length);
      ByteData.view(buffer.buffer).setInt32(0, packetType, Endian.little);
      ByteData.view(buffer.buffer).setInt32(4, message.length, Endian.little);
      buffer.setRange(8, buffer.lengthInBytes, utf8.encode(message));

      socket.add(buffer);
      await socket.flush();

      // Receive response
      List<int> responseBuffer = [];
      int responseLength = 0;

      await for (var data in socket) {
        responseBuffer.addAll(data);

        // Read response type & length
        if (responseBuffer.length >= 8 && responseLength == 0) {
          int responseType =
              ByteData.view(Uint8List.fromList(responseBuffer).buffer)
                  .getInt32(0, Endian.little);
          responseLength =
              ByteData.view(Uint8List.fromList(responseBuffer).buffer)
                  .getInt32(4, Endian.little);
          print('responseType: $responseType, responseLength: $responseLength');
        }

        if (responseBuffer.length >= responseLength) {
          receivedMessage =
              utf8.decode(responseBuffer.sublist(8, responseLength));
          print("Received Message: $receivedMessage");
          break;
        }
      }

      await socket.close();
    } catch (e) {
      print('Error in sendMessage: $e');
      return "Err: Network Error, No internet or Server is down";
    }

    return receivedMessage;
  }

  Future<Uint8List> downloadImage({
    required String ip,
    required int port,
    required int tlv,
    required String path,
  }) async {
    final socket = await Socket.connect(ip, port);
    print("Connected to $ip:$port");

    try {
      // ---- SEND TLV ----
      final payload = utf8.encode(path);
      final buffer = BytesBuilder();
      buffer.add(_int32(tlv)); // TLV No (559)
      buffer.add(_int32(payload.length)); // Length
      buffer.add(payload);

      socket.add(buffer.toBytes());
      await socket.flush();

      // ---- READ HEADER ----
      final header = await _readExact(8);
      final bd = ByteData.sublistView(header);
      final respLen = bd.getInt32(4, Endian.big);

      if (respLen <= 0) {
        throw Exception("Empty image received");
      }

      // ---- READ IMAGE BYTES ----
      final imageBytes = await _readExact(respLen);
      print("Image bytes received: ${imageBytes.length}");

      return imageBytes;
    } finally {
      socket.destroy(); // SAME AS Java close()
      print("Socket closed");
    }
  }

  Future<void> downloadHomeworkImage() async {
    try {
      print("Glb Query is: ${Glb.query}");

      // 🔴 SAME AS Java do_all_network() + save_image()
      final bytes = await downloadImage(
        ip: Glb.ip,
        port: Glb.port,
        tlv: 559,
        path: Glb.query,
      );

      // 🔴 SAME AS glbObj.localimagePath
      final savePath = "/storage/emulated/0/TrueGuide/466.jpg";

      final file = File(savePath);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);

      print("✅ Image saved at $savePath");
    } catch (e) {
      print("❌ Async_Download_doc ERROR: $e");
    }
  }

  Future<Uint8List> doAllNetworkImage(
    int tlvNo,
    String tlvStr,
  ) async {
    if (!_connected) throw Exception("Socket not connected");

    final payload = utf8.encode(tlvStr);

    final req = BytesBuilder();
    req.add(_int32(tlvNo)); // TLV type
    req.add(_int32(payload.length)); // TLV length
    req.add(payload);

    _socket.add(req.toBytes());
    await _socket.flush();

    // 🔴 STEP 1: READ SERVER ERROR CODE (4 bytes)
    final errBuf = await _readExact(4);
    final errorCode = ByteData.sublistView(errBuf).getInt32(0, Endian.big);

    if (errorCode != 0) {
      throw Exception("Server error code: $errorCode");
    }

    // 🔴 STEP 2: READ IMAGE SIZE (4 bytes)
    final lenBuf = await _readExact(4);
    final imageLen = ByteData.sublistView(lenBuf).getInt32(0, Endian.big);

    if (imageLen <= 0) {
      throw Exception("Invalid image length");
    }

    // 🔴 STEP 3: READ IMAGE BYTES
    final imageBytes = await _readExact(imageLen);

    return imageBytes;
  }

  Future<SocketResult> sendImage({
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
      Glb.ErrorCode = responseBytes.toString();

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

  /// Send TLV and read response
  Future<String> doAllNetwork(int tlvNo, String tlvStr) async {
    if (!_connected) throw Exception("Socket not connected!");

    final payload = utf8.encode(tlvStr);
    final buffer = BytesBuilder();
    buffer.add(_int32(tlvNo));
    buffer.add(_int32(payload.length));
    buffer.add(payload);

    _socket.add(buffer.toBytes());
    await _socket.flush();

    // Read header
    final header = await _readExact(8);
    if (header.length != 8) throw Exception("Failed to read TLV header");

    final bd = ByteData.sublistView(header);
    final length = bd.getInt32(4, Endian.big);

    if (length <= 0) throw Exception("No data received for TLV $tlvNo");

    // Read body
    Uint8List body = await _readExact(length);
    if (!skipCompression) body = _tryDecompress(body);

    return utf8.decode(body);
  }

  Uint8List _tryDecompress(Uint8List data) {
    try {
      return Uint8List.fromList(GZipDecoder().decodeBytes(data));
    } catch (_) {
      return data;
    }
  }

  Uint8List _int32(int v) {
    final b = ByteData(4);
    b.setInt32(0, v, Endian.big);
    return b.buffer.asUint8List();
  }
}

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
