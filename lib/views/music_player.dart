import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geza_music_player/constants/colors.dart';
import 'package:geza_music_player/constants/strings.dart';
import 'package:geza_music_player/models/music.dart';
import 'package:geza_music_player/views/lyrics_page.dart';
import 'package:geza_music_player/views/widgets/search_bar.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:spotify/spotify.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'widgets/art_work_image.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final player = AudioPlayer();
  Music music = Music(trackId: "4PYfFHKfjYz6dwAtZhBy1z");

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final credentials = SpotifyApiCredentials(
      CustomStrings.clientId,
      CustomStrings.clientSecret,
    );
    final spotify = SpotifyApi(credentials);
    spotify.tracks.get(music.trackId).then((track) async {
      String? tempSongName = track.name;
      if (tempSongName != null) {
        music.songName = tempSongName;
        music.artistName = track.artists?.first.name ?? "";
        String? image = track.album?.images?.first.url;
        if (image != null) {
          music.songImage = image;
          final tempSongColor = await getImagePalette(NetworkImage(image));
          if (tempSongColor != null) {
            music.songColor = tempSongColor;
          }
        }
        music.artistImage = track.artists?.first.images?.first.url;
        final yt = YoutubeExplode();
        final video =
            (await yt.search.search("$tempSongName ${music.artistName ?? ""}"))
                .first;
        final videoId = video.id.value;
        music.duration = video.duration;
        setState(() {});
        var manifest = await yt.videos.streamsClient.getManifest(videoId);
        var audioUrl = manifest.audioOnly.first.url;
        player.play(UrlSource(audioUrl.toString()));
      }
    });
    super.initState();
  }

  void playNewSong(String trackId) async {
    // Mark the function as async
    final credentials = SpotifyApiCredentials(
      CustomStrings.clientId,
      CustomStrings.clientSecret,
    );
    final spotify = SpotifyApi(credentials);
    final yt = YoutubeExplode(); // Define 'yt' in the scope
    String videoId = ""; // Define 'videoId' in the scope

    await spotify.tracks.get(trackId).then((track) async {
      String? tempSongName = track.name;
      if (tempSongName != null) {
        setState(() {
          music.songName = tempSongName;
          music.artistName = track.artists?.first.name ?? "";
          String? image = track.album?.images?.first.url;
          if (image != null) {
            music.songImage = image;
            getImagePalette(NetworkImage(image)).then((tempSongColor) {
              if (tempSongColor != null) {
                setState(() {
                  music.songColor = tempSongColor;
                });
              }
            });
          }
          music.artistImage = track.artists?.first.images?.first.url;
        });
        final video =
            (await yt.search.search("$tempSongName ${music.artistName ?? ""}"))
                .first;
        videoId = video.id.value; // Assign value to 'videoId' here
        music.duration = video.duration;
      }
    });

    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    var audioUrl = manifest.audioOnly.first.url;
    player.play(UrlSource(audioUrl.toString()));
  }

  Future<Color?> getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor?.color;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: music.songColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TrackSearchBar(
                    onSearch: (trackId) {
                      setState(() {
                        music.trackId = trackId;
                      });
                      playNewSong(trackId);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.close, color: Colors.transparent),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Gezita Music App :)\nPlaying Now",
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color.fromARGB(255, 183, 27, 27),
                        ),
                        textAlign: TextAlign.center, // Align the text center
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: music.artistImage != null
                                ? NetworkImage(music.artistImage!)
                                : null,
                            radius: 10,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            music.artistName ?? "",
                            style: textTheme.bodyLarge
                                ?.copyWith(color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ],
              ),
              Expanded(
                  flex: 2,
                  child: Center(
                    child: ArtWorkImage(image: music.songImage ?? ""),
                  )),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              music.songName ?? "",
                              style: textTheme.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text(
                              music.artistName ?? "",
                              style: textTheme.titleMedium
                                  ?.copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.favorite,
                          color: CustomColors.primaryColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder(
                        stream: player.onPositionChanged,
                        builder: (context, data) {
                          return ProgressBar(
                            progress: data.data ?? const Duration(seconds: 0),
                            total: music.duration ?? const Duration(minutes: 4),
                            bufferedBarColor: Colors.white38,
                            baseBarColor: Colors.white10,
                            thumbColor: Colors.white,
                            timeLabelTextStyle:
                                const TextStyle(color: Colors.white),
                            progressBarColor: Colors.white,
                            onSeek: (duration) {
                              player.seek(duration);
                            },
                          );
                        }),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LyricsPage(
                                    music: music,
                                    player: player,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.lyrics_outlined,
                                color: Colors.white)),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.skip_previous,
                              color: Colors.white, size: 36),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (player.state == PlayerState.playing) {
                              await player.pause();
                            } else {
                              await player.resume();
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            player.state == PlayerState.playing
                                ? Icons.pause
                                : Icons.play_circle,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.skip_next,
                              color: Colors.white, size: 36),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.loop,
                              color: CustomColors.primaryColor),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
