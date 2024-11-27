import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Video Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: VideoChatScreen(),
    );
  }
}

class VideoChatScreen extends StatefulWidget {
  @override
  _VideoChatScreenState createState() => _VideoChatScreenState();
}

class _VideoChatScreenState extends State<VideoChatScreen> {
  late IO.Socket socket;
  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;

  @override
  void initState() {
    super.initState();
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    _initSocket();
    _initRenderers();
  }

  _initSocket() {
    socket = IO.io('https://your-app-name.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to signaling server');
    });

    socket.on('signal', (data) {
      // Handle incoming signals for WebRTC
      print('Received signal from: ${data['from']}');
      // Handle WebRTC signaling logic here
    });
  }

  _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    socket.disconnect();
    super.dispose();
  }

  _startCall() {
    // Here you can add the WebRTC setup code, such as creating an offer or answer
    // Then emit the signaling data to the server:
    socket.emit('signal', {'to': 'otherUserId', 'signal': 'someSignalData'});
  }

  _endCall() {
    // Code to close the WebRTC call
    socket.emit('signal', {'to': 'otherUserId', 'signal': 'closeCall'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Random Video Chat')),
      body: Column(
        children: [
          // Local Video Stream
          Expanded(child: RTCVideoView(_localRenderer)),
          // Remote Video Stream
          Expanded(child: RTCVideoView(_remoteRenderer)),
          ElevatedButton(onPressed: _startCall, child: Text('Start Call')),
          ElevatedButton(onPressed: _endCall, child: Text('End Call')),
        ],
      ),
    );
  }
}
