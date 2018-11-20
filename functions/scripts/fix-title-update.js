const admin = require("firebase-admin");
const moment = require("moment");
const puppeteer = require("puppeteer");
const titles = require("./titles.json");

async function main(args) {
    const browser = await puppeteer.launch({
        timeout: 90000,
    });
    const page = await browser.newPage();
    const serviceAccount = require(args[2]);

    const app = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://anime-filler.firebaseio.com",
    });

    const db = app.firestore();

    const titlesCollection = db.collection("titles");

    for (const title of titles) {
        console.log(`Title: ${title.title}`)

        const doc = (await titlesCollection
            .select("link")
            .where("id", "==", title.id)
            .get()).docs[0];
        const data = doc.data();
        const ref = doc.ref;

        await page.goto(data.link);

        const dtstr = await page.$eval(".Details .Right .Date", dt => dt.textContent);
        const dttosave = moment(dtstr, "[Updated on ]MMMM DD, YYYY").format("YYYY-MM-DD");

        await ref.set({updatedAt: dttosave}, {merge: true});
    }

    await browser.close();
}

main(process.argv);
