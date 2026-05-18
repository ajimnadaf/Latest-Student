import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'Glb.dart' as Glb;

int _mtu = 512;

class SocketService {
  // Singleton pattern
  static final SocketService _instance = SocketService._internal();

  factory SocketService() => _instance;

  SocketService._internal();

  // External user ID if needed
  bool httpsEnabled = false; // mimic Java flag if needed
  String endPoint = "101.53.149.18:3336"; // server IP/host if needed

  /// ---------------------------
  /// Send raw TLV-style message (original sendMessage)
  /// ---------------------------
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

  // Future<void> updateHostFromHostnames() async {
  //   if (Glb.Hostnames.isEmpty) return;

  //   String host = Glb.Hostnames[Glb.currentHostIndex];

  //   if (host.contains(":")) {
  //     final parts = host.split(":");
  //     Glb.ip = parts[0];
  //     Glb.port = int.tryParse(parts[1]) ?? 3333;
  //   } else {
  //     Glb.ip = "101.53.149.18";
  //     Glb.port = 3336; // default port
  //   }

  //   print("🔁 Active Host => ${Glb.ip}:${Glb.port}");
  // }

  /// ---------------------------
  /// Send JSON TLV query (Java gen_nio_query equivalent)
  /// ---------------------------
  Future<String> sendQuery(String query, int tlvNo) async {
    String receivedMessage = '';
    try {
      // Use raw SQL instead of JSON
      String sqlString = query;

      // ✅ Support full URLs like https://host:port/
      Uri uri = Uri.parse(endPoint);
      String ip = uri.host;
      int port = uri.hasPort ? uri.port : 80;

      print('Connecting to $ip:$port');

      Socket socket = await Socket.connect(ip, port);
      print(
          'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

      // Build packet [tlvNo][length][data]
      Uint8List buffer = Uint8List(8 + sqlString.length);
      ByteData.view(buffer.buffer).setInt32(0, tlvNo, Endian.little);
      ByteData.view(buffer.buffer).setInt32(4, sqlString.length, Endian.little);
      buffer.setRange(8, buffer.lengthInBytes, utf8.encode(sqlString));

      socket.add(buffer);
      await socket.flush();

      // Receive response
      List<int> responseBuffer = [];
      int responseLength = 0;

      await for (var data in socket) {
        responseBuffer.addAll(data);

        if (responseBuffer.length >= 8 && responseLength == 0) {
          responseLength =
              ByteData.view(Uint8List.fromList(responseBuffer).buffer)
                  .getInt32(4, Endian.little);
        }

        if (responseBuffer.length >= responseLength) {
          receivedMessage =
              utf8.decode(responseBuffer.sublist(8, responseLength));
          break;
        }
      }

      await socket.close();

      // Java-style error handling
      if (receivedMessage.contains("ErrorCode#0")) return receivedMessage;
      if (receivedMessage.contains("ErrorCode#2")) return receivedMessage;
      if (receivedMessage.contains("ErrorCode#8")) return receivedMessage;
      if (receivedMessage.contains("ErrorCode#101")) return receivedMessage;
    } catch (e) {
      print('Error in sendQuery: $e');
      return "Err: Network Error, No internet or Server is down";
    }

    return receivedMessage;
  }

  Future<Uint8List> sendMessageBytes(
    String ip,
    int port,
    String message,
    int timeout,
  ) async {
    final socket = await Socket.connect(
      ip,
      port,
      timeout: Duration(milliseconds: timeout),
    );

    socket.add(utf8.encode(message));
    await socket.flush();

    final buffer = <int>[];

    await socket
        .listen(
          (data) => buffer.addAll(data),
          onDone: () => socket.destroy(),
          onError: (_) => socket.destroy(),
        )
        .asFuture();

    return Uint8List.fromList(buffer);
  }

  Future<void> updateHostFromHostnames() async {
    if (Glb.Hostnames.isEmpty) return;

    String host = Glb.Hostnames[Glb.currentHostIndex];

    if (host.contains(":")) {
      final parts = host.split(":");
      Glb.ip = parts[0];
      Glb.port = int.tryParse(parts[1]) ?? 3333;
    } else {
      Glb.ip = "101.53.149.18";
      Glb.port = 3333; // default port
    }

    print("🔁 Active Host => ${Glb.ip}:${Glb.port}");
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

  // ================= HELPERS =================

  /// Read final server response (like rcvFullTlv + handleerror)
  static Future<void> _readAck(Socket socket) async {
    final completer = Completer<void>();

    socket.listen(
      (data) {
        // optional: parse server response here
        // print('ACK: ${data.length} bytes');
      },
      onDone: () => completer.complete(),
      onError: (e) => completer.completeError(e),
      cancelOnError: true,
    );

    await completer.future;
  }
}

/// ---------------------------
/// Process Java-style record# response
/// ---------------------------
Map<String, List<String>> processData(String input) {
  List<String> records =
      input.split('record#').where((record) => record.isNotEmpty).toList();
  Map<String, List<String>> resultMap = {};

  for (var record in records) {
    List<String> items = record.split('&');
    for (var item in items) {
      List<String> parts = item.split('#');
      if (parts.length == 2) {
        String key = parts[0];
        String value = parts[1];
        resultMap.putIfAbsent(key, () => []).add(value);
      }
    }
  }

  return resultMap;
}

Future<int> sendFCM(
    String deviceToken, String title, String body, String serToken) async {
  if (serToken.isEmpty) {
    return -1;
  } else {
    String jsonStr = "";
    Map<String, dynamic> newObj = {
      "title": title,
      "body": body,
      "sound": "default",
    };

    Map<String, dynamic> jsonObject = {
      "notification": newObj,
      "to": deviceToken,
      "priority": "high",
    };

    jsonStr = jsonEncode(jsonObject);

    return await doPosthttps(FCMEndPoint, jsonStr, serToken);
  }
}

// Define your endpoint URL
String FCMEndPoint = "https://fcm.googleapis.com/fcm/send";

// Equivalent of doPosthttps()
Future<int> doPosthttps(String url, String jsonStr, String serToken) async {
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=$serToken",
      },
      body: jsonStr,
    );

    return response.statusCode; // similar to returning the result code
  } catch (e) {
    print("Error sending FCM: $e");
    return -1;
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
