import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: const HomePage(),
      ),
    ),
  );
}

class Films {
  final int id;
  final String title;
  final String description;
  final bool isFavourite;

  const Films({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavourite,
  });
  @override
  String toString() {
    return 'Film(id:$id,title:$title, descreption:$description, isFavourite:$isFavourite)';
  }

  Films copied(bool isFavourite) {
    return Films(
        id: id,
        title: title,
        description: description,
        isFavourite: isFavourite);
  }

  @override
  bool operator ==(covariant Films other) =>
      id == other.id && isFavourite == other.isFavourite;

  @override
  int get hashCode => Object.hash(id, isFavourite);
}

const allFilms = [
  Films(
      id: 1,
      title: 'Amalayu',
      description: 'A film by girum ermiyas',
      isFavourite: false),
  Films(
      id: 2,
      title: 'Shefu',
      description: 'Best Amharic comedy film',
      isFavourite: false),
  Films(
      id: 3,
      title: 'Wendoch Guday',
      description: 'An Amaharic comdey film ',
      isFavourite: false),
  Films(
      id: 4,
      title: 'Semayawi Feres',
      description: 'A Film by serawit fikre',
      isFavourite: false)
];

enum FavouriteStatus {
  all,
  isFavourite,
  notFavourite,
}

class FilmsNotifier extends StateNotifier<List<Films>> {
  FilmsNotifier() : super(allFilms);
  void update(Films film, bool isFavourite) {
    state = state
        .map(
          (thisfilm) =>
              thisfilm.id == film.id ? thisfilm.copied(isFavourite) : thisfilm,
        )
        .toList();
  }
}

final favoriteStatusProvider = StateProvider((ref) => FavouriteStatus.all);
final allFilmProvider = StateNotifierProvider<FilmsNotifier, List<Films>>(
  (ref) => FilmsNotifier(),
);

final favouriteFilmsProvider = Provider(
  (ref) => ref
      .watch(allFilmProvider)
      .where(
        (film) => film.isFavourite,
      )
      .toList(),
);
final notfavouriteFilmsProvider = Provider(
  (ref) => ref
      .watch(allFilmProvider)
      .where(
        (film) => !film.isFavourite,
      )
      .toList(),
);

class FilmWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<List<Films>> provider;
  const FilmWidget({required this.provider, super.key});

  @override
  Widget build(BuildContext context, ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
          itemCount: films.length,
          itemBuilder: (context, index) {
            final film = films[index];
            return ListTile(
                title: Text(film.title),
                subtitle: Text(films[index].description),
                trailing: IconButton(
                  onPressed: () {
                    final favourite = !film.isFavourite;

                    ref.read(allFilmProvider.notifier).update(film, favourite);
                  },
                  icon: film.isFavourite
                      ? const Icon(Icons.favorite_sharp)
                      : const Icon(
                          Icons.favorite_border,
                        ),
                ));
          }),
    );
  }
}

class FavoriteStatusWidget extends StatelessWidget {
  const FavoriteStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: ((context, ref, child) {
      return DropdownButton(
          value: ref.watch(favoriteStatusProvider),
          items: FavouriteStatus.values
              .map((fs) => DropdownMenuItem(
                  value: fs, child: Text(fs.name.split('.').last)))
              .toList(),
          onChanged: (fs) =>
              ref.read(favoriteStatusProvider.notifier).state = fs!);
    }));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('HomePage'),
        ),
        body: Column(
          children: [
            const FavoriteStatusWidget(),
            Consumer(builder: (context, ref, child) {
              final favourite = ref.watch(favoriteStatusProvider);
              switch (favourite) {
                case FavouriteStatus.all:
                  return FilmWidget(
                    provider: allFilmProvider,
                  );

                case FavouriteStatus.isFavourite:
                  return FilmWidget(provider: favouriteFilmsProvider);
                case FavouriteStatus.notFavourite:
                  return FilmWidget(provider: notfavouriteFilmsProvider);
              }
            })
          ],
        ));
  }
}
