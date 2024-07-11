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
  late ARKitGltfNode node;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Screen Home'),
        actions: [
          IconButton(
            onPressed: () {
              _changeColor();
            },
            icon: const Icon(Icons.color_lens_outlined),
          ),
        ],
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
    // final node  = await _getNodeFromNetwork(position);
     node = await _getNodeFromNetwork(position);
    arKitController.add(node);

  }

  /*
  // ------------ Load Model From Asset
  ARKitGltfNode _getNodeFromFlutterAsset(vector.Vector3 position) =>
      ARKitGltfNode(
        assetType: AssetType.flutterAsset,
        // Box model from
        // https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Box/glTF-Binary/Box.glb
        url: 'assets/curtain_vertical.glb',
        scale: vector.Vector3(0.05, 0.05, 0.05),
        position: position,
      );
  // ------------------------------------------------------------
  */
  Future<ARKitGltfNode> _getNodeFromNetwork(vector.Vector3 position) async {
    final file = await _downloadFile(
        "https://firebasestorage.googleapis.com/v0/b/fir-practice-7ec8c.appspot.com/o/Scene%20(3).glb?alt=media&token=81c068ea-f002-4d08-8157-f90a5e5845b4");
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

  void _changeColor(){
    // ar KitController.update(node.name,node: node,materials:[ARKitMaterial(specular: ARKitMaterialProperty.color(Colors.red))] );
  }
}
