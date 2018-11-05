const admin = require("firebase-admin");
const titles = require("./titles.json");

async function main(args) {
    const serviceAccount = require(args[2]);

    const app = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://anime-filler.firebaseio.com",
    });

    const db = app.firestore();

    const titlesCollection = db.collection("titles");


    for (const title of titles) {
        console.log(`Title: ${title.title}`)

        const tref = (await titlesCollection
            .where("id", "==", title.id)
            .get()).docs[0].ref;

        const episodesCollection = tref.collection("episodes");

        for (const episode of title.episodes) {
            const eref = (await episodesCollection
                .where("id", "==", episode.id)
                .get()).docs[0].ref;

            await eref.set({kind: episode.kind}, {merge: true});
        }
    }
}

main(process.argv);
