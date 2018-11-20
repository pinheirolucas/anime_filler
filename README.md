# anime_filler

This repository contains a sample app for listing [Anime Filler List](https://animefillerlist.com) site content.

All the content showed in the app is fetched from a firebase-firestore via the [official flutter plugin](https://github.com/flutter/plugins/tree/master/packages/cloud_firestore).

The firebase database was populated by JS scripts using [puppeteer](https://github.com/GoogleChrome/puppeteer) as a web scraper.

## TODO

- [ ] Implement a routine to update the titles in firebase-firestore;
- [ ] Deveolop icons and splashscreens for the app;
- [ ] Local storage for titles and episodes data;
- [ ] Improve the titles search (the current implementation is really poor 🙈);
- [ ] Improve the episodes grid layout;
- [ ] Load title covers from firebase-storage;
- [ ] Implement some kind of user authentication for saving the preferences and favorites at the firebase-firestore.

## License

This app is distributed under the MIT license found in the
[LICENSE](https://github.com/pinheirolucas/anime_filler/blob/master/LICENSE) file.
