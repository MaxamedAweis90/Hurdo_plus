import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Returns a widget for displaying artwork, using a local file if available, otherwise falling back to network.
Future<Widget> buildArtworkWidget({
  required String artUri,
  required String soundUrl,
  required ThemeData theme,
}) async {
  final localPath = await getLocalArtPath(artUri, soundUrl);
  if (localPath != null &&
      localPath.isNotEmpty &&
      File(localPath).existsSync()) {
    return Image.file(File(localPath), fit: BoxFit.cover);
  } else if (artUri.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: artUri,
      fit: BoxFit.cover,
      placeholder: (context, url) => artworkPlaceholder(theme),
      errorWidget: (context, url, error) => artworkPlaceholder(theme),
    );
  } else {
    return artworkPlaceholder(theme);
  }
}

Future<String?> getLocalArtPath(String artUri, String soundUrl) async {
  final prefs = await SharedPreferences.getInstance();
  final keyArt = 'local_art::$soundUrl';
  final localPath = prefs.getString(keyArt);
  if (localPath != null &&
      localPath.isNotEmpty &&
      File(localPath).existsSync()) {
    return localPath;
  }
  return null;
}

Widget artworkPlaceholder(ThemeData theme) {
  return Container(
    decoration: BoxDecoration(
      color: theme.colorScheme.primary.withOpacity(0.08),
      border: Border.all(color: theme.colorScheme.primary, width: 2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: Icon(
        Icons.music_note,
        size: 64,
        color: theme.colorScheme.onSurface,
      ),
    ),
  );
}
