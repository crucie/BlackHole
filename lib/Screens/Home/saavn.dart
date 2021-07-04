import 'package:blackhole/Screens/Common/song_list.dart';
import 'package:blackhole/Screens/Player/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:blackhole/APIs/api.dart';

List playlists = [
  {
    "id": "RecentlyPlayed",
    "title": "RecentlyPlayed",
    "image": "",
    "songsList": [],
    "type": ""
  }
];
List cachedPlaylists = [
  {
    "id": "RecentlyPlayed",
    "title": "RecentlyPlayed",
    "image": "",
    "songsList": [],
    "type": ""
  }
];
bool fetched = false;
bool showCached = true;
List preferredLanguage =
    Hive.box('settings').get('preferredLanguage') ?? ['Hindi'];
Map data = {};
final lists = [
  "recent",
  "new_trending",
  "charts",
  "new_albums",
  "top_playlists",
  // "city_mod",
  // "artist_recos"
];

class SaavnHomePage extends StatefulWidget {
  @override
  _SaavnHomePageState createState() => _SaavnHomePageState();
}

class _SaavnHomePageState extends State<SaavnHomePage> {
  List recentList = Hive.box('recentlyPlayed').get('recentSongs') ?? [];

  // getPlaylists() async {
  //   final dbRef = FirebaseDatabase.instance.reference().child("Playlists");
  //   for (int a = 0; a < preferredLanguage.length; a++) {
  //     await dbRef
  //         .child(preferredLanguage[a])
  //         .once()
  //         .then((DataSnapshot snapshot) {
  //       playlists.addAll(snapshot.value);
  //       Hive.box('cache').put(preferredLanguage[a], snapshot.value);
  //     });
  //   }
  // }

  // getPlaylistSongs() async {
  //   await getPlaylists();
  //   for (int i = 1; i < playlists.length; i++) {
  //     try {
  //       playlists[i] = await SaavnAPI().fetchPlaylistSongs2(playlists[i]);
  //       if (playlists[i]["songsList"].isNotEmpty) {
  //         Hive.box('cache').put(playlists[i]["id"], playlists[i]);
  //       }
  //     } catch (e) {
  //       print("Error in Index $i in TrendingList: $e");
  //       playlists[i] = cachedPlaylists[i];
  //     }
  //   }
  //   setState(() {
  //     cachedPlaylists = playlists;
  //     showCached = false;
  //   });
  // }

  getCachedPlaylists() async {
    for (int a = 0; a < preferredLanguage.length; a++) {
      Iterable value = await Hive.box('cache').get(preferredLanguage[a]);
      if (value == null) return;
      cachedPlaylists.addAll(value);
    }
    if (cachedPlaylists.length <= 1) return;
    for (int i = 1; i < cachedPlaylists.length; i++) {
      try {
        cachedPlaylists[i] =
            await Hive.box('cache').get(cachedPlaylists[i]["id"]);
      } catch (e) {
        print("Error in Index $i in CachedTrendingList: $e");
      }
    }
    setState(() {});
  }

  getHomePageData() async {
    data = await SaavnAPI().fetchHomePageData();
    setState(() {});
  }

  getSubTitle(Map<dynamic, dynamic> item) {
    final type = item['type'];
    if (type == 'playlist') {
      return item['subtitle'] ?? '';
    } else if (type == 'radio_station') {
      return "Artist Radio";
    } else {
      final artists = item['more_info']['artistMap']['artists']
          .map((artist) => artist['name'])
          .toList();
      return artists.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!fetched) {
      getHomePageData();
      getCachedPlaylists();
      // getPlaylistSongs();
      fetched = true;
    }
    return ListView.builder(
        physics: BouncingScrollPhysics(), //NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        scrollDirection: Axis.vertical,
        itemCount: data.isEmpty ? 1 : lists.length,
        itemBuilder: (context, idx) {
          if (idx == 0) {
            return (recentList.isEmpty ||
                    !Hive.box('settings').get('showRecent', defaultValue: true))
                ? SizedBox()
                : Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                            child: Text(
                              'Last Session',
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          itemCount: recentList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: SizedBox(
                                width: 150,
                                child: Column(
                                  children: [
                                    Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        errorWidget: (context, _, __) => Image(
                                          image: AssetImage('assets/cover.jpg'),
                                        ),
                                        imageUrl: recentList[index]["image"]
                                            .replaceAll('http:', 'https:'),
                                        placeholder: (context, url) => Image(
                                          image: AssetImage('assets/cover.jpg'),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${recentList[index]["title"]}',
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${recentList[index]["artist"]}',
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .textTheme
                                              .caption
                                              .color),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (_, __, ___) => PlayScreen(
                                      data: {
                                        'response': recentList,
                                        'index': index,
                                        'offline': false,
                                      },
                                      fromMiniplayer: false,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
          }
          return Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
                    child: Text(
                      '${(data['modules'][lists[idx]]["title"])}',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              data[lists[idx]] == null
                  ? SizedBox(
                      height: 200,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 150,
                            child: Column(
                              children: [
                                Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image(
                                    image: AssetImage('assets/cover.jpg'),
                                  ),
                                ),
                                Text(
                                  'Loading ...',
                                  textAlign: TextAlign.center,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  // style: TextStyle(
                                  //     color: Theme.of(context).accentColor),
                                ),
                                Text(
                                  'Please Wait',
                                  textAlign: TextAlign.center,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .color),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        itemCount: data[lists[idx]].length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            // TODO: don't draw for radio station
                            child: SizedBox(
                              width: 150,
                              child: Column(
                                children: [
                                  Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: CachedNetworkImage(
                                      errorWidget: (context, _, __) => Image(
                                        image: AssetImage('assets/cover.jpg'),
                                      ),
                                      imageUrl: data[lists[idx]][index]["image"]
                                          .replaceAll('http:', 'https:'),
                                      placeholder: (context, url) => Image(
                                        image: AssetImage('assets/cover.jpg'),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${data[lists[idx]][index]["title"]}',
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    // maxLines: 2,
                                    // style: TextStyle(
                                    //     color: Theme.of(context).accentColor),
                                  ),
                                  lists[idx] != 'charts'
                                      ? Text(
                                          getSubTitle(data[lists[idx]][index]),
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .color),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (_, __, ___) => SongsListPage(
                                    listItem: data[lists[idx]][index],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
            ],
          );
        });
  }
}