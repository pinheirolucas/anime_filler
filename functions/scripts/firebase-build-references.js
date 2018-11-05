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
        console.log(`Title ${title.title}`);
        const maintref = (await titlesCollection
            .where("id", "==", title.id)
            .get()).docs[0].ref;

        const shows = [];
        for (const show of title.relatedShows) {
            const relatedRef = (await titlesCollection
                .where("link", "==", show)
                .get()).docs[0].ref;

            shows.push(relatedRef);
        }

        await maintref.set({relatedShows: shows}, {merge: true});
    }
}

main(process.argv);
