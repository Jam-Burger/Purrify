import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:purrify/components/list_item_adapter.dart';
import 'package:purrify/models/artist.dart';
import 'package:purrify/models/list_item.dart';
import 'package:purrify/models/track.dart';
import 'package:purrify/utilities/access_token_manager.dart';
import 'package:purrify/utilities/functions.dart';

class SearchFragment extends StatefulWidget {
  const SearchFragment({super.key});

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  final TextEditingController _controller = TextEditingController();
  List<ListItem> _items = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              contentPadding: const EdgeInsets.all(15),
              labelText: 'Search',
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search_outlined),
            ),
            onChanged: (value) {
              _onChanged(value);
            },
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              _onSubmit();
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) => index % 2 == 0
                ? ListItemAdapter(
                    viewHolder: _items.elementAt(index),
                  )
                : ListItemAdapter(
                    viewHolder: _items.elementAt(index),
                  ),
          ),
        ),
      ],
    );
  }

  void _onChanged(String value) async {
    final list = <ListItem>[];
    if (value.isEmpty) {
      await Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _items = list;
        });
      });
      return;
    }
    Uri url = Uri.https('api.spotify.com', '/v1/search', {
      'q': value,
      'type': 'track',
      'market': 'IN',
      'limit': '10',
    });
    String token = await AccessTokenManager.getToken();
    log(url);
    Response response =
        await get(url, headers: {'Authorization': 'Bearer $token'});
    Map<String, dynamic> data = json.decode(response.body);

    if (data['artists'] != null) {
      list.addAll(((data['artists'] as Map<String, dynamic>)['items']
              as Iterable<dynamic>)
          .map((e) {
        Artist artist = Artist.fromJson(e);
        return ListItem(
          title: artist.name,
          subTitle: 'Artist',
          uri: artist.uri,
          imageUrl: artist.images.isNotEmpty ? artist.images.first.url : null,
          popularity: artist.popularity,
        );
      }));
    }
    if (data['tracks'] != null) {
      list.addAll(((data['tracks'] as Map<String, dynamic>)['items']
              as Iterable<dynamic>)
          .map((e) {
        Track track = Track.fromJson(e);
        final artists = track.artists.map((e) => e.name).join(', ');
        return ListItem(
          title: track.name,
          subTitle: 'Song \u2981 $artists',
          uri: track.uri,
          imageUrl: track.images.isNotEmpty ? track.images.first.url : null,
          popularity: track.popularity,
        );
      }));
    }
    setState(() {
      _items = list;
    });
  }

  void _onSubmit() {}
}
