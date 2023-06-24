import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purrify/models/list_item.dart';
import 'package:purrify/pages/player_page.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class ListItemAdapter extends StatelessWidget {
  final ListItem viewHolder;

  const ListItemAdapter({super.key, required this.viewHolder});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        SpotifySdk.play(spotifyUri: viewHolder.uri);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const PlayerPage()));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            if (viewHolder.imageUrl != null)
              Image.network(
                viewHolder.imageUrl!.toString(),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    viewHolder.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    viewHolder.subTitle,
                    style: GoogleFonts.openSans(
                      fontSize: 15,
                      color: Colors.white54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
