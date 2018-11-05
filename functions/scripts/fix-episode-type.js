const fs = require("fs");
const puppeteer = require("puppeteer");
const titles = require("./titles.json")

async function main() {
    const browser = await puppeteer.launch({
        timeout: 90000,
    });
    const page = await browser.newPage();

    for (const title of titles) {
        console.log(`Visiting ${title.title} page: ${title.link}`);

        await page.goto(title.link);

        for (const episode of title.episodes) {
            episode.kind = await page.$eval(
                `#eps-${episode.epNum}`,
                (row) => {
                    const episodeTypeMapping = {
                        "Mostly Canon": 1,
                        "Canon": 2,
                        "Mostly Filler": 3,
                        "Filler": 4,
                    };

                    const typeNode = row.childNodes[2];
                    return episodeTypeMapping[typeNode.childNodes[0].innerHTML]
                },
                episode,
            );
        }
    }

    await browser.close();

    fs.writeFile("titles-fixed.json", JSON.stringify(titles, null, 4), "utf8", () => {});
}

main();
