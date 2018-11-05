const admin = require("firebase-admin");
const crypto = require("crypto");
const fetch = require("node-fetch");
const fileType = require("file-type");

async function main(args) {
    const serviceAccount = require(args[2]);

    const app = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://anime-filler.firebaseio.com",
        storageBucket: "anime-filler.appspot.com",
    });

    const db = app.firestore();
    const bucket = app.storage().bucket();

    const titlesCollection = db.collection("titles");

    const trefs = await titlesCollection
        .select("title", "cover")
        .get();

    for (const tref of trefs.docs) {
        const {cover, title} = tref.data();

        console.log(`> Updating ${title} ref`);
        console.log(`    > Downloading cover: ${cover}`);
        const response = await fetch(cover);
        if (!response.ok) {
            console.log(`    > ERROR: response returned with status: ${response.statusText}`);
        }

        const buf = await response.buffer();
        const imgInfo = fileType(buf);

        const sha1 = crypto.createHash("sha1");
        sha1.update(buf)
        const hash = sha1.digest("hex");

        const fbFileName = `covers/${hash}.${imgInfo.ext}`;
        const file = bucket.file(fbFileName);

        console.log(`    > Uploading the cover file as ${fbFileName}`);
        await file.save(buf, {contentType: imgInfo.mime});

        console.log("    > Updating title reference");
        await tref.ref.set({fbCover: fbFileName}, {merge: true});
    }
}

main(process.argv);
