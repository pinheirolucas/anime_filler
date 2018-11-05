const admin = require("firebase-admin");
const titles = require("./titles.json");

const rangeKind = {
    FILLER: 1,
    CANON: 2,
};

async function main(args) {
    const serviceAccount = require(args[2]);

    const app = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://anime-filler.firebaseio.com",
    });

    const db = app.firestore();

    const titlesCollection = db.collection("titles");

    for (const title of titles) {
        const tref = await titlesCollection.add({
            id: title.id,
            title: title.title,
            link: title.link,
            cover: title.cover,
            fillerInfo: title.fillerInfo,
            description: title.description,
        });

        // ranges
        const episodeRangesCollection = tref.collection("episodeRanges");

        for (const range of title.fillerRanges) {
            await episodeRangesCollection.add({
                kind: rangeKind.FILLER,
                init: range.init,
                end: range.end || null,
            });
        }

        for (const range of title.canonRanges) {
            await episodeRangesCollection.add({
                kind: rangeKind.CANON,
                init: range.init,
                end: range.end || null,
            });
        }

        // episodes
        const episodesCollection = tref.collection("episodes");

        for (const episode of title.episodes) {
            await episodesCollection.add({
                id: episode.id,
                epNum: episode.epNum,
                title: episode.title,
                link: episode.link,
                kind: episode.kind,
                airdate: episode.airdate,
            });
        }
    }
}

main(process.argv);
