import 'dart:io';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARScreen extends StatefulWidget {
  const ARScreen({super.key});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  late ARKitController arKitController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Screen Home'),
      ),
      body: ARKitSceneView(
        showFeaturePoints: true,
        enableTapRecognizer: true,
        planeDetection: ARPlaneDetection.horizontalAndVertical,
        onARKitViewCreated: (controller) {
          this.arKitController = controller;
          this.arKitController.onARTap = (ar) {
            final point = ar.firstWhereOrNull(
              (o) => o.type == ARKitHitTestResultType.featurePoint,
            );
            if (point != null) {
              _onARTapHandler(point);
            }
          };
        },
      ),
    );
  }

  Future<void> _onARTapHandler(ARKitTestResult point) async {
    final position = vector.Vector3(
      point.worldTransform.getColumn(3).x,
      point.worldTransform.getColumn(3).y,
      point.worldTransform.getColumn(3).z,
    );

    final node = await _getNodeFromNetwork(position);
    arKitController.add(node);
    ;
  }

  Future<ARKitGltfNode> _getNodeFromNetwork(vector.Vector3 position) async {
    final file = await _downloadFile(
        "https://firebasestorage.googleapis.com/v0/b/flutter-ar-427312.appspot.com/o/sample_curtain.glb?alt=media&token=5f985ba1-2dca-477b-8c49-563abbf0830e");
    if (file.existsSync()) {
      //Load from app document folder
      return ARKitGltfNode(
        assetType: AssetType.documents,
        url: file.path.split('/').last, //  filename.extension only!
        scale: vector.Vector3(0.01, 0.01, 0.01),
        position: position,
      );
    }
    throw Exception('Failed to load $file');
  }

  Future<File> _downloadFile(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${url.split("/").last}';
      await Dio().download(url, filePath);
      final file = File(filePath);
      print('Download completed!! path = $filePath');
      return file;
    } catch (e) {
      print('Caught an exception: $e');
      rethrow;
    }
  }
}
